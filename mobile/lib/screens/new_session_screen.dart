import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'interview_screen.dart';
import 'dart:ui';

class NewSessionScreen extends StatefulWidget {
  const NewSessionScreen({super.key});

  @override
  State<NewSessionScreen> createState() => _NewSessionScreenState();
}

class _NewSessionScreenState extends State<NewSessionScreen> {
  final _jdController = TextEditingController();
  File? _selectedFile;
  String? _fileName;
  bool _isUploading = false;
  bool _isCreatingSession = false;
  int? _resumeId;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _jdController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _jdController.dispose();
    super.dispose();
  }

  Future<void> _pickResume() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _fileName = result.files.single.name;
      });
    }
  }

  Future<void> _uploadResume() async {
    if (_selectedFile == null) return;

    setState(() => _isUploading = true);

    final apiService = ApiService(context.read<AuthService>());
    final result = await apiService.uploadResume(_selectedFile!);

    setState(() => _isUploading = false);

    if (result != null && result['id'] != null) {
      setState(() {
        _resumeId = result['id'];
        _currentStep = 1;
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to upload resume. Please try again.'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _createSession() async {
    if (_resumeId == null || _jdController.text.trim().isEmpty) return;

    setState(() => _isCreatingSession = true);

    final apiService = ApiService(context.read<AuthService>());
    final result = await apiService.createSession(
      _resumeId!,
      _jdController.text.trim(),
    );

    setState(() => _isCreatingSession = false);

    if (!mounted) return;

    if (result != null) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => InterviewScreen(sessionData: result),
          transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create session. Please try again.'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('New Practice Session'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Ethereal Orbs
          Positioned(
            top: -50,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accentBlue.withValues(alpha: 0.12),
                boxShadow: [BoxShadow(color: AppTheme.accentBlue.withValues(alpha: 0.12), blurRadius: 100, spreadRadius: 50)],
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
           .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 7.seconds, curve: AppTheme.fluidCurve),

          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: IgnorePointer(
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStepIndicator(),
                  const SizedBox(height: 48),

                  AnimatedSwitcher(
                    duration: 600.ms,
                    switchInCurve: AppTheme.fluidCurve,
                    switchOutCurve: Curves.easeOutCubic,
                    child: _currentStep == 0
                        ? _buildResumeStep(key: const ValueKey('resume'))
                        : _buildJDStep(key: const ValueKey('jd')),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: [
        _StepDot(label: 'Resume', isActive: true, isComplete: _currentStep > 0),
        Expanded(
          child: Container(
            height: 2,
            color: _currentStep > 0 ? AppTheme.accentGreen : AppTheme.borderDark,
          ).animate(target: _currentStep > 0 ? 1 : 0).tint(color: AppTheme.accentGreen),
        ),
        _StepDot(label: 'Job Description', isActive: _currentStep >= 1, isComplete: false),
      ],
    ).animate().fadeIn(duration: 800.ms, curve: AppTheme.fluidCurve);
  }

  Widget _buildResumeStep({required Key key}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload Your Resume',
          style: Theme.of(context).textTheme.headlineMedium,
        ).animate().fadeIn(delay: 100.ms, curve: AppTheme.fluidCurve).slideX(begin: -0.05),
        const SizedBox(height: 12),
        Text(
          'We\'ll parse your resume to match it against job descriptions and generate tailored questions.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
        ).animate().fadeIn(delay: 200.ms, curve: AppTheme.fluidCurve).slideX(begin: -0.05),
        const SizedBox(height: 48),

        // File Picker Area (Double Bezel)
        GestureDetector(
          onTap: _pickResume,
          child: Container(
            decoration: AppTheme.doubleBezelOuter(),
            padding: const EdgeInsets.all(4),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(48),
              decoration: AppTheme.doubleBezelInner(),
              child: Column(
                children: [
                  Icon(
                    _selectedFile != null ? Icons.check_circle_rounded : Icons.cloud_upload_outlined,
                    size: 64,
                    color: _selectedFile != null ? AppTheme.accentGreen : AppTheme.textSecondary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _fileName ?? 'Tap to select a PDF resume',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _selectedFile != null ? AppTheme.textPrimary : AppTheme.textSecondary,
                      fontSize: 16,
                      fontWeight: _selectedFile != null ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                  if (_selectedFile == null) ...[
                    const SizedBox(height: 12),
                    const Text('Supports .pdf files', style: TextStyle(color: AppTheme.textMuted, fontSize: 14)),
                  ],
                ],
              ),
            ),
          ),
        ).animate().fadeIn(delay: 300.ms, curve: AppTheme.fluidCurve).slideY(begin: 0.1),

        const SizedBox(height: 48),

        SizedBox(
          width: double.infinity,
          height: 64,
          child: ElevatedButton(
            onPressed: _selectedFile == null || _isUploading ? null : _uploadResume,
            child: _isUploading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation(AppTheme.primaryDark)),
                  )
                : const Text('Upload & Continue'),
          ),
        ).animate().fadeIn(delay: 400.ms, curve: AppTheme.fluidCurve).slideY(begin: 0.1),
      ],
    );
  }

  Widget _buildJDStep({required Key key}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.accentGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_rounded, color: AppTheme.accentGreen, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Resume uploaded: $_fileName',
                  style: const TextStyle(color: AppTheme.accentGreen, fontSize: 14, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms, curve: AppTheme.fluidCurve).slideY(begin: 0.2),
        const SizedBox(height: 32),

        Text(
          'Paste Job Description',
          style: Theme.of(context).textTheme.headlineMedium,
        ).animate().fadeIn(delay: 100.ms, curve: AppTheme.fluidCurve).slideX(begin: -0.05),
        const SizedBox(height: 12),
        Text(
          'Paste the full job description. We\'ll compute a match score and generate tailored interview questions.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
        ).animate().fadeIn(delay: 200.ms, curve: AppTheme.fluidCurve).slideX(begin: -0.05),
        const SizedBox(height: 32),

        Container(
          decoration: AppTheme.doubleBezelOuter(),
          padding: const EdgeInsets.all(4),
          child: Container(
            decoration: AppTheme.doubleBezelInner(),
            child: TextFormField(
              controller: _jdController,
              maxLines: 12,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15, height: 1.6),
              decoration: const InputDecoration(
                hintText: 'Paste the job description here...',
                alignLabelWithHint: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                fillColor: Colors.transparent,
              ),
            ),
          ),
        ).animate().fadeIn(delay: 300.ms, curve: AppTheme.fluidCurve).slideY(begin: 0.1),

        const SizedBox(height: 48),

        SizedBox(
          width: double.infinity,
          height: 64,
          child: ElevatedButton(
            onPressed: _jdController.text.trim().isEmpty || _isCreatingSession
                ? null
                : _createSession,
            child: _isCreatingSession
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation(AppTheme.primaryDark)),
                      ),
                      SizedBox(width: 12),
                      Text('Generating Questions...'),
                    ],
                  )
                : const Text('Start Interview'),
          ),
        ).animate().fadeIn(delay: 400.ms, curve: AppTheme.fluidCurve).slideY(begin: 0.1),
      ],
    );
  }
}

class _StepDot extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isComplete;

  const _StepDot({required this.label, required this.isActive, required this.isComplete});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isComplete
                ? AppTheme.accentGreen
                : isActive
                    ? AppTheme.accentBlue
                    : AppTheme.surfaceDark,
            border: Border.all(
              color: isComplete
                  ? AppTheme.accentGreen
                  : isActive
                      ? AppTheme.accentBlue
                      : AppTheme.borderDark,
              width: 2,
            ),
          ),
          child: Icon(
            isComplete ? Icons.check_rounded : Icons.circle,
            size: isComplete ? 24 : 12,
            color: isComplete || isActive ? Colors.white : AppTheme.textMuted,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: isActive ? AppTheme.textPrimary : AppTheme.textMuted,
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

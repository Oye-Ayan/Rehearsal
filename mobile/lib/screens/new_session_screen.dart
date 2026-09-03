import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'interview_screen.dart';

class NewSessionScreen extends StatefulWidget {
  const NewSessionScreen({super.key});

  @override
  State<NewSessionScreen> createState() => _NewSessionScreenState();
}

class _NewSessionScreenState extends State<NewSessionScreen> {
  final _jdController = TextEditingController();
  final _userDetailsController = TextEditingController();
  
  // 0 = With Resume, 1 = Quick Start (No Resume)
  int _selectedTab = 0;

  File? _selectedFile;
  String? _fileName;
  bool _isUploading = false;
  bool _isCreatingSession = false;
  int? _resumeId;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _jdController.addListener(() => setState(() {}));
    _userDetailsController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _jdController.dispose();
    _userDetailsController.dispose();
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
    final jdText = _jdController.text.trim();
    if (jdText.isEmpty) return;

    setState(() => _isCreatingSession = true);
    final apiService = ApiService(context.read<AuthService>());
    Map<String, dynamic>? result;

    if (_selectedTab == 0) {
      // With Resume
      if (_resumeId == null) return;
      result = await apiService.createSession(_resumeId!, jdText);
    } else {
      // Quick Start (No Resume)
      final userDetailsText = _userDetailsController.text.trim();
      result = await apiService.createQuickSession(jdText, userDetailsText);
    }

    setState(() => _isCreatingSession = false);

    if (!mounted) return;

    if (result != null) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => InterviewScreen(sessionData: result!),
          transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to generate interview. Please check your connection.'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = isDark ? Colors.black : AppTheme.primaryLight;
    final textPrimaryColor = isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight;
    final textSecondaryColor = isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight;
    final textMutedColor = isDark ? AppTheme.textMuted : AppTheme.textMutedLight;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Start Practice Session',
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: -0.5, color: textPrimaryColor),
        ),
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: textPrimaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accentBlue.withValues(alpha: isDark ? 0.12 : 0.08),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 16),
                // Mode Toggle Segmented Tabs (Liquid Glass)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: AppTheme.glassCard(
                    isDark: isDark,
                    padding: const EdgeInsets.all(4),
                    borderRadius: 16,
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedTab = 0),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _selectedTab == 0 ? AppTheme.accentBlue : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.description_rounded,
                                    size: 18,
                                    color: _selectedTab == 0 ? Colors.white : textSecondaryColor,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'With Resume',
                                    style: TextStyle(
                                      color: _selectedTab == 0 ? Colors.white : textSecondaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedTab = 1),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _selectedTab == 1 ? AppTheme.accentBlue : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.bolt_rounded,
                                    size: 18,
                                    color: _selectedTab == 1 ? Colors.white : textSecondaryColor,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Quick Start',
                                    style: TextStyle(
                                      color: _selectedTab == 1 ? Colors.white : textSecondaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: _selectedTab == 0
                        ? _buildWithResumeFlow(isDark, textPrimaryColor, textSecondaryColor, textMutedColor)
                        : _buildQuickStartFlow(isDark, textPrimaryColor, textSecondaryColor, textMutedColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWithResumeFlow(bool isDark, Color textPrimary, Color textSecondary, Color textMuted) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stepper Header
        Row(
          children: [
            Expanded(child: _buildStepIndicator(0, 'Upload Resume', textPrimary, textMuted)),
            Container(width: 20, height: 1, color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
            Expanded(child: _buildStepIndicator(1, 'Job Description', textPrimary, textMuted)),
          ],
        ).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: 28),

        if (_currentStep == 0) ...[
          Text('Upload Resume (PDF)', style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold, height: 1.2)),
          const SizedBox(height: 6),
          Text('We will analyze your resume against the target role.', style: TextStyle(color: textSecondary, fontSize: 14, height: 1.3)),
          const SizedBox(height: 20),
          
          AppTheme.glassCard(
            isDark: isDark,
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
            onTap: _pickResume,
            child: Column(
              children: [
                Icon(
                  _selectedFile != null ? Icons.picture_as_pdf_rounded : Icons.cloud_upload_rounded,
                  size: 48,
                  color: _selectedFile != null ? AppTheme.accentBlue : textSecondary,
                ),
                const SizedBox(height: 16),
                Text(
                  _fileName ?? 'Tap to select PDF file',
                  style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 15, height: 1.2),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          if (_selectedFile != null)
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isUploading ? null : _uploadResume,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isUploading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Continue to Job Description', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
        ] else ...[
          Text('Paste Job Description', style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold, height: 1.2)),
          const SizedBox(height: 6),
          Text('Provide details about the position to tailor interview questions.', style: TextStyle(color: textSecondary, fontSize: 14, height: 1.3)),
          const SizedBox(height: 20),
          
          TextField(
            controller: _jdController,
            maxLines: 8,
            style: TextStyle(color: textPrimary, height: 1.3),
            decoration: InputDecoration(
              hintText: 'Paste target Job Description here...',
              fillColor: isDark ? AppTheme.surfaceDark : Colors.white,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: (_isCreatingSession || _jdController.text.trim().isEmpty) ? null : _createSession,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isCreatingSession
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Generate Interview Session', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildQuickStartFlow(bool isDark, Color textPrimary, Color textSecondary, Color textMuted) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Start (No Resume Required)', style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold, height: 1.2)),
        const SizedBox(height: 6),
        Text('Generate targeted interview questions using just the Job Description.', style: TextStyle(color: textSecondary, fontSize: 14, height: 1.3)),
        const SizedBox(height: 20),

        Text('Job Description *', style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: _jdController,
          maxLines: 6,
          style: TextStyle(color: textPrimary, height: 1.3),
          decoration: InputDecoration(
            hintText: 'Paste Job Description here...',
            fillColor: isDark ? AppTheme.surfaceDark : Colors.white,
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
        const SizedBox(height: 20),

        Text('About You (Optional)', style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Mention key skills, years of experience, or target role focus.', style: TextStyle(color: textMuted, fontSize: 12)),
        const SizedBox(height: 8),
        TextField(
          controller: _userDetailsController,
          maxLines: 4,
          style: TextStyle(color: textPrimary, height: 1.3),
          decoration: InputDecoration(
            hintText: 'e.g. 3 years as Senior Flutter developer specializing in state management...',
            fillColor: isDark ? AppTheme.surfaceDark : Colors.white,
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: (_isCreatingSession || _jdController.text.trim().isEmpty) ? null : _createSession,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: _isCreatingSession
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Start Interview Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildStepIndicator(int stepIndex, String title, Color textPrimary, Color textMuted) {
    final isActive = _currentStep == stepIndex;
    final isDone = _currentStep > stepIndex;

    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive || isDone ? AppTheme.accentBlue : textMuted.withValues(alpha: 0.2),
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                : Text('${stepIndex + 1}', style: TextStyle(color: isActive ? Colors.white : textMuted, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: TextStyle(color: isActive ? textPrimary : textMuted, fontWeight: isActive ? FontWeight.bold : FontWeight.normal, fontSize: 12, height: 1.2),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}

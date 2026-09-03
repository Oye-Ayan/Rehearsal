import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class ReportScreen extends StatefulWidget {
  final int sessionId;

  const ReportScreen({super.key, required this.sessionId});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  Map<String, dynamic>? _sessionData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReport();
  }

  Future<void> _fetchReport() async {
    final apiService = ApiService(context.read<AuthService>());
    final data = await apiService.getSessionDetails(widget.sessionId);
    
    if (mounted) {
      setState(() {
        _sessionData = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Performance Report', style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: -0.5)),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close_rounded, size: 20, color: AppTheme.textPrimary),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          // Subtle Premium Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.5, -0.5),
                  radius: 1.2,
                  colors: [
                    Color(0xFF18181B), // Zinc 900
                    Color(0xFF09090B), // Zinc 950
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryDark))
                : _sessionData == null
                    ? const Center(child: Text('Failed to load report.', style: TextStyle(color: AppTheme.errorRed)))
                    : _buildReportContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildReportContent() {
    final matchScore = _sessionData!['matchScore'] ?? 0;
    final questions = _sessionData!['questions'] as List<dynamic>? ?? [];
    
    // Calculate aggregate stats from answers
    int totalWpm = 0;
    int totalFillers = 0;
    int answeredCount = 0;

    for (var q in questions) {
      final answer = q['answer'] as Map<String, dynamic>?;
      if (answer != null) {
        totalWpm += (answer['wpm'] as num?)?.toInt() ?? 0;
        totalFillers += (answer['fillerWordCount'] as num?)?.toInt() ?? 0;
        answeredCount++;
      }
    }

    final avgWpm = answeredCount > 0 ? (totalWpm / answeredCount).round() : 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Session Overview',
            style: Theme.of(context).textTheme.displayLarge,
          ).animate().fadeIn(duration: 800.ms, curve: AppTheme.fluidCurve).slideX(begin: -0.05),
          const SizedBox(height: 32),
          
          // Bento Grid for Stats
          _buildBentoGrid(matchScore, avgWpm, totalFillers),
          
          const SizedBox(height: 48),

          Text(
            'Detailed Feedback',
            style: Theme.of(context).textTheme.displayMedium,
          ).animate().fadeIn(delay: 200.ms, curve: AppTheme.fluidCurve).slideX(begin: -0.05),
          const SizedBox(height: 24),

          // Detailed QA list
          ...questions.asMap().entries.map((entry) {
            final idx = entry.key;
            final q = entry.value;
            final answer = q['answer'] as Map<String, dynamic>?;
            final aiFeedback = answer != null ? answer['aiFeedback'] : 'No answer recorded for this question.';

            return Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: _buildFeedbackCard(idx + 1, q['text'], aiFeedback, delay: 300 + (idx * 100)),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBentoGrid(int matchScore, int avgWpm, int totalFillers) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 3,
              child: _buildStatCard(
                title: 'Match Score',
                value: '$matchScore%',
                icon: Icons.auto_awesome_rounded,
                color: AppTheme.accentGreen,
                delay: 100,
                isLarge: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: _buildStatCard(
                title: 'Avg Speed',
                value: '$avgWpm',
                subtitle: 'WPM',
                icon: Icons.speed_rounded,
                color: AppTheme.accentIndigo,
                delay: 150,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Filler Words',
                value: '$totalFillers',
                icon: Icons.mic_off_rounded,
                color: AppTheme.accentPurple,
                delay: 200,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: 'Confidence',
                value: 'Strong',
                icon: Icons.psychology_rounded,
                color: Colors.orangeAccent,
                delay: 250,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    String? subtitle,
    required IconData icon,
    required Color color,
    required int delay,
    bool isLarge = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.borderDark),
      ),
      padding: EdgeInsets.all(isLarge ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: isLarge ? 28 : 24),
          ),
          SizedBox(height: isLarge ? 24 : 16),
          Text(
            title,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: isLarge ? 15 : 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(color: AppTheme.textPrimary, fontSize: isLarge ? 36 : 24, fontWeight: FontWeight.w700, letterSpacing: -1),
              ),
              if (subtitle != null) ...[
                const SizedBox(width: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay), duration: 800.ms, curve: AppTheme.fluidCurve).slideY(begin: 0.1);
  }

  Widget _buildFeedbackCard(int number, String questionText, String? feedback, {required int delay}) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.borderDark),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accentIndigo.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  'Q$number',
                  style: const TextStyle(color: AppTheme.accentIndigo, fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            questionText,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Divider(color: AppTheme.borderDark, height: 1),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.psychology_rounded, color: AppTheme.accentPurple, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('AI Coaching', style: TextStyle(color: AppTheme.accentPurple, fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                    const SizedBox(height: 8),
                    Text(
                      feedback ?? 'No feedback provided.',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay), duration: 800.ms, curve: AppTheme.fluidCurve).slideY(begin: 0.1);
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class ReportScreen extends StatefulWidget {
  final int sessionId;
  final int? userSessionNumber;

  const ReportScreen({
    super.key,
    required this.sessionId,
    this.userSessionNumber,
  });

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  Map<String, dynamic>? _sessionData;
  bool _isLoading = true;
  bool _isDownloadingPdf = false;

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

      if (data != null && (data['actionPlan'] == null || (data['actionPlan'] as String).isEmpty)) {
        _generateActionPlan();
      }
    }
  }

  Future<void> _generateActionPlan() async {
    final apiService = ApiService(context.read<AuthService>());
    final updatedData = await apiService.generateActionPlan(widget.sessionId);
    if (mounted && updatedData != null) {
      setState(() {
        _sessionData = updatedData;
      });
    }
  }

  Future<void> _downloadPdf() async {
    setState(() => _isDownloadingPdf = true);
    final apiService = ApiService(context.read<AuthService>());
    final bytes = await apiService.downloadSessionPdf(widget.sessionId);
    setState(() => _isDownloadingPdf = false);

    if (!mounted) return;

    if (bytes != null) {
      try {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/Rehearsal_Report_Session_${widget.userSessionNumber ?? widget.sessionId}.pdf');
        await file.writeAsBytes(bytes);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('PDF Report saved to ${file.path}'),
              backgroundColor: AppTheme.accentGreen,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to write PDF file locally.'), backgroundColor: AppTheme.errorRed),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to generate PDF. Please try again.'), backgroundColor: AppTheme.errorRed),
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

    final displaySessionTitle = widget.userSessionNumber != null ? 'Session #${widget.userSessionNumber}' : 'Session #${widget.sessionId}';

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Performance Report',
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: -0.5, color: textPrimaryColor),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textPrimaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: _isDownloadingPdf
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accentBlue))
                : const Icon(Icons.picture_as_pdf_rounded, color: AppTheme.accentBlue),
            onPressed: _isDownloadingPdf ? null : _downloadPdf,
            tooltip: 'Download PDF Report',
          ),
        ],
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.accentBlue))
                : _sessionData == null
                    ? Center(
                        child: Text(
                          'Failed to load report.',
                          style: TextStyle(color: textMutedColor),
                        ),
                      )
                    : SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Session Title & Overall Score (Liquid Glass)
                            AppTheme.glassCard(
                              isDark: isDark,
                              padding: const EdgeInsets.all(24),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          displaySessionTitle,
                                          style: TextStyle(
                                            color: textPrimaryColor,
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: -0.5,
                                            height: 1.2,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Comprehensive AI Feedback',
                                          style: TextStyle(
                                            color: textSecondaryColor,
                                            fontSize: 13,
                                            height: 1.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Score Ring Container
                                  Container(
                                    width: 72,
                                    height: 72,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppTheme.accentBlue.withValues(alpha: 0.15),
                                      border: Border.all(color: AppTheme.accentBlue.withValues(alpha: 0.4), width: 2),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '${_sessionData!['matchScore'] ?? 0}%',
                                          style: const TextStyle(
                                            color: AppTheme.accentBlue,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                        const Text(
                                          'MATCH',
                                          style: TextStyle(
                                            color: AppTheme.accentBlue,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.05),

                            const SizedBox(height: 24),

                            // Metrics Grid
                            _buildMetricsGrid(_sessionData!, isDark, textPrimaryColor, textSecondaryColor),

                            const SizedBox(height: 28),

                            // Action Plan Card (Liquid Glass)
                            _buildActionPlanSection(_sessionData!['actionPlan'], isDark, textPrimaryColor, textSecondaryColor),

                            const SizedBox(height: 28),

                            // Detailed Questions & Feedback List
                            Text(
                              'Question Analysis & Coaching',
                              style: TextStyle(
                                color: textPrimaryColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                            ).animate().fadeIn(delay: 400.ms, duration: 500.ms),

                            const SizedBox(height: 14),

                            ...(_sessionData!['questions'] as List<dynamic>? ?? []).asMap().entries.map((entry) {
                              final index = entry.key;
                              final q = entry.value;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _buildQuestionFeedbackCard(
                                  question: q,
                                  questionIndex: index + 1,
                                  isDark: isDark,
                                  textPrimary: textPrimaryColor,
                                  textSecondary: textSecondaryColor,
                                  textMuted: textMutedColor,
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(Map<String, dynamic> data, bool isDark, Color textPrimary, Color textSecondary) {
    int totalFillerWords = 0;
    int avgWpm = 0;
    final questions = data['questions'] as List<dynamic>? ?? [];
    int answeredCount = 0;

    for (var q in questions) {
      final ans = q['answer'];
      if (ans != null) {
        answeredCount++;
        totalFillerWords += (ans['fillerWordCount'] as num?)?.toInt() ?? 0;
        avgWpm += (ans['wpm'] as num?)?.toInt() ?? 0;
      }
    }

    if (answeredCount > 0) {
      avgWpm = (avgWpm / answeredCount).round();
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Pacing (WPM)',
                value: '$avgWpm',
                subtitle: avgWpm >= 110 && avgWpm <= 160 ? 'Optimal Speech Speed' : 'Adjustment Recommended',
                color: AppTheme.accentBlue,
                isDark: isDark,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: 'Filler Words',
                value: '$totalFillerWords',
                subtitle: totalFillerWords <= 3 ? 'Clear Delivery' : 'Reduce fillers like "um"',
                color: AppTheme.accentIndigo,
                isDark: isDark,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 200.ms, duration: 600.ms);
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return AppTheme.glassCard(
      isDark: isDark,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(color: textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                color: textPrimary,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: -1,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(color: textSecondary.withValues(alpha: 0.8), fontSize: 11, height: 1.3),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActionPlanSection(String? actionPlan, bool isDark, Color textPrimary, Color textSecondary) {
    final isGenerating = actionPlan == null || actionPlan.isEmpty;

    return AppTheme.glassCard(
      isDark: isDark,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.accentPurple.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.auto_awesome_rounded, color: AppTheme.accentPurple, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'AI Coaching Action Plan',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (isGenerating)
            Row(
              children: [
                const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accentPurple)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Generating tailored action plan...',
                    style: TextStyle(color: textSecondary, fontSize: 13, fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            )
          else
            Text(
              actionPlan,
              style: TextStyle(
                color: textPrimary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 600.ms);
  }

  Widget _buildQuestionFeedbackCard({
    required dynamic question,
    required int questionIndex,
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
    required Color textMuted,
  }) {
    final qText = question['text'] ?? '';
    final category = question['category'] ?? 'General';
    final ans = question['answer'];
    final transcript = ans?['transcriptText'];
    final feedback = ans?['aiFeedback'];

    return AppTheme.glassCard(
      isDark: isDark,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  'Q$questionIndex • ${category.toUpperCase()}',
                  style: const TextStyle(
                    color: AppTheme.accentBlue,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            qText,
            style: TextStyle(
              color: textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 14),

          if (transcript != null && (transcript as String).isNotEmpty) ...[
            Text('Your Answer:', style: TextStyle(color: textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.black.withValues(alpha: 0.3) : AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '"$transcript"',
                style: TextStyle(color: textPrimary, fontSize: 13, height: 1.4, fontStyle: FontStyle.italic),
              ),
            ),
            const SizedBox(height: 12),
          ],

          if (feedback != null && (feedback as String).isNotEmpty) ...[
            Text('AI Feedback:', style: TextStyle(color: AppTheme.accentGreen, fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(
              feedback,
              style: TextStyle(color: textSecondary, fontSize: 13, height: 1.4),
            ),
          ] else if (transcript == null || (transcript as String).isEmpty) ...[
            Text(
              'No answer recorded for this question.',
              style: TextStyle(color: textMuted, fontSize: 13, fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }
}

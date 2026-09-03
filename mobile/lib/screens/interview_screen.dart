import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme.dart';
import 'recording_screen.dart';
import 'report_screen.dart';

class InterviewScreen extends StatefulWidget {
  final Map<String, dynamic> sessionData;
  
  const InterviewScreen({super.key, required this.sessionData});

  @override
  State<InterviewScreen> createState() => _InterviewScreenState();
}

class _InterviewScreenState extends State<InterviewScreen> {
  int _currentQuestionIndex = 0;

  List<dynamic> get _questions => widget.sessionData['questions'] ?? [];
  int get _matchScore => widget.sessionData['matchScore'] ?? 0;
  int get _sessionId => widget.sessionData['id'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Practice Interview', style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: -0.5)),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close_rounded, size: 20, color: AppTheme.textPrimary),
          ),
          onPressed: () => _showExitDialog(),
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
            child: _questions.isEmpty
                ? _buildNoQuestions()
                : _buildQuestionView(),
          ),
        ],
      ),
    );
  }

  Widget _buildNoQuestions() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.surfaceDark,
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: const Icon(Icons.quiz_rounded, size: 48, color: AppTheme.textSecondary),
            ).animate().scale(delay: 200.ms, duration: 800.ms, curve: AppTheme.fluidCurve),
            const SizedBox(height: 32),
            Text(
              'No questions generated yet.',
              style: Theme.of(context).textTheme.headlineMedium,
            ).animate().fadeIn(delay: 300.ms, curve: AppTheme.fluidCurve),
            const SizedBox(height: 16),
            Text(
              'The AI is still processing your resume and job description. Please try again.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
            ).animate().fadeIn(delay: 400.ms, curve: AppTheme.fluidCurve),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Match Score & Progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: _getScoreColor(_matchScore).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome_rounded, color: _getScoreColor(_matchScore), size: 16),
                    const SizedBox(width: 8),
                    Text(
                      '$_matchScore% Match',
                      style: TextStyle(
                        color: _getScoreColor(_matchScore),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: AppTheme.borderDark),
                ),
                child: Text(
                  '${_currentQuestionIndex + 1} / ${_questions.length}',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(duration: 800.ms, curve: AppTheme.fluidCurve),
          
          const SizedBox(height: 24),

          // Progress Bar (Premium segmented)
          Row(
            children: List.generate(_questions.length, (index) {
              final isActive = index <= _currentQuestionIndex;
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: index == _questions.length - 1 ? 0 : 8),
                  decoration: BoxDecoration(
                    color: isActive ? AppTheme.accentIndigo : AppTheme.borderDark,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ).animate().fadeIn(delay: 100.ms, curve: AppTheme.fluidCurve),
          
          const SizedBox(height: 32),

          // Question Card
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              switchInCurve: AppTheme.fluidCurve,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (Widget child, Animation<double> animation) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.05, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: _buildGlassCard(
                key: ValueKey<int>(_currentQuestionIndex),
                question: _questions[_currentQuestionIndex],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Premium Action Buttons
          Row(
            children: [
              // Previous button
              if (_currentQuestionIndex > 0)
                Container(
                  height: 60,
                  width: 60,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceDark,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.borderDark),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary),
                    onPressed: () => setState(() => _currentQuestionIndex--),
                  ),
                ).animate().fadeIn(curve: AppTheme.fluidCurve).slideX(begin: -0.1),

              // Record button
              Expanded(
                child: SizedBox(
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => RecordingScreen(
                            question: _questions[_currentQuestionIndex],
                            questionIndex: _currentQuestionIndex,
                            totalQuestions: _questions.length,
                          ),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            return FadeTransition(opacity: animation, child: child);
                          },
                        ),
                      ).then((_) {
                        // After recording, check if it's the last question
                        if (_currentQuestionIndex == _questions.length - 1) {
                          _goToReport();
                        } else {
                          setState(() => _currentQuestionIndex++);
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.errorRed,
                      foregroundColor: Colors.white,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.fiber_manual_record, size: 18),
                        SizedBox(width: 8),
                        Text('Record Answer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 200.ms, curve: AppTheme.fluidCurve).slideY(begin: 0.1),
            ],
          ),
          
          const SizedBox(height: 16),

          // Next / Finish
          Center(
            child: TextButton(
              onPressed: () {
                if (_currentQuestionIndex < _questions.length - 1) {
                  setState(() => _currentQuestionIndex++);
                } else {
                  _goToReport();
                }
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _currentQuestionIndex < _questions.length - 1 ? 'Skip to Next' : 'Finish & View Report',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _currentQuestionIndex < _questions.length - 1 ? Icons.arrow_forward_rounded : Icons.insights_rounded,
                    size: 18, 
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 300.ms, curve: AppTheme.fluidCurve),
        ],
      ),
    );
  }

  Widget _buildGlassCard({required Key key, required Map<String, dynamic> question}) {
    return Container(
      key: key,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.borderDark),
      ),
      padding: const EdgeInsets.fromLTRB(32, 32, 32, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.accentIndigo.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              (question['category'] ?? 'GENERAL').toString().toUpperCase(),
              style: const TextStyle(
                color: AppTheme.accentIndigo,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Icon(Icons.format_quote_rounded, color: AppTheme.borderDark, size: 48),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Text(
                  question['text'] ?? 'Question text unavailable',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 75) return AppTheme.accentGreen;
    if (score >= 50) return AppTheme.accentIndigo;
    return AppTheme.errorRed;
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          backgroundColor: AppTheme.surfaceDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: AppTheme.borderDark),
          ),
          title: const Text('Exit Session?', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
          content: const Text(
            'Your progress will not be saved. Are you sure you want to end this interview?',
            style: TextStyle(color: AppTheme.textSecondary, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Keep Practicing', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorRed,
                foregroundColor: Colors.white,
              ),
              child: const Text('Exit'),
            ),
          ],
        ),
      ),
    );
  }

  void _goToReport() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ReportScreen(sessionId: _sessionId),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }
}

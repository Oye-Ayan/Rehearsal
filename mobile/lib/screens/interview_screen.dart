import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/tts_service.dart';
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
  late List<dynamic> _questionsList;
  bool _isLoadingMore = false;
  bool _isSubmittingTypedAnswer = false;

  int get _matchScore => widget.sessionData['matchScore'] ?? 0;
  int get _sessionId => widget.sessionData['id'];

  @override
  void initState() {
    super.initState();
    _questionsList = List<dynamic>.from(widget.sessionData['questions'] ?? []);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_questionsList.isNotEmpty) {
        TTSService().speak(_questionsList[_currentQuestionIndex]['text'] ?? '');
      }
    });
  }

  void _changeQuestion(int newIndex) {
    setState(() => _currentQuestionIndex = newIndex);
    if (_questionsList.isNotEmpty && newIndex < _questionsList.length) {
      TTSService().speak(_questionsList[newIndex]['text'] ?? '');
    }
  }

  Future<void> _requestMoreQuestions() async {
    setState(() => _isLoadingMore = true);
    final apiService = ApiService(context.read<AuthService>());
    final newQuestions = await apiService.requestMoreQuestions(_sessionId);
    setState(() => _isLoadingMore = false);

    if (newQuestions != null && newQuestions.isNotEmpty) {
      setState(() {
        _questionsList.addAll(newQuestions);
        _currentQuestionIndex++;
      });
      TTSService().speak(_questionsList[_currentQuestionIndex]['text'] ?? '');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added ${newQuestions.length} new AI questions!'),
            backgroundColor: AppTheme.accentBlue,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not generate more questions at this time.'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  void _showTypedAnswerDialog(Map<String, dynamic> currentQuestion) {
    final textController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.surfaceDark.withValues(alpha: 0.95) : Colors.white.withValues(alpha: 0.95),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(color: isDark ? AppTheme.glassBorderDark : AppTheme.glassBorderLight),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.accentBlue.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit_note_rounded, color: AppTheme.accentBlue, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Type Your Answer',
                        style: TextStyle(
                          color: isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: textController,
                  maxLines: 5,
                  style: TextStyle(color: isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight),
                  decoration: InputDecoration(
                    hintText: 'Write out your detailed answer to this question...',
                    fillColor: isDark ? AppTheme.cardDark : AppTheme.cardLight,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () async {
                      final text = textController.text.trim();
                      if (text.isEmpty) return;

                      Navigator.pop(ctx);
                      setState(() => _isSubmittingTypedAnswer = true);

                      try {
                        final authService = context.read<AuthService>();
                        final apiService = ApiService(authService);
                        final questionId = currentQuestion['id'];

                        final words = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
                        final estimatedWpm = (words * 2).clamp(90, 160);

                        final metrics = {
                          'transcription': text,
                          'wpm': estimatedWpm,
                          'fillerWordsCount': 0,
                          'sentimentScore': 0.85,
                          'mediaRef': 'typed-answer-${DateTime.now().millisecondsSinceEpoch}',
                        };

                        await apiService.submitAnswer(questionId, metrics);

                        if (mounted) {
                          setState(() => _isSubmittingTypedAnswer = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Typed answer saved & analyzed!'),
                              backgroundColor: AppTheme.accentGreen,
                            ),
                          );
                          if (_currentQuestionIndex < _questionsList.length - 1) {
                            _changeQuestion(_currentQuestionIndex + 1);
                          }
                        }
                      } catch (e) {
                        if (mounted) {
                          setState(() => _isSubmittingTypedAnswer = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error saving answer: $e'),
                              backgroundColor: AppTheme.errorRed,
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Submit Typed Answer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return AppTheme.accentGreen;
    if (score >= 60) return AppTheme.accentBlue;
    if (score >= 40) return Colors.amber;
    return AppTheme.errorRed;
  }

  void _goToReport() {
    TTSService().stop();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ReportScreen(sessionId: _sessionId),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _showExitDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          backgroundColor: isDark ? AppTheme.surfaceDark.withValues(alpha: 0.9) : Colors.white.withValues(alpha: 0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: isDark ? AppTheme.glassBorderDark : AppTheme.glassBorderLight),
          ),
          title: Text('Exit Interview?', style: TextStyle(color: isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight, fontWeight: FontWeight.bold)),
          content: Text(
            'Your progress will be saved in your session history.',
            style: TextStyle(color: isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorRed,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Exit', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = isDark ? Colors.black : AppTheme.primaryLight;
    final textPrimaryColor = isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight;
    final textSecondaryColor = isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('Practice Interview', style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: -0.5, color: textPrimaryColor)),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.surfaceDark : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
            ),
            child: Icon(Icons.close_rounded, size: 18, color: textPrimaryColor),
          ),
          onPressed: () {
            TTSService().stop();
            _showExitDialog();
          },
        ),
        actions: [
          ListenableBuilder(
            listenable: TTSService(),
            builder: (context, _) {
              final isMuted = TTSService().isMuted;
              return IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.surfaceDark : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
                  ),
                  child: Icon(
                    isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded, 
                    size: 18, 
                    color: textPrimaryColor,
                  ),
                ),
                onPressed: () => TTSService().toggleMute(),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            top: 20,
            left: -40,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accentBlue.withValues(alpha: isDark ? 0.12 : 0.06),
              ),
            ),
          ),

          SafeArea(
            child: _questionsList.isEmpty
                ? _buildNoQuestions(textPrimaryColor, textSecondaryColor)
                : _buildQuestionView(isDark, textPrimaryColor, textSecondaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildNoQuestions(Color textPrimary, Color textSecondary) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz_rounded, size: 48, color: textSecondary),
            const SizedBox(height: 24),
            Text('No questions generated yet.', style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(
              'The AI is still processing your job details. Please try again.',
              textAlign: TextAlign.center,
              style: TextStyle(color: textSecondary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionView(bool isDark, Color textPrimary, Color textSecondary) {
    final isLastQuestion = _currentQuestionIndex == _questionsList.length - 1;
    final currentQuestion = _questionsList[_currentQuestionIndex];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Match Score & Progress Pill (Fixed Overflow)
              Row(
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: _getScoreColor(_matchScore).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome_rounded, color: _getScoreColor(_matchScore), size: 14),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              _matchScore > 0 ? '$_matchScore% Match' : 'Quick Session',
                              style: TextStyle(
                                color: _getScoreColor(_matchScore),
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
                    ),
                    child: Text(
                      '${_currentQuestionIndex + 1} / ${_questionsList.length}',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 500.ms),
              
              const SizedBox(height: 16),

              // Segmented Progress Bar
              Row(
                children: List.generate(_questionsList.length, (index) {
                  final isActive = index <= _currentQuestionIndex;
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(right: index == _questionsList.length - 1 ? 0 : 6),
                      decoration: BoxDecoration(
                        color: isActive ? AppTheme.accentBlue : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ).animate().fadeIn(delay: 100.ms),
              
              const SizedBox(height: 24),

              // Question Card (Liquid Glass)
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: _buildQuestionCard(
                    key: ValueKey<int>(_currentQuestionIndex),
                    question: currentQuestion,
                    isDark: isDark,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Multi-Mode Answering Trigger Buttons
              if (_isSubmittingTypedAnswer)
                const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(color: AppTheme.accentBlue)))
              else
                Column(
                  children: [
                    Row(
                      children: [
                        // Previous button
                        if (_currentQuestionIndex > 0)
                          Container(
                            height: 52,
                            width: 52,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: isDark ? AppTheme.surfaceDark : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.arrow_back_rounded, color: textPrimary, size: 20),
                              onPressed: () => _changeQuestion(_currentQuestionIndex - 1),
                            ),
                          ),

                        // Audio Only Record Button
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation, secondaryAnimation) => RecordingScreen(
                                      question: currentQuestion,
                                      questionIndex: _currentQuestionIndex,
                                      totalQuestions: _questionsList.length,
                                      isAudioOnly: true,
                                    ),
                                    transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
                                  ),
                                ).then((_) {
                                  if (!isLastQuestion) _changeQuestion(_currentQuestionIndex + 1);
                                });
                              },
                              icon: const Icon(Icons.mic_rounded, size: 18, color: Colors.white),
                              label: const Text('Audio Record', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.accentBlue,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Video Camera Record Button
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation, secondaryAnimation) => RecordingScreen(
                                      question: currentQuestion,
                                      questionIndex: _currentQuestionIndex,
                                      totalQuestions: _questionsList.length,
                                      isAudioOnly: false,
                                    ),
                                    transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
                                  ),
                                ).then((_) {
                                  if (!isLastQuestion) _changeQuestion(_currentQuestionIndex + 1);
                                });
                              },
                              icon: const Icon(Icons.videocam_rounded, size: 18, color: Colors.white),
                              label: const Text('Video Record', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.errorRed,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Type Answer Option Button
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: OutlinedButton.icon(
                        onPressed: () => _showTypedAnswerDialog(currentQuestion),
                        icon: Icon(Icons.keyboard_alt_outlined, size: 18, color: textPrimary),
                        label: Text('Type Written Answer', style: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ],
                ),
              
              const SizedBox(height: 12),

              // Bottom Navigation & "Ask More Questions" Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (isLastQuestion)
                    OutlinedButton.icon(
                      onPressed: _isLoadingMore ? null : _requestMoreQuestions,
                      icon: _isLoadingMore
                          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.add_rounded, size: 16, color: AppTheme.accentBlue),
                      label: const Text('Ask More', style: TextStyle(color: AppTheme.accentBlue, fontSize: 13, fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.accentBlue),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    )
                  else
                    const SizedBox.shrink(),

                  TextButton(
                    onPressed: () {
                      if (!isLastQuestion) {
                        _changeQuestion(_currentQuestionIndex + 1);
                      } else {
                        _goToReport();
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          !isLastQuestion ? 'Skip Question' : 'Finish & View Report',
                          style: TextStyle(color: textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          !isLastQuestion ? Icons.arrow_forward_rounded : Icons.insights_rounded,
                          size: 16, 
                          color: textSecondary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCard({
    required Key key,
    required Map<String, dynamic> question,
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final text = question['text'] ?? '';
    final category = question['category'] ?? 'General Question';

    return AppTheme.glassCard(
      key: key,
      isDark: isDark,
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
                  category.toUpperCase(),
                  style: const TextStyle(
                    color: AppTheme.accentIndigo,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.volume_up_rounded, color: AppTheme.accentBlue, size: 22),
                onPressed: () => TTSService().speak(text),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Text(
                text,
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  height: 1.45,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

import 'new_session_screen.dart';
import 'report_screen.dart';
import 'profile_screen.dart';
import 'interview_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic>? _historyList;
  bool _isLoading = true;
  int _avgScore = 0;
  String _username = '';

  // AI Question of the Day sample pool
  final List<Map<String, String>> _dailyQuestions = [
    {
      'category': 'BEHAVIORAL',
      'text': 'Tell me about a time you had to handle a high-pressure deadline with incomplete specs.',
    },
    {
      'category': 'LEADERSHIP',
      'text': 'How do you prioritize technical debt versus building new features for clients?',
    },
    {
      'category': 'PROBLEM SOLVING',
      'text': 'Walk me through how you debug a production memory leak in a Flutter application.',
    },
  ];
  int _selectedDailyQuestionIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authService = context.read<AuthService>();
    final apiService = ApiService(authService);

    final results = await Future.wait([
      apiService.getUserProfile(),
      apiService.getHistory(),
    ]);

    final profileData = results[0] as Map<String, dynamic>?;
    final history = results[1] as List<dynamic>?;

    if (mounted) {
      if (profileData != null && profileData['username'] != null && (profileData['username'] as String).isNotEmpty) {
        _username = profileData['username'];
      } else {
        _username = authService.email?.split('@').first ?? 'User';
      }

      if (history != null && history.isNotEmpty) {
        int totalScore = 0;
        for (var session in history) {
          totalScore += (session['matchScore'] as num?)?.toInt() ?? 0;
        }
        _avgScore = (totalScore / history.length).round();
      }

      setState(() {
        _historyList = history;
        _isLoading = false;
      });
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _getTimeAgo(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString).toLocal();
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return DateFormat('MMM d').format(date);
    } catch (_) {
      return '';
    }
  }

  // Calculate user-relative session number (e.g. Session #1 for oldest, Session #N for newest)
  int _getUserSessionNumber(int indexInHistoryList) {
    if (_historyList == null || _historyList!.isEmpty) return 1;
    return _historyList!.length - indexInHistoryList;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = isDark ? Colors.black : AppTheme.primaryLight;
    final textPrimaryColor = isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight;
    final textSecondaryColor = isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight;
    final textMutedColor = isDark ? AppTheme.textMuted : AppTheme.textMutedLight;

    final todayFormatted = DateFormat('EEEE, MMM d').format(DateTime.now());

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Ambient Liquid Glass Background Glows
          Positioned(
            top: -60,
            left: -40,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accentBlue.withValues(alpha: isDark ? 0.15 : 0.08),
              ),
            ),
          ),
          Positioned(
            top: 220,
            right: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accentIndigo.withValues(alpha: isDark ? 0.12 : 0.06),
              ),
            ),
          ),

          SafeArea(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.accentBlue))
                : CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // ── Header: Greeting + Streak Pill + Profile Avatar ──
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                        sliver: SliverToBoxAdapter(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          todayFormatted.toUpperCase(),
                                          style: const TextStyle(
                                            color: AppTheme.accentBlue,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 1.0,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.amber.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(100),
                                            border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.local_fire_department_rounded, color: Colors.amber, size: 12),
                                              const SizedBox(width: 3),
                                              Text(
                                                '${(_historyList?.length ?? 0) > 0 ? (_historyList!.length.clamp(1, 7)) : 0}d streak',
                                                style: const TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ).animate().fadeIn(duration: 500.ms),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${_getGreeting()}, $_username',
                                      style: TextStyle(
                                        color: textPrimaryColor,
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: -0.8,
                                        height: 1.2,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ).animate().fadeIn(delay: 100.ms, duration: 600.ms).slideX(begin: -0.02),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Profile Avatar
                              GestureDetector(
                                onTap: () async {
                                  await Navigator.of(context).push(
                                    PageRouteBuilder(
                                      pageBuilder: (_, __, ___) => const ProfileScreen(),
                                      transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
                                    ),
                                  );
                                  _loadData();
                                },
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isDark ? AppTheme.surfaceDark : Colors.white,
                                    border: Border.all(
                                      color: isDark ? AppTheme.glassBorderDark : AppTheme.glassBorderLight,
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.accentBlue.withValues(alpha: 0.15),
                                        blurRadius: 12,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      _username.isNotEmpty ? _username[0].toUpperCase() : 'U',
                                      style: TextStyle(
                                        color: textPrimaryColor,
                                        fontSize: 19,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ).animate().fadeIn(delay: 200.ms, duration: 600.ms).scale(begin: const Offset(0.85, 0.85)),
                            ],
                          ),
                        ),
                      ),

                      // ── Hero Action Card (Liquid Glass) ──
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        sliver: SliverToBoxAdapter(
                          child: AppTheme.glassCard(
                            isDark: isDark,
                            borderRadius: 28,
                            padding: const EdgeInsets.all(22),
                            onTap: () async {
                              await Navigator.of(context).push(
                                PageRouteBuilder(
                                  pageBuilder: (_, __, ___) => const NewSessionScreen(),
                                  transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
                                ),
                              );
                              _loadData();
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppTheme.accentBlue.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: const Icon(
                                        Icons.mic_rounded,
                                        color: AppTheme.accentBlue,
                                        size: 26,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: AppTheme.accentGreen.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(100),
                                        border: Border.all(color: AppTheme.accentGreen.withValues(alpha: 0.3)),
                                      ),
                                      child: const Row(
                                        children: [
                                          Icon(Icons.auto_awesome, color: AppTheme.accentGreen, size: 12),
                                          SizedBox(width: 4),
                                          Text(
                                            'AI Practice Ready',
                                            style: TextStyle(
                                              color: AppTheme.accentGreen,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                Text(
                                  'Generate Interview Session',
                                  style: TextStyle(
                                    color: textPrimaryColor,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.5,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tailored questions generated instantly from your resume or target job description.',
                                  style: TextStyle(
                                    color: textSecondaryColor,
                                    fontSize: 14,
                                    height: 1.45,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentBlue,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Start Practice Session',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(delay: 300.ms, duration: 600.ms).slideY(begin: 0.05),
                        ),
                      ),

                      // ── Dynamic Performance Chart & Quick Stats ──
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        sliver: SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildStatChip(
                                      label: 'Total Practice',
                                      value: '${_historyList?.length ?? 0} Sessions',
                                      icon: Icons.graphic_eq_rounded,
                                      color: AppTheme.accentIndigo,
                                      isDark: isDark,
                                      textColor: textPrimaryColor,
                                      mutedColor: textSecondaryColor,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildStatChip(
                                      label: 'Avg Score',
                                      value: '$_avgScore%',
                                      icon: Icons.bolt_rounded,
                                      color: AppTheme.accentBlue,
                                      isDark: isDark,
                                      textColor: textPrimaryColor,
                                      mutedColor: textSecondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              if (_historyList != null && _historyList!.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                _buildPerformanceBarChart(isDark, textPrimaryColor, textSecondaryColor),
                              ],
                            ],
                          ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
                        ),
                      ),

                      // ── Dynamic AI Question of the Day Card ──
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        sliver: SliverToBoxAdapter(
                          child: _buildDailyQuestionCard(isDark, textPrimaryColor, textSecondaryColor)
                              .animate().fadeIn(delay: 450.ms, duration: 600.ms),
                        ),
                      ),

                      // ── Section Title: History ──
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                        sliver: SliverToBoxAdapter(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Recent Sessions',
                                style: TextStyle(
                                  color: textPrimaryColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              if (_historyList != null && _historyList!.isNotEmpty)
                                Text(
                                  '${_historyList!.length} completed',
                                  style: TextStyle(
                                    color: textMutedColor,
                                    fontSize: 13,
                                  ),
                                ),
                            ],
                          ).animate().fadeIn(delay: 500.ms, duration: 600.ms),
                        ),
                      ),

                      // ── History List / Empty State ──
                      if (_historyList == null || _historyList!.isEmpty)
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                          sliver: SliverToBoxAdapter(
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(Icons.history_rounded, size: 48, color: textMutedColor),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No practice sessions yet',
                                    style: TextStyle(color: textSecondaryColor, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Tap "Generate Interview Session" above to start.',
                                    style: TextStyle(color: textMutedColor, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final session = _historyList![index];
                                final userSessionNum = _getUserSessionNumber(index);
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _buildHistoryCard(
                                    session: session,
                                    userSessionNum: userSessionNum,
                                    index: index,
                                    isDark: isDark,
                                    textPrimary: textPrimaryColor,
                                    textSecondary: textSecondaryColor,
                                    textMuted: textMutedColor,
                                  ),
                                );
                              },
                              childCount: _historyList!.length,
                            ),
                          ),
                        ),

                      const SliverToBoxAdapter(child: SizedBox(height: 40)),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
    required Color textColor,
    required Color mutedColor,
  }) {
    return AppTheme.glassCard(
      isDark: isDark,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    color: mutedColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceBarChart(bool isDark, Color textPrimary, Color textSecondary) {
    final recent = _historyList!.take(5).toList().reversed.toList();

    return AppTheme.glassCard(
      isDark: isDark,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Score Progress', style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
              Text('Recent ${recent.length} sessions', style: TextStyle(color: textSecondary, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: recent.asMap().entries.map((entry) {
                final idx = entry.key;
                final session = entry.value;
                final score = (session['matchScore'] as num?)?.toDouble() ?? 50.0;
                final userNum = _historyList!.length - (_historyList!.length - 1 - idx);

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('${score.toInt()}%', style: TextStyle(color: AppTheme.accentBlue, fontSize: 10, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 600),
                      width: 18,
                      height: (score / 100 * 42).clamp(12.0, 42.0),
                      decoration: BoxDecoration(
                        color: score >= 75 ? AppTheme.accentGreen : (score >= 50 ? AppTheme.accentBlue : Colors.amber),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('#$userNum', style: TextStyle(color: textSecondary, fontSize: 10)),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyQuestionCard(bool isDark, Color textPrimary, Color textSecondary) {
    final currentQ = _dailyQuestions[_selectedDailyQuestionIndex];

    return AppTheme.glassCard(
      isDark: isDark,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accentPurple.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  'DAILY CHALLENGE',
                  style: const TextStyle(color: AppTheme.accentPurple, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, size: 18, color: AppTheme.accentPurple),
                onPressed: () {
                  setState(() {
                    _selectedDailyQuestionIndex = (_selectedDailyQuestionIndex + 1) % _dailyQuestions.length;
                  });
                },
                tooltip: 'Next Question',
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            currentQ['text']!,
            style: TextStyle(color: textPrimary, fontSize: 15, fontWeight: FontWeight.w600, height: 1.4),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                final mockSession = {
                  'id': 0,
                  'matchScore': 90,
                  'questions': [
                    {'id': 100, 'text': currentQ['text']!, 'category': currentQ['category']!}
                  ],
                };
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => InterviewScreen(sessionData: mockSession),
                    transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
                  ),
                );
              },
              icon: const Icon(Icons.flash_on_rounded, size: 16, color: AppTheme.accentPurple),
              label: const Text('Try Quick Answer', style: TextStyle(color: AppTheme.accentPurple, fontWeight: FontWeight.bold, fontSize: 13)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.accentPurple),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard({
    required dynamic session,
    required int userSessionNum,
    required int index,
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
    required Color textMuted,
  }) {
    final score = session['matchScore'] ?? 0;
    final timeAgo = _getTimeAgo(session['createdAt']);
    final isPinned = session['pinned'] == true;
    final rawId = session['id'];

    return AppTheme.glassCard(
      isDark: isDark,
      padding: const EdgeInsets.all(16),
      onTap: () async {
        await Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => ReportScreen(sessionId: rawId, userSessionNumber: userSessionNum),
            transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
          ),
        );
        _loadData();
      },
      child: Row(
        children: [
          // Circle match score indicator
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.accentBlue.withValues(alpha: 0.15),
              border: Border.all(color: AppTheme.accentBlue.withValues(alpha: 0.3)),
            ),
            child: Center(
              child: Text(
                '$score%',
                style: const TextStyle(
                  color: AppTheme.accentBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Session #$userSessionNum',
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    if (isPinned) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.push_pin_rounded, size: 14, color: AppTheme.accentBlue),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  session['jobDescriptionText'] != null && (session['jobDescriptionText'] as String).trim().isNotEmpty
                      ? (session['jobDescriptionText'] as String).trim()
                      : 'General Practice Session',
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 13,
                    height: 1.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          if (timeAgo.isNotEmpty) ...[
            const SizedBox(width: 10),
            Text(
              timeAgo,
              style: TextStyle(color: textMuted, fontSize: 12),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 500 + (index * 40)), duration: 500.ms).slideX(begin: 0.04);
  }
}

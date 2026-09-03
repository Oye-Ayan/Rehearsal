import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/theme_notifier.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import 'report_screen.dart';
import 'package:intl/intl.dart';
import 'login_screen.dart' as import_login_screen;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<dynamic>? _historyList;
  bool _isLoading = true;
  String _userEmail = '';
  String _userName = '';
  int _avgScore = 0;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final authService = context.read<AuthService>();
    final apiService = ApiService(authService);
    
    _userEmail = authService.email ?? 'Unknown User';
    
    final results = await Future.wait([
      apiService.getUserProfile(),
      apiService.getHistory(),
    ]);

    final profileData = results[0] as Map<String, dynamic>?;
    final history = results[1] as List<dynamic>?;
    
    if (mounted) {
      if (profileData != null && profileData['username'] != null && (profileData['username'] as String).isNotEmpty) {
        _userName = profileData['username'];
      } else {
        _userName = _userEmail.split('@').first;
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

  int _getUserSessionNumber(int indexInHistoryList) {
    if (_historyList == null || _historyList!.isEmpty) return 1;
    return _historyList!.length - indexInHistoryList;
  }

  Future<void> _showEditUsernameDialog() async {
    final TextEditingController controller = TextEditingController(text: _userName);
    bool isSaving = false;
    String? errorText;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: isDark ? AppTheme.surfaceDark.withValues(alpha: 0.9) : Colors.white.withValues(alpha: 0.9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(color: isDark ? AppTheme.glassBorderDark : AppTheme.glassBorderLight),
              ),
              title: Text('Edit Username', style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: controller,
                    style: TextStyle(color: textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Enter new username',
                      filled: true,
                      fillColor: isDark ? Colors.black.withValues(alpha: 0.3) : AppTheme.primaryLight,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  if (errorText != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(errorText!, style: const TextStyle(color: AppTheme.errorRed, fontSize: 13)),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(ctx),
                  child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          final newName = controller.text.trim();
                          if (newName.length < 3) {
                            setStateDialog(() => errorText = 'Username must be at least 3 characters.');
                            return;
                          }
                          if (newName == _userName) {
                            Navigator.pop(ctx);
                            return;
                          }

                          setStateDialog(() {
                            isSaving = true;
                            errorText = null;
                          });

                          final authService = context.read<AuthService>();
                          final apiService = ApiService(authService);
                          final navigator = Navigator.of(ctx);
                          final scaffoldMessenger = ScaffoldMessenger.of(context);
                          final error = await apiService.updateUsername(newName);

                          if (error == null) {
                            if (mounted) {
                              setState(() => _userName = newName);
                              navigator.pop();
                              scaffoldMessenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Username updated successfully!', style: TextStyle(color: Colors.white)),
                                  backgroundColor: AppTheme.accentGreen,
                                ),
                              );
                            }
                          } else {
                            setStateDialog(() {
                              isSaving = false;
                              errorText = error;
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isSaving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _deleteSession(int sessionId) async {
    final apiService = ApiService(context.read<AuthService>());
    final success = await apiService.deleteSession(sessionId);
    if (success) {
      _loadProfileData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session deleted.')),
        );
      }
    }
  }

  Future<void> _togglePin(int sessionId) async {
    final apiService = ApiService(context.read<AuthService>());
    final result = await apiService.togglePin(sessionId);
    if (result != null) {
      _loadProfileData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeNotifier = context.watch<ThemeNotifier>();

    final backgroundColor = isDark ? Colors.black : AppTheme.primaryLight;
    final textPrimaryColor = isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight;
    final textSecondaryColor = isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight;
    final textMutedColor = isDark ? AppTheme.textMuted : AppTheme.textMutedLight;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('Profile & Settings', style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: -0.5, color: textPrimaryColor)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textPrimaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppTheme.errorRed),
            tooltip: 'Logout',
            onPressed: () async {
              final authService = context.read<AuthService>();
              await authService.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => const import_login_screen.LoginScreen(),
                    transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
                  ),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            top: -30,
            right: -30,
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
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile Header Card (Liquid Glass)
                        AppTheme.glassCard(
                          isDark: isDark,
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: isDark ? AppTheme.surfaceDark : Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: isDark ? AppTheme.glassBorderDark : AppTheme.glassBorderLight, width: 2),
                                ),
                                child: Center(
                                  child: Icon(Icons.person_rounded, size: 44, color: AppTheme.accentBlue),
                                ),
                              ).animate().fadeIn(duration: 600.ms, curve: AppTheme.fluidCurve).scale(begin: const Offset(0.85, 0.85)),
                              const SizedBox(height: 14),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: Text(
                                      '@$_userName',
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
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: _showEditUsernameDialog,
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: AppTheme.accentBlue.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.edit_rounded, size: 16, color: AppTheme.accentBlue),
                                    ),
                                  ),
                                ],
                              ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
                              const SizedBox(height: 6),
                              Text(
                                _userEmail,
                                style: TextStyle(
                                  color: textSecondaryColor,
                                  fontSize: 13,
                                  height: 1.2,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ).animate().fadeIn(delay: 300.ms, duration: 600.ms),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),

                        // Settings Card (Theme Toggle)
                        AppTheme.glassCard(
                          isDark: isDark,
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentBlue.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                                  color: AppTheme.accentBlue,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Appearance',
                                      style: TextStyle(color: textPrimaryColor, fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      isDark ? 'Dark Theme (Liquid Glass)' : 'Light Theme (Liquid Glass)',
                                      style: TextStyle(color: textMutedColor, fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                              ),
                              Switch.adaptive(
                                value: isDark,
                                activeTrackColor: AppTheme.accentBlue,
                                onChanged: (val) {
                                  themeNotifier.toggleTheme(val);
                                },
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 350.ms, duration: 500.ms),

                        const SizedBox(height: 28),

                        // Stats Grid
                        Text(
                          'Overall Progress',
                          style: TextStyle(color: textPrimaryColor, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                        ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
                        const SizedBox(height: 14),
                        
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                title: 'Total Sessions',
                                value: _historyList != null ? '${_historyList!.length}' : '-',
                                icon: Icons.schedule_rounded,
                                color: AppTheme.accentIndigo,
                                isDark: isDark,
                                textPrimary: textPrimaryColor,
                                textSecondary: textSecondaryColor,
                                delay: 450,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                title: 'Avg. Match Score',
                                value: _historyList != null && _historyList!.isNotEmpty ? '$_avgScore%' : '-',
                                icon: Icons.analytics_rounded,
                                color: AppTheme.accentBlue,
                                isDark: isDark,
                                textPrimary: textPrimaryColor,
                                textSecondary: textSecondaryColor,
                                delay: 500,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        // Detailed History
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'History Details',
                              style: TextStyle(color: textPrimaryColor, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                            ),
                            Text(
                              'Auto-deletes 7d',
                              style: TextStyle(color: textMutedColor, fontSize: 12),
                            ),
                          ],
                        ).animate().fadeIn(delay: 550.ms, duration: 600.ms),
                        const SizedBox(height: 14),

                        if (_historyList == null || _historyList!.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Text(
                                'No sessions recorded yet.',
                                style: TextStyle(color: textMutedColor),
                              ),
                            ),
                          )
                        else
                          ..._historyList!.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final session = entry.value;
                            final userSessionNum = _getUserSessionNumber(idx);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: _buildHistoryDetailCard(
                                session: session,
                                userSessionNum: userSessionNum,
                                index: idx,
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

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
    required int delay,
  }) {
    return AppTheme.glassCard(
      isDark: isDark,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: TextStyle(color: textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(color: textPrimary, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: -0.5, height: 1.1),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay), duration: 600.ms, curve: AppTheme.fluidCurve).slideY(begin: 0.05);
  }

  Widget _buildHistoryDetailCard({
    required dynamic session,
    required int userSessionNum,
    required int index,
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
    required Color textMuted,
  }) {
    String dateStr = 'Unknown Date';
    if (session['createdAt'] != null) {
      try {
        final date = DateTime.parse(session['createdAt']).toLocal();
        dateStr = DateFormat('MMM d, yyyy').format(date);
      } catch (_) {}
    }

    final score = session['matchScore'] ?? 0;
    final isPinned = session['pinned'] == true;
    final sessionId = session['id'];

    return AppTheme.glassCard(
      isDark: isDark,
      padding: const EdgeInsets.all(14),
      onTap: () async {
        await Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => ReportScreen(sessionId: sessionId, userSessionNumber: userSessionNum),
            transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
          ),
        );
        _loadProfileData();
      },
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Session #$userSessionNum',
                        style: TextStyle(color: textPrimary, fontSize: 15, fontWeight: FontWeight.bold, height: 1.2),
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
                  dateStr,
                  style: TextStyle(color: textMuted, fontSize: 12, height: 1.2),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                  color: isPinned ? AppTheme.accentBlue : textMuted,
                  size: 18,
                ),
                onPressed: () => _togglePin(sessionId),
                tooltip: isPinned ? 'Pinned' : 'Pin',
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(8),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.errorRed, size: 18),
                onPressed: () => _deleteSession(sessionId),
                tooltip: 'Delete',
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(8),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: AppTheme.accentBlue.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '$score%',
                  style: const TextStyle(color: AppTheme.accentBlue, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 500 + (index * 40)), duration: 500.ms).slideX(begin: 0.04);
  }
}

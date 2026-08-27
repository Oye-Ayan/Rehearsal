import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'new_session_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic>? _historyList;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final authService = context.read<AuthService>();
    final apiService = ApiService(authService);
    final history = await apiService.getHistory();
    if (mounted) {
      setState(() {
        _historyList = history;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.mic_rounded, size: 18, color: AppTheme.primaryDark),
            ),
            const SizedBox(width: 10),
            const Text('Rehearsal', style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppTheme.textSecondary),
            onPressed: () async {
              await auth.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => const LoginScreen(),
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
          // Ethereal Glass Background Orbs
          Positioned(
            top: -50,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accentPurple.withOpacity(0.08),
                boxShadow: [BoxShadow(color: AppTheme.accentPurple.withOpacity(0.08), blurRadius: 150, spreadRadius: 50)],
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
           .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 8.seconds, curve: AppTheme.fluidCurve),

          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accentBlue.withOpacity(0.06),
                boxShadow: [BoxShadow(color: AppTheme.accentBlue.withOpacity(0.06), blurRadius: 150, spreadRadius: 50)],
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
           .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 10.seconds, curve: AppTheme.fluidCurve),

          // Glassmorphic Noise Overlay
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
              child: IgnorePointer(
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Massive Editorial Greeting
                        Text(
                          'Welcome back,',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textSecondary,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            fontFamily: 'Inter',
                          ),
                        ).animate().fadeIn(duration: 800.ms, curve: AppTheme.fluidCurve).slideY(begin: 0.1),
                        const SizedBox(height: 8),
                        Text(
                          auth.email?.split('@').first.toUpperCase() ?? 'USER',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -2,
                            height: 1,
                          ),
                        ).animate().fadeIn(delay: 100.ms, duration: 800.ms, curve: AppTheme.fluidCurve).slideY(begin: 0.1),
                        
                        const SizedBox(height: 48),

                        // Asymmetrical Bento Layout for Actions
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: _buildPrimaryActionCard().animate().fadeIn(delay: 200.ms, duration: 800.ms, curve: AppTheme.fluidCurve).slideX(begin: -0.1),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: Column(
                                children: [
                                  _buildSecondaryActionCard(
                                    icon: Icons.psychology_rounded,
                                    title: 'AI Coach',
                                    color: AppTheme.accentPurple,
                                  ).animate().fadeIn(delay: 300.ms, duration: 800.ms, curve: AppTheme.fluidCurve).slideX(begin: 0.1),
                                  const SizedBox(height: 16),
                                  _buildSecondaryActionCard(
                                    icon: Icons.analytics_rounded,
                                    title: 'Analytics',
                                    color: Colors.orangeAccent,
                                  ).animate().fadeIn(delay: 400.ms, duration: 800.ms, curve: AppTheme.fluidCurve).slideX(begin: 0.1),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 48),

                        // Session History Header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withOpacity(0.1)),
                              ),
                              child: const Text(
                                'HISTORY',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                          ],
                        ).animate().fadeIn(delay: 500.ms, duration: 800.ms, curve: AppTheme.fluidCurve),
                      ],
                    ),
                  ),
                ),
                
                // Session History List
                if (_isLoading)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator(color: AppTheme.accentBlue)),
                  )
                else if (_historyList == null || _historyList!.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Center(
                        child: Text(
                          'No practice sessions yet.\nStart a new session above.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppTheme.textSecondary.withOpacity(0.5), fontSize: 16, height: 1.5),
                        ),
                      ),
                    ).animate().fadeIn(delay: 600.ms, duration: 800.ms),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final session = _historyList![index];
                          return _buildHistoryCard(session, index);
                        },
                        childCount: _historyList!.length,
                      ),
                    ),
                  ),
                  
                const SliverToBoxAdapter(child: SizedBox(height: 100)), // Bottom padding for FAB
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        height: 64,
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const NewSessionScreen(),
                transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accentBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            padding: const EdgeInsets.symmetric(horizontal: 24),
          ),
          icon: const Icon(Icons.add_rounded, size: 24),
          label: const Text('New Session', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ),
      ).animate().fadeIn(delay: 700.ms, duration: 800.ms, curve: AppTheme.fluidCurve).slideY(begin: 0.2),
    );
  }

  Widget _buildPrimaryActionCard() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const NewSessionScreen(),
            transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
          ),
        );
      },
      child: Container(
        height: 220, // Tall card in the asymmetrical bento
        decoration: AppTheme.doubleBezelOuter(),
        padding: const EdgeInsets.all(4),
        child: Container(
          decoration: AppTheme.doubleBezelInner().copyWith(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.accentBlue.withOpacity(0.15),
                AppTheme.primaryDark,
              ],
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.videocam_rounded, color: AppTheme.accentBlue, size: 32),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Start\nRehearsing',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Upload Resume',
                          style: TextStyle(color: AppTheme.accentBlue, fontSize: 12, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppTheme.accentBlue.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_forward_rounded, color: AppTheme.accentBlue, size: 12),
                      )
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryActionCard({required IconData icon, required String title, required Color color}) {
    return Container(
      height: 102,
      decoration: AppTheme.doubleBezelOuter(),
      padding: const EdgeInsets.all(4),
      child: Container(
        decoration: AppTheme.doubleBezelInner(),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(dynamic session, int index) {
    // Format date nicely
    String dateStr = 'Unknown Date';
    if (session['createdAt'] != null) {
      try {
        final date = DateTime.parse(session['createdAt']).toLocal();
        dateStr = DateFormat('MMM d, yyyy • h:mm a').format(date);
      } catch (_) {}
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        decoration: AppTheme.doubleBezelOuter(),
        padding: const EdgeInsets.all(4),
        child: Container(
          decoration: AppTheme.doubleBezelInner(),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: const Icon(Icons.check_circle_outline_rounded, color: AppTheme.accentGreen),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Session #${session['id']}',
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateStr,
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
            ],
          ),
        ),
      ).animate().fadeIn(delay: Duration(milliseconds: 600 + (index * 100)), duration: 600.ms, curve: AppTheme.fluidCurve).slideY(begin: 0.1),
    );
  }
}

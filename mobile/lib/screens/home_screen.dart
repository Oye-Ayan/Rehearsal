import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'new_session_screen.dart';
import 'dart:ui';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    return Scaffold(
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
          // Ethereal Background Orbs
          Positioned(
            top: 50,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accentPurple.withValues(alpha: 0.08),
                boxShadow: [BoxShadow(color: AppTheme.accentPurple.withValues(alpha: 0.08), blurRadius: 100, spreadRadius: 50)],
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
           .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 8.seconds, curve: AppTheme.fluidCurve),

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
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting
                  Text(
                    'Welcome back,',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
                  ).animate().fadeIn(duration: 800.ms, curve: AppTheme.fluidCurve).slideX(begin: -0.05),
                  const SizedBox(height: 4),
                  Text(
                    auth.email?.split('@').first.toUpperCase() ?? 'USER',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ).animate().fadeIn(delay: 100.ms, duration: 800.ms, curve: AppTheme.fluidCurve).slideX(begin: -0.05),
                  
                  const SizedBox(height: 40),

                  // Quick Stats Card (Double Bezel)
                  Container(
                    decoration: AppTheme.doubleBezelOuter(),
                    padding: const EdgeInsets.all(4),
                    child: Container(
                      decoration: AppTheme.doubleBezelInner(),
                      padding: const EdgeInsets.all(28),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.accentBlue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.bolt_rounded, color: AppTheme.accentBlue, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Ready to Practice?',
                                  style: TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Upload your resume & paste a job description to begin',
                                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.4),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 200.ms, duration: 800.ms, curve: AppTheme.fluidCurve).slideY(begin: 0.1),

                  const SizedBox(height: 32),

                  // Feature Cards
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.72, // Reduced to prevent overflow
                      children: [
                        _FeatureCard(
                          icon: Icons.description_rounded,
                          title: 'Resume Match',
                          subtitle: 'AI-powered scoring',
                          color: AppTheme.accentBlue,
                          delay: 300,
                        ),
                        _FeatureCard(
                          icon: Icons.psychology_rounded,
                          title: 'AI Coach',
                          subtitle: 'Targeted feedback',
                          color: AppTheme.accentPurple,
                          delay: 400,
                        ),
                        _FeatureCard(
                          icon: Icons.videocam_rounded,
                          title: 'Record Answers',
                          subtitle: 'Video practice',
                          color: AppTheme.accentGreen,
                          delay: 500,
                        ),
                        _FeatureCard(
                          icon: Icons.analytics_rounded,
                          title: 'Analytics',
                          subtitle: 'Pacing & fillers',
                          color: Colors.orangeAccent,
                          delay: 600,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
          icon: const Icon(Icons.add_rounded, size: 24),
          label: const Text('New Session'),
        ),
      ).animate().fadeIn(delay: 700.ms, duration: 800.ms, curve: AppTheme.fluidCurve).slideY(begin: 0.2),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final int delay;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.doubleBezelOuter(),
      padding: const EdgeInsets.all(4),
      child: Container(
        decoration: AppTheme.doubleBezelInner(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.3),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay), duration: 800.ms, curve: AppTheme.fluidCurve).slideY(begin: 0.1);
  }
}

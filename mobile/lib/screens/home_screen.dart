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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.textPrimary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.mic_rounded, size: 18, color: AppTheme.primaryDark),
            ),
            const SizedBox(width: 10),
            const Text('Rehearsal', style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: -0.5)),
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
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Greeting
                        Text(
                          'Good morning,',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                            letterSpacing: -0.2,
                          ),
                        ).animate().fadeIn(duration: 800.ms, curve: AppTheme.fluidCurve).slideY(begin: 0.1),
                        
                        const SizedBox(height: 4),
                        
                        Text(
                          auth.email?.split('@').first.toUpperCase() ?? 'USER',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 40),
                        ).animate().fadeIn(delay: 100.ms, duration: 800.ms, curve: AppTheme.fluidCurve).slideY(begin: 0.1),
                        
                        const SizedBox(height: 48),

                        // Main Dashboard Action Card
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              PageRouteBuilder(
                                pageBuilder: (_, __, ___) => const NewSessionScreen(),
                                transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppTheme.cardDark,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: AppTheme.borderDark, width: 1),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.4),
                                  blurRadius: 30,
                                  offset: const Offset(0, 15),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                // Subtle overlay pattern or gradient for premium feel
                                Positioned(
                                  right: -50,
                                  top: -50,
                                  child: Container(
                                    width: 200,
                                    height: 200,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          AppTheme.accentIndigo.withValues(alpha: 0.15),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppTheme.surfaceDark,
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: AppTheme.borderDark),
                                        ),
                                        child: const Icon(Icons.play_arrow_rounded, color: AppTheme.textPrimary, size: 28),
                                      ),
                                      const SizedBox(height: 32),
                                      const Text(
                                        'Start Practice',
                                        style: TextStyle(
                                          color: AppTheme.textPrimary,
                                          fontSize: 28,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -1,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Begin a new AI interview session',
                                        style: TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ).animate().fadeIn(delay: 200.ms, duration: 800.ms, curve: AppTheme.fluidCurve).slideY(begin: 0.1),
                        
                        const SizedBox(height: 24),

                        // Analytics Bento Boxes
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.schedule_rounded,
                                value: _historyList != null ? '${_historyList!.length}' : '-',
                                label: 'Total Sessions',
                              ).animate().fadeIn(delay: 300.ms, duration: 800.ms, curve: AppTheme.fluidCurve).slideY(begin: 0.1),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.analytics_rounded,
                                value: 'N/A', // Placeholder for actual avg score
                                label: 'Avg. Score',
                              ).animate().fadeIn(delay: 400.ms, duration: 800.ms, curve: AppTheme.fluidCurve).slideY(begin: 0.1),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 48),

                        // Session History Header
                        const Text(
                          'Recent Sessions',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.5,
                          ),
                        ).animate().fadeIn(delay: 500.ms, duration: 800.ms, curve: AppTheme.fluidCurve),
                      ],
                    ),
                  ),
                ),
                
                // Session History List
                if (_isLoading)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator(color: AppTheme.textPrimary)),
                  )
                else if (_historyList == null || _historyList!.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Center(
                        child: Text(
                          'No practice sessions yet.\nTap Start Practice to begin.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppTheme.textMuted, fontSize: 15, height: 1.5),
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
                  
                const SliverToBoxAdapter(child: SizedBox(height: 48)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({required IconData icon, required String value, required String label}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderDark, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.accentIndigo, size: 24),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.borderDark, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.cardDark,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.borderDark),
              ),
              child: const Icon(Icons.check_circle_outline_rounded, color: AppTheme.textPrimary),
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
      ).animate().fadeIn(delay: Duration(milliseconds: 600 + (index * 100)), duration: 600.ms, curve: AppTheme.fluidCurve).slideY(begin: 0.1),
    );
  }
}

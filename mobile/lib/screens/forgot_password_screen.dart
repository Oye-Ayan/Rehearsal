import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email'), backgroundColor: AppTheme.errorRed),
      );
      return;
    }

    final authService = context.read<AuthService>();
    final error = await authService.forgotPassword(email);

    if (!mounted) return;

    if (error == null) {
      setState(() => _isSent = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppTheme.errorRed),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Background Orbs
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accentPurple.withOpacity(0.1),
                boxShadow: [
                  BoxShadow(color: AppTheme.accentPurple.withOpacity(0.1), blurRadius: 100, spreadRadius: 50)
                ],
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
           .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 8.seconds, curve: AppTheme.fluidCurve),

          // Glass Noise Filter
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
              child: IgnorePointer(child: Container(color: Colors.transparent)),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 600),
                  switchInCurve: AppTheme.fluidCurve,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                  child: _isSent ? _buildSuccessView() : _buildFormView(auth.isLoading),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormView(bool isLoading) {
    return Column(
      key: const ValueKey('form'),
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.lock_reset_rounded, size: 64, color: AppTheme.textPrimary)
            .animate().fadeIn(duration: 800.ms).slideY(begin: 0.2, curve: AppTheme.fluidCurve),
        const SizedBox(height: 24),
        const Text(
          'Reset Password',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: -1.0,
          ),
        ).animate().fadeIn(delay: 100.ms, duration: 800.ms).slideY(begin: 0.2, curve: AppTheme.fluidCurve),
        const SizedBox(height: 12),
        const Text(
          'Enter the email address associated with your account and we\'ll send you a link to reset your password.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 16, height: 1.5),
        ).animate().fadeIn(delay: 200.ms, duration: 800.ms).slideY(begin: 0.2, curve: AppTheme.fluidCurve),
        const SizedBox(height: 48),

        Container(
          decoration: AppTheme.doubleBezelOuter(),
          padding: const EdgeInsets.all(4),
          child: Container(
            decoration: AppTheme.doubleBezelInner(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: TextField(
              controller: _emailController,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16),
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Email Address',
                hintStyle: TextStyle(color: AppTheme.textSecondary),
                icon: Icon(Icons.email_rounded, color: AppTheme.textSecondary),
              ),
            ),
          ),
        ).animate().fadeIn(delay: 300.ms, duration: 800.ms).slideY(begin: 0.2, curve: AppTheme.fluidCurve),
        const SizedBox(height: 32),

        SizedBox(
          height: 64,
          child: ElevatedButton(
            onPressed: isLoading ? null : _handleReset,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: isLoading
                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                : const Text('Send Reset Link', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ),
        ).animate().fadeIn(delay: 400.ms, duration: 800.ms).slideY(begin: 0.2, curve: AppTheme.fluidCurve),
      ],
    );
  }

  Widget _buildSuccessView() {
    return Column(
      key: const ValueKey('success'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.accentGreen.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.mark_email_read_rounded, size: 64, color: AppTheme.accentGreen),
        ).animate().fadeIn(duration: 800.ms).scale(begin: const Offset(0.8, 0.8), curve: AppTheme.fluidCurve),
        const SizedBox(height: 32),
        const Text(
          'Check Your Inbox',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: -1.0,
          ),
        ).animate().fadeIn(delay: 100.ms, duration: 800.ms).slideY(begin: 0.2, curve: AppTheme.fluidCurve),
        const SizedBox(height: 16),
        Text(
          'We\'ve sent a password reset link to\n${_emailController.text}',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 16, height: 1.5),
        ).animate().fadeIn(delay: 200.ms, duration: 800.ms).slideY(begin: 0.2, curve: AppTheme.fluidCurve),
        const SizedBox(height: 48),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Return to Login', style: TextStyle(color: AppTheme.accentBlue, fontSize: 16, fontWeight: FontWeight.w600)),
        ).animate().fadeIn(delay: 300.ms, duration: 800.ms).slideY(begin: 0.2, curve: AppTheme.fluidCurve),
      ],
    );
  }
}

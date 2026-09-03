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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Subtle, ultra-premium background gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(-0.8, -0.8),
                  radius: 1.5,
                  colors: [
                    Color(0xFF18181B), // Zinc 900
                    Color(0xFF09090B), // Zinc 950
                  ],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.borderDark, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(Icons.lock_reset_rounded, size: 32, color: AppTheme.textPrimary),
          ).animate().fadeIn(duration: 800.ms, curve: AppTheme.fluidCurve).slideY(begin: 0.2),
        ),
        
        const SizedBox(height: 32),
        
        Text(
          'Reset Password',
          textAlign: TextAlign.left,
          style: Theme.of(context).textTheme.displayMedium,
        ).animate().fadeIn(delay: 100.ms, duration: 800.ms).slideY(begin: 0.2, curve: AppTheme.fluidCurve),
        
        const SizedBox(height: 12),
        
        Text(
          'Enter the email address associated with your account and we\'ll send you a link to reset your password.',
          textAlign: TextAlign.left,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
        ).animate().fadeIn(delay: 200.ms, duration: 800.ms).slideY(begin: 0.2, curve: AppTheme.fluidCurve),
        
        const SizedBox(height: 48),

        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(fontWeight: FontWeight.w500),
          decoration: const InputDecoration(
            labelText: 'Email Address',
            prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textSecondary),
          ),
        ).animate().fadeIn(delay: 300.ms, duration: 800.ms).slideY(begin: 0.2, curve: AppTheme.fluidCurve),
        
        const SizedBox(height: 32),

        SizedBox(
          height: 60,
          child: ElevatedButton(
            onPressed: isLoading ? null : _handleReset,
            child: isLoading
                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: AppTheme.primaryDark, strokeWidth: 3))
                : const Text('Send Reset Link'),
          ),
        ).animate().fadeIn(delay: 400.ms, duration: 800.ms).slideY(begin: 0.2, curve: AppTheme.fluidCurve),
      ],
    );
  }

  Widget _buildSuccessView() {
    return Column(
      key: const ValueKey('success'),
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.borderDark, width: 1),
            ),
            child: const Icon(Icons.mark_email_read_rounded, size: 32, color: AppTheme.accentIndigo),
          ).animate().fadeIn(duration: 800.ms, curve: AppTheme.fluidCurve).slideY(begin: 0.2),
        ),
        
        const SizedBox(height: 32),
        
        Text(
          'Check Your Inbox',
          textAlign: TextAlign.left,
          style: Theme.of(context).textTheme.displayMedium,
        ).animate().fadeIn(delay: 100.ms, duration: 800.ms).slideY(begin: 0.2, curve: AppTheme.fluidCurve),
        
        const SizedBox(height: 12),
        
        Text(
          'We\'ve sent a password reset link to ${_emailController.text}',
          textAlign: TextAlign.left,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
        ).animate().fadeIn(delay: 200.ms, duration: 800.ms).slideY(begin: 0.2, curve: AppTheme.fluidCurve),
        
        const SizedBox(height: 48),
        
        SizedBox(
          height: 60,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Return to Login'),
          ),
        ).animate().fadeIn(delay: 300.ms, duration: 800.ms).slideY(begin: 0.2, curve: AppTheme.fluidCurve),
      ],
    );
  }
}

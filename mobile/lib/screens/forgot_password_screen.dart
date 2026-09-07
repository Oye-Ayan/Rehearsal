// Backup of previous ForgotPasswordScreen code is preserved below as comment:
/*
class ForgotPasswordScreen extends StatefulWidget { ... }
*/

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final String? initialToken;

  const ForgotPasswordScreen({super.key, this.initialToken});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _tokenController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isSent = false;
  bool _isTokenMode = false;
  bool _resetComplete = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialToken != null && widget.initialToken!.isNotEmpty) {
      _tokenController.text = widget.initialToken!;
      _isTokenMode = true;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _tokenController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSendResetLink() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email address'), backgroundColor: AppTheme.errorRed),
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

  Future<void> _handleConfirmReset() async {
    final token = _tokenController.text.trim();
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your reset token'), backgroundColor: AppTheme.alertCoral),
      );
      return;
    }

    if (newPassword.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 8 characters'), backgroundColor: AppTheme.alertCoral),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match'), backgroundColor: AppTheme.alertCoral),
      );
      return;
    }

    final authService = context.read<AuthService>();
    final error = await authService.resetPassword(token, newPassword);

    if (!mounted) return;

    if (error == null) {
      setState(() {
        _resetComplete = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppTheme.alertCoral),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgGradientColors = isDark
        ? [AppTheme.midnightBlueGray, AppTheme.darkCharcoal]
        : [AppTheme.pureWhite, AppTheme.softIceBlue];
    final surfaceColor = isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight;
    final borderColor = isDark ? AppTheme.borderDark : AppTheme.borderLight;
    final textPrimary = isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight;
    final textSecondary = isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight;
    final actionColor = isDark ? AppTheme.electricTeal : AppTheme.confidenceTeal;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.8, -0.8),
                  radius: 1.5,
                  colors: bgGradientColors,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  switchInCurve: AppTheme.fluidCurve,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                  child: _resetComplete
                      ? _buildResetCompleteView(surfaceColor, borderColor, textPrimary, textSecondary, actionColor)
                      : _isTokenMode
                          ? _buildTokenResetFormView(auth.isLoading, surfaceColor, borderColor, textPrimary, textSecondary, actionColor)
                          : _isSent
                              ? _buildSuccessView(surfaceColor, borderColor, textPrimary, textSecondary, actionColor)
                              : _buildEmailFormView(auth.isLoading, surfaceColor, borderColor, textPrimary, textSecondary, actionColor),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailFormView(bool isLoading, Color surfaceColor, Color borderColor, Color textPrimary, Color textSecondary, Color actionColor) {
    return Column(
      key: const ValueKey('email_form'),
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Icon(Icons.lock_reset_rounded, size: 32, color: actionColor),
          ).animate().fadeIn(duration: 600.ms, curve: AppTheme.fluidCurve).slideY(begin: 0.2),
        ),
        const SizedBox(height: 28),
        Text(
          'Reset Password',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(color: textPrimary),
        ).animate().fadeIn(delay: 100.ms, duration: 600.ms).slideY(begin: 0.2),
        const SizedBox(height: 12),
        Text(
          'Enter your email address and we\'ll send you a direct link and token to reset your password.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: textSecondary),
        ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: 0.2),
        const SizedBox(height: 40),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: TextStyle(fontWeight: FontWeight.w500, color: textPrimary),
          decoration: InputDecoration(
            labelText: 'Email Address',
            prefixIcon: Icon(Icons.email_outlined, color: textSecondary),
          ),
        ).animate().fadeIn(delay: 300.ms, duration: 600.ms).slideY(begin: 0.2),
        const SizedBox(height: 28),
        SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: isLoading ? null : _handleSendResetLink,
            style: ElevatedButton.styleFrom(
              backgroundColor: actionColor,
              foregroundColor: Theme.of(context).brightness == Brightness.dark ? AppTheme.primaryDark : Colors.white,
            ),
            child: isLoading
                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                : const Text('Send Reset Link'),
          ),
        ).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideY(begin: 0.2),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => setState(() => _isTokenMode = true),
          child: Text('Already have a reset token?', style: TextStyle(color: actionColor, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildTokenResetFormView(bool isLoading, Color surfaceColor, Color borderColor, Color textPrimary, Color textSecondary, Color actionColor) {
    return Column(
      key: const ValueKey('token_form'),
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: actionColor.withValues(alpha: 0.4), width: 1),
            ),
            child: Icon(Icons.key_rounded, size: 32, color: actionColor),
          ).animate().fadeIn(duration: 600.ms, curve: AppTheme.fluidCurve).slideY(begin: 0.2),
        ),
        const SizedBox(height: 28),
        Text(
          'Set New Password',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(color: textPrimary),
        ).animate().fadeIn(delay: 100.ms, duration: 600.ms).slideY(begin: 0.2),
        const SizedBox(height: 12),
        Text(
          'Enter your reset token from the email and your new password below (min 8 chars).',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: textSecondary),
        ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: 0.2),
        const SizedBox(height: 36),
        TextFormField(
          controller: _tokenController,
          style: TextStyle(color: textPrimary),
          decoration: InputDecoration(
            labelText: 'Reset Token',
            prefixIcon: Icon(Icons.vpn_key_outlined, color: textSecondary),
          ),
        ).animate().fadeIn(delay: 300.ms, duration: 600.ms).slideY(begin: 0.2),
        const SizedBox(height: 16),
        TextFormField(
          controller: _newPasswordController,
          obscureText: _obscurePassword,
          style: TextStyle(color: textPrimary),
          decoration: InputDecoration(
            labelText: 'New Password (min 8 chars)',
            prefixIcon: Icon(Icons.lock_outline, color: textSecondary),
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: textSecondary),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ).animate().fadeIn(delay: 350.ms, duration: 600.ms).slideY(begin: 0.2),
        const SizedBox(height: 16),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: _obscurePassword,
          style: TextStyle(color: textPrimary),
          decoration: InputDecoration(
            labelText: 'Confirm Password',
            prefixIcon: Icon(Icons.lock_outline, color: textSecondary),
          ),
        ).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideY(begin: 0.2),
        const SizedBox(height: 28),
        SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: isLoading ? null : _handleConfirmReset,
            style: ElevatedButton.styleFrom(
              backgroundColor: actionColor,
              foregroundColor: Theme.of(context).brightness == Brightness.dark ? AppTheme.primaryDark : Colors.white,
            ),
            child: isLoading
                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                : const Text('Update Password'),
          ),
        ).animate().fadeIn(delay: 450.ms, duration: 600.ms).slideY(begin: 0.2),
      ],
    );
  }

  Widget _buildSuccessView(Color surfaceColor, Color borderColor, Color textPrimary, Color textSecondary, Color actionColor) {
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
              color: surfaceColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: actionColor.withValues(alpha: 0.4), width: 1),
            ),
            child: Icon(Icons.mark_email_read_rounded, size: 32, color: actionColor),
          ).animate().fadeIn(duration: 600.ms, curve: AppTheme.fluidCurve).slideY(begin: 0.2),
        ),
        const SizedBox(height: 28),
        Text(
          'Check Your Link',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(color: textPrimary),
        ).animate().fadeIn(delay: 100.ms, duration: 600.ms).slideY(begin: 0.2),
        const SizedBox(height: 12),
        Text(
          'We\'ve sent a reset link to ${_emailController.text}. Tap the link in your email to open the app, or enter your token below.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: textSecondary),
        ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: 0.2),
        const SizedBox(height: 36),
        SizedBox(
          height: 56,
          child: OutlinedButton(
            onPressed: () => setState(() => _isTokenMode = true),
            style: OutlinedButton.styleFrom(
              foregroundColor: textPrimary,
              side: BorderSide(color: borderColor),
            ),
            child: const Text('Enter Token Manually'),
          ),
        ),
      ],
    );
  }

  Widget _buildResetCompleteView(Color surfaceColor, Color borderColor, Color textPrimary, Color textSecondary, Color actionColor) {
    return Column(
      key: const ValueKey('complete'),
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: actionColor, width: 1),
            ),
            child: Icon(Icons.check_circle_outline_rounded, size: 32, color: actionColor),
          ).animate().fadeIn(duration: 600.ms, curve: AppTheme.fluidCurve).slideY(begin: 0.2),
        ),
        const SizedBox(height: 28),
        Text(
          'Password Updated',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(color: textPrimary),
        ).animate().fadeIn(delay: 100.ms, duration: 600.ms).slideY(begin: 0.2),
        const SizedBox(height: 12),
        Text(
          'Your password has been successfully reset. You can now log in with your new credentials.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: textSecondary),
        ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: 0.2),
        const SizedBox(height: 36),
        SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: actionColor,
              foregroundColor: Theme.of(context).brightness == Brightness.dark ? AppTheme.primaryDark : Colors.white,
            ),
            child: const Text('Back to Login'),
          ),
        ),
      ],
    );
  }
}

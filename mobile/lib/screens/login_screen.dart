import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import 'home_screen.dart';
import 'dart:ui';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = context.read<AuthService>();
    final error = await authService.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (error == null) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch, // Make children fill width
                    children: [
                      // Logo / Brand
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
                          child: const Icon(Icons.mic_rounded, size: 32, color: AppTheme.textPrimary),
                        ).animate().fadeIn(duration: 800.ms, curve: AppTheme.fluidCurve).slideY(begin: 0.2),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      Text(
                        'Welcome Back',
                        style: Theme.of(context).textTheme.displayMedium,
                        textAlign: TextAlign.left,
                      ).animate().fadeIn(delay: 200.ms, duration: 800.ms, curve: AppTheme.fluidCurve).slideY(begin: 0.1),
                      
                      const SizedBox(height: 12),
                      
                      Text(
                        'Sign in to continue your interview preparation.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
                        textAlign: TextAlign.left,
                      ).animate().fadeIn(delay: 300.ms, duration: 800.ms, curve: AppTheme.fluidCurve).slideY(begin: 0.1),
                      
                      const SizedBox(height: 48),

                      // Refined Form Fields
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                        decoration: const InputDecoration(
                          labelText: 'Email Address',
                          prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textSecondary),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Email is required';
                          if (!v.contains('@')) return 'Enter a valid email';
                          return null;
                        },
                      ).animate().fadeIn(delay: 400.ms, duration: 800.ms, curve: AppTheme.fluidCurve).slideY(begin: 0.1),
                      
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.textSecondary),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: AppTheme.textSecondary,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Password is required';
                          if (v.length < 6) return 'Password must be at least 6 characters';
                          return null;
                        },
                      ).animate().fadeIn(delay: 450.ms, duration: 800.ms, curve: AppTheme.fluidCurve).slideY(begin: 0.1),
                      
                      const SizedBox(height: 12),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              PageRouteBuilder(
                                pageBuilder: (_, __, ___) => const ForgotPasswordScreen(),
                                transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
                              ),
                            );
                          },
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: 500.ms, duration: 800.ms),

                      const SizedBox(height: 32),

                      // Premium Solid Button
                      SizedBox(
                        height: 60,
                        child: ElevatedButton(
                          onPressed: auth.isLoading ? null : _login,
                          child: auth.isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation(AppTheme.primaryDark)),
                                )
                              : const Text('Sign In'),
                        ),
                      ).animate().fadeIn(delay: 550.ms, duration: 800.ms, curve: AppTheme.fluidCurve).slideY(begin: 0.1),

                      const SizedBox(height: 24),
                      
                      // Divider
                      Row(
                        children: [
                          Expanded(child: Divider(color: AppTheme.borderDark)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text('OR', style: TextStyle(color: AppTheme.textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                          Expanded(child: Divider(color: AppTheme.borderDark)),
                        ],
                      ).animate().fadeIn(delay: 600.ms, duration: 800.ms),

                      const SizedBox(height: 24),

                      // Google Login Mock
                      SizedBox(
                        height: 60,
                        child: OutlinedButton.icon(
                          onPressed: auth.isLoading ? null : () async {
                            final authService = context.read<AuthService>();
                            final loginError = await authService.loginWithGoogle();
                            
                            if (!context.mounted) return;
                            
                            if (loginError != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(loginError), backgroundColor: AppTheme.errorRed),
                              );
                            } else {
                              Navigator.of(context).pushReplacement(
                                PageRouteBuilder(
                                  pageBuilder: (_, __, ___) => const HomeScreen(),
                                  transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
                          label: const Text('Continue with Google'),
                        ),
                      ).animate().fadeIn(delay: 650.ms, duration: 800.ms, curve: AppTheme.fluidCurve).slideY(begin: 0.1),

                      const SizedBox(height: 48),

                      // Register Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Don't have an account? ", style: Theme.of(context).textTheme.bodyMedium),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  pageBuilder: (_, __, ___) => const RegisterScreen(),
                                  transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
                                ),
                              );
                            },
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 700.ms, duration: 800.ms, curve: AppTheme.fluidCurve),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';
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
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Ethereal Orbs
          Positioned(
            top: -150,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accentPurple.withValues(alpha: 0.15),
                boxShadow: [BoxShadow(color: AppTheme.accentPurple.withValues(alpha: 0.15), blurRadius: 100, spreadRadius: 50)],
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
           .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 6.seconds, curve: AppTheme.fluidCurve),
          
          Positioned(
            bottom: -150,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accentBlue.withValues(alpha: 0.15),
                boxShadow: [BoxShadow(color: AppTheme.accentBlue.withValues(alpha: 0.15), blurRadius: 100, spreadRadius: 50)],
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
           .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 5.seconds, curve: AppTheme.fluidCurve),

          // Glassmorphic Noise Overlay
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: IgnorePointer(
                child: Container(color: Colors.transparent),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo / Brand
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.2),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.mic_rounded, size: 36, color: AppTheme.primaryDark),
                      ).animate().fadeIn(duration: 800.ms, curve: AppTheme.fluidCurve).slideY(begin: 0.2),
                      
                      const SizedBox(height: 32),
                      
                      Text(
                        'Welcome to\nRehearsal.',
                        style: Theme.of(context).textTheme.displayMedium,
                      ).animate().fadeIn(delay: 200.ms, duration: 800.ms, curve: AppTheme.fluidCurve).slideY(begin: 0.1),
                      
                      const SizedBox(height: 12),
                      
                      Text(
                        'Practice interviews with AI precision.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
                      ).animate().fadeIn(delay: 300.ms, duration: 800.ms, curve: AppTheme.fluidCurve).slideY(begin: 0.1),
                      
                      const SizedBox(height: 48),

                      // Double Bezel Container for form
                      Container(
                        decoration: AppTheme.doubleBezelOuter(),
                        padding: const EdgeInsets.all(4),
                        child: Container(
                          decoration: AppTheme.doubleBezelInner(),
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                style: const TextStyle(fontWeight: FontWeight.w500),
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textSecondary),
                                  fillColor: Colors.transparent,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Email is required';
                                  if (!v.contains('@')) return 'Enter a valid email';
                                  return null;
                                },
                              ),
                              Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                style: const TextStyle(fontWeight: FontWeight.w500),
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  fillColor: Colors.transparent,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
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
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: 400.ms, duration: 800.ms, curve: AppTheme.fluidCurve).slideY(begin: 0.1),
                      
                      const SizedBox(height: 32),

                      // Login Button (Button-in-Button inspired)
                      SizedBox(
                        width: double.infinity,
                        height: 64,
                        child: ElevatedButton(
                          onPressed: auth.isLoading ? null : _login,
                          child: auth.isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation(AppTheme.primaryDark)),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('Sign In'),
                                    const SizedBox(width: 8),
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryDark.withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.arrow_forward_rounded, size: 14),
                                    ),
                                  ],
                                ),
                        ),
                      ).animate().fadeIn(delay: 500.ms, duration: 800.ms, curve: AppTheme.fluidCurve).slideY(begin: 0.1),

                      const SizedBox(height: 32),

                      // Google Login Mock
                      SizedBox(
                        width: double.infinity,
                        height: 64,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final email = "google_user@test.com";
                            final password = "password123";
                            setState(() {
                              _emailController.text = email;
                              _passwordController.text = password;
                            });
                            
                            final authService = context.read<AuthService>();
                            final loginError = await authService.login(email, password);
                            
                            if (!mounted) return;
                            
                            if (loginError != null) {
                              final regError = await authService.register(email, password);
                              if (!mounted) return;
                              
                              if (regError == null) {
                                Navigator.of(context).pushReplacement(
                                  PageRouteBuilder(
                                    pageBuilder: (_, __, ___) => const HomeScreen(),
                                    transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(regError), backgroundColor: AppTheme.errorRed),
                                );
                              }
                            } else {
                              Navigator.of(context).pushReplacement(
                                PageRouteBuilder(
                                  pageBuilder: (_, __, ___) => const HomeScreen(),
                                  transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.g_mobiledata_rounded, size: 32),
                          label: const Text('Continue with Google'),
                        ),
                      ).animate().fadeIn(delay: 600.ms, duration: 800.ms, curve: AppTheme.fluidCurve).slideY(begin: 0.1),

                      const SizedBox(height: 32),

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
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
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

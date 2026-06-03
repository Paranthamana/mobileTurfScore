import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/colors.dart';
import '../../../../injection_container.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _obscurePassword = ValueNotifier<bool>(true);
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _obscurePassword.dispose();
    super.dispose();
  }

  void _showAppToast(
    BuildContext context, {
    required String message,
    _ToastType type = _ToastType.info,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    final (icon, accent) = switch (type) {
      _ToastType.success => (
        Icons.check_circle_rounded,
        const Color(0xFF2EE59D),
      ),
      _ToastType.error => (Icons.error_rounded, const Color(0xFFFF4D4D)),
      _ToastType.info => (Icons.info_rounded, AppColors.primary),
    };

    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 16.h),
        duration: 1800.ms,
        content: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            gradient: LinearGradient(
              colors: [
                Colors.black.withValues(alpha: 0.92),
                Colors.black.withValues(alpha: 0.82),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(color: accent.withValues(alpha: 0.35), width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 36.r,
                height: 36.r,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: accent, size: 20.r),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 180.ms).slideY(begin: 0.15, end: 0),
      ),
    );
  }

  String? _validateEmail(String? value) {
    final email = (value ?? '').trim();
    if (email.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email)) return 'Enter a valid email';
    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Password is required';
    if (password.length < 8) return 'Password must be at least 8 characters';
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Include 1 uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Include 1 lowercase letter';
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>_\-\\/\[\]=+~`]').hasMatch(password)) {
      return 'Include 1 special character';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else if (state is AuthFailure) {
            _showAppToast(
              context,
              message: state.message,
              type: _ToastType.error,
            );
          }
        },
        child: Scaffold(
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.sports_cricket,
                      size: 64.r,
                      color: AppColors.primary,
                    ).animate().scale(duration: 400.ms).fadeIn(),
                    SizedBox(height: 16.h),
                    Text(
                          'Welcome Back',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineLarge,
                        )
                        .animate()
                        .fadeIn(delay: 200.ms)
                        .slideY(begin: 0.1, end: 0),
                    SizedBox(height: 8.h),
                    Text(
                          'Sign in to continue to TurfScore',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium,
                        )
                        .animate()
                        .fadeIn(delay: 300.ms)
                        .slideY(begin: 0.1, end: 0),
                    SizedBox(height: 48.h),

                    TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                        )
                        .animate()
                        .fadeIn(delay: 400.ms)
                        .slideX(begin: -0.1, end: 0),

                    SizedBox(height: 16.h),

                    ValueListenableBuilder<bool>(
                          valueListenable: _obscurePassword,
                          builder: (context, obscure, _) {
                            return TextFormField(
                              controller: _passwordController,
                              obscureText: obscure,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    obscure
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed:
                                      () => _obscurePassword.value = !obscure,
                                ),
                              ),
                              textInputAction: TextInputAction.done,
                            );
                          },
                        )
                        .animate()
                        .fadeIn(delay: 500.ms)
                        .slideX(begin: -0.1, end: 0),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 600.ms),

                    SizedBox(height: 24.h),

                    BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            final isLoading = state is AuthLoading;
                            return ElevatedButton(
                              onPressed:
                                  isLoading
                                      ? null
                                      : () {
                                        final emailError = _validateEmail(
                                          _emailController.text,
                                        );
                                        if (emailError != null) {
                                          _showAppToast(
                                            context,
                                            message: emailError,
                                            type: _ToastType.error,
                                          );
                                          return;
                                        }

                                        final passwordError = _validatePassword(
                                          _passwordController.text,
                                        );
                                        if (passwordError != null) {
                                          _showAppToast(
                                            context,
                                            message: passwordError,
                                            type: _ToastType.error,
                                          );
                                          return;
                                        }

                                        context.read<AuthBloc>().add(
                                          AuthLoginSubmitted(
                                            email: _emailController.text.trim(),
                                            password: _passwordController.text,
                                          ),
                                        );
                                      },
                              child:
                                  isLoading
                                      ? SizedBox(
                                        width: 18.r,
                                        height: 18.r,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                      : const Text('Login'),
                            );
                          },
                        )
                        .animate()
                        .fadeIn(delay: 700.ms)
                        .scale(begin: const Offset(0.9, 0.9)),

                    SizedBox(height: 16.h),

                    OutlinedButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                              context,
                              '/dashboard',
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: const BorderSide(color: AppColors.primary),
                          ),
                          child: const Text(
                            'Login as Guest',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 800.ms)
                        .scale(begin: const Offset(0.9, 0.9)),

                    SizedBox(height: 24.h),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: theme.textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed:
                              () => Navigator.pushNamed(context, '/signup'),
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 900.ms),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _ToastType { success, error, info }

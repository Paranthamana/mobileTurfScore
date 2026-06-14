import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/brand_backdrop.dart';
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
  final _rememberMe = ValueNotifier<bool>(false);
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _obscurePassword.dispose();
    _rememberMe.dispose();
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
          backgroundColor: AppColors.backgroundLight,
          body: Stack(
            fit: StackFit.expand,
            children: [
              const BrandBackdrop(),
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 28.h),
                    child: Container(
                      constraints: BoxConstraints(maxWidth: 430.w),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.fromLTRB(28.w, 28.h, 28.w, 118.h),
                            decoration: BoxDecoration(
                              gradient: AppColors.brandHeroGradient,
                              borderRadius: BorderRadius.circular(36.r),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.brandInk.withValues(alpha: 0.16),
                                  blurRadius: 28,
                                  offset: const Offset(0, 18),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: 48.r,
                                  height: 48.r,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.16),
                                    borderRadius: BorderRadius.circular(16.r),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.shield_rounded,
                                    color: Colors.white,
                                    size: 24.r,
                                  ),
                                ).animate().scale(duration: 420.ms).fadeIn(),
                                SizedBox(height: 20.h),
                                Text(
                                      'Sign in to your\naccount',
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.headlineLarge?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        height: 1.12,
                                      ),
                                    )
                                    .animate()
                                    .fadeIn(delay: 180.ms)
                                    .slideY(begin: 0.08, end: 0),
                                SizedBox(height: 12.h),
                                Text(
                                      'Enter your email and password to log in and continue live scoring.',
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: Colors.white.withValues(alpha: 0.82),
                                        height: 1.45,
                                      ),
                                    )
                                    .animate()
                                    .fadeIn(delay: 260.ms)
                                    .slideY(begin: 0.08, end: 0),
                              ],
                            ),
                          ),
                          Transform.translate(
                            offset: Offset(0, -86.h),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(22.w),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(30.r),
                                border: Border.all(
                                  color: AppColors.brandField.withValues(alpha: 0.08),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.brandInk.withValues(alpha: 0.08),
                                    blurRadius: 30,
                                    offset: const Offset(0, 16),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  TextFormField(
                                        controller: _emailController,
                                        decoration: InputDecoration(
                                          hintText: 'Enter your email',
                                          prefixIcon: const Icon(Icons.mail_outline_rounded),
                                          filled: true,
                                          fillColor: AppColors.backgroundLight,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(16.r),
                                            borderSide: BorderSide.none,
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(16.r),
                                            borderSide: BorderSide(
                                              color: AppColors.brandInk.withValues(alpha: 0.06),
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(16.r),
                                            borderSide: const BorderSide(
                                              color: AppColors.brandField,
                                              width: 1.4,
                                            ),
                                          ),
                                        ),
                                        keyboardType: TextInputType.emailAddress,
                                        textInputAction: TextInputAction.next,
                                      )
                                      .animate()
                                      .fadeIn(delay: 340.ms)
                                      .slideX(begin: -0.08, end: 0),
                                  SizedBox(height: 14.h),
                                  ValueListenableBuilder<bool>(
                                        valueListenable: _obscurePassword,
                                        builder: (context, obscure, _) {
                                          return TextFormField(
                                            controller: _passwordController,
                                            obscureText: obscure,
                                            decoration: InputDecoration(
                                              hintText: 'Enter your password',
                                              prefixIcon: const Icon(Icons.lock_outline_rounded),
                                              filled: true,
                                              fillColor: AppColors.backgroundLight,
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(16.r),
                                                borderSide: BorderSide.none,
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(16.r),
                                                borderSide: BorderSide(
                                                  color: AppColors.brandInk.withValues(alpha: 0.06),
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(16.r),
                                                borderSide: const BorderSide(
                                                  color: AppColors.brandField,
                                                  width: 1.4,
                                                ),
                                              ),
                                              suffixIcon: IconButton(
                                                icon: Icon(
                                                  obscure
                                                      ? Icons.visibility_off_outlined
                                                      : Icons.visibility_outlined,
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
                                      .fadeIn(delay: 420.ms)
                                      .slideX(begin: -0.08, end: 0),
                                  SizedBox(height: 14.h),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ValueListenableBuilder<bool>(
                                          valueListenable: _rememberMe,
                                          builder: (context, rememberMe, _) {
                                            return InkWell(
                                              borderRadius: BorderRadius.circular(12.r),
                                              onTap: () => _rememberMe.value = !rememberMe,
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(vertical: 4.h),
                                                child: Row(
                                                  children: [
                                                    Checkbox(
                                                      value: rememberMe,
                                                      activeColor: AppColors.brandField,
                                                      visualDensity: VisualDensity.compact,
                                                      onChanged:
                                                          (value) =>
                                                              _rememberMe.value = value ?? false,
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        'Remember me',
                                                        style: theme.textTheme.bodySmall?.copyWith(
                                                          color: AppColors.textSecondaryLight,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {},
                                        child: const Text(
                                          'Forgot Password?',
                                          style: TextStyle(
                                            color: AppColors.brandField,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ).animate().fadeIn(delay: 500.ms),
                                  SizedBox(height: 12.h),
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
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.brandField,
                                              foregroundColor: Colors.white,
                                              elevation: 0,
                                              padding: EdgeInsets.symmetric(vertical: 17.h),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(16.r),
                                              ),
                                            ),
                                            child:
                                                isLoading
                                                    ? SizedBox(
                                                      width: 20.r,
                                                      height: 20.r,
                                                      child: const CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: Colors.white,
                                                      ),
                                                    )
                                                    : const Text('Log In'),
                                          );
                                        },
                                      )
                                      .animate()
                                      .fadeIn(delay: 580.ms)
                                      .scale(begin: const Offset(0.96, 0.96)),
                                  SizedBox(height: 14.h),
                                  OutlinedButton(
                                    onPressed: () {
                                      Navigator.pushReplacementNamed(
                                        context,
                                        '/dashboard',
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(vertical: 15.h),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16.r),
                                      ),
                                      side: BorderSide(
                                        color: AppColors.brandInk.withValues(alpha: 0.14),
                                      ),
                                      foregroundColor: AppColors.brandInk,
                                    ),
                                    child: const Text(
                                      'Login as Guest',
                                      style: TextStyle(fontWeight: FontWeight.w700),
                                    ),
                                  ).animate().fadeIn(delay: 660.ms),
                                  SizedBox(height: 18.h),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Don't have an account? ",
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: AppColors.textSecondaryLight,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pushNamed(context, '/signup'),
                                        child: const Text(
                                          'Sign Up',
                                          style: TextStyle(
                                            color: AppColors.brandField,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ).animate().fadeIn(delay: 740.ms),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 10.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _ToastType { success, error, info }

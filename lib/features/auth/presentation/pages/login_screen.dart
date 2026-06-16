import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/colors.dart';
import '../../../../injection_container.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_card_shell.dart';

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
      _ToastType.success => (Icons.check_circle_rounded, AppColors.success),
      _ToastType.error => (Icons.error_rounded, AppColors.error),
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

  InputDecoration _fieldDecoration(
    BuildContext context, {
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    final theme = Theme.of(context);

    return InputDecoration(
      hintText: hintText,
      hintStyle: theme.textTheme.bodyMedium?.copyWith(
        color: AppColors.textSecondaryLight.withValues(alpha: 0.92),
        fontWeight: FontWeight.w600,
      ),
      prefixIcon: Icon(prefixIcon, size: 20.r),
      prefixIconColor: AppColors.brandField,
      suffixIcon: suffixIcon,
      suffixIconColor: AppColors.textSecondaryLight,
      filled: true,
      fillColor: theme.colorScheme.surface,
      contentPadding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 17.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: BorderSide(color: AppColors.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: BorderSide(color: AppColors.brandField, width: 1.6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        child: Builder(
          builder: (context) {
            final theme = Theme.of(context);

            return AuthCardShell(
              heroIcon: Icons.shield_rounded,
              heroBadge: 'LOGIN',
              title: 'Welcome back',
              subtitle: 'Sign in to continue.',
              panelTitle: 'Sign in',
              panelSubtitle:
                  'Use your email and password to access your account.',
              footerChild: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 2.w,
                children: [
                  Text(
                    "Don't have an account?",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/signup'),
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 8.h,
                      ),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              formChild: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                        controller: _emailController,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppColors.textLight,
                          fontWeight: FontWeight.w600,
                        ),
                        cursorColor: AppColors.brandField,
                        decoration: _fieldDecoration(
                          context,
                          hintText: 'Enter your email',
                          prefixIcon: Icons.mail_outline_rounded,
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
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: AppColors.textLight,
                              fontWeight: FontWeight.w600,
                            ),
                            cursorColor: AppColors.brandField,
                            decoration: _fieldDecoration(
                              context,
                              hintText: 'Enter your password',
                              prefixIcon: Icons.lock_outline_rounded,
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
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final stackActions = constraints.maxWidth < 360.w;
                      final rememberMeToggle = ValueListenableBuilder<bool>(
                        valueListenable: _rememberMe,
                        builder: (context, rememberMe, _) {
                          return InkWell(
                            borderRadius: BorderRadius.circular(12.r),
                            onTap: () => _rememberMe.value = !rememberMe,
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 4.h),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Checkbox(
                                    value: rememberMe,
                                    activeColor: AppColors.brandField,
                                    checkColor: Colors.white,
                                    visualDensity: VisualDensity.compact,
                                    onChanged:
                                        (value) =>
                                            _rememberMe.value = value ?? false,
                                  ),
                                  Flexible(
                                    child: Text(
                                      'Remember me',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
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
                      );

                      final forgotPasswordButton = TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 8.h,
                          ),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Forgot Password?',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.brandField,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      );

                      if (stackActions) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            rememberMeToggle,
                            Align(
                              alignment: Alignment.centerRight,
                              child: forgotPasswordButton,
                            ),
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Expanded(child: rememberMeToggle),
                          SizedBox(width: 8.w),
                          Flexible(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: forgotPasswordButton,
                            ),
                          ),
                        ],
                      );
                    },
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
                      Navigator.pushReplacementNamed(context, '/dashboard');
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      side: BorderSide(color: AppColors.outline),
                      foregroundColor: AppColors.brandInk,
                    ),
                    child: const Text(
                      'Login as Guest',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ).animate().fadeIn(delay: 660.ms),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

enum _ToastType { success, error, info }

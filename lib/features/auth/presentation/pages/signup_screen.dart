import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/colors.dart';
import '../../../../injection_container.dart';
import '../bloc/signup_bloc.dart';
import '../bloc/signup_event.dart';
import '../bloc/signup_state.dart';
import '../widgets/auth_card_shell.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _obscurePassword = ValueNotifier<bool>(true);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _obscurePassword.dispose();
    super.dispose();
  }

  void _toast(String message, {bool isError = false}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    final accent = isError ? AppColors.error : AppColors.success;
    final icon = isError ? Icons.error_rounded : Icons.check_circle_rounded;

    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 16.h),
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

  String? _validateName(String? value) {
    final name = (value ?? '').trim();
    if (name.isEmpty) return 'Name is required';
    if (name.length < 2) return 'Enter a valid name';
    return null;
  }

  String? _validateEmail(String? value) {
    final email = (value ?? '').trim();
    if (email.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email)) return 'Enter a valid email';
    return null;
  }

  String? validatePassword(String? value) {
    final password = value ?? '';

    if (password.isEmpty) {
      return 'Password is required';
    }

    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }

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

  String? _firstValidationMessage() {
    return _validateName(_nameController.text) ??
        _validateEmail(_emailController.text) ??
        validatePassword(_passwordController.text);
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
      create: (_) => sl<SignupBloc>(),
      child: BlocListener<SignupBloc, SignupState>(
        listener: (context, state) {
          if (state is SignupFailure) {
            _toast(state.message, isError: true);
          } else if (state is SignupSuccess) {
            _toast(state.message);
            Navigator.pop(context); // back to login
          }
        },
        child: Builder(
          builder: (context) {
            final theme = Theme.of(context);

            return AuthCardShell(
              heroIcon: Icons.person_add_alt_1_rounded,
              heroBadge: 'NEW SCORER SETUP',
              title: 'Create your\naccount',
              subtitle:
                  'Set up your scorer profile and get ready for your next live match session.',
              panelTitle: 'Build your scorer profile',
              panelSubtitle:
                  'Create your account once and keep every match, team, and session in one organized desk.',
              overlayAction: IconButton(
                onPressed: () => Navigator.pop(context),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.14),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.arrow_back_rounded),
              ).animate().fadeIn(duration: 260.ms),
              formChild: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                          controller: _nameController,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: AppColors.textLight,
                            fontWeight: FontWeight.w600,
                          ),
                          cursorColor: AppColors.brandField,
                          decoration: _fieldDecoration(
                            context,
                            hintText: 'Enter your full name',
                            prefixIcon: Icons.person_outline_rounded,
                          ),
                          validator: _validateName,
                          textInputAction: TextInputAction.next,
                        )
                        .animate()
                        .fadeIn(delay: 340.ms)
                        .slideX(begin: -0.08, end: 0),
                    SizedBox(height: 14.h),
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
                          validator: _validateEmail,
                          textInputAction: TextInputAction.next,
                        )
                        .animate()
                        .fadeIn(delay: 420.ms)
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
                                hintText: 'Create your password',
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
                              validator: validatePassword,
                              textInputAction: TextInputAction.done,
                            );
                          },
                        )
                        .animate()
                        .fadeIn(delay: 500.ms)
                        .slideX(begin: -0.08, end: 0),
                    SizedBox(height: 22.h),
                    BlocBuilder<SignupBloc, SignupState>(
                          builder: (context, state) {
                            final isLoading = state is SignupLoading;
                            return ElevatedButton(
                              onPressed:
                                  isLoading
                                      ? null
                                      : () {
                                        final msg = _firstValidationMessage();
                                        if (msg != null) {
                                          _toast(msg, isError: true);
                                        }
                                        final ok =
                                            _formKey.currentState?.validate() ??
                                            false;
                                        if (!ok) return;
                                        context.read<SignupBloc>().add(
                                          SignupSubmitted(
                                            name: _nameController.text.trim(),
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
                                      : const Text('Create Account'),
                            );
                          },
                        )
                        .animate()
                        .fadeIn(delay: 580.ms)
                        .scale(begin: const Offset(0.96, 0.96)),
                    SizedBox(height: 18.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Log In',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 660.ms),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

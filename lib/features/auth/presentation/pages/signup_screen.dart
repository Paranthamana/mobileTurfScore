import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/colors.dart';
import '../../../../injection_container.dart';
import '../bloc/signup_bloc.dart';
import '../bloc/signup_event.dart';
import '../bloc/signup_state.dart';

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

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (_) => sl<SignupBloc>(),
      child: BlocListener<SignupBloc, SignupState>(
        listener: (context, state) {
          if (state is SignupFailure) {
            _toast(state.message);
          } else if (state is SignupSuccess) {
            _toast(state.message);
            Navigator.pop(context); // back to login
          }
        },
        child: Scaffold(
          appBar: AppBar(title: const Text('Sign Up'), centerTitle: true),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.person_add_alt_1,
                      size: 64.r,
                      color: AppColors.primary,
                    ).animate().scale(duration: 400.ms).fadeIn(),
                    SizedBox(height: 16.h),
                    Text(
                          'Create Account',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineLarge,
                        )
                        .animate()
                        .fadeIn(delay: 200.ms)
                        .slideY(begin: 0.1, end: 0),
                    SizedBox(height: 8.h),
                    Text(
                          'Sign up to start using TurfScore',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium,
                        )
                        .animate()
                        .fadeIn(delay: 300.ms)
                        .slideY(begin: 0.1, end: 0),
                    SizedBox(height: 32.h),

                    TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: _validateName,
                          textInputAction: TextInputAction.next,
                        )
                        .animate()
                        .fadeIn(delay: 400.ms)
                        .slideX(begin: -0.1, end: 0),

                    SizedBox(height: 16.h),

                    TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: _validateEmail,
                          textInputAction: TextInputAction.next,
                        )
                        .animate()
                        .fadeIn(delay: 500.ms)
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
                              validator: validatePassword,
                              textInputAction: TextInputAction.done,
                            );
                          },
                        )
                        .animate()
                        .fadeIn(delay: 600.ms)
                        .slideX(begin: -0.1, end: 0),

                    SizedBox(height: 24.h),

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
                                          _toast(msg);
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
                              child:
                                  isLoading
                                      ? SizedBox(
                                        width: 18.r,
                                        height: 18.r,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                      : const Text('Sign Up'),
                            );
                          },
                        )
                        .animate()
                        .fadeIn(delay: 700.ms)
                        .scale(begin: const Offset(0.9, 0.9)),

                    SizedBox(height: 16.h),

                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Back to Login'),
                    ).animate().fadeIn(delay: 800.ms),
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

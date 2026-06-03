import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/colors.dart';
import '../../../../injection_container.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _navigated = false;
  late final AuthBloc _authBloc;

  @override
  void initState() {
    super.initState();
    _authBloc = sl<AuthBloc>()..add(const AuthAppStarted());
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      if (_navigated) return;
      _navigated = true;
      final state = _authBloc.state;
      if (state is AuthAuthenticated) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authBloc,
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (!mounted || _navigated) return;
          if (state is AuthAuthenticated) {
            _navigated = true;
            Navigator.pushReplacementNamed(context, '/dashboard');
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.primary,
          body: Container(
            decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sports_cricket, size: 80.r, color: Colors.white)
                      .animate()
                      .scale(duration: 600.ms, curve: Curves.easeOutBack)
                      .fadeIn(duration: 600.ms),
                  SizedBox(height: 16.h),
                  Text(
                        'TurfScore',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                      )
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 600.ms)
                      .slideY(begin: 0.2, end: 0, delay: 400.ms, duration: 600.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

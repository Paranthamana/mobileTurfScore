import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/widgets/brand_backdrop.dart';
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
    Future.delayed(const Duration(seconds: 15), () {
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
    final theme = Theme.of(context);

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
          backgroundColor: AppColors.backgroundLight,
          body: Stack(
            fit: StackFit.expand,
            children: [
              const BrandBackdrop(),
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 24.h),
                  child: Column(
                    children: [
                      Expanded(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned(
                              top: 70.h,
                              left: 0,
                              child: _SplashStatChip(
                                    icon: Icons.auto_graph_rounded,
                                    title: 'Live Overs',
                                    value: 'Real-time',
                                  )
                                  .animate(
                                    onPlay:
                                        (controller) =>
                                            controller.repeat(reverse: true),
                                  )
                                  .moveY(
                                    begin: 0,
                                    end: -10,
                                    duration: 2000.ms,
                                    curve: Curves.easeInOut,
                                  ),
                            ),
                            Positioned(
                              top: 132.h,
                              right: 0,
                              child: _SplashStatChip(
                                    icon: Icons.emoji_events_rounded,
                                    title: 'Results',
                                    value: 'Instant',
                                    alignEnd: true,
                                  )
                                  .animate(
                                    onPlay:
                                        (controller) =>
                                            controller.repeat(reverse: true),
                                  )
                                  .moveY(
                                    begin: -6,
                                    end: 8,
                                    duration: 2200.ms,
                                    curve: Curves.easeInOut,
                                  ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 250.w,
                                  height: 250.w,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                            width: 240.r,
                                            height: 240.r,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: AppColors.brandField
                                                  .withValues(alpha: 0.08),
                                            ),
                                          )
                                          .animate(
                                            onPlay:
                                                (controller) =>
                                                    controller.repeat(),
                                          )
                                          .scaleXY(
                                            begin: 0.92,
                                            end: 1.04,
                                            duration: 2200.ms,
                                            curve: Curves.easeInOut,
                                          )
                                          .fade(
                                            begin: 0.55,
                                            end: 0.9,
                                            duration: 2200.ms,
                                            curve: Curves.easeInOut,
                                          ),
                                      Container(
                                        width: 190.r,
                                        height: 190.r,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.brandInk.withValues(
                                            alpha: 0.07,
                                          ),
                                        ),
                                      ).animate().fadeIn(delay: 180.ms),
                                      Container(
                                            width: 124.r,
                                            height: 124.r,
                                            decoration: BoxDecoration(
                                              gradient:
                                                  AppColors.brandHeroGradient,
                                              borderRadius:
                                                  BorderRadius.circular(38.r),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: AppColors.brandField
                                                      .withValues(alpha: 0.24),
                                                  blurRadius: 28,
                                                  offset: const Offset(0, 16),
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              Icons.sports_cricket_rounded,
                                              size: 60.r,
                                              color: Colors.white,
                                            ),
                                          )
                                          .animate()
                                          .scale(
                                            duration: 650.ms,
                                            curve: Curves.easeOutBack,
                                          )
                                          .fadeIn(duration: 650.ms),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                      'TurfScore',
                                      style: theme.textTheme.displaySmall
                                          ?.copyWith(
                                            color: AppColors.brandInk,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 1,
                                          ),
                                    )
                                    .animate()
                                    .fadeIn(delay: 320.ms, duration: 550.ms)
                                    .slideY(
                                      begin: 0.18,
                                      end: 0,
                                      delay: 320.ms,
                                      duration: 550.ms,
                                    ),
                                SizedBox(height: 10.h),
                                ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: 310.w),
                                  child: Text(
                                    'Fast live scoring, cleaner scorecards, and completed match results in one polished match-day desk.',
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: AppColors.textSecondaryLight,
                                      height: 1.5,
                                    ),
                                  ).animate().fadeIn(
                                    delay: 450.ms,
                                    duration: 520.ms,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
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

class _SplashStatChip extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool alignEnd;

  const _SplashStatChip({
    required this.icon,
    required this.title,
    required this.value,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 132.w,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: AppColors.brandField.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandInk.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            width: 34.r,
            height: 34.r,
            decoration: BoxDecoration(
              gradient: AppColors.brandHeroGradient,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: Colors.white, size: 18.r),
          ),
          SizedBox(height: 10.h),
          Text(
            title,
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.textSecondaryLight,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.brandInk,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/brand_backdrop.dart';

class AuthCardShell extends StatelessWidget {
  final IconData heroIcon;
  final String title;
  final String subtitle;
  final String heroBadge;
  final String panelTitle;
  final String panelSubtitle;
  final Widget formChild;
  final Widget? footerChild;
  final Widget? overlayAction;

  const AuthCardShell({
    super.key,
    required this.heroIcon,
    required this.title,
    required this.subtitle,
    required this.heroBadge,
    required this.panelTitle,
    required this.panelSubtitle,
    required this.formChild,
    this.footerChild,
    this.overlayAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewInsets = MediaQuery.viewInsetsOf(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const BrandBackdrop(),
          AnimatedPadding(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.only(bottom: viewInsets.bottom),
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final keyboardOpen = viewInsets.bottom > 0;
                  final wideHero = constraints.maxWidth >= 390;
                  final tightHero =
                      !keyboardOpen && constraints.maxHeight < 700;
                  final compactHero =
                      keyboardOpen || constraints.maxHeight < 760;
                  final showFooter = footerChild != null && !keyboardOpen;
                  final showHeroSubtitle = !keyboardOpen;
                  final showFeatureChips =
                      !keyboardOpen && constraints.maxHeight >= 820 && wideHero;
                  final heroTopPadding =
                      keyboardOpen
                          ? 12.h
                          : tightHero
                          ? 12.h
                          : compactHero
                          ? 18.h
                          : 20.h;
                  final heroBottomPadding =
                      showFeatureChips
                          ? 92.h
                          : keyboardOpen
                          ? 18.h
                          : tightHero
                          ? 28.h
                          : compactHero
                          ? 42.h
                          : 56.h;
                  final heroIconBoxSize =
                      keyboardOpen
                          ? 48.r
                          : tightHero
                          ? 54.r
                          : compactHero
                          ? 60.r
                          : 72.r;
                  final heroIconSize =
                      keyboardOpen
                          ? 22.r
                          : tightHero
                          ? 26.r
                          : compactHero
                          ? 28.r
                          : 32.r;
                  final heroIconRadius =
                      keyboardOpen
                          ? 16.r
                          : tightHero
                          ? 18.r
                          : compactHero
                          ? 20.r
                          : 24.r;
                  final heroTitleSpacing =
                      keyboardOpen
                          ? 10.h
                          : tightHero
                          ? 12.h
                          : compactHero
                          ? 16.h
                          : 22.h;
                  final heroSubtitleSpacing =
                      tightHero
                          ? 8.h
                          : compactHero
                          ? 10.h
                          : 12.h;
                  final heroTitleStyle = (keyboardOpen
                          ? theme.textTheme.titleLarge
                          : tightHero
                          ? theme.textTheme.headlineSmall
                          : compactHero
                          ? theme.textTheme.headlineMedium
                          : theme.textTheme.headlineLarge)
                      ?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        height:
                            tightHero
                                ? 1.08
                                : compactHero
                                ? 1.12
                                : 1.08,
                      );
                  final heroSubtitleStyle = (compactHero
                          ? theme.textTheme.bodySmall
                          : theme.textTheme.bodyMedium)
                      ?.copyWith(
                        color: Colors.white.withValues(alpha: 0.82),
                        height:
                            tightHero
                                ? 1.3
                                : compactHero
                                ? 1.38
                                : 1.45,
                      );
                  final heroHeight =
                      (constraints.maxHeight *
                              (keyboardOpen
                                  ? 0.24
                                  : tightHero
                                  ? 0.44
                                  : compactHero
                                  ? 0.40
                                  : 0.46))
                          .clamp(
                            keyboardOpen
                                ? 168.h
                                : tightHero
                                ? 290.h
                                : 250.h,
                            keyboardOpen
                                ? 220.h
                                : compactHero
                                ? 340.h
                                : 420.h,
                          )
                          .toDouble();
                  final panelOverlap =
                      keyboardOpen
                          ? 28.h
                          : tightHero
                          ? 42.h
                          : compactHero
                          ? 48.h
                          : 66.h;
                  final contentWidth =
                      constraints.maxWidth > 620 ? 560.0 : constraints.maxWidth;

                  return Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: contentWidth,
                      height: constraints.maxHeight,
                      child: Stack(
                        children: [
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            height: heroHeight,
                            child: Container(
                              padding: EdgeInsets.fromLTRB(
                                24.w,
                                heroTopPadding,
                                24.w,
                                heroBottomPadding,
                              ),
                              decoration: BoxDecoration(
                                gradient: AppColors.brandHeroGradient,
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(42.r),
                                  bottomRight: Radius.circular(42.r),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.brandInk.withValues(
                                      alpha: 0.18,
                                    ),
                                    blurRadius: 30,
                                    offset: const Offset(0, 18),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  if (overlayAction != null)
                                    Positioned(
                                      top: 0,
                                      left: 0,
                                      child: overlayAction!,
                                    ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: compactHero ? 12.w : 14.w,
                                        vertical: compactHero ? 7.h : 8.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.14,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          999.r,
                                        ),
                                        border: Border.all(
                                          color: Colors.white.withValues(
                                            alpha: 0.16,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        heroBadge,
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing:
                                                  compactHero ? 0.9 : 1.1,
                                            ),
                                      ),
                                    ).animate().fadeIn(duration: 300.ms),
                                  ),
                                  Center(
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth: wideHero ? 320.w : 280.w,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                                width: heroIconBoxSize,
                                                height: heroIconBoxSize,
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.14),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        heroIconRadius,
                                                      ),
                                                  border: Border.all(
                                                    color: Colors.white
                                                        .withValues(
                                                          alpha: 0.18,
                                                        ),
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.white
                                                          .withValues(
                                                            alpha: 0.08,
                                                          ),
                                                      blurRadius: 26,
                                                      spreadRadius: 4,
                                                    ),
                                                  ],
                                                ),
                                                child: Icon(
                                                  heroIcon,
                                                  color: Colors.white,
                                                  size: heroIconSize,
                                                ),
                                              )
                                              .animate()
                                              .scale(duration: 420.ms)
                                              .fadeIn(),
                                          SizedBox(height: heroTitleSpacing),
                                          Text(
                                                title,
                                                textAlign: TextAlign.center,
                                                style: heroTitleStyle,
                                              )
                                              .animate()
                                              .fadeIn(delay: 180.ms)
                                              .slideY(begin: 0.08, end: 0),
                                          if (showHeroSubtitle) ...[
                                            SizedBox(
                                              height: heroSubtitleSpacing,
                                            ),
                                            Text(
                                                  subtitle,
                                                  textAlign: TextAlign.center,
                                                  style: heroSubtitleStyle,
                                                )
                                                .animate()
                                                .fadeIn(delay: 260.ms)
                                                .slideY(begin: 0.08, end: 0),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: heroHeight - panelOverlap,
                            left: 16.w,
                            right: 16.w,
                            bottom: 0,
                            child: Container(
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface,
                                    borderRadius: BorderRadius.circular(34.r),
                                    border: Border.all(
                                      color: AppColors.brandField.withValues(
                                        alpha: 0.08,
                                      ),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.brandInk.withValues(
                                          alpha: 0.09,
                                        ),
                                        blurRadius: 34,
                                        offset: const Offset(0, 18),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      SizedBox(height: 12.h),
                                      Container(
                                        width: 52.w,
                                        height: 5.h,
                                        decoration: BoxDecoration(
                                          color: AppColors.outline,
                                          borderRadius: BorderRadius.circular(
                                            999.r,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(
                                          20.w,
                                          14.h,
                                          20.w,
                                          8.h,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 12.w,
                                                vertical: 7.h,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppColors.accent,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      999.r,
                                                    ),
                                              ),
                                              child: Text(
                                                'Turf Score Center',
                                                style: theme
                                                    .textTheme
                                                    .labelSmall
                                                    ?.copyWith(
                                                      color:
                                                          AppColors.brandField,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                    ),
                                              ),
                                            ),
                                            SizedBox(height: 12.h),
                                            Text(
                                              panelTitle,
                                              style: theme.textTheme.titleLarge
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                            ),
                                            SizedBox(height: 4.h),
                                            Text(
                                              panelSubtitle,
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                    color:
                                                        AppColors
                                                            .textSecondaryLight,
                                                    height: 1.4,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: SingleChildScrollView(
                                          physics:
                                              const BouncingScrollPhysics(),
                                          padding: EdgeInsets.fromLTRB(
                                            22.w,
                                            0,
                                            22.w,
                                            showFooter ? 10.h : 22.h,
                                          ),
                                          child: formChild,
                                        ),
                                      ),
                                      if (showFooter)
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(
                                            22.w,
                                            0,
                                            22.w,
                                            18.h,
                                          ),
                                          child: footerChild!,
                                        ),
                                    ],
                                  ),
                                )
                                .animate()
                                .fadeIn(duration: 340.ms)
                                .slideY(begin: 0.08, end: 0, duration: 340.ms),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

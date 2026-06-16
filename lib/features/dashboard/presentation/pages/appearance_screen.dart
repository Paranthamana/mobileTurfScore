import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_theme_controller.dart';
import '../../../../core/theme/colors.dart';
import '../../../../injection_container.dart';

class AppearanceScreen extends StatelessWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = sl<AppThemeController>();

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final palette = controller.activePalette;
        final theme = Theme.of(context);

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: Stack(
            children: [
              Container(
                height: 240.h,
                decoration: BoxDecoration(gradient: palette.brandHeroGradient),
              ),
              SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(8.w, 8.h, 20.w, 0),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            color: Colors.white,
                            icon: const Icon(Icons.arrow_back_ios_new_rounded),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Choose Theme',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 16.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(top: 18.h),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(34.r),
                            topRight: Radius.circular(34.r),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.brandInk.withValues(alpha: 0.08),
                              blurRadius: 28,
                              offset: const Offset(0, -8),
                            ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(18.w, 24.h, 18.w, 28.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 44.r,
                                    height: 44.r,
                                    decoration: BoxDecoration(
                                      color: palette.accent,
                                      borderRadius: BorderRadius.circular(16.r),
                                    ),
                                    child: Icon(
                                      Icons.auto_awesome_rounded,
                                      color: palette.brandField,
                                      size: 22.r,
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Personalize Your Experience',
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 13.5.sp,
                                              ),
                                        ),
                                        SizedBox(height: 4.h),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.tune_rounded,
                                              size: 12.r,
                                              color:
                                                  AppColors.textSecondaryLight,
                                            ),
                                            SizedBox(width: 6.w),
                                            Expanded(
                                              child: Text(
                                                'Choose a theme that suits your style.',
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(
                                                      color:
                                                          AppColors
                                                              .textSecondaryLight,
                                                      fontSize: 10.8.sp,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 22.h),
                              _ThemeModeSelector(
                                selectedMode: controller.themeMode,
                                onChanged: controller.setThemeMode,
                              ),
                              SizedBox(height: 22.h),
                              for (final preview in AppColors.availablePalettes)
                                Padding(
                                  padding: EdgeInsets.only(bottom: 18.h),
                                  child: _ThemePreviewCard(
                                    palette: preview,
                                    isSelected:
                                        preview.preset ==
                                        controller.themePreset,
                                    onTap:
                                        () => controller.setThemePreset(
                                          preview.preset,
                                        ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ThemeModeSelector extends StatelessWidget {
  final ThemeMode selectedMode;
  final ValueChanged<ThemeMode> onChanged;

  const _ThemeModeSelector({
    required this.selectedMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final options = [
      _ThemeModeOption(
        mode: ThemeMode.light,
        label: 'Light',
        icon: Icons.wb_sunny_outlined,
      ),
      _ThemeModeOption(
        mode: ThemeMode.dark,
        label: 'Dark',
        icon: Icons.dark_mode_outlined,
      ),
      _ThemeModeOption(
        mode: ThemeMode.system,
        label: 'System',
        icon: Icons.settings_suggest_outlined,
      ),
    ];

    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: Row(
        children:
            options
                .map(
                  (option) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2.w),
                      child: _ModeChip(
                        option: option,
                        isSelected: selectedMode == option.mode,
                        onTap: () => onChanged(option.mode),
                      ),
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final _ThemeModeOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeChip({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18.r),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(18.r),
            boxShadow:
                isSelected
                    ? [
                      BoxShadow(
                        color: AppColors.brandInk.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                    : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                option.icon,
                size: 16.r,
                color:
                    isSelected
                        ? AppColors.brandField
                        : AppColors.textSecondaryLight,
              ),
              SizedBox(width: 8.w),
              Text(
                option.label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color:
                      isSelected
                          ? AppColors.brandField
                          : AppColors.textSecondaryLight,
                  fontWeight: FontWeight.w700,
                  fontSize: 11.sp,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemePreviewCard extends StatelessWidget {
  final AppThemePalette palette;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemePreviewCard({
    required this.palette,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(30.r),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(30.r),
            border: Border.all(
              color:
                  isSelected
                      ? palette.brandField
                      : AppColors.outline.withValues(alpha: 0.7),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    isSelected
                        ? palette.brandField.withValues(alpha: 0.16)
                        : AppColors.brandInk.withValues(alpha: 0.06),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30.r),
            child: Column(
              children: [
                Container(
                  height: 118.h,
                  width: double.infinity,
                  padding: EdgeInsets.all(18.r),
                  decoration: BoxDecoration(
                    gradient: palette.brandHeroGradient,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 12.r,
                            height: 12.r,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.55),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Container(
                            width: 66.w,
                            height: 12.h,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.58),
                              borderRadius: BorderRadius.circular(999.r),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            width: 12.r,
                            height: 12.r,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.38),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 18.h),
                      Container(
                        width: 96.w,
                        height: 10.h,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.28),
                          borderRadius: BorderRadius.circular(999.r),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Container(
                            width: 96.w,
                            height: 10.h,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.32),
                              borderRadius: BorderRadius.circular(999.r),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Container(
                            width: 64.w,
                            height: 10.h,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(999.r),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            width: 54.w,
                            height: 26.h,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(999.r),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 18.h),
                  child: Row(
                    children: [
                      ...palette.swatches.map(
                        (color) => Container(
                          width: 22.r,
                          height: 22.r,
                          margin: EdgeInsets.only(right: 8.w),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: color.withValues(alpha: 0.22),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              palette.label,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontSize: 14.5.sp,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              palette.description,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondaryLight,
                                fontSize: 10.8.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        width: 24.r,
                        height: 24.r,
                        decoration: BoxDecoration(
                          color: isSelected ? palette.brandField : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                isSelected
                                    ? palette.brandField
                                    : AppColors.outline,
                            width: 1.5,
                          ),
                          boxShadow:
                              isSelected
                                  ? [
                                    BoxShadow(
                                      color: palette.brandField.withValues(
                                        alpha: 0.22,
                                      ),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                  : null,
                        ),
                        child:
                            isSelected
                                ? Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 14.r,
                                )
                                : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeModeOption {
  final ThemeMode mode;
  final String label;
  final IconData icon;

  const _ThemeModeOption({
    required this.mode,
    required this.label,
    required this.icon,
  });
}

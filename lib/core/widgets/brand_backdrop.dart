import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/colors.dart';

class BrandBackdrop extends StatelessWidget {
  const BrandBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(gradient: AppColors.surfaceGlowGradient),
      child: Stack(
        children: [
          Positioned(
            top: -90.h,
            left: -30.w,
            child: Container(
              width: 270.w,
              height: 270.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.22),
                    AppColors.primary.withValues(alpha: 0.02),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 110.h,
            right: -52.w,
            child: Container(
              width: 220.w,
              height: 220.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.info.withValues(alpha: 0.14),
                    AppColors.info.withValues(alpha: 0.01),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 110.h,
            left: 18.w,
            child: Container(
              width: 140.w,
              height: 140.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.gold.withValues(alpha: 0.18),
                    AppColors.gold.withValues(alpha: 0.01),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 32.h,
            right: 22.w,
            child: Transform.rotate(
              angle: -0.28,
              child: Container(
                width: 94.w,
                height: 94.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28.r),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.82),
                      AppColors.accent.withValues(alpha: 0.52),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.55),
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

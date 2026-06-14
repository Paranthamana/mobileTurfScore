import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/colors.dart';

class BrandBackdrop extends StatelessWidget {
  const BrandBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.backgroundLight,
            AppColors.backgroundLight,
            AppColors.brandMint,
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -70.h,
            left: -20.w,
            child: Container(
              width: 240.w,
              height: 240.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.brandField.withValues(alpha: 0.12),
              ),
            ),
          ),
          Positioned(
            top: 140.h,
            right: -40.w,
            child: Container(
              width: 190.w,
              height: 190.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.brandInk.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            bottom: 130.h,
            left: 30.w,
            child: Container(
              width: 110.w,
              height: 110.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF22C55E).withValues(alpha: 0.08),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

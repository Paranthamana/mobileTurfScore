import 'package:flutter/material.dart';

class AppColors {
  static const Color brandInk = Color(0xFF0F172A);
  static const Color brandField = Color(0xFF166534);
  static const Color brandMint = Color(0xFFF0FFF6);

  // Brand Colors
  static const Color primary = Color(0xFF00C853); // Premium Green
  static const Color primaryDark = Color(0xFF009624);
  static const Color primaryLight = Color(0xFF5EFB83);
  
  static const Color accent = Color(0xFFE2F1E5);
  
  // Background Colors
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color backgroundDark = Color(0xFF121212);
  
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF1E1E1E);
  
  // Text Colors
  static const Color textLight = Color(0xFF212529);
  static const Color textDark = Color(0xFFF8F9FA);
  static const Color textSecondaryLight = Color(0xFF6C757D);
  static const Color textSecondaryDark = Color(0xFFAAAAAA);
  
  // Status Colors
  static const Color success = Color(0xFF00C853);
  static const Color error = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFFFA000);
  static const Color info = Color(0xFF1976D2);
  
  // Custom Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00C853), Color(0xFF009624)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF2C2C2C), Color(0xFF1A1A1A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient brandHeroGradient = LinearGradient(
    colors: [brandInk, brandField],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

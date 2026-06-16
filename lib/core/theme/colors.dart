import 'package:flutter/material.dart';

enum AppThemePreset { purple, blue, pink, gold, teal }

class AppThemePalette {
  final AppThemePreset preset;
  final String label;
  final String description;
  final Color brandField;
  final Color brandMint;
  final Color primary;
  final Color primaryDark;
  final Color primaryLight;
  final Color accent;
  final LinearGradient primaryGradient;
  final LinearGradient brandHeroGradient;
  final List<Color> swatches;

  const AppThemePalette({
    required this.preset,
    required this.label,
    required this.description,
    required this.brandField,
    required this.brandMint,
    required this.primary,
    required this.primaryDark,
    required this.primaryLight,
    required this.accent,
    required this.primaryGradient,
    required this.brandHeroGradient,
    required this.swatches,
  });
}

class AppColors {
  static const AppThemePreset defaultPreset = AppThemePreset.blue;

  static const Color brandInk = Color(0xFF081120);

  static const Color backgroundLight = Color(0xFFF4F7FB);
  static const Color backgroundDark = Color(0xFF07111D);

  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF101A2C);
  static const Color surfaceMuted = Color(0xFFEDF3FA);
  static const Color surfaceMutedDark = Color(0xFF16243A);

  static const Color textLight = Color(0xFF0A1730);
  static const Color textDark = Color(0xFFF7FAFF);
  static const Color textSecondaryLight = Color(0xFF61728D);
  static const Color textSecondaryDark = Color(0xFFA7B4CA);

  static const Color outline = Color(0xFFD6E2F0);
  static const Color outlineDark = Color(0xFF24324A);

  static const Color success = Color(0xFF22C983);
  static const Color successDeep = Color(0xFF0F8D5C);
  static const Color successSoft = Color(0xFFE3FBF1);
  static const Color error = Color(0xFFFF6B6B);
  static const Color errorDeep = Color(0xFFC13A4A);
  static const Color errorSoft = Color(0xFFFFE7E9);
  static const Color warning = Color(0xFFF5A524);
  static const Color warningDeep = Color(0xFFC97A0A);
  static const Color warningSoft = Color(0xFFFFF1D6);
  static const Color info = Color(0xFF4A8DFF);
  static const Color infoDeep = Color(0xFF245CD4);
  static const Color infoSoft = Color(0xFFE7F0FF);
  static const Color live = Color(0xFFFF5B67);
  static const Color liveSoft = Color(0xFFFFE3E6);
  static const Color gold = Color(0xFFFFC857);
  static const Color goldDeep = Color(0xFFE89A19);
  static const Color goldSoft = Color(0xFFFFF0CD);

  static const List<AppThemePalette> availablePalettes = [
    AppThemePalette(
      preset: AppThemePreset.purple,
      label: 'Purple',
      description: 'Bold & Professional',
      brandField: Color(0xFF5E38B7),
      brandMint: Color(0xFFF7F1FF),
      primary: Color(0xFF7046D9),
      primaryDark: Color(0xFF43278A),
      primaryLight: Color(0xFFD7C6FF),
      accent: Color(0xFFF1EAFF),
      primaryGradient: LinearGradient(
        colors: [Color(0xFF8662EE), Color(0xFF5E38B7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      brandHeroGradient: LinearGradient(
        colors: [Color(0xFF342160), Color(0xFF5E38B7), Color(0xFF8662EE)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      swatches: [Color(0xFF5E38B7), Color(0xFFBFA7F6), Color(0xFFE8DDFF)],
    ),
    AppThemePalette(
      preset: AppThemePreset.blue,
      label: 'Blue',
      description: 'Classic & Trustworthy',
      brandField: Color(0xFF3049A5),
      brandMint: Color(0xFFF2F5FF),
      primary: Color(0xFF3E5FCE),
      primaryDark: Color(0xFF23347B),
      primaryLight: Color(0xFFBCC8FF),
      accent: Color(0xFFE8EEFF),
      primaryGradient: LinearGradient(
        colors: [Color(0xFF5273E9), Color(0xFF3049A5)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      brandHeroGradient: LinearGradient(
        colors: [Color(0xFF1F2C6C), Color(0xFF3049A5), Color(0xFF5273E9)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      swatches: [Color(0xFF3049A5), Color(0xFFAEBBEE), Color(0xFFE4E9FF)],
    ),
    AppThemePalette(
      preset: AppThemePreset.pink,
      label: 'Pink',
      description: 'Vibrant & Energetic',
      brandField: Color(0xFFC8197E),
      brandMint: Color(0xFFFFF2FA),
      primary: Color(0xFFB81873),
      primaryDark: Color(0xFF8D0F59),
      primaryLight: Color(0xFFF4B6DA),
      accent: Color(0xFFFFE7F4),
      primaryGradient: LinearGradient(
        colors: [Color(0xFFE33B99), Color(0xFFC8197E)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      brandHeroGradient: LinearGradient(
        colors: [Color(0xFF840F53), Color(0xFFC8197E), Color(0xFFE33B99)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      swatches: [Color(0xFFC8197E), Color(0xFFF08CCB), Color(0xFFFFDDF2)],
    ),
    AppThemePalette(
      preset: AppThemePreset.gold,
      label: 'Shriram Gold',
      description: 'Warm & Premium',
      brandField: Color(0xFFC18B00),
      brandMint: Color(0xFFFFFAEA),
      primary: Color(0xFFB47A00),
      primaryDark: Color(0xFF825700),
      primaryLight: Color(0xFFF5D887),
      accent: Color(0xFFFFF2CF),
      primaryGradient: LinearGradient(
        colors: [Color(0xFFE3A800), Color(0xFFC18B00)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      brandHeroGradient: LinearGradient(
        colors: [Color(0xFF8D6500), Color(0xFFC18B00), Color(0xFFF1BD35)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      swatches: [Color(0xFFC18B00), Color(0xFFFFE08A), Color(0xFFFFF5D8)],
    ),
    AppThemePalette(
      preset: AppThemePreset.teal,
      label: 'Teal',
      description: 'Fresh & Focused',
      brandField: Color(0xFF0D8A80),
      brandMint: Color(0xFFF0FFFC),
      primary: Color(0xFF0C978C),
      primaryDark: Color(0xFF07655E),
      primaryLight: Color(0xFF9EE7DF),
      accent: Color(0xFFE1FBF6),
      primaryGradient: LinearGradient(
        colors: [Color(0xFF1ABEB1), Color(0xFF0D8A80)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      brandHeroGradient: LinearGradient(
        colors: [Color(0xFF0A5B54), Color(0xFF0D8A80), Color(0xFF1ABEB1)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      swatches: [Color(0xFF0D8A80), Color(0xFF8ADDD4), Color(0xFFD9FBF7)],
    ),
  ];

  static AppThemePalette _activePalette = paletteFor(defaultPreset);

  static AppThemePalette get activePalette => _activePalette;

  static AppThemePalette paletteFor(AppThemePreset preset) {
    for (final palette in availablePalettes) {
      if (palette.preset == preset) {
        return palette;
      }
    }
    for (final palette in availablePalettes) {
      if (palette.preset == defaultPreset) {
        return palette;
      }
    }
    return availablePalettes.first;
  }

  static void applyPalette(AppThemePreset preset) {
    _activePalette = paletteFor(preset);
  }

  static Color get brandField => _activePalette.brandField;
  static Color get brandMint => _activePalette.brandMint;
  static Color get primary => _activePalette.primary;
  static Color get primaryDark => _activePalette.primaryDark;
  static Color get primaryLight => _activePalette.primaryLight;
  static Color get accent => _activePalette.accent;
  static Color get purple => _activePalette.brandField;
  static Color get purpleSoft => _activePalette.accent;
  static LinearGradient get primaryGradient => _activePalette.primaryGradient;
  static LinearGradient get brandHeroGradient =>
      _activePalette.brandHeroGradient;

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF0B162B), Color(0xFF142744)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warmAccentGradient = LinearGradient(
    colors: [Color(0xFFFFC857), Color(0xFFFF7B72)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get surfaceGlowGradient => LinearGradient(
    colors: [
      const Color(0xFFF9FBFF),
      _activePalette.accent,
      _activePalette.brandMint,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

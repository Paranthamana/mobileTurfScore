import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'colors.dart';

class AppThemeController extends ChangeNotifier {
  static const _themeModeKey = 'app_theme_mode';
  static const _themePresetKey = 'app_theme_preset';

  final SharedPreferences prefs;

  ThemeMode _themeMode = ThemeMode.light;
  AppThemePreset _themePreset = AppColors.defaultPreset;

  AppThemeController({required this.prefs});

  ThemeMode get themeMode => _themeMode;
  AppThemePreset get themePreset => _themePreset;
  AppThemePalette get activePalette => AppColors.paletteFor(_themePreset);

  Future<void> load() async {
    _themeMode = _themeModeFromName(prefs.getString(_themeModeKey));
    _themePreset = _themePresetFromName(prefs.getString(_themePresetKey));
    AppColors.applyPalette(_themePreset);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    if (_themeMode == themeMode) {
      return;
    }

    _themeMode = themeMode;
    await prefs.setString(_themeModeKey, themeMode.name);
    notifyListeners();
  }

  Future<void> setThemePreset(AppThemePreset themePreset) async {
    if (_themePreset == themePreset) {
      return;
    }

    _themePreset = themePreset;
    AppColors.applyPalette(themePreset);
    await prefs.setString(_themePresetKey, themePreset.name);
    notifyListeners();
  }

  ThemeMode _themeModeFromName(String? value) {
    for (final mode in ThemeMode.values) {
      if (mode.name == value) {
        return mode;
      }
    }
    return ThemeMode.light;
  }

  AppThemePreset _themePresetFromName(String? value) {
    for (final preset in AppThemePreset.values) {
      if (preset.name == value) {
        return preset;
      }
    }
    return AppColors.defaultPreset;
  }
}

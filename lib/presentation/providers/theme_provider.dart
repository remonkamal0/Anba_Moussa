import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.light) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString(AppConstants.selectedThemeKey) ?? 'light';
    state = themeString == 'dark' ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final newTheme = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await prefs.setString(AppConstants.selectedThemeKey, newTheme == ThemeMode.dark ? 'dark' : 'light');
    state = newTheme;
  }

  Future<void> setTheme(ThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.selectedThemeKey, themeMode == ThemeMode.dark ? 'dark' : 'light');
    state = themeMode;
  }
}

class AccentColorNotifier extends StateNotifier<Color> {
  AccentColorNotifier() : super(AppTheme.getAccentColor('orange')) {
    _loadAccentColor();
  }

  Future<void> _loadAccentColor() async {
    final prefs = await SharedPreferences.getInstance();
    final colorName = prefs.getString(AppConstants.selectedAccentColorKey) ?? 'orange';
    state = AppTheme.getAccentColor(colorName);
  }

  Future<void> changeAccentColor(String colorName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.selectedAccentColorKey, colorName);
    state = AppTheme.getAccentColor(colorName);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

final accentColorProvider = StateNotifierProvider<AccentColorNotifier, Color>((ref) {
  return AccentColorNotifier();
});

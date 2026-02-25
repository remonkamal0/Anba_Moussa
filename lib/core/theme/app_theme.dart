import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class AppTheme {
  static ThemeData light({Color? accentColor}) {
    final primary = accentColor ?? AppConstants.primaryColor;
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: primary,
        surface: const Color(0xFFFFFFFF),
        onSurface: Colors.black,
      ),
      fontFamily: AppConstants.cairoFont,
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.mediumBorderRadius),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.mediumBorderRadius),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.mediumBorderRadius),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        filled: true,
        fillColor: const Color(0xFFFAFAFA),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppConstants.mediumSpacing,
          vertical: AppConstants.smallSpacing,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.mediumBorderRadius),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: AppConstants.mediumSpacing,
            vertical: AppConstants.smallSpacing,
          ),
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 4,
      ),
    );
  }

  static ThemeData dark({Color? accentColor}) {
    final primary = accentColor ?? AppConstants.primaryColor;
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: primary,
        secondary: primary,
        surface: const Color(0xFF121212),
        onSurface: Colors.white,
      ),
      fontFamily: AppConstants.cairoFont,
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.mediumBorderRadius),
          borderSide: const BorderSide(color: Color(0xFF757575)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.mediumBorderRadius),
          borderSide: const BorderSide(color: Color(0xFF757575)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.mediumBorderRadius),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        filled: true,
        fillColor: const Color(0xFF424242),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppConstants.mediumSpacing,
          vertical: AppConstants.smallSpacing,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.mediumBorderRadius),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: AppConstants.mediumSpacing,
            vertical: AppConstants.smallSpacing,
          ),
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 4,
      ),
    );
  }

  // Accent colors
  static const Map<String, Color> accentColors = {
    'orange': Color(0xFFFF6B35),
    'purple': Color(0xFF9B59B6),
    'green': Color(0xFF27AE60),
    'blue': Color(0xFF3498DB),
  };

  static Color getAccentColor(String colorName) {
    return accentColors[colorName] ?? accentColors['orange']!;
  }
}

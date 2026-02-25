import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class AppTheme {
  static ThemeData light({Color? accentColor, Locale? locale}) {
    final primary = accentColor ?? AppConstants.primaryColor;
    final isArabic = locale?.languageCode == 'ar';
    final primaryFont = isArabic ? 'Cairo' : 'Inter';
    final fallbackFont = isArabic ? 'Inter' : 'Cairo';
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: primary,
        surface: const Color(0xFFFFFFFF),
        onSurface: Colors.black,
      ),
      fontFamily: primaryFont,
      textTheme: _buildTextTheme(primaryFont, fallbackFont),
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

  static ThemeData dark({Color? accentColor, Locale? locale}) {
    final primary = accentColor ?? AppConstants.primaryColor;
    final isArabic = locale?.languageCode == 'ar';
    final primaryFont = isArabic ? 'Cairo' : 'Inter';
    final fallbackFont = isArabic ? 'Inter' : 'Cairo';
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: primary,
        secondary: primary,
        surface: const Color(0xFF121212),
        onSurface: Colors.white,
      ),
      fontFamily: primaryFont,
      textTheme: _buildTextTheme(primaryFont, fallbackFont),
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

  // ── Shared text theme builder ──────────────────────────────────────────────
  static TextTheme _buildTextTheme(String primaryFont, String fallbackFont) {
    TextStyle ts({
      required double size,
      required FontWeight weight,
    }) => TextStyle(
      fontFamily: primaryFont,
      fontFamilyFallback: [fallbackFont],
      fontSize: size,
      fontWeight: weight,
    );

    return TextTheme(
      displayLarge:  ts(size: 32, weight: FontWeight.w900),
      displayMedium: ts(size: 28, weight: FontWeight.w900),
      displaySmall:  ts(size: 24, weight: FontWeight.w900),
      headlineLarge:  ts(size: 22, weight: FontWeight.w900),
      headlineMedium: ts(size: 20, weight: FontWeight.w800),
      headlineSmall:  ts(size: 18, weight: FontWeight.w700),
      titleLarge:  ts(size: 16, weight: FontWeight.w900),
      titleMedium: ts(size: 14, weight: FontWeight.w800),
      titleSmall:  ts(size: 12, weight: FontWeight.w700),
      bodyLarge:  ts(size: 16, weight: FontWeight.w600),
      bodyMedium: ts(size: 14, weight: FontWeight.w500),
      bodySmall:  ts(size: 12, weight: FontWeight.w400),
      labelLarge:  ts(size: 14, weight: FontWeight.w700),
      labelMedium: ts(size: 12, weight: FontWeight.w600),
      labelSmall:  ts(size: 10, weight: FontWeight.w500),
    );
  }

  // ── Accent colors ──────────────────────────────────────────────────────────
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

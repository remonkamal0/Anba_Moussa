import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class AppTheme {
  static ThemeData light({Color? accentColor, Locale? locale}) {
    final primary = accentColor ?? AppConstants.primaryColor;
    final isArabic = locale?.languageCode == 'ar';
    final primaryFont = isArabic ? 'Cairo' : 'Inter';
    final fallbackFont = isArabic ? 'Inter' : 'Cairo';
    const surface = Color(0xFFFFFFFF);
    const onSurface = Color(0xFF0D0D0D);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: surface,
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: primary,
        surface: surface,
        onSurface: onSurface,
        outline: const Color(0xFFE0E0E0),
        outlineVariant: const Color(0xFFF0F0F0),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: onSurface,
        elevation: 0,
        iconTheme: const IconThemeData(color: onSurface),
        titleTextStyle: TextStyle(
          fontFamily: primaryFont,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: onSurface,
        ),
      ),
      iconTheme: const IconThemeData(color: onSurface),
      dividerColor: const Color(0xFFEEEEEE),
      fontFamily: primaryFont,
      textTheme: _buildTextTheme(primaryFont, fallbackFont, onSurface),
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
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: onSurface,
          side: const BorderSide(color: Color(0xFFE0E0E0)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.mediumBorderRadius),
          ),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: onSurface,
        textColor: onSurface,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        color: surface,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }

  static ThemeData dark({Color? accentColor, Locale? locale}) {
    final primary = accentColor ?? AppConstants.primaryColor;
    final isArabic = locale?.languageCode == 'ar';
    final primaryFont = isArabic ? 'Cairo' : 'Inter';
    final fallbackFont = isArabic ? 'Inter' : 'Cairo';
    const surface = Color(0xFF121212);
    const surfaceContainer = Color(0xFF1E1E1E);
    const onSurface = Color(0xFFF5F5F5);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: surface,
      colorScheme: ColorScheme.dark(
        primary: primary,
        secondary: primary,
        surface: surface,
        onSurface: onSurface,
        outline: const Color(0xFF424242),
        outlineVariant: const Color(0xFF2C2C2C),
        surfaceContainerHighest: surfaceContainer,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: onSurface,
        elevation: 0,
        iconTheme: const IconThemeData(color: onSurface),
        titleTextStyle: TextStyle(
          fontFamily: primaryFont,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: onSurface,
        ),
      ),
      iconTheme: const IconThemeData(color: onSurface),
      dividerColor: const Color(0xFF333333),
      fontFamily: primaryFont,
      textTheme: _buildTextTheme(primaryFont, fallbackFont, onSurface),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.mediumBorderRadius),
          borderSide: const BorderSide(color: Color(0xFF555555)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.mediumBorderRadius),
          borderSide: const BorderSide(color: Color(0xFF555555)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.mediumBorderRadius),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        filled: true,
        fillColor: surfaceContainer,
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
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: onSurface,
          side: const BorderSide(color: Color(0xFF555555)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.mediumBorderRadius),
          ),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: onSurface,
        textColor: onSurface,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        color: surfaceContainer,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }

  // ── Shared text theme builder ──────────────────────────────────────────────
  static TextTheme _buildTextTheme(String primaryFont, String fallbackFont, Color onSurface) {
    TextStyle ts({
      required double size,
      required FontWeight weight,
    }) => TextStyle(
      fontFamily: primaryFont,
      fontFamilyFallback: [fallbackFont],
      fontSize: size,
      fontWeight: weight,
      color: onSurface,
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
    'blue': Color(0xFF2F80ED),
    'green': Color(0xFF27AE60),
    'purple': Color(0xFF9B51E0),
    'red': Color(0xFFEB5757),
  };

  static Color getAccentColor(String colorName) {
    return accentColors[colorName] ?? accentColors['orange']!;
  }
}

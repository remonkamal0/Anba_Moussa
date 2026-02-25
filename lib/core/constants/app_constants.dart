import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'Anba Moussa';
  static const String appVersion = '1.0.0';
  
  // Colors
  static const Color primaryColor = Color(0xFFFF6B35);
  static const Color accentColor = Color(0xFF4CAF50);
  static const Color backgroundColor = Colors.white;
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Colors.red;
  static const Color successColor = Colors.green;
  
  // API
  static const String supabaseUrl = 'https://ktzgztlphytgaofwencb.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt0emd6dGxwaHl0Z2FvZndlbmNiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzE2NjMzOTgsImV4cCI6MjA4NzIzOTM5OH0.j8DMoB51_7-CFGCt12R5DuFTr1Oy6ryeakyVDh8j020';
  
  // Storage
  static const String userPreferencesKey = 'user_preferences';
  static const String onboardingCompletedKey = 'onboarding_completed';
  static const String selectedLanguageKey = 'selected_language';
  static const String selectedThemeKey = 'selected_theme';
  static const String selectedAccentColorKey = 'selected_accent_color';
  
  // Routes
  static const String onboardingRoute = '/onboarding';
  static const String homeRoute = '/home';
  static const String playerRoute = '/player';
  static const String profileRoute = '/profile';
  static const String settingsRoute = '/settings';
  
  // Assets
  static const String logoPath = 'assets/images/logo.png';
  static const String defaultCoverPath = 'assets/images/default_cover.png';
  
  // Font Family
  static const String cairoFont = 'Cairo';
  
  // Animation Durations
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
  
  // Border Radius
  static const double smallBorderRadius = 8.0;
  static const double mediumBorderRadius = 12.0;
  static const double largeBorderRadius = 16.0;
  
  // Spacing
  static const double extraSmallSpacing = 4.0;
  static const double smallSpacing = 8.0;
  static const double mediumSpacing = 16.0;
  static const double largeSpacing = 24.0;
  static const double extraLargeSpacing = 32.0;
  
  // Text Sizes
  static const double smallTextSize = 12.0;
  static const double mediumTextSize = 14.0;
  static const double largeTextSize = 16.0;
  static const double extraLargeTextSize = 18.0;
  static const double titleTextSize = 24.0;
  static const double headingTextSize = 28.0;
}

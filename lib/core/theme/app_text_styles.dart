import 'package:flutter/material.dart';

class AppTextStyles {
  // English text styles using Inter font
  static const TextStyle interDisplayLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 32,
    fontWeight: FontWeight.w900,
  );

  static const TextStyle interDisplayMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 28,
    fontWeight: FontWeight.w900,
  );

  static const TextStyle interDisplaySmall = TextStyle(
    fontFamily: 'Inter',
    fontSize: 24,
    fontWeight: FontWeight.w900,
  );

  static const TextStyle interHeadlineLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 22,
    fontWeight: FontWeight.w900,
  );

  static const TextStyle interHeadlineMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 20,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle interHeadlineSmall = TextStyle(
    fontFamily: 'Inter',
    fontSize: 18,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle interTitleLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w900,
  );

  static const TextStyle interTitleMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle interTitleSmall = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle interBodyLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle interBodyMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle interBodySmall = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle interLabelLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle interLabelMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle interLabelSmall = TextStyle(
    fontFamily: 'Inter',
    fontSize: 10,
    fontWeight: FontWeight.w500,
  );

  // Arabic text styles using Cairo font
  static const TextStyle cairoDisplayLarge = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 32,
    fontWeight: FontWeight.w900,
  );

  static const TextStyle cairoDisplayMedium = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 28,
    fontWeight: FontWeight.w900,
  );

  static const TextStyle cairoDisplaySmall = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 24,
    fontWeight: FontWeight.w900,
  );

  static const TextStyle cairoHeadlineLarge = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 22,
    fontWeight: FontWeight.w900,
  );

  static const TextStyle cairoHeadlineMedium = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 20,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle cairoHeadlineSmall = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 18,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle cairoTitleLarge = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 16,
    fontWeight: FontWeight.w900,
  );

  static const TextStyle cairoTitleMedium = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 14,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle cairoTitleSmall = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle cairoBodyLarge = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle cairoBodyMedium = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle cairoBodySmall = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle cairoLabelLarge = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle cairoLabelMedium = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle cairoLabelSmall = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 10,
    fontWeight: FontWeight.w500,
  );

  // Helper method to get appropriate text style based on locale
  static TextStyle getDisplayLarge(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'ar' ? cairoDisplayLarge : interDisplayLarge;
  }

  static TextStyle getDisplayMedium(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'ar' ? cairoDisplayMedium : interDisplayMedium;
  }

  static TextStyle getDisplaySmall(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'ar' ? cairoDisplaySmall : interDisplaySmall;
  }

  static TextStyle getHeadlineLarge(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'ar' ? cairoHeadlineLarge : interHeadlineLarge;
  }

  static TextStyle getHeadlineMedium(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'ar' ? cairoHeadlineMedium : interHeadlineMedium;
  }

  static TextStyle getHeadlineSmall(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'ar' ? cairoHeadlineSmall : interHeadlineSmall;
  }

  static TextStyle getTitleLarge(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'ar' ? cairoTitleLarge : interTitleLarge;
  }

  static TextStyle getTitleMedium(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'ar' ? cairoTitleMedium : interTitleMedium;
  }

  static TextStyle getTitleSmall(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'ar' ? cairoTitleSmall : interTitleSmall;
  }

  static TextStyle getBodyLarge(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'ar' ? cairoBodyLarge : interBodyLarge;
  }

  static TextStyle getBodyMedium(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'ar' ? cairoBodyMedium : interBodyMedium;
  }

  static TextStyle getBodySmall(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'ar' ? cairoBodySmall : interBodySmall;
  }

  static TextStyle getLabelLarge(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'ar' ? cairoLabelLarge : interLabelLarge;
  }

  static TextStyle getLabelMedium(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'ar' ? cairoLabelMedium : interLabelMedium;
  }

  static TextStyle getLabelSmall(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'ar' ? cairoLabelSmall : interLabelSmall;
  }
}

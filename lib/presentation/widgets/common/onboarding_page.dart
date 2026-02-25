import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:anba_moussa/l10n/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../models/onboarding_page_data.dart';
import '../common/language_selector.dart';
import '../common/theme_selector.dart';
import '../common/accent_color_selector.dart';
import '../../providers/locale_provider.dart';

class OnboardingPage extends ConsumerWidget {
  final OnboardingPageData pageData;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final bool isLastPage;
  final bool isFirstPage;

  const OnboardingPage({
    super.key,
    required this.pageData,
    required this.onNext,
    required this.onPrevious,
    required this.isLastPage,
    required this.isFirstPage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);

    return Directionality(
      textDirection: locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive adjustments based on screen size
          final isSmallScreen = constraints.maxWidth < 360;
          final isLargeScreen = constraints.maxWidth > 600;
          
          return Padding(
            padding: EdgeInsets.all(
              isSmallScreen ? AppConstants.smallSpacing.r : AppConstants.mediumSpacing.r
            ),
            child: Column(
              children: [
                // Skip button
                if (!isLastPage)
                  Align(
                    alignment: locale.languageCode == 'ar' ? Alignment.topLeft : Alignment.topRight,
                    child: Padding(
                      padding: EdgeInsets.all(AppConstants.mediumSpacing.r),
                      child: TextButton(
                        onPressed: () {
                          // Navigate to login
                          context.go('/login');
                        },
                        child: Text(
                          l10n.onboardingSkip,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
          // Image
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: isLargeScreen ? 280.h : 240.h,
                maxWidth:  isLargeScreen ? 280.h : 240.h,
              ),
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: isSmallScreen ? 2.w : 4.w,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFE8DDD5),
                            Color(0xFFD4C4B5),
                          ],
                        ),
                      ),
                      child: pageData.imagePath.startsWith('http')
                          ? CachedNetworkImage(
                              imageUrl: pageData.imagePath,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Center(
                                child: CircularProgressIndicator(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              errorWidget: (context, url, error) => Icon(
                                Icons.image,
                                size: 80.w,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                              ),
                            )
                          : Image.asset(
                              pageData.imagePath,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Icon(
                                Icons.image,
                                size: 80.w,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                              ),
                            ),
                    ),
                  ),
                ).animate().scale(
                  duration: AppConstants.defaultAnimationDuration,
                  curve: Curves.easeOut,
                ),
              ),
            ),
          ),

          SizedBox(height: AppConstants.largeSpacing.h),

          // Title and subtitle
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    _getLocalizedText(l10n, pageData.titleKey, locale),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                    textDirection: locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                  ).animate().fadeIn(
                    duration: AppConstants.defaultAnimationDuration,
                    delay: const Duration(milliseconds: 200),
                  ),

                  SizedBox(height: AppConstants.mediumSpacing.h),

                  Text(
                    _getLocalizedText(l10n, pageData.subtitleKey, locale),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                    textDirection: locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                  ).animate().fadeIn(
                    duration: AppConstants.defaultAnimationDuration,
                    delay: const Duration(milliseconds: 400),
                  ),

                  // Custom selectors for first page
                  if (pageData.showLanguageSelector) ...[
                    SizedBox(height: AppConstants.largeSpacing.h),
                    const LanguageSelector().animate().fadeIn(
                      duration: AppConstants.defaultAnimationDuration,
                      delay: const Duration(milliseconds: 600),
                    ),
                  ],

                  if (pageData.showThemeSelector || pageData.showAccentColorSelector) ...[
                    SizedBox(height: AppConstants.mediumSpacing.h),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          if (pageData.showThemeSelector)
                            const ThemeSelector(),
                          if (pageData.showThemeSelector && pageData.showAccentColorSelector)
                            SizedBox(width: AppConstants.largeSpacing.w),
                          if (pageData.showAccentColorSelector)
                            const AccentColorSelector(),
                        ],
                      ),
                    ).animate().fadeIn(
                      duration: AppConstants.defaultAnimationDuration,
                      delay: const Duration(milliseconds: 800),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Action buttons
          SizedBox(
            width: double.infinity,
            height: 56.h,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isLastPage 
                        ? l10n.onboardingGetStarted
                        : l10n.onboardingNext,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(
                    locale.languageCode == 'ar' ? Icons.arrow_back : Icons.arrow_forward,
                    size: 20.w,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // Footer text
          Text(
            'SOULSYNC APP V.1.0 • CUSTOMIZE ANYTIME IN SETTINGS',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[400],
              fontSize: 10.sp,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
          ),
        );
      },
    ),
    );
  }

  String _getLocalizedText(AppLocalizations l10n, String key, Locale locale) {
    switch (key) {
      case 'onboarding.welcome':
        return l10n.onboardingWelcome;
      case 'onboarding.welcomeSubtitle':
        return l10n.onboardingWelcomeSubtitle;
      case 'onboarding.discover':
        return l10n.onboardingDiscover;
      case 'onboarding.discoverSubtitle':
        return l10n.onboardingDiscoverSubtitle;
      case 'onboarding.personalize':
        return l10n.onboardingPersonalize;
      case 'onboarding.personalizeSubtitle':
        return l10n.onboardingPersonalizeSubtitle;
      case 'onboarding.listen':
        return l10n.onboardingListen;
      case 'onboarding.listenSubtitle':
        return l10n.onboardingListenSubtitle;
      case 'onboarding.simpleWelcome':
        return locale.languageCode == 'ar' ? 'استمع إلى موسيقاك المفضلة' : 'Listen to your favorite music';
      case 'onboarding.simpleSubtitle':
        return locale.languageCode == 'ar' 
            ? 'اكتشف أحدث المسارات والألبومات والفنانين من حول العالم. رحلتك الموسيقية تبدأ هنا.'
            : 'Discover the latest tracks, albums, and artists from around the world. Your music journey starts here.';
      default:
        return key;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:anba_moussa/l10n/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/locale_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/onboarding_page_data.dart';
import '../../widgets/common/language_selector.dart';
import '../../widgets/common/theme_selector.dart';
import '../../widgets/common/accent_color_selector.dart';
import '../../widgets/common/onboarding_page.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      titleKey: 'onboarding.welcome',
      subtitleKey: 'onboarding.welcomeSubtitle',
      imagePath: 'assets/images/onboarding_welcome.png',
      showLanguageSelector: true,
      showThemeSelector: true,
      showAccentColorSelector: true,
    ),
    OnboardingPageData(
      titleKey: 'onboarding.discover',
      subtitleKey: 'onboarding.discoverSubtitle',
      imagePath: 'assets/images/onboarding_discover.png',
    ),
    OnboardingPageData(
      titleKey: 'onboarding.personalize',
      subtitleKey: 'onboarding.personalizeSubtitle',
      imagePath: 'assets/images/onboarding_personalize.png',
    ),
    OnboardingPageData(
      titleKey: 'onboarding.listen',
      subtitleKey: 'onboarding.listenSubtitle',
      imagePath: 'assets/images/onboarding_listen.png',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: AppConstants.defaultAnimationDuration,
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: AppConstants.defaultAnimationDuration,
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  void _completeOnboarding() {
    // Save onboarding completion status
    // Navigate to login page
    context.go('/login'); // Change to login route
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final locale = ref.watch(localeProvider); // Force rebuild on locale change
    final accentColor = ref.watch(accentColorProvider); // Force rebuild on accent color change

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: PageView.builder(
          key: ValueKey('${locale.languageCode}_${accentColor.value}'), // Force rebuild
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          itemCount: _pages.length,
          itemBuilder: (context, index) {
            final pageData = _pages[index];
            return OnboardingPage(
              pageData: pageData,
              onNext: _nextPage,
              onPrevious: _previousPage,
              isLastPage: index == _pages.length - 1,
              isFirstPage: index == 0,
            );
          },
        ),
      ),
    );
  }
}

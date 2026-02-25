class OnboardingPageData {
  final String titleKey;
  final String subtitleKey;
  final String imagePath;
  final bool showLanguageSelector;
  final bool showThemeSelector;
  final bool showAccentColorSelector;
  final bool isLastPage;
  final bool isSimplePage;

  OnboardingPageData({
    required this.titleKey,
    required this.subtitleKey,
    required this.imagePath,
    this.showLanguageSelector = false,
    this.showThemeSelector = false,
    this.showAccentColorSelector = false,
    this.isLastPage = false,
    this.isSimplePage = false,
  });
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Anba Moussa'**
  String get appTitle;

  /// No description provided for @onboardingWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to SoulSync'**
  String get onboardingWelcome;

  /// No description provided for @onboardingWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Connect through rhythm and faith. Personalize your sacred space.'**
  String get onboardingWelcomeSubtitle;

  /// No description provided for @onboardingDiscover.
  ///
  /// In en, this message translates to:
  /// **'Discover Sacred Melodies'**
  String get onboardingDiscover;

  /// No description provided for @onboardingDiscoverSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Explore a vast collection of spiritual hymns and contemporary worship music curated for your soul\'s journey.'**
  String get onboardingDiscoverSubtitle;

  /// No description provided for @onboardingPersonalize.
  ///
  /// In en, this message translates to:
  /// **'Personalize Your Spirit'**
  String get onboardingPersonalize;

  /// No description provided for @onboardingPersonalizeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your own playlists and save your favorite hymns for anytime listening.'**
  String get onboardingPersonalizeSubtitle;

  /// No description provided for @onboardingListen.
  ///
  /// In en, this message translates to:
  /// **'Listen Anywhere'**
  String get onboardingListen;

  /// No description provided for @onboardingListenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Download tracks and watch videos offline without interruptions.'**
  String get onboardingListenSubtitle;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingGetStarted;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get onboardingBack;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @languageFrench.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @accentColorOrange.
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get accentColorOrange;

  /// No description provided for @accentColorBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get accentColorBlue;

  /// No description provided for @accentColorGreen.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get accentColorGreen;

  /// No description provided for @accentColorYellow.
  ///
  /// In en, this message translates to:
  /// **'Yellow'**
  String get accentColorYellow;

  /// No description provided for @settingsCustomizeAnytime.
  ///
  /// In en, this message translates to:
  /// **'CUSTOMIZE ANYTIME IN SETTINGS'**
  String get settingsCustomizeAnytime;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'ANBA MOUSSA APP V.1.0'**
  String get appVersion;

  /// No description provided for @navigationHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navigationHome;

  /// No description provided for @navigationSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navigationSearch;

  /// No description provided for @navigationLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get navigationLibrary;

  /// No description provided for @navigationGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get navigationGallery;

  /// No description provided for @navigationVideos.
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get navigationVideos;

  /// No description provided for @navigationProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navigationProfile;

  /// No description provided for @navigationSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navigationSettings;

  /// No description provided for @playerNowPlaying.
  ///
  /// In en, this message translates to:
  /// **'Now Playing'**
  String get playerNowPlaying;

  /// No description provided for @playerFavorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get playerFavorite;

  /// No description provided for @playerAddToPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Add to Playlist'**
  String get playerAddToPlaylist;

  /// No description provided for @playerDownload.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get playerDownload;

  /// No description provided for @playerShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get playerShare;

  /// No description provided for @drawerMyPlaylists.
  ///
  /// In en, this message translates to:
  /// **'My Playlists'**
  String get drawerMyPlaylists;

  /// No description provided for @drawerLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get drawerLanguage;

  /// No description provided for @drawerDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get drawerDarkMode;

  /// No description provided for @drawerTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get drawerTheme;

  /// No description provided for @drawerFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get drawerFavorites;

  /// No description provided for @drawerDownloads.
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get drawerDownloads;

  /// No description provided for @drawerNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get drawerNotifications;

  /// No description provided for @drawerDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get drawerDeleteAccount;

  /// No description provided for @drawerLogOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get drawerLogOut;

  /// No description provided for @drawerArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get drawerArabic;

  /// No description provided for @drawerEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get drawerEnglish;

  /// No description provided for @dialogLogoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get dialogLogoutTitle;

  /// No description provided for @dialogLogoutContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get dialogLogoutContent;

  /// No description provided for @dialogDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get dialogDeleteTitle;

  /// No description provided for @dialogDeleteContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action cannot be undone.'**
  String get dialogDeleteContent;

  /// No description provided for @dialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dialogCancel;

  /// No description provided for @dialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get dialogConfirm;

  /// No description provided for @playlistCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'New Playlist'**
  String get playlistCreateTitle;

  /// No description provided for @playlistAddCover.
  ///
  /// In en, this message translates to:
  /// **'ADD COVER'**
  String get playlistAddCover;

  /// No description provided for @playlistNameLabel.
  ///
  /// In en, this message translates to:
  /// **'PLAYLIST NAME'**
  String get playlistNameLabel;

  /// No description provided for @playlistNameHint.
  ///
  /// In en, this message translates to:
  /// **'Give your playlist a name'**
  String get playlistNameHint;

  /// No description provided for @playlistSearchTracksHint.
  ///
  /// In en, this message translates to:
  /// **'Search tracks to add'**
  String get playlistSearchTracksHint;

  /// No description provided for @playlistSuggestedTracks.
  ///
  /// In en, this message translates to:
  /// **'SUGGESTED TRACKS'**
  String get playlistSuggestedTracks;

  /// No description provided for @playlistCreateButton.
  ///
  /// In en, this message translates to:
  /// **'Create Playlist'**
  String get playlistCreateButton;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we will\nsend you a link to reset your\npassword.'**
  String get forgotPasswordSubtitle;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'EMAIL ADDRESS'**
  String get emailAddress;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'hello@example.com'**
  String get emailHint;

  /// No description provided for @sendLink.
  ///
  /// In en, this message translates to:
  /// **'Send Link'**
  String get sendLink;

  /// No description provided for @backTo.
  ///
  /// In en, this message translates to:
  /// **'Back to '**
  String get backTo;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'PASSWORD'**
  String get password;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @welcomeBackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Discover and stream your favorite hits'**
  String get welcomeBackSubtitle;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'••••••••'**
  String get passwordHint;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get invalidEmail;

  /// No description provided for @emptyEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address'**
  String get emptyEmail;

  /// No description provided for @emptyPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get emptyPassword;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'OR CONTINUE WITH'**
  String get orContinueWith;

  /// No description provided for @google.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get google;

  /// No description provided for @apple.
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get apple;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @createAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join us to start your spiritual journey'**
  String get createAccountSubtitle;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'FULL NAME'**
  String get fullName;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get fullNameHint;

  /// No description provided for @emptyName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get emptyName;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'CONFIRM PASSWORD'**
  String get confirmPassword;

  /// No description provided for @passwordsNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsNotMatch;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

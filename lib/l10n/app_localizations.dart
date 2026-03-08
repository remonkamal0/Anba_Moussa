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
  /// **'Welcome to Anba Moussa App'**
  String get onboardingWelcome;

  /// No description provided for @onboardingWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Discover a rich spiritual library of sermons by His Grace Anba Moussa in audio, video, and images to inspire and strengthen youth spiritually..'**
  String get onboardingWelcomeSubtitle;

  /// No description provided for @onboardingDiscover.
  ///
  /// In en, this message translates to:
  /// **'His Holiness Pope Tawadros II'**
  String get onboardingDiscover;

  /// No description provided for @onboardingDiscoverSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pope and Patriarch of the See of Saint Mark.'**
  String get onboardingDiscoverSubtitle;

  /// No description provided for @onboardingPersonalize.
  ///
  /// In en, this message translates to:
  /// **'His Grace Anba Moussa'**
  String get onboardingPersonalize;

  /// No description provided for @onboardingPersonalizeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'General Bishop of Youth in the Coptic Orthodox Church.'**
  String get onboardingPersonalizeSubtitle;

  /// No description provided for @onboardingListen.
  ///
  /// In en, this message translates to:
  /// **'Youth Bishopric'**
  String get onboardingListen;

  /// No description provided for @onboardingListenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A ministry dedicated to spiritually and intellectually building youth in the Coptic Orthodox Church through teaching, activities, and service..'**
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

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search for audio track'**
  String get searchHint;

  /// No description provided for @searchTracksSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Search for your favorite tracks'**
  String get searchTracksSubtitle;

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

  /// No description provided for @signupAgreement.
  ///
  /// In en, this message translates to:
  /// **'I agree to the '**
  String get signupAgreement;

  /// No description provided for @signupTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get signupTerms;

  /// No description provided for @signupAnd.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get signupAnd;

  /// No description provided for @signupPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy\nPolicy.'**
  String get signupPrivacy;

  /// No description provided for @signupAgreeError.
  ///
  /// In en, this message translates to:
  /// **'Please agree to Terms of Service and Privacy Policy.'**
  String get signupAgreeError;

  /// No description provided for @signupSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully! Please check your email to verify your account, then login.'**
  String get signupSuccess;

  /// No description provided for @signupFailed.
  ///
  /// In en, this message translates to:
  /// **'Signup failed. Please try again.'**
  String get signupFailed;

  /// No description provided for @signupEmailExists.
  ///
  /// In en, this message translates to:
  /// **'An account with this email already exists'**
  String get signupEmailExists;

  /// No description provided for @signupWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak. Please choose a stronger password.'**
  String get signupWeakPassword;

  /// No description provided for @signupPasswordLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get signupPasswordLength;

  /// No description provided for @churchHint.
  ///
  /// In en, this message translates to:
  /// **'Grace Community Church'**
  String get churchHint;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'GENDER'**
  String get gender;

  /// No description provided for @genderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get genderFemale;

  /// No description provided for @birthDate.
  ///
  /// In en, this message translates to:
  /// **'BIRTH DATE'**
  String get birthDate;

  /// No description provided for @pickDate.
  ///
  /// In en, this message translates to:
  /// **'Pick Date'**
  String get pickDate;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @myPlaylistsHeader.
  ///
  /// In en, this message translates to:
  /// **'MY PLAYLISTS'**
  String get myPlaylistsHeader;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @noPlaylistsYet.
  ///
  /// In en, this message translates to:
  /// **'No playlists yet'**
  String get noPlaylistsYet;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'PREFERENCES'**
  String get preferences;

  /// No description provided for @themeCustomization.
  ///
  /// In en, this message translates to:
  /// **'Theme Customization'**
  String get themeCustomization;

  /// No description provided for @myLibraryHeader.
  ///
  /// In en, this message translates to:
  /// **'MY LIBRARY'**
  String get myLibraryHeader;

  /// No description provided for @securityAlerts.
  ///
  /// In en, this message translates to:
  /// **'SECURITY & ALERTS'**
  String get securityAlerts;

  /// No description provided for @aboutDeveloper.
  ///
  /// In en, this message translates to:
  /// **'About Developer'**
  String get aboutDeveloper;

  /// No description provided for @aboutTeam.
  ///
  /// In en, this message translates to:
  /// **'About the Team'**
  String get aboutTeam;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'PHONE NUMBER'**
  String get phoneNumber;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'+1 (555) 000-0000'**
  String get phoneHint;

  /// No description provided for @churchName.
  ///
  /// In en, this message translates to:
  /// **'CHURCH NAME'**
  String get churchName;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get profileUpdated;

  /// No description provided for @profileAndPasswordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile and password updated successfully!'**
  String get profileAndPasswordUpdated;

  /// No description provided for @profileUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Error updating profile'**
  String get profileUpdateError;

  /// No description provided for @emailCannotBeChanged.
  ///
  /// In en, this message translates to:
  /// **'Email Address (Cannot be changed)'**
  String get emailCannotBeChanged;

  /// No description provided for @changePasswordOptional.
  ///
  /// In en, this message translates to:
  /// **'Change Password (Optional)'**
  String get changePasswordOptional;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @leaveBlankToKeep.
  ///
  /// In en, this message translates to:
  /// **'Leave blank to keep current'**
  String get leaveBlankToKeep;

  /// No description provided for @confirmNewPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmNewPasswordHint;

  /// No description provided for @adminSendNotification.
  ///
  /// In en, this message translates to:
  /// **'Send Notification'**
  String get adminSendNotification;

  /// No description provided for @adminLabel.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get adminLabel;

  /// No description provided for @homeCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get homeCategories;

  /// No description provided for @homeViewAll.
  ///
  /// In en, this message translates to:
  /// **'VIEW ALL'**
  String get homeViewAll;

  /// No description provided for @homeTopTracks.
  ///
  /// In en, this message translates to:
  /// **'Top 10 Tracks'**
  String get homeTopTracks;

  /// No description provided for @homeWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'WELCOME BACK,'**
  String get homeWelcomeBack;

  /// No description provided for @unknownSpeaker.
  ///
  /// In en, this message translates to:
  /// **'Unknown Speaker'**
  String get unknownSpeaker;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorOccurred;

  /// No description provided for @noCategoriesFound.
  ///
  /// In en, this message translates to:
  /// **'No categories found'**
  String get noCategoriesFound;

  /// No description provided for @playAll.
  ///
  /// In en, this message translates to:
  /// **'Play All'**
  String get playAll;

  /// No description provided for @shuffle.
  ///
  /// In en, this message translates to:
  /// **'Shuffle'**
  String get shuffle;

  /// No description provided for @likedTracksCount.
  ///
  /// In en, this message translates to:
  /// **'{count} LIKED TRACKS'**
  String likedTracksCount(int count);

  /// No description provided for @noFavoritesYet.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get noFavoritesYet;

  /// No description provided for @noDownloadsYet.
  ///
  /// In en, this message translates to:
  /// **'No downloads yet'**
  String get noDownloadsYet;

  /// No description provided for @deleteAllDownloadsTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete All Downloads'**
  String get deleteAllDownloadsTitle;

  /// No description provided for @deleteAllDownloadsContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove all downloaded tracks from your device?'**
  String get deleteAllDownloadsContent;

  /// No description provided for @deleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete All'**
  String get deleteAll;

  /// No description provided for @offlineTracks.
  ///
  /// In en, this message translates to:
  /// **'OFFLINE TRACKS'**
  String get offlineTracks;

  /// No description provided for @tracksCount.
  ///
  /// In en, this message translates to:
  /// **'Tracks'**
  String get tracksCount;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @deleteDownloadTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Download'**
  String get deleteDownloadTitle;

  /// No description provided for @deleteDownloadContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this download from your device?'**
  String get deleteDownloadContent;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @markAllAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllAsRead;

  /// No description provided for @noNotificationsFound.
  ///
  /// In en, this message translates to:
  /// **'No notifications found'**
  String get noNotificationsFound;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @timeMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String timeMinutesAgo(int count);

  /// No description provided for @timeHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String timeHoursAgo(int count);

  /// No description provided for @timeDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String timeDaysAgo(int count);

  /// No description provided for @playlistEnterNameError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a playlist name'**
  String get playlistEnterNameError;

  /// No description provided for @playlistChooseIcon.
  ///
  /// In en, this message translates to:
  /// **'Choose Icon'**
  String get playlistChooseIcon;

  /// No description provided for @playlistTapToChangeIcon.
  ///
  /// In en, this message translates to:
  /// **'Tap to change icon'**
  String get playlistTapToChangeIcon;

  /// No description provided for @playlistNameEnLabel.
  ///
  /// In en, this message translates to:
  /// **'Playlist Name (English)'**
  String get playlistNameEnLabel;

  /// No description provided for @playlistNameEnHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Morning Praise'**
  String get playlistNameEnHint;

  /// No description provided for @playlistNameArLabel.
  ///
  /// In en, this message translates to:
  /// **'Playlist Name (Arabic)'**
  String get playlistNameArLabel;

  /// No description provided for @playlistNameArHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Morning Praise'**
  String get playlistNameArHint;

  /// No description provided for @playlistPublicLabel.
  ///
  /// In en, this message translates to:
  /// **'Public Playlist'**
  String get playlistPublicLabel;

  /// No description provided for @playlistPublicSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Others can discover this'**
  String get playlistPublicSubtitle;

  /// No description provided for @playlistNextTracksSave.
  ///
  /// In en, this message translates to:
  /// **'Next: Tracks & Save'**
  String get playlistNextTracksSave;

  /// No description provided for @playlistAddTracks.
  ///
  /// In en, this message translates to:
  /// **'Add Tracks'**
  String get playlistAddTracks;

  /// No description provided for @playlistSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String playlistSelectedCount(int count);

  /// No description provided for @playlistNoTracksFound.
  ///
  /// In en, this message translates to:
  /// **'No tracks found'**
  String get playlistNoTracksFound;

  /// No description provided for @playlistNoAlbum.
  ///
  /// In en, this message translates to:
  /// **'No Album'**
  String get playlistNoAlbum;

  /// No description provided for @playlistCreateEmpty.
  ///
  /// In en, this message translates to:
  /// **'Create Playlist (Empty)'**
  String get playlistCreateEmpty;

  /// No description provided for @playlistCreateWithCount.
  ///
  /// In en, this message translates to:
  /// **'Create with {count} Tracks'**
  String playlistCreateWithCount(int count);

  /// No description provided for @playlistCreatedByOfficial.
  ///
  /// In en, this message translates to:
  /// **'Created by Official'**
  String get playlistCreatedByOfficial;

  /// No description provided for @playlistCreatedByMe.
  ///
  /// In en, this message translates to:
  /// **'Created by Me'**
  String get playlistCreatedByMe;

  /// No description provided for @playlistTracksCount.
  ///
  /// In en, this message translates to:
  /// **'• {count} Tracks'**
  String playlistTracksCount(int count);

  /// No description provided for @playlistPlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get playlistPlay;

  /// No description provided for @playlistShuffle.
  ///
  /// In en, this message translates to:
  /// **'Shuffle'**
  String get playlistShuffle;

  /// No description provided for @playlistErrorLoadingTracks.
  ///
  /// In en, this message translates to:
  /// **'Error loading tracks'**
  String get playlistErrorLoadingTracks;

  /// No description provided for @playlistEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Playlist'**
  String get playlistEdit;

  /// No description provided for @playlistSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search playlists…'**
  String get playlistSearchHint;

  /// No description provided for @playlistNoPlaylists.
  ///
  /// In en, this message translates to:
  /// **'No playlists yet'**
  String get playlistNoPlaylists;

  /// No description provided for @playlistCreateFirst.
  ///
  /// In en, this message translates to:
  /// **'Create your first playlist'**
  String get playlistCreateFirst;

  /// No description provided for @playlistFailedToLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load playlists'**
  String get playlistFailedToLoad;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @playlistDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete Playlist'**
  String get playlistDelete;

  /// No description provided for @playlistDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?'**
  String playlistDeleteConfirm(Object name);

  /// No description provided for @playlistPublic.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get playlistPublic;

  /// No description provided for @logoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutTitle;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirm;

  /// No description provided for @profileMyPlaylists.
  ///
  /// In en, this message translates to:
  /// **'My Playlists'**
  String get profileMyPlaylists;

  /// No description provided for @profileLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguage;

  /// No description provided for @profileDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get profileDarkMode;

  /// No description provided for @profileTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get profileTheme;

  /// No description provided for @profileFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get profileFavorites;

  /// No description provided for @profileDownloads.
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get profileDownloads;

  /// No description provided for @profileNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get profileNotifications;

  /// No description provided for @profileLogOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get profileLogOut;
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

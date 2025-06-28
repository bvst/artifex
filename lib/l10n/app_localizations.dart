import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_no.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('en'),
    Locale('no'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Artifex'**
  String get appTitle;

  /// The application tagline
  ///
  /// In en, this message translates to:
  /// **'Your World, Reimagined'**
  String get appTagline;

  /// Welcome screen main title
  ///
  /// In en, this message translates to:
  /// **'Transform Your Photos with AI'**
  String get welcomeTitle;

  /// Welcome screen description text
  ///
  /// In en, this message translates to:
  /// **'Turn your everyday photos into extraordinary works of art using the power of AI. Choose from various styles and let creativity flow.'**
  String get welcomeDescription;

  /// Camera button title
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get cameraButtonTitle;

  /// Camera button description
  ///
  /// In en, this message translates to:
  /// **'Capture a new photo with your camera'**
  String get cameraButtonDescription;

  /// Gallery button title
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get galleryButtonTitle;

  /// Gallery button description
  ///
  /// In en, this message translates to:
  /// **'Select an existing photo from your gallery'**
  String get galleryButtonDescription;

  /// Prompt asking user how to add a photo
  ///
  /// In en, this message translates to:
  /// **'How would you like to add a photo?'**
  String get choosePhotoPrompt;

  /// Error message when photo capture fails
  ///
  /// In en, this message translates to:
  /// **'Failed to capture photo'**
  String get photoCaptureFailed;

  /// Success message when photo is captured
  ///
  /// In en, this message translates to:
  /// **'Photo captured successfully!'**
  String get photoCaptureSuccess;

  /// Error message with details when photo capture fails
  ///
  /// In en, this message translates to:
  /// **'Error capturing photo: {error}'**
  String photoCaptureError(String error);

  /// Message when camera permission is needed
  ///
  /// In en, this message translates to:
  /// **'Camera permission is required. Please allow access in settings.'**
  String get cameraPermissionRequired;

  /// Generic error message for unexpected errors
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get unexpectedErrorOccurred;

  /// Message shown when camera falls back to gallery on desktop
  ///
  /// In en, this message translates to:
  /// **'Camera opens gallery on desktop'**
  String get cameraFallbackMessage;

  /// Loading message when processing photo
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// Retry button text
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;
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
      <String>['en', 'no'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'no':
      return AppLocalizationsNo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

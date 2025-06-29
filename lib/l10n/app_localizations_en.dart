// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Artifex';

  @override
  String get appTagline => 'Your World, Reimagined';

  @override
  String get welcomeTitle => 'Transform Your Photos with AI';

  @override
  String get welcomeDescription =>
      'Turn your everyday photos into extraordinary works of art using the power of AI. Choose from various styles and let creativity flow.';

  @override
  String get cameraButtonTitle => 'Take Photo';

  @override
  String get cameraButtonDescription => 'Capture a new photo with your camera';

  @override
  String get galleryButtonTitle => 'Choose from Gallery';

  @override
  String get galleryButtonDescription =>
      'Select an existing photo from your gallery';

  @override
  String get choosePhotoPrompt => 'How would you like to add a photo?';

  @override
  String get photoCaptureFailed => 'Failed to capture photo';

  @override
  String get photoCaptureSuccess => 'Photo captured successfully!';

  @override
  String photoCaptureError(String error) {
    return 'Error capturing photo: $error';
  }

  @override
  String get cameraPermissionRequired =>
      'Camera permission is required. Please allow access in settings.';

  @override
  String get unexpectedErrorOccurred =>
      'An unexpected error occurred. Please try again.';

  @override
  String get cameraFallbackMessage => 'Camera opens gallery on desktop';

  @override
  String get processing => 'Processing...';

  @override
  String get retry => 'Retry';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get systemDefault => 'System Default';

  @override
  String get english => 'English';

  @override
  String get norwegian => 'Norwegian';

  @override
  String languageChanged(String language) {
    return 'Language changed to $language';
  }
}

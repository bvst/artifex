// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Norwegian (`no`).
class AppLocalizationsNo extends AppLocalizations {
  AppLocalizationsNo([String locale = 'no']) : super(locale);

  @override
  String get appTitle => 'Artifex';

  @override
  String get appTagline => 'Din verden, nyforestilt';

  @override
  String get welcomeTitle => 'Forvandle bildene dine med KI';

  @override
  String get welcomeDescription =>
      'Gjør hverdagsbildene dine til ekstraordinære kunstverk ved hjelp av KI. Velg mellom ulike stiler og la kreativiteten flyte.';

  @override
  String get cameraButtonTitle => 'Ta bilde';

  @override
  String get cameraButtonDescription => 'Ta et nytt bilde med kameraet';

  @override
  String get galleryButtonTitle => 'Velg fra galleri';

  @override
  String get galleryButtonDescription =>
      'Velg et eksisterende bilde fra galleriet';

  @override
  String get choosePhotoPrompt => 'Hvordan vil du legge til et bilde?';

  @override
  String get photoCaptureFailed => 'Kunne ikke ta bilde';

  @override
  String get photoCaptureSuccess => 'Bilde tatt!';

  @override
  String photoCaptureError(String error) {
    return 'Feil ved bildeopptaking: $error';
  }

  @override
  String get cameraPermissionRequired =>
      'Kameraløyve kreves. Tillat tilgang i innstillinger.';

  @override
  String get unexpectedErrorOccurred => 'En uventet feil oppstod. Prøv igjen.';

  @override
  String get cameraFallbackMessage => 'Kamera åpner galleri på datamaskin';

  @override
  String get processing => 'Behandler...';

  @override
  String get retry => 'Prøv igjen';
}

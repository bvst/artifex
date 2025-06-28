import 'package:artifex/core/constants/app_constants.dart';
import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
    level: AppConstants.isDebug ? Level.debug : Level.info,
  );

  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  static void wtf(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }
}

// Extension for easier logging
extension LoggerExtension on Object {
  void logDebug([dynamic error, StackTrace? stackTrace]) {
    AppLogger.debug(toString(), error, stackTrace);
  }

  void logInfo([dynamic error, StackTrace? stackTrace]) {
    AppLogger.info(toString(), error, stackTrace);
  }

  void logWarning([dynamic error, StackTrace? stackTrace]) {
    AppLogger.warning(toString(), error, stackTrace);
  }

  void logError([dynamic error, StackTrace? stackTrace]) {
    AppLogger.error(toString(), error, stackTrace);
  }
}

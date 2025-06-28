import 'package:artifex/core/constants/app_constants.dart';
import 'package:logger/logger.dart';

class AppLogger {
  static Logger _logger = _createLogger();

  static Logger _createLogger() {
    // Check if running in test environment
    const isTest = bool.fromEnvironment('FLUTTER_TEST');

    if (isTest) {
      return Logger(
        printer: SimplePrinter(),
        level: Level.error, // Only errors during tests
      );
    }

    return Logger(
      printer: PrettyPrinter(
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
      level: AppConstants.isDebug ? Level.debug : Level.info,
    );
  }

  // Allow injecting a different logger for testing
  static void setLogger(Logger logger) {
    _logger = logger;
  }

  // Reset to default logger (useful for tests)
  static void resetLogger() {
    _logger = _createLogger();
  }

  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  static void error(
    String message, [
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? additionalData,
  ]) {
    if (additionalData != null && additionalData.isNotEmpty) {
      final enrichedMessage = '$message\nAdditional Data: $additionalData';
      _logger.e(enrichedMessage, error: error, stackTrace: stackTrace);
    } else {
      _logger.e(message, error: error, stackTrace: stackTrace);
    }
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

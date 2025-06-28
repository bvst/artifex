import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Error Handling Tests', () {
    setUp(() {
      // Reset error handling for each test
      FlutterError.onError = null;
    });

    test('should filter keyboard assertion errors', () {
      final List<String> loggedMessages = [];

      // Mock the logger to capture debug messages
      void mockDebugLog(
        String message, [
        dynamic error,
        StackTrace? stackTrace,
      ]) {
        loggedMessages.add(message);
      }

      // Set up error handler that filters keyboard errors
      FlutterError.onError = (FlutterErrorDetails details) {
        if (details.exception.toString().contains(
              'HardwareKeyboard._assertEventIsRegular',
            ) ||
            details.exception.toString().contains('_AssertionError')) {
          mockDebugLog(
            'Filtered keyboard assertion error: ${details.exception}',
          );
          return;
        }
      };

      // Simulate keyboard assertion error
      final keyboardError = FlutterErrorDetails(
        exception: Exception(
          'HardwareKeyboard._assertEventIsRegular test error',
        ),
        stack: StackTrace.current,
      );

      FlutterError.onError!(keyboardError);

      expect(loggedMessages, hasLength(1));
      expect(
        loggedMessages.first,
        contains('Filtered keyboard assertion error'),
      );
    });

    test('should not filter non-keyboard errors', () {
      final List<String> loggedMessages = [];
      final List<String> errorMessages = [];

      // Mock logger methods
      void mockDebugLog(
        String message, [
        dynamic error,
        StackTrace? stackTrace,
      ]) {
        loggedMessages.add(message);
      }

      void mockErrorLog(
        String message, [
        dynamic error,
        StackTrace? stackTrace,
      ]) {
        errorMessages.add(message);
      }

      // Set up error handler
      FlutterError.onError = (FlutterErrorDetails details) {
        if (details.exception.toString().contains(
              'HardwareKeyboard._assertEventIsRegular',
            ) ||
            details.exception.toString().contains('_AssertionError')) {
          mockDebugLog(
            'Filtered keyboard assertion error: ${details.exception}',
          );
          return;
        }

        mockErrorLog('Flutter error: ${details.exception}');
      };

      // Simulate non-keyboard error
      final normalError = FlutterErrorDetails(
        exception: Exception('Normal application error'),
        stack: StackTrace.current,
      );

      FlutterError.onError!(normalError);

      expect(loggedMessages, isEmpty);
      expect(errorMessages, hasLength(1));
      expect(errorMessages.first, contains('Normal application error'));
    });

    test('should handle assertion errors specifically', () {
      final List<String> loggedMessages = [];

      void mockDebugLog(
        String message, [
        dynamic error,
        StackTrace? stackTrace,
      ]) {
        loggedMessages.add(message);
      }

      FlutterError.onError = (FlutterErrorDetails details) {
        if (details.exception.toString().contains(
              'HardwareKeyboard._assertEventIsRegular',
            ) ||
            details.exception.toString().contains('_AssertionError')) {
          mockDebugLog(
            'Filtered keyboard assertion error: ${details.exception}',
          );
          return;
        }
      };

      // Simulate _AssertionError
      final assertionError = FlutterErrorDetails(
        exception: AssertionError('_AssertionError from keyboard handling'),
        stack: StackTrace.current,
      );

      FlutterError.onError!(assertionError);

      expect(loggedMessages, hasLength(1));
      expect(
        loggedMessages.first,
        contains('Filtered keyboard assertion error'),
      );
    });
  });
}

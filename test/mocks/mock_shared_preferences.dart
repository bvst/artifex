import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'mock_shared_preferences.mocks.dart';

export 'mock_shared_preferences.mocks.dart';

// Generate mocks for SharedPreferences
@GenerateMocks([SharedPreferences])
void main() {}

/// Mock SharedPreferences for testing
class MockSharedPreferencesHelper {
  static MockSharedPreferences create() => MockSharedPreferences();

  /// Set up mock with initial values
  static void setupWithValues(
    MockSharedPreferences mockPrefs,
    Map<String, dynamic> values,
  ) {
    // Set up getString
    for (final entry in values.entries) {
      if (entry.value is String) {
        when(mockPrefs.getString(entry.key)).thenReturn(entry.value as String);
      }
    }

    // Set up getBool
    for (final entry in values.entries) {
      if (entry.value is bool) {
        when(mockPrefs.getBool(entry.key)).thenReturn(entry.value as bool);
      }
    }

    // Set up getInt
    for (final entry in values.entries) {
      if (entry.value is int) {
        when(mockPrefs.getInt(entry.key)).thenReturn(entry.value as int);
      }
    }

    // Set up getDouble
    for (final entry in values.entries) {
      if (entry.value is double) {
        when(mockPrefs.getDouble(entry.key)).thenReturn(entry.value as double);
      }
    }

    // Set up getStringList
    for (final entry in values.entries) {
      if (entry.value is List<String>) {
        when(
          mockPrefs.getStringList(entry.key),
        ).thenReturn(entry.value as List<String>);
      }
    }
  }

  /// Set up mock to return successful write operations
  static void setupSuccessfulWrites(MockSharedPreferences mockPrefs) {
    when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
    when(mockPrefs.setBool(any, any)).thenAnswer((_) async => true);
    when(mockPrefs.setInt(any, any)).thenAnswer((_) async => true);
    when(mockPrefs.setDouble(any, any)).thenAnswer((_) async => true);
    when(mockPrefs.setStringList(any, any)).thenAnswer((_) async => true);
    when(mockPrefs.remove(any)).thenAnswer((_) async => true);
    when(mockPrefs.clear()).thenAnswer((_) async => true);
  }

  /// Set up mock to simulate write failures
  static void setupWriteFailures(MockSharedPreferences mockPrefs) {
    when(mockPrefs.setString(any, any)).thenAnswer((_) async => false);
    when(mockPrefs.setBool(any, any)).thenAnswer((_) async => false);
    when(mockPrefs.setInt(any, any)).thenAnswer((_) async => false);
    when(mockPrefs.setDouble(any, any)).thenAnswer((_) async => false);
    when(mockPrefs.setStringList(any, any)).thenAnswer((_) async => false);
    when(mockPrefs.remove(any)).thenAnswer((_) async => false);
    when(mockPrefs.clear()).thenAnswer((_) async => false);
  }

  /// Set up mock for empty/fresh preferences
  static void setupEmpty(MockSharedPreferences mockPrefs) {
    when(mockPrefs.getString(any)).thenReturn(null);
    when(mockPrefs.getBool(any)).thenReturn(null);
    when(mockPrefs.getInt(any)).thenReturn(null);
    when(mockPrefs.getDouble(any)).thenReturn(null);
    when(mockPrefs.getStringList(any)).thenReturn(null);
    when(mockPrefs.getKeys()).thenReturn(<String>{});
    when(mockPrefs.containsKey(any)).thenReturn(false);

    setupSuccessfulWrites(mockPrefs);
  }

  /// Set up mock for common app settings
  static void setupAppSettings(
    MockSharedPreferences mockPrefs, {
    bool onboardingComplete = true,
    String locale = 'en',
  }) {
    setupWithValues(mockPrefs, {
      'onboarding_complete': onboardingComplete,
      'locale': locale,
    });
    setupSuccessfulWrites(mockPrefs);
  }
}

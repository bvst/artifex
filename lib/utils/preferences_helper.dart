import 'package:artifex/core/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHelper {
  static const String _onboardingCompleteKey = 'onboarding_complete';

  static Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      return prefs.getBool(_onboardingCompleteKey) ?? false;
    } on TypeError {
      // Handle corrupted preferences gracefully - this is a specific business requirement
      // If the stored value is corrupted (wrong type), default to false (show onboarding)
      AppLogger.warning(
        'Corrupted preferences detected for onboarding key, defaulting to false',
      );

      // Clean up the corrupted value
      await prefs.remove(_onboardingCompleteKey);
      return false;
    }
  }

  static Future<void> setOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompleteKey, true);
  }

  static Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompleteKey, false);
  }
}

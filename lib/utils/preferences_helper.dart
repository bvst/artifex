import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHelper {
  static const String _onboardingCompleteKey = 'onboarding_complete';

  static Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      return prefs.getBool(_onboardingCompleteKey) ?? false;
    } catch (e) {
      // Handle corrupted preferences gracefully - default to false (show onboarding)
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

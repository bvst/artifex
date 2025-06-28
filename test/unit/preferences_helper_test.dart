import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:artifex/utils/preferences_helper.dart';

void main() {
  group('PreferencesHelper', () {
    setUp(() {
      // Reset SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    test('isOnboardingComplete returns false by default', () async {
      final isComplete = await PreferencesHelper.isOnboardingComplete();
      expect(isComplete, false);
    });

    test('setOnboardingComplete saves true correctly', () async {
      // Set onboarding as complete
      await PreferencesHelper.setOnboardingComplete();

      // Verify it was saved
      final isComplete = await PreferencesHelper.isOnboardingComplete();
      expect(isComplete, true);
    });

    test('resetOnboarding sets status back to false', () async {
      // Set onboarding complete
      await PreferencesHelper.setOnboardingComplete();
      expect(await PreferencesHelper.isOnboardingComplete(), true);

      // Reset onboarding
      await PreferencesHelper.resetOnboarding();
      expect(await PreferencesHelper.isOnboardingComplete(), false);
    });

    test('preferences persist across instances', () async {
      // Set value
      await PreferencesHelper.setOnboardingComplete();

      // Verify through the public API that the value persists
      expect(await PreferencesHelper.isOnboardingComplete(), true);
    });

    test('multiple resets work correctly', () async {
      // Initially false
      expect(await PreferencesHelper.isOnboardingComplete(), false);

      // Set and reset multiple times
      await PreferencesHelper.setOnboardingComplete();
      expect(await PreferencesHelper.isOnboardingComplete(), true);

      await PreferencesHelper.resetOnboarding();
      expect(await PreferencesHelper.isOnboardingComplete(), false);

      await PreferencesHelper.setOnboardingComplete();
      expect(await PreferencesHelper.isOnboardingComplete(), true);
    });
  });
}

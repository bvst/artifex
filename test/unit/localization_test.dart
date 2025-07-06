import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Localization Coverage Tests', () {
    test('all strings in English ARB file have Norwegian translations', () async {
      // Read both ARB files
      final enFile = File('lib/l10n/app_en.arb');
      final noFile = File('lib/l10n/app_no.arb');

      expect(
        enFile.existsSync(),
        isTrue,
        reason: 'English ARB file must exist',
      );
      expect(
        noFile.existsSync(),
        isTrue,
        reason: 'Norwegian ARB file must exist',
      );

      // Parse JSON content
      final enContent =
          jsonDecode(await enFile.readAsString()) as Map<String, dynamic>;
      final noContent =
          jsonDecode(await noFile.readAsString()) as Map<String, dynamic>;

      // Get all translatable keys (exclude metadata keys starting with @)
      final enKeys = enContent.keys
          .where((key) => !key.startsWith('@'))
          .toSet();
      final noKeys = noContent.keys
          .where((key) => !key.startsWith('@'))
          .toSet();

      // Find missing translations
      final missingInNorwegian = enKeys.difference(noKeys);

      expect(
        missingInNorwegian,
        isEmpty,
        reason:
            'The following keys are missing Norwegian translations: ${missingInNorwegian.join(", ")}',
      );
    });

    test('all filter names have translations', () async {
      // This test verifies that filter names used in UI have translation keys

      // Read English ARB to check for required filter translation keys
      final enFile = File('lib/l10n/app_en.arb');
      final enContent =
          jsonDecode(await enFile.readAsString()) as Map<String, dynamic>;

      // List of required filter translation keys
      final requiredFilterKeys = [
        'makeKidsDrawingReal',
        'makeKidsDrawingRealDescription',
      ];

      final missingKeys = <String>[];
      for (final key in requiredFilterKeys) {
        if (!enContent.containsKey(key)) {
          missingKeys.add(key);
        }
      }

      expect(
        missingKeys,
        isEmpty,
        reason:
            'The following filter translation keys are missing: ${missingKeys.join(", ")}',
      );
    });
  });
}

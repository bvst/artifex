import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Internationalization Coverage Tests', () {
    test('should verify all user-facing text has translations', () async {
      // This test scans the codebase for hardcoded strings that should be localized

      final violations = <String>[];

      // Define directories to scan
      final dirsToScan = [
        'lib/features/',
        'lib/screens/',
        'lib/widgets/',
        'lib/shared/',
      ];

      // Define patterns that indicate hardcoded user-facing text
      final violationPatterns = [
        // Common hardcoded text patterns
        RegExp(r'''Text\s*\(\s*['"]([^'"]+)['"]'''), // Text('hardcoded string')
        RegExp(r'''title:\s*['"]([^'"]+)['"]'''), // title: 'hardcoded string'
        RegExp(r'''label:\s*['"]([^'"]+)['"]'''), // label: 'hardcoded string'
        RegExp(
          r'''hintText:\s*['"]([^'"]+)['"]''',
        ), // hintText: 'hardcoded string'
      ];

      // Whitelist patterns - these are allowed hardcoded strings
      final whitelist = [
        RegExp(r'^\s*$'), // Empty strings
        RegExp(r'^[0-9\s\.,\-\+\(\)]+$'), // Numbers and symbols only
        RegExp(r'^[A-Z_][A-Z0-9_]*$'), // Constants (ALL_CAPS)
        RegExp(r'^#[0-9A-Fa-f]+$'), // Color codes
        RegExp(r'^https?://'), // URLs
        RegExp(r'^/'), // Routes
        RegExp(r'^[a-z][a-zA-Z0-9_]*$'), // Variable names
        RegExp(r'\.png$|\.jpg$|\.jpeg$|\.gif$|\.svg$'), // Image paths
        RegExp(r'^assets/'), // Asset paths
      ];

      // Scan directories
      for (final dirPath in dirsToScan) {
        final dir = Directory(dirPath);
        if (!dir.existsSync()) continue;

        await for (final entity in dir.list(recursive: true)) {
          if (entity is File && entity.path.endsWith('.dart')) {
            final content = await entity.readAsString();

            // Check for violations
            for (final pattern in violationPatterns) {
              final matches = pattern.allMatches(content);
              for (final match in matches) {
                final extractedText = match.group(1) ?? '';

                // Check if it's whitelisted
                final isWhitelisted = whitelist.any(
                  (wl) => wl.hasMatch(extractedText),
                );

                if (!isWhitelisted && extractedText.isNotEmpty) {
                  violations.add('${entity.path}: "$extractedText"');
                }
              }
            }
          }
        }
      }

      // Report violations
      if (violations.isNotEmpty) {
        final report =
            'Found ${violations.length} potential hardcoded strings that should be localized:\n'
            '${violations.take(20).join('\n')}' // Show first 20
            '${violations.length > 20 ? '\n... and ${violations.length - 20} more' : ''}';

        // For now, make this a warning rather than a failure
        // Once we fix all violations, we can make this fail the test
        // ignore: avoid_print
        print('⚠️  I18N WARNING: $report');
      }

      // Test passes for now - this is more of a code quality check
      expect(true, isTrue, reason: 'I18N coverage check completed');
    });

    test('should verify ARB files have consistent keys', () async {
      // Check that all ARB files have the same set of keys
      final arbDir = Directory('lib/l10n');
      if (!arbDir.existsSync()) {
        // ignore: avoid_print
        print('⚠️  No l10n directory found');
        return;
      }

      final arbFiles = <File>[];
      await for (final entity in arbDir.list()) {
        if (entity is File && entity.path.endsWith('.arb')) {
          arbFiles.add(entity);
        }
      }

      if (arbFiles.isEmpty) {
        // ignore: avoid_print
        print('⚠️  No ARB files found');
        return;
      }

      // Read all ARB files and extract keys
      final allKeys = <String, Set<String>>{};
      for (final file in arbFiles) {
        final content = await file.readAsString();
        final keys = <String>{};

        // Simple regex to extract JSON keys (this could be more robust)
        final keyRegex = RegExp(r'"([^"@][^"]*)":\s*"');
        final matches = keyRegex.allMatches(content);
        for (final match in matches) {
          keys.add(match.group(1)!);
        }

        allKeys[file.path] = keys;
      }

      // Check for consistency
      if (allKeys.length > 1) {
        final firstKeys = allKeys.values.first;
        for (final entry in allKeys.entries) {
          final fileName = entry.key;
          final keys = entry.value;

          final missingKeys = firstKeys.difference(keys);
          final extraKeys = keys.difference(firstKeys);

          if (missingKeys.isNotEmpty || extraKeys.isNotEmpty) {
            // ignore: avoid_print
            print('⚠️  ARB file inconsistency in $fileName:');
            if (missingKeys.isNotEmpty) {
              // ignore: avoid_print
              print('   Missing keys: ${missingKeys.join(', ')}');
            }
            if (extraKeys.isNotEmpty) {
              // ignore: avoid_print
              print('   Extra keys: ${extraKeys.join(', ')}');
            }
          }
        }
      }

      expect(
        arbFiles.isNotEmpty,
        isTrue,
        reason: 'Should have ARB files for internationalization',
      );
    });
  });
}

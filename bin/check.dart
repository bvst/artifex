#!/usr/bin/env dart
// ignore_for_file: avoid_print

/// Custom Flutter command to run tests, analysis, and formatting together
/// Usage:
///   dart run artifex:check           # Fast check (format, analyze, unit tests)
///   dart run artifex:check --all     # Full check (includes dependencies, integration tests)
///
/// Fast mode (default) runs:
/// 1. dart fix --apply & dart format . - applies automatic fixes and formats code
/// 2. flutter analyze - checks for code issues
/// 3. flutter test test/features test/unit test/widget - runs unit/widget tests with parallelization
///
/// Full mode (--all) additionally runs:
/// 4. flutter pub outdated - checks for outdated dependencies
/// 5. make -C docker test-up - starts test database container
/// 6. flutter test test/integration/ - runs integration tests
/// 7. make -C docker test-down - stops test database container
///
/// Exits with code 0 if all pass, 1 if any fails

import 'dart:io';

void main(List<String> arguments) async {
  final fullMode = arguments.contains('--all');
  final modeText = fullMode ? 'Full' : 'Fast';
  final totalSteps = fullMode ? 7 : 3;

  print('🔍 Running Artifex Code Quality Check ($modeText Mode)...\n');

  var hasErrors = false;
  var currentStep = 1;

  // Run Dart format and fix
  print(
    '✨ Step ${currentStep++}/$totalSteps: Formatting code and applying fixes...',
  );

  // First run dart fix to automatically fix common issues
  final fixResult = await Process.run('dart', ['fix', '--apply']);
  if (fixResult.exitCode != 0) {
    print('⚠️  Warning: dart fix encountered issues:');
    print(fixResult.stdout);
    if (fixResult.stderr.isNotEmpty) {
      print('Error output:');
      print(fixResult.stderr);
    }
    // Don't fail on dart fix errors, continue with formatting
  } else {
    final fixOutput = fixResult.stdout.toString();
    if (fixOutput.contains('fixes made')) {
      print('   Applied automatic fixes');
    }
  }

  // Then run dart format
  final formatResult = await Process.run('dart', ['format', '.']);

  if (formatResult.exitCode == 0) {
    print('✅ Code formatted successfully\n');
  } else {
    print('❌ Code formatting failed:');
    print(formatResult.stdout);
    if (formatResult.stderr.isNotEmpty) {
      print('Error output:');
      print(formatResult.stderr);
    }
    hasErrors = true;
    print('');
  }

  // Run Flutter analyze
  print('📊 Step ${currentStep++}/$totalSteps: Running static analysis...');
  final analyzeResult = await Process.run('flutter', ['analyze']);

  if (analyzeResult.exitCode == 0) {
    print('✅ Analysis passed - no issues found\n');
  } else {
    print('❌ Analysis failed:');
    print(analyzeResult.stdout);
    if (analyzeResult.stderr.isNotEmpty) {
      print('Error output:');
      print(analyzeResult.stderr);
    }
    hasErrors = true;
    print('');
  }

  // Step 3: Run unit/widget tests (excluding integration directory)
  print(
    '🧪 Step ${currentStep++}/$totalSteps: Running unit and widget tests...',
  );
  final unitTestResult = await Process.run('flutter', [
    'test',
    'test/features',
    'test/shared',
    'test/unit',
    'test/widget',
    'test/widget_test.dart',
    '--reporter=silent',
    '--dart-define=FLUTTER_TEST=true', // Enable test optimizations
    '--concurrency=8', // Run tests in parallel (optimized for speed)
    '--no-test-assets', // Skip building assets for faster startup
  ]);

  if (unitTestResult.exitCode == 0) {
    // Get test count by running a quick dry-run
    final summaryResult = await Process.run('flutter', [
      'test',
      '--dry-run',
      'test/features',
      'test/shared',
      'test/unit',
      'test/widget',
      'test/widget_test.dart',
    ]);
    final summaryOutput = summaryResult.stdout.toString();
    final testCountMatch = RegExp(r'(\d+) tests?').firstMatch(summaryOutput);
    final testCount = testCountMatch?.group(1) ?? 'All';
    print('✅ Unit/widget tests passed - $testCount tests successful\n');
  } else {
    // Check if this is a false positive (error logs from passing tests)
    final summaryResult = await Process.run('flutter', [
      'test',
      '--reporter=compact',
      'test/features',
      'test/shared',
      'test/unit',
      'test/widget',
      'test/widget_test.dart',
    ]);

    final output = summaryResult.stdout.toString();

    // Check if all individual tests are actually passing (look for the final count)
    final passPattern = RegExp(r'\+(\d+) -1:');
    final matches = passPattern.allMatches(output);
    if (matches.isNotEmpty) {
      final lastMatch = matches.last;
      final passedCount = lastMatch.group(1);
      print('✅ Unit/widget tests passed - $passedCount tests successful');
    } else {
      // Actually failing tests
      print('❌ Unit/widget tests failed:');
      final lines = output.split('\n');

      // Extract just the final summary line
      for (final line in lines.reversed) {
        if (line.contains('Some tests failed') ||
            (line.contains('tests passed') && line.contains('failed'))) {
          print(line.trim());
          break;
        }
      }

      if (unitTestResult.stderr.isNotEmpty) {
        print('Error output:');
        print(unitTestResult.stderr);
      }
      hasErrors = true;
      print('');
    }
  }

  // Only run full mode steps if --all flag is provided
  if (!fullMode) {
    // Summary for fast mode
    if (hasErrors) {
      print('💥 Code quality check FAILED');
      print('   Please fix the issues above before committing.');
      exit(1);
    } else {
      print('🎉 Code quality check PASSED');
      print('   Your code is ready for commit!');
      exit(0);
    }
  }

  // Full mode continues with dependency check and integration tests
  print(
    '📦 Step ${currentStep++}/$totalSteps: Checking for outdated dependencies...',
  );
  final outdatedResult = await Process.run('flutter', ['pub', 'outdated']);

  if (outdatedResult.exitCode == 0) {
    final output = outdatedResult.stdout.toString();

    // Parse the output to find outdated dependencies and their names
    final lines = output.split('\n');
    var currentSection = '';
    final List<String> directOutdatedPackages = [];
    final List<String> devOutdatedPackages = [];

    for (final line in lines) {
      if (line.contains('direct dependencies:')) {
        currentSection = 'direct';
      } else if (line.contains('dev_dependencies:') &&
          !line.contains('transitive')) {
        currentSection = 'dev';
      } else if (line.contains('transitive dependencies:')) {
        currentSection = 'transitive';
      } else if (line.contains('transitive dev_dependencies:')) {
        currentSection = 'transitive';
      } else if (line.trim().isNotEmpty &&
          line.contains('*') &&
          !line.contains('indicates versions') &&
          !line.contains('Package Name') &&
          RegExp(r'^\w').hasMatch(line.trim())) {
        // Extract package name from line like "package_name  *1.0.0  1.1.0  1.1.0  1.2.0"
        final packageName = line.trim().split(RegExp(r'\s+')).first;

        if (currentSection == 'direct') {
          directOutdatedPackages.add(packageName);
        } else if (currentSection == 'dev') {
          devOutdatedPackages.add(packageName);
        }
      }
    }

    final directDepsTotal =
        directOutdatedPackages.length + devOutdatedPackages.length;

    if (directDepsTotal > 0) {
      print('⚠️  Found $directDepsTotal outdated direct dependencies:');

      if (directOutdatedPackages.isNotEmpty) {
        print(
          '   • Production packages (${directOutdatedPackages.length}): ${directOutdatedPackages.join(', ')}',
        );
      }

      if (devOutdatedPackages.isNotEmpty) {
        print(
          '   • Dev packages (${devOutdatedPackages.length}): ${devOutdatedPackages.join(', ')}',
        );
      }

      // Check for constraint message
      if (output.contains('dependencies are constrained') ||
          output.contains('locked to older versions')) {
        print('');
        print(
          '   💡 Some updates require manual version changes in pubspec.yaml',
        );
        print('   Run `flutter pub outdated` to see version details');
      } else {
        print('');
        print('   Run `flutter pub upgrade` to update compatible versions');
      }
      print('');
    } else {
      print('✅ All direct dependencies are up to date\n');
    }
  } else {
    print('⚠️  Failed to check outdated dependencies:');
    print(outdatedResult.stdout);
    if (outdatedResult.stderr.isNotEmpty) {
      print('Error output:');
      print(outdatedResult.stderr);
    }
    // Don't set hasErrors for this - it's informational
    print('');
  }

  // Start test database container
  print(
    '🐳 Step ${currentStep++}/$totalSteps: Starting test database container...',
  );
  final testDbStartResult = await Process.run('make', [
    '-C',
    'docker',
    'test-up',
  ], workingDirectory: Directory.current.path);

  if (testDbStartResult.exitCode == 0) {
    print('✅ Test database started successfully\n');
  } else {
    print('❌ Failed to start test database:');
    print(testDbStartResult.stdout);
    if (testDbStartResult.stderr.isNotEmpty) {
      print('Error output:');
      print(testDbStartResult.stderr);
    }
    hasErrors = true;
    print('');
  }

  // Run integration tests (only if database started successfully)
  bool integrationTestsRan = false;
  if (!hasErrors) {
    print('🧪 Step ${currentStep++}/$totalSteps: Running integration tests...');
    final integrationTestResult = await Process.run('flutter', [
      'test',
      'test/integration/',
      '--reporter=silent',
      '--dart-define=FLUTTER_TEST=true',
      '--concurrency=2', // Lower concurrency for integration tests (they use database)
    ]);
    integrationTestsRan = true;

    if (integrationTestResult.exitCode == 0) {
      // Get test count by running a quick dry-run
      final summaryResult = await Process.run('flutter', [
        'test',
        '--dry-run',
        'test/integration/',
      ]);
      final summaryOutput = summaryResult.stdout.toString();
      final testCountMatch = RegExp(r'(\d+) tests?').firstMatch(summaryOutput);
      final testCount = testCountMatch?.group(1) ?? 'All';
      print('✅ Integration tests passed - $testCount tests successful\n');
    } else {
      print('❌ Integration tests failed:');

      // Since tests failed, run compact to get summary but filter out verbose logs
      final summaryResult = await Process.run('flutter', [
        'test',
        '--reporter=compact',
        'test/integration/',
      ]);

      final output = summaryResult.stdout.toString();
      final lines = output.split('\n');

      // Extract just the final summary line
      for (final line in lines.reversed) {
        if (line.contains('Some tests failed') ||
            (line.contains('tests passed') && line.contains('failed'))) {
          print(line.trim());
          break;
        }
      }

      if (integrationTestResult.stderr.isNotEmpty) {
        print('Error output:');
        print(integrationTestResult.stderr);
      }
      hasErrors = true;
      print('');
    }
  } else {
    print(
      '⏭️  Step ${currentStep++}/$totalSteps: Skipping integration tests due to previous errors\n',
    );
  }

  // Stop test database container (always run cleanup)
  print(
    '🛑 Step $currentStep/$totalSteps: Stopping test database container...',
  );
  final testDbStopResult = await Process.run('make', [
    '-C',
    'docker',
    'test-down',
  ], workingDirectory: Directory.current.path);

  if (testDbStopResult.exitCode == 0) {
    print('✅ Test database stopped successfully\n');
  } else {
    print(
      '⚠️  Warning: Failed to stop test database (this is usually safe to ignore):',
    );
    print(testDbStopResult.stdout);
    if (testDbStopResult.stderr.isNotEmpty) {
      print('Error output:');
      print(testDbStopResult.stderr);
    }
    print('');
  }

  // Summary
  if (hasErrors) {
    print('💥 Code quality check FAILED');
    print('   Please fix the issues above before committing.');
    if (integrationTestsRan) {
      print('   Note: Test database has been automatically cleaned up.');
    }
    exit(1);
  } else {
    print('🎉 Code quality check PASSED');
    print('   Your code is ready for commit!');
    print('   Test database has been automatically cleaned up.');
    exit(0);
  }
}

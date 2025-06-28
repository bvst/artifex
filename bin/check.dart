#!/usr/bin/env dart
// ignore_for_file: avoid_print

/// Custom Flutter command to run tests, analysis, and formatting together
/// Usage:
///   dart run artifex:check           # Fast check (format, analyze, unit tests)
///   dart run artifex:check --all     # Full check (includes dependencies, integration tests)
///
/// Fast mode (default) runs:
/// 1. dart format . - formats all code consistently
/// 2. flutter analyze - checks for code issues
/// 3. flutter test test/features test/unit test/widget - runs unit/widget tests only
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

  // Run Dart format
  print('✨ Step ${currentStep++}/$totalSteps: Formatting code...');
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
    '--reporter=compact',
    '--dart-define=FLUTTER_TEST=true', // Enable test optimizations
  ]);

  if (unitTestResult.exitCode == 0) {
    // Extract test count from output
    final output = unitTestResult.stdout.toString();
    final testCountMatch = RegExp(r'(\d+) tests?').firstMatch(output);
    final testCount = testCountMatch?.group(1) ?? 'All';
    print('✅ Unit/widget tests passed - $testCount tests successful\n');
  } else {
    print('❌ Unit/widget tests failed:');
    print(unitTestResult.stdout);
    if (unitTestResult.stderr.isNotEmpty) {
      print('Error output:');
      print(unitTestResult.stderr);
    }
    hasErrors = true;
    print('');
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

    // Parse the output to count outdated dependencies
    final lines = output.split('\n');
    var directOutdated = 0;
    var devOutdated = 0;
    var transitiveOutdated = 0;
    var currentSection = '';

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
        // This line has an outdated dependency
        if (currentSection == 'direct')
          directOutdated++;
        else if (currentSection == 'dev')
          devOutdated++;
        else if (currentSection == 'transitive')
          transitiveOutdated++;
      }
    }

    final directDepsTotal = directOutdated + devOutdated;

    if (directDepsTotal > 0) {
      print('⚠️  Found $directDepsTotal outdated direct dependencies:');
      if (directOutdated > 0) {
        print('   • $directOutdated production dependencies');
      }
      if (devOutdated > 0) {
        print('   • $devOutdated dev dependencies');
      }

      // Check for constraint message
      if (output.contains('dependencies are constrained')) {
        print('');
        print(
          '   💡 Some updates require manual version changes in pubspec.yaml',
        );
        print('   Run `flutter pub outdated` to see details');
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
      '--reporter=compact',
    ]);
    integrationTestsRan = true;

    if (integrationTestResult.exitCode == 0) {
      // Extract test count from output
      final output = integrationTestResult.stdout.toString();
      final testCountMatch = RegExp(r'(\d+) tests?').firstMatch(output);
      final testCount = testCountMatch?.group(1) ?? 'All';
      print('✅ Integration tests passed - $testCount tests successful\n');
    } else {
      print('❌ Integration tests failed:');
      print(integrationTestResult.stdout);
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

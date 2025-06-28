#!/usr/bin/env dart
// ignore_for_file: avoid_print

/// Custom Flutter command to run tests, analysis, and formatting together
/// Usage: dart run artifex:check
///
/// This command runs:
/// 1. Dart format - formats all code consistently
/// 2. Flutter analyze - checks for code issues
/// 3. Check outdated dependencies - shows which packages need updates
/// 4. Start test database container
/// 5. Flutter test - runs all tests (including integration tests)
/// 6. Stop test database container
///
/// Exits with code 0 if all pass, 1 if any fails

import 'dart:io';

void main(List<String> arguments) async {
  print('🔍 Running Artifex Code Quality Check...\n');

  var hasErrors = false;

  // Run Dart format
  print('✨ Step 1/5: Formatting code...');
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
  print('📊 Step 2/6: Running static analysis...');
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

  // Check for outdated dependencies
  print('📦 Step 3/6: Checking for outdated dependencies...');
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

    final totalOutdated = directOutdated + devOutdated + transitiveOutdated;

    if (totalOutdated > 0) {
      print('⚠️  Found $totalOutdated outdated dependencies:');
      if (directOutdated > 0) {
        print('   • $directOutdated direct dependencies');
      }
      if (devOutdated > 0) {
        print('   • $devOutdated dev dependencies');
      }
      if (transitiveOutdated > 0) {
        print(
          '   • $transitiveOutdated transitive dependencies (auto-updated)',
        );
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
      print('✅ All dependencies are up to date\n');
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
  print('🐳 Step 4/6: Starting test database container...');
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

  // Run Flutter test (only if database started successfully)
  bool testsRan = false;
  if (!hasErrors) {
    print('🧪 Step 5/6: Running tests...');
    final testResult = await Process.run('flutter', [
      'test',
      '--reporter=compact',
    ]);
    testsRan = true;

    if (testResult.exitCode == 0) {
      // Extract test count from output
      final output = testResult.stdout.toString();
      final lines = output.split('\n');
      final lastLine = lines
          .where((line) => line.contains('All tests passed!'))
          .firstOrNull;

      if (lastLine != null) {
        // Find the test count in the output
        final testCountMatch = RegExp(r'(\d+) tests?').firstMatch(output);
        final testCount = testCountMatch?.group(1) ?? 'All';
        print('✅ Tests passed - $testCount tests successful\n');
      } else {
        print('✅ Tests passed\n');
      }
    } else {
      print('❌ Tests failed:');
      print(testResult.stdout);
      if (testResult.stderr.isNotEmpty) {
        print('Error output:');
        print(testResult.stderr);
      }
      hasErrors = true;
      print('');
    }
  } else {
    print('⏭️  Step 5/6: Skipping tests due to previous errors\n');
  }

  // Stop test database container (always run cleanup)
  print('🛑 Step 6/6: Stopping test database container...');
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
    if (testsRan) {
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

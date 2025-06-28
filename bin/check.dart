#!/usr/bin/env dart
// ignore_for_file: avoid_print

/// Custom Flutter command to run tests, analysis, and formatting together
/// Usage: dart run artifex:check
///
/// This command runs:
/// 1. Dart format - formats all code consistently
/// 2. Flutter analyze - checks for code issues
/// 3. Start test database container
/// 4. Flutter test - runs all tests (including integration tests)
/// 5. Stop test database container
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
  print('📊 Step 2/5: Running static analysis...');
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

  // Start test database container
  print('🐳 Step 3/5: Starting test database container...');
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
    print('🧪 Step 4/5: Running tests...');
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
    print('⏭️  Step 4/5: Skipping tests due to previous errors\n');
  }

  // Stop test database container (always run cleanup)
  print('🛑 Step 5/5: Stopping test database container...');
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

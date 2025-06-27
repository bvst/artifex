#!/usr/bin/env dart

// ignore_for_file: avoid_print

/// Shorter alias for the check command
/// Usage: flutter pub run artifex:test_analyze

import 'dart:io';

void main(List<String> arguments) async {
  print('🔍 Running Artifex Code Quality Check...\n');
  
  var hasErrors = false;
  
  // Run Flutter analyze
  print('📊 Step 1/2: Running static analysis...');
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
  
  // Run Flutter test
  print('🧪 Step 2/2: Running tests...');
  final testResult = await Process.run('flutter', ['test', '--reporter=compact']);
  
  if (testResult.exitCode == 0) {
    // Extract test count from output
    final output = testResult.stdout.toString();
    final lines = output.split('\n');
    final lastLine = lines.where((line) => line.contains('All tests passed!')).firstOrNull;
    
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
  
  // Summary
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
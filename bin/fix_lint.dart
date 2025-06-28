#!/usr/bin/env dart

import 'dart:io';

Future<void> main(List<String> args) async {
  print('🔧 Artifex Lint Fixer');
  print('════════════════════════════════════════════════════');

  if (args.isEmpty) {
    print('Usage: dart run artifex:fix_lint <command>');
    print('');
    print('Available commands:');
    print('  auto       - Fix automatically fixable issues');
    print('  imports    - Fix package imports');
    print('  const      - Add missing const constructors');
    print('  trailing   - Add trailing commas');
    print('  analysis   - Show categorized analysis results');
    print('  count      - Count issues by type');
    return;
  }

  final command = args[0];

  switch (command) {
    case 'auto':
      await _runAutoFix();
      break;
    case 'imports':
      await _fixPackageImports();
      break;
    case 'const':
      await _fixConstConstructors();
      break;
    case 'trailing':
      await _fixTrailingCommas();
      break;
    case 'analysis':
      await _showCategorizedAnalysis();
      break;
    case 'count':
      await _countIssues();
      break;
    default:
      print('❌ Unknown command: $command');
      exit(1);
  }
}

Future<void> _runAutoFix() async {
  print('🚀 Running automatic fixes...');

  // Run dart fix to apply automatic fixes
  final result = await Process.run('dart', ['fix', '--apply']);

  if (result.exitCode == 0) {
    print('✅ Automatic fixes applied successfully');
    print(result.stdout);
  } else {
    print('❌ Automatic fixes failed');
    print(result.stderr);
  }
}

Future<void> _fixPackageImports() async {
  print('📦 Fixing package imports...');

  // Find all Dart files in lib/
  final result = await Process.run('find', ['lib/', '-name', '*.dart']);
  if (result.exitCode != 0) {
    print('❌ Failed to find Dart files');
    return;
  }

  final files = result.stdout.toString().trim().split('\n');

  for (final file in files) {
    if (file.isEmpty) continue;
    await _fixImportsInFile(file);
  }

  print('✅ Package imports fixed');
}

Future<void> _fixImportsInFile(String filePath) async {
  final file = File(filePath);
  if (!await file.exists()) return;

  final content = await file.readAsString();
  final lines = content.split('\n');
  final updatedLines = <String>[];

  for (final line in lines) {
    if (line.startsWith('import ') && !line.contains('package:')) {
      // Check if it's a relative import to lib/
      if (line.contains("'lib/") || line.contains('"lib/')) {
        final updated = line
            .replaceAll("'lib/", "'package:artifex/")
            .replaceAll('"lib/', '"package:artifex/');
        updatedLines.add(updated);
        continue;
      }

      // Check if it's a relative import within lib/
      if ((line.contains("'../") || line.contains('"../')) &&
          filePath.startsWith('lib/')) {
        // Convert relative to package import
        final importPath = _convertToPackageImport(line, filePath);
        if (importPath != null) {
          updatedLines.add(importPath);
          continue;
        }
      }
    }
    updatedLines.add(line);
  }

  await file.writeAsString(updatedLines.join('\n'));
}

String? _convertToPackageImport(String importLine, String currentFile) {
  // This is a simplified conversion - in practice, you'd need more sophisticated logic
  final regex = RegExp(r'''import\s+['"]([^'"]+)['"]''');
  final match = regex.firstMatch(importLine);

  if (match != null) {
    final importPath = match.group(1)!;

    // If it's a relative import starting with '../', try to resolve it
    if (importPath.startsWith('../')) {
      // Simple heuristic: if we're in lib/ and importing with ../,
      // it's probably still within lib/
      final packagePath = importPath.replaceAll('../', '');
      return importLine
          .replaceAll("'$importPath'", "'package:artifex/$packagePath'")
          .replaceAll('"$importPath"', '"package:artifex/$packagePath"');
    }
  }

  return null;
}

Future<void> _fixConstConstructors() async {
  print('🏗️ Adding const constructors...');

  // This would require more sophisticated parsing to implement safely
  print('⚠️ Manual review required for const constructors');
  print('   Use your IDE\'s quick fix feature for: prefer_const_constructors');
}

Future<void> _fixTrailingCommas() async {
  print('🔗 Adding trailing commas...');

  // Run dart format which should add trailing commas automatically
  final result = await Process.run('dart', ['format', '.']);

  if (result.exitCode == 0) {
    print('✅ Trailing commas added via formatting');
  } else {
    print('❌ Formatting failed');
    print(result.stderr);
  }
}

Future<void> _showCategorizedAnalysis() async {
  print('📊 Categorized Analysis Results');
  print('════════════════════════════════════════════════════');

  final result = await Process.run('flutter', ['analyze', '--no-fatal-infos']);
  if (result.exitCode != 0) {
    final output = result.stdout.toString();
    final issues = _parseAnalysisOutput(output);

    _printIssuesByCategory(issues);
  }
}

Future<void> _countIssues() async {
  print('📈 Issue Count by Type');
  print('════════════════════════════════════════════════════');

  final result = await Process.run('flutter', ['analyze', '--no-fatal-infos']);
  final output = result.stdout.toString();
  final issues = _parseAnalysisOutput(output);

  final counts = <String, int>{};
  for (final issue in issues) {
    counts[issue.rule] = (counts[issue.rule] ?? 0) + 1;
  }

  final sortedCounts = counts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  for (final entry in sortedCounts.take(20)) {
    print('${entry.value.toString().padLeft(3)} × ${entry.key}');
  }

  if (sortedCounts.length > 20) {
    final remaining = sortedCounts.length - 20;
    print('... and $remaining more issue types');
  }
}

List<AnalysisIssue> _parseAnalysisOutput(String output) {
  final issues = <AnalysisIssue>[];
  final lines = output.split('\n');

  for (final line in lines) {
    if (line.contains('•') && line.contains('•')) {
      final parts = line.split('•');
      if (parts.length >= 3) {
        final message = parts[1].trim();
        final rule = parts.last.trim();
        final severity = line.contains('warning') ? 'warning' : 'info';

        issues.add(
          AnalysisIssue(message: message, rule: rule, severity: severity),
        );
      }
    }
  }

  return issues;
}

void _printIssuesByCategory(List<AnalysisIssue> issues) {
  final categories = <String, List<AnalysisIssue>>{
    'Package Imports': [],
    'Const Constructors': [],
    'Redundant Values': [],
    'Code Organization': [],
    'Performance': [],
    'Other': [],
  };

  for (final issue in issues) {
    if (issue.rule.contains('package_imports')) {
      categories['Package Imports']!.add(issue);
    } else if (issue.rule.contains('const')) {
      categories['Const Constructors']!.add(issue);
    } else if (issue.rule.contains('redundant')) {
      categories['Redundant Values']!.add(issue);
    } else if (issue.rule.contains('ordering') || issue.rule.contains('sort')) {
      categories['Code Organization']!.add(issue);
    } else if (issue.rule.contains('performance') ||
        issue.rule.contains('build')) {
      categories['Performance']!.add(issue);
    } else {
      categories['Other']!.add(issue);
    }
  }

  for (final entry in categories.entries) {
    if (entry.value.isNotEmpty) {
      print('\n${entry.key} (${entry.value.length} issues):');
      final counts = <String, int>{};
      for (final issue in entry.value) {
        counts[issue.rule] = (counts[issue.rule] ?? 0) + 1;
      }

      for (final ruleEntry in counts.entries) {
        print('  ${ruleEntry.value.toString().padLeft(3)} × ${ruleEntry.key}');
      }
    }
  }
}

class AnalysisIssue {
  final String message;
  final String rule;
  final String severity;

  AnalysisIssue({
    required this.message,
    required this.rule,
    required this.severity,
  });
}

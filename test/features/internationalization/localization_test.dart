import 'package:artifex/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_app_wrapper.dart';

void main() {
  group('Internationalization Tests', () {
    testWidgets('should load English localizations', (tester) async {
      await tester.pumpWidget(
        TestAppWrapper.createSimpleApp(
          locale: const Locale('en'),
          child: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              return Column(
                children: [
                  Text(l10n.appTitle),
                  Text(l10n.appTagline),
                  Text(l10n.welcomeTitle),
                ],
              );
            },
          ),
        ),
      );

      // Verify English text is loaded
      expect(find.text('Artifex'), findsOneWidget);
      expect(find.text('Your World, Reimagined'), findsOneWidget);
      expect(find.text('Transform Your Photos with AI'), findsOneWidget);
    });

    testWidgets('should load Norwegian localizations', (tester) async {
      await tester.pumpWidget(
        TestAppWrapper.createSimpleApp(
          locale: const Locale('no'),
          child: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              return Column(
                children: [
                  Text(l10n.appTitle),
                  Text(l10n.appTagline),
                  Text(l10n.welcomeTitle),
                ],
              );
            },
          ),
        ),
      );

      // Verify Norwegian text is loaded
      expect(find.text('Artifex'), findsOneWidget);
      expect(find.text('Din verden, nyforestilt'), findsOneWidget);
      expect(find.text('Forvandle bildene dine med KI'), findsOneWidget);
    });

    testWidgets('should format messages with parameters', (tester) async {
      await tester.pumpWidget(
        TestAppWrapper.createSimpleApp(
          locale: const Locale('en'),
          child: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              return Text(l10n.photoCaptureError('Test error'));
            },
          ),
        ),
      );

      // Verify parameterized message works
      expect(find.text('Error capturing photo: Test error'), findsOneWidget);
    });
  });
}

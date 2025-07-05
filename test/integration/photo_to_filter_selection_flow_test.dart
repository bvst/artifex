import 'package:artifex/features/ai_transformation/presentation/screens/filter_selection_screen.dart';
import 'package:artifex/features/ai_transformation/presentation/widgets/filter_card.dart';
import 'package:artifex/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Photo to Filter Selection Flow', () {
    testWidgets(
      'should display image and filters when navigation flow completes',
      (tester) async {
        // Arrange - simulate completing the photo selection flow
        const testImagePath = '/test/photo.jpg';

        // Act - navigate to filter selection (simulating complete flow)
        await tester.pumpWidget(
          const MaterialApp(
            home: FilterSelectionScreen(imagePath: testImagePath),
            localizationsDelegates: [AppLocalizations.delegate],
            supportedLocales: [Locale('en'), Locale('no')],
          ),
        );

        // Assert - essential flow elements are present
        expect(find.byType(FilterSelectionScreen), findsOneWidget);
        expect(find.byType(Image), findsOneWidget); // User's photo
        expect(find.byType(FilterCard), findsWidgets); // Filter options

        // Verify flow data integrity - image path passed correctly
        final screen = tester.widget<FilterSelectionScreen>(
          find.byType(FilterSelectionScreen),
        );
        expect(screen.imagePath, equals(testImagePath));
      },
    );

    testWidgets(
      'should provide expected filter options (business requirement)',
      (tester) async {
        // Arrange - ensure adequate screen space for filter display
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.reset());

        await tester.pumpWidget(
          const MaterialApp(
            home: FilterSelectionScreen(imagePath: '/test/photo.jpg'),
            localizationsDelegates: [AppLocalizations.delegate],
            supportedLocales: [Locale('en'), Locale('no')],
          ),
        );

        // Make scrollable content visible if needed
        if (find.byType(GridView).evaluate().isNotEmpty) {
          await tester.drag(find.byType(GridView), const Offset(0, -100));
          await tester.pump();
        }

        // Assert - business requirement: exactly 5 filter options
        expect(find.byType(FilterCard), findsNWidgets(5));
      },
    );

    testWidgets('should support basic user interactions without errors', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FilterSelectionScreen(imagePath: '/test/photo.jpg'),
          localizationsDelegates: [AppLocalizations.delegate],
          supportedLocales: [Locale('en'), Locale('no')],
        ),
      );

      // Act & Assert - basic interactions should work without crashes

      // Back navigation should be available
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump();

      // Filter selection should be interactive
      final firstFilter = find.byType(FilterCard).first;
      expect(firstFilter, findsOneWidget);
      await tester.tap(firstFilter);
      await tester.pump();
    });
  });
}

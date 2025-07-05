import 'package:artifex/features/ai_transformation/presentation/screens/filter_selection_screen.dart';
import 'package:artifex/features/ai_transformation/presentation/widgets/filter_card.dart';
import 'package:artifex/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Photo to Filter Selection Flow Integration Test', () {
    testWidgets(
      'filter selection screen should be properly constructed with image path',
      (tester) async {
        // Simple test to verify filter selection screen navigation works
        const testPhotoPath = '/test/photo.jpg';

        await tester.pumpWidget(
          const MaterialApp(
            home: FilterSelectionScreen(imagePath: testPhotoPath),
            localizationsDelegates: [AppLocalizations.delegate],
            supportedLocales: [Locale('en'), Locale('no')],
          ),
        );

        // Verify we're on filter selection screen
        expect(find.byType(FilterSelectionScreen), findsOneWidget);

        // Verify the correct image path was passed
        final filterScreen = tester.widget<FilterSelectionScreen>(
          find.byType(FilterSelectionScreen),
        );
        expect(filterScreen.imagePath, equals(testPhotoPath));
      },
    );

    testWidgets(
      'filter selection screen should display the captured image path',
      (tester) async {
        // Arrange
        const testImagePath = '/test/image.jpg';

        // Navigate directly to filter selection screen
        await tester.pumpWidget(
          const MaterialApp(
            home: FilterSelectionScreen(imagePath: testImagePath),
            localizationsDelegates: [AppLocalizations.delegate],
            supportedLocales: [Locale('en'), Locale('no')],
          ),
        );

        // Assert - Image widget should be present
        expect(find.byType(Image), findsOneWidget);

        // The FilterSelectionScreen should have received the correct path
        final filterScreen = tester.widget<FilterSelectionScreen>(
          find.byType(FilterSelectionScreen),
        );
        expect(filterScreen.imagePath, equals(testImagePath));
      },
    );

    testWidgets('should show all 5 filter options after photo selection', (
      tester,
    ) async {
      // Arrange
      const testImagePath = '/test/image.jpg';

      // Set larger screen size for grid visibility
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(
        const MaterialApp(
          home: FilterSelectionScreen(imagePath: testImagePath),
          localizationsDelegates: [AppLocalizations.delegate],
          supportedLocales: [Locale('en'), Locale('no')],
        ),
      );

      // Scroll to ensure all filters are visible
      await tester.drag(find.byType(GridView), const Offset(0, -300));
      await tester.pump();

      // Assert - All 5 filters should be displayed
      expect(find.byType(FilterCard), findsNWidgets(5));

      // Check for specific filter icons
      expect(find.byIcon(Icons.draw), findsOneWidget);
      expect(find.byIcon(Icons.rocket_launch), findsOneWidget);
      expect(find.byIcon(Icons.portrait), findsOneWidget);
      expect(find.byIcon(Icons.location_city), findsOneWidget);
      expect(find.byIcon(Icons.brush), findsOneWidget);
    });

    testWidgets('should handle back navigation from filter selection to home', (
      tester,
    ) async {
      // This would require a more complex setup with navigation stack
      // For now, we test that the back button exists and is tappable

      await tester.pumpWidget(
        const MaterialApp(
          home: FilterSelectionScreen(imagePath: '/test/image.jpg'),
          localizationsDelegates: [AppLocalizations.delegate],
          supportedLocales: [Locale('en'), Locale('no')],
        ),
      );

      // Find back button
      final backButton = find.byIcon(Icons.arrow_back);
      expect(backButton, findsOneWidget);

      // Tap back button
      await tester.tap(backButton);
      await tester.pump();
    });
  });
}

import 'package:artifex/features/ai_transformation/presentation/screens/filter_selection_screen.dart';
import 'package:artifex/features/ai_transformation/presentation/screens/processing_screen.dart';
import 'package:artifex/features/ai_transformation/presentation/widgets/filter_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/test_app_wrapper.dart';

void main() {
  group('FilterSelectionScreen', () {
    testWidgets('should display app bar with back button', (tester) async {
      // RED: This test should fail as FilterSelectionScreen doesn't exist yet
      await tester.pumpWidget(
        const TestAppWrapper(
          child: FilterSelectionScreen(imagePath: '/test/image.jpg'),
        ),
      );

      // Should have an app bar with back button
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('should display selected image preview', (tester) async {
      const testImagePath = '/test/image.jpg';

      await tester.pumpWidget(
        const TestAppWrapper(
          child: FilterSelectionScreen(imagePath: testImagePath),
        ),
      );

      // Should display the selected image
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('should display all available filters', (tester) async {
      // Set a larger screen size to ensure all filters are visible
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(
        const TestAppWrapper(
          child: FilterSelectionScreen(imagePath: '/test/image.jpg'),
        ),
      );

      // Scroll down to ensure all filters are visible
      await tester.drag(find.byType(GridView), const Offset(0, -300));
      await tester.pump();

      // Should display all 5 initial filters
      expect(find.byType(FilterCard), findsNWidgets(5));

      // Check for filter names (using icons instead of text for i18n)
      expect(find.byIcon(Icons.draw), findsOneWidget); // Kids Drawing
      expect(find.byIcon(Icons.rocket_launch), findsOneWidget); // Mars
      expect(find.byIcon(Icons.portrait), findsOneWidget); // Renaissance
      expect(find.byIcon(Icons.location_city), findsOneWidget); // Cyberpunk
      expect(find.byIcon(Icons.brush), findsOneWidget); // Watercolor
    });

    testWidgets(
      'should navigate to processing screen when filter is selected',
      (tester) async {
        await tester.pumpWidget(
          const TestAppWrapper(
            child: FilterSelectionScreen(imagePath: '/test/image.jpg'),
          ),
        );

        // Tap on first filter
        await tester.tap(find.byType(FilterCard).first);
        await tester.pump();
        await tester.pump();

        // Should navigate to processing screen
        expect(find.byType(ProcessingScreen), findsOneWidget);
      },
    );

    testWidgets('should pass correct filter data when selected', (
      tester,
    ) async {
      await tester.pumpWidget(
        const TestAppWrapper(
          child: FilterSelectionScreen(imagePath: '/test/image.jpg'),
        ),
      );

      // Find and tap the Mars filter
      final marsFilter = find.byWidgetPredicate(
        (widget) => widget is FilterCard && widget.filter.id == 'send_to_mars',
      );

      expect(marsFilter, findsOneWidget);
      await tester.tap(marsFilter);
      await tester.pump();
      await tester.pump();

      // Verify correct filter was passed to processing screen
      final processingScreen = tester.widget<ProcessingScreen>(
        find.byType(ProcessingScreen),
      );
      expect(processingScreen.filter.id, equals('send_to_mars'));
      expect(processingScreen.imagePath, equals('/test/image.jpg'));
    });

    testWidgets('should handle back navigation correctly', (tester) async {
      await tester.pumpWidget(
        const TestAppWrapper(
          child: FilterSelectionScreen(imagePath: '/test/image.jpg'),
        ),
      );

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Should pop the screen
      expect(find.byType(FilterSelectionScreen), findsNothing);
    });
  });
}

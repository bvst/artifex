import 'package:artifex/features/ai_transformation/presentation/screens/filter_selection_screen.dart';
import 'package:artifex/features/ai_transformation/presentation/widgets/filter_card.dart';
import 'package:artifex/features/home/presentation/screens/home_screen.dart';
import 'package:artifex/l10n/app_localizations.dart';
import 'package:artifex/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Essential Flow Tests', () {
    setUp(() {
      // Ensure clean state for each test
      SharedPreferences.setMockInitialValues({});
    });

    group('App Launch Flow', () {
      testWidgets(
        'app should launch and reach home screen when onboarding is complete',
        (tester) async {
          // Arrange - user has completed onboarding
          SharedPreferences.setMockInitialValues({
            'onboarding_complete': true,
          });

          // Act - launch the app
          await tester.pumpWidget(
            ProviderScope(
              child: ArtifexApp(splashDuration: Duration(milliseconds: 50)),
            ),
          );

          // Wait for splash screen transition
          await tester.pump(Duration(milliseconds: 100));
          await tester.pumpAndSettle();

          // Assert - should reach home screen
          expect(find.byType(HomeScreen), findsOneWidget);
        },
      );

      testWidgets(
        'app should show onboarding when not completed',
        (tester) async {
          // Arrange - fresh install (no onboarding completion)
          SharedPreferences.setMockInitialValues({});

          // Act - launch the app
          await tester.pumpWidget(
            ProviderScope(
              child: ArtifexApp(splashDuration: Duration(milliseconds: 50)),
            ),
          );

          // Wait for splash screen transition
          await tester.pump(Duration(milliseconds: 100));
          await tester.pumpAndSettle();

          // Assert - should show onboarding (not home screen)
          expect(find.byType(HomeScreen), findsNothing);
          // Note: We don't test exact onboarding widgets to avoid brittleness
        },
      );
    });

    group('Filter Selection Flow', () {
      testWidgets(
        'filter selection screen should display filters when given an image',
        (tester) async {
          // Arrange
          const imagePath = '/test/photo.jpg';

          // Act - navigate directly to filter selection
          await tester.pumpWidget(
            MaterialApp(
              home: FilterSelectionScreen(imagePath: imagePath),
              localizationsDelegates: [AppLocalizations.delegate],
              supportedLocales: [Locale('en'), Locale('no')],
            ),
          );

          // Assert - essential elements are present
          expect(find.byType(FilterSelectionScreen), findsOneWidget);
          expect(find.byType(Image), findsOneWidget); // User's photo
          expect(find.byType(FilterCard), findsWidgets); // Filter options

          // Verify the image path was received correctly
          final screen = tester.widget<FilterSelectionScreen>(
            find.byType(FilterSelectionScreen),
          );
          expect(screen.imagePath, equals(imagePath));
        },
      );

      testWidgets(
        'user can interact with filter selection screen',
        (tester) async {
          // Arrange
          await tester.pumpWidget(
            MaterialApp(
              home: FilterSelectionScreen(imagePath: '/test/photo.jpg'),
              localizationsDelegates: [AppLocalizations.delegate],
              supportedLocales: [Locale('en'), Locale('no')],
            ),
          );

          // Act & Assert - basic interactions work
          // Back navigation should be available
          expect(find.byIcon(Icons.arrow_back), findsOneWidget);

          // Filter cards should be tappable (at least one)
          final firstFilter = find.byType(FilterCard).first;
          expect(firstFilter, findsOneWidget);

          // Should be able to tap without crashing
          await tester.tap(firstFilter);
          await tester.pump();
        },
      );
    });

    group('Core Navigation Flow', () {
      testWidgets(
        'essential screens can be navigated to without crashing',
        (tester) async {
          // This tests that the core screens can be instantiated and rendered
          // without testing specific navigation paths that might change

          // Home Screen
          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp(
                home: HomeScreen(),
                localizationsDelegates: [AppLocalizations.delegate],
                supportedLocales: [Locale('en'), Locale('no')],
              ),
            ),
          );
          expect(find.byType(HomeScreen), findsOneWidget);

          // Filter Selection Screen
          await tester.pumpWidget(
            MaterialApp(
              home: FilterSelectionScreen(imagePath: '/test/photo.jpg'),
              localizationsDelegates: [AppLocalizations.delegate],
              supportedLocales: [Locale('en'), Locale('no')],
            ),
          );
          expect(find.byType(FilterSelectionScreen), findsOneWidget);
        },
      );
    });

    group('Essential UI Elements', () {
      testWidgets(
        'home screen provides photo input options',
        (tester) async {
          // Arrange
          SharedPreferences.setMockInitialValues({
            'onboarding_complete': true,
          });

          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp(
                home: HomeScreen(),
                localizationsDelegates: [AppLocalizations.delegate],
                supportedLocales: [Locale('en'), Locale('no')],
              ),
            ),
          );

          // Assert - essential photo input functionality exists
          // Don't test specific button text or icons to avoid i18n brittleness
          // Instead, test that interactive elements are present
          final tappableElements = find.byType(InkWell);
          expect(tappableElements, findsWidgets);

          // Settings should be accessible
          expect(find.byIcon(Icons.settings), findsOneWidget);
        },
      );

      testWidgets(
        'filter selection provides expected filter count',
        (tester) async {
          // Set larger screen size to ensure all filters are visible
          tester.view.physicalSize = Size(400, 800);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() => tester.view.reset());

          await tester.pumpWidget(
            MaterialApp(
              home: FilterSelectionScreen(imagePath: '/test/photo.jpg'),
              localizationsDelegates: [AppLocalizations.delegate],
              supportedLocales: [Locale('en'), Locale('no')],
            ),
          );

          // Ensure scrollable content is visible
          if (find.byType(GridView).evaluate().isNotEmpty) {
            await tester.drag(find.byType(GridView), Offset(0, -100));
            await tester.pump();
          }

          // Assert - expected number of filters (business requirement)
          // This tests the core business logic, not UI implementation
          expect(find.byType(FilterCard), findsNWidgets(5));
        },
      );
    });
  });
}
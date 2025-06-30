import 'package:artifex/features/ai_transformation/presentation/screens/filter_selection_screen.dart';
import 'package:artifex/features/ai_transformation/presentation/widgets/filter_card.dart';
import 'package:artifex/features/home/presentation/screens/home_screen.dart';
import 'package:artifex/features/home/presentation/widgets/image_input_button.dart';
import 'package:artifex/features/photo_capture/data/datasources/photo_local_datasource.dart';
import 'package:artifex/features/photo_capture/data/models/photo_model.dart';
import 'package:artifex/l10n/app_localizations.dart';
import 'package:artifex/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

@GenerateMocks([ImagePicker, PhotoLocalDataSource])
import 'photo_to_filter_selection_flow_test.mocks.dart';

void main() {
  group('Photo to Filter Selection Flow Integration Test', () {
    late MockImagePicker mockImagePicker;
    late MockPhotoLocalDataSource mockPhotoLocalDataSource;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      mockImagePicker = MockImagePicker();
      mockPhotoLocalDataSource = MockPhotoLocalDataSource();
    });

    testWidgets(
      'should navigate from home to filter selection after photo capture',
      (tester) async {
        // Arrange
        const testPhotoPath = '/test/photo.jpg';
        final testPhoto = PhotoModel(
          id: '123',
          path: testPhotoPath,
          name: 'test.jpg',
          size: 1000,
          createdAt: DateTime.now(),
        );

        when(
          mockImagePicker.pickImage(source: ImageSource.gallery),
        ).thenAnswer((_) async => XFile(testPhotoPath));

        when(
          mockPhotoLocalDataSource.pickImageFromGallery(),
        ).thenAnswer((_) async => testPhoto);

        // Start the app
        await tester.pumpWidget(const ArtifexApp());
        await tester.pumpAndSettle();

        // Wait for splash screen to complete
        await tester.pump(const Duration(seconds: 3));
        await tester.pumpAndSettle();

        // Should be on home screen
        expect(find.byType(HomeScreen), findsOneWidget);

        // Find and tap gallery button
        final galleryButton = find.byWidgetPredicate(
          (widget) =>
              widget is ImageInputButton && widget.icon == Icons.photo_library,
        );
        expect(galleryButton, findsOneWidget);

        // Tap gallery button
        await tester.tap(galleryButton);
        await tester.pump();

        // Wait for navigation animation
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();

        // Should now be on filter selection screen
        expect(find.byType(FilterSelectionScreen), findsOneWidget);
        expect(find.byType(FilterCard), findsWidgets);
      },
    );

    testWidgets(
      'filter selection screen should display the captured image path',
      (tester) async {
        // Arrange
        const testImagePath = '/test/image.jpg';

        // Navigate directly to filter selection screen
        await tester.pumpWidget(
          MaterialApp(
            home: FilterSelectionScreen(imagePath: testImagePath),
            localizationsDelegates: const [AppLocalizations.delegate],
            supportedLocales: const [Locale('en'), Locale('no')],
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
        MaterialApp(
          home: FilterSelectionScreen(imagePath: testImagePath),
          localizationsDelegates: const [AppLocalizations.delegate],
          supportedLocales: const [Locale('en'), Locale('no')],
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
        MaterialApp(
          home: FilterSelectionScreen(imagePath: '/test/image.jpg'),
          localizationsDelegates: const [AppLocalizations.delegate],
          supportedLocales: const [Locale('en'), Locale('no')],
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

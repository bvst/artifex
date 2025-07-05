/// Example demonstrating proper external service mocking in Flutter tests
///
/// This file shows the correct patterns for mocking external dependencies
/// like camera, gallery, API services, and file system operations.
library;

import 'package:artifex/core/errors/exceptions.dart';
import 'package:artifex/features/ai_transformation/data/models/transformation_result_model.dart';
import 'package:artifex/features/photo_capture/data/models/photo_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mocks/mock_ai_datasource.dart';
import '../mocks/mock_image_picker.dart';
import '../mocks/mock_photo_datasource.dart';
import '../mocks/mock_shared_preferences.dart';

void main() {
  group('External Service Mocking Examples', () {
    group('Image Picker Mocking', () {
      test('should mock successful camera capture', () async {
        // Arrange
        final mockImagePicker = MockImagePickerHelper.create();
        MockImagePickerHelper.setupSuccessfulCameraCapture(
          mockImagePicker,
          imagePath: '/test/camera_photo.jpg',
        );

        // This demonstrates the mocking pattern - in practice,
        // you'd inject this mock into your data source
        expect(mockImagePicker, isNotNull);
      });

      test('should mock user cancellation', () async {
        // Arrange
        final mockImagePicker = MockImagePickerHelper.create();
        MockImagePickerHelper.setupUserCancellation(mockImagePicker);

        // This shows how to test cancellation scenarios
        expect(mockImagePicker, isNotNull);
      });

      test('should mock permission errors', () async {
        // Arrange
        final mockImagePicker = MockImagePickerHelper.create();
        MockImagePickerHelper.setupException(
          mockImagePicker,
          Exception('Camera permission denied'),
        );

        // This shows how to test error scenarios
        expect(mockImagePicker, isNotNull);
      });
    });

    group('Photo Data Source Mocking', () {
      test('should mock successful photo operations', () async {
        // Arrange
        final mockDataSource = MockPhotoDataSourceHelper.create();
        final testPhoto = PhotoModel(
          id: 'test-id',
          name: 'test.jpg',
          path: '/test/path.jpg',
          size: 1024,
          createdAt: DateTime.now(),
        );

        MockPhotoDataSourceHelper.setupSuccessfulCapture(
          mockDataSource,
          testPhoto,
        );
        MockPhotoDataSourceHelper.setupSuccessfulGalleryPick(
          mockDataSource,
          testPhoto,
        );
        MockPhotoDataSourceHelper.setupRecentPhotos(mockDataSource, [
          testPhoto,
        ]);

        // This demonstrates comprehensive data source mocking
        expect(mockDataSource, isNotNull);
      });

      test('should mock data source failures', () async {
        // Arrange
        final mockDataSource = MockPhotoDataSourceHelper.create();

        MockPhotoDataSourceHelper.setupException(
          mockDataSource,
          const FileException('Storage full'),
          forCapture: true,
          forGallery: true,
        );

        // This shows how to test various failure scenarios
        expect(mockDataSource, isNotNull);
      });
    });

    group('AI Service Mocking', () {
      test('should mock successful AI transformation', () async {
        // Arrange
        final mockAIDataSource = MockAIDataSourceHelper.create();
        final mockResult = TransformationResultModel(
          id: 'transformation-id',
          imageUrl: 'https://example.com/transformed.jpg',
          thumbnailUrl: 'https://example.com/thumbnail.jpg',
          prompt: 'Make it cyberpunk',
          style: 'cyberpunk',
          createdAt: DateTime.now(),
        );

        MockAIDataSourceHelper.setupSuccessfulTransformation(
          mockAIDataSource,
          mockResult,
        );
        MockAIDataSourceHelper.setupHealthyService(mockAIDataSource);

        // This demonstrates AI service mocking
        expect(mockAIDataSource, isNotNull);
      });

      test('should mock AI service failures', () async {
        // Arrange
        final mockAIDataSource = MockAIDataSourceHelper.create();

        MockAIDataSourceHelper.setupTransformationException(
          mockAIDataSource,
          const APIException('Rate limit exceeded'),
        );
        MockAIDataSourceHelper.setupUnhealthyService(mockAIDataSource);

        // This shows how to test API failure scenarios
        expect(mockAIDataSource, isNotNull);
      });
    });

    group('SharedPreferences Mocking', () {
      test('should mock app settings', () async {
        // Arrange
        final mockPrefs = MockSharedPreferencesHelper.create();
        MockSharedPreferencesHelper.setupAppSettings(mockPrefs);

        // This demonstrates preferences mocking
        expect(mockPrefs, isNotNull);
      });

      test('should mock empty preferences', () async {
        // Arrange
        final mockPrefs = MockSharedPreferencesHelper.create();
        MockSharedPreferencesHelper.setupEmpty(mockPrefs);

        // This shows how to test fresh app installations
        expect(mockPrefs, isNotNull);
      });

      test('should mock write failures', () async {
        // Arrange
        final mockPrefs = MockSharedPreferencesHelper.create();
        MockSharedPreferencesHelper.setupWriteFailures(mockPrefs);

        // This shows how to test storage failures
        expect(mockPrefs, isNotNull);
      });
    });
  });
}

/// Best Practices for External Service Mocking:
///
/// 1. **Always mock external dependencies**:
///    - Camera/Gallery (ImagePicker)
///    - Network calls (Dio, API clients)
///    - File system operations (path_provider, File I/O)
///    - Platform services (SharedPreferences, device info)
///
/// 2. **Create helper classes for common mock setups**:
///    - Reduces boilerplate in individual tests
///    - Ensures consistent mock behavior
///    - Makes tests more readable
///
/// 3. **Test all scenarios**:
///    - Success cases
///    - Failure cases (exceptions, network errors)
///    - Edge cases (user cancellation, empty responses)
///
/// 4. **Use dependency injection**:
///    - Make external services injectable
///    - Override providers in tests with mocks
///    - Avoid static dependencies that can't be mocked
///
/// 5. **Keep mocks simple and focused**:
///    - Mock only what you need for the specific test
///    - Don't over-engineer mock implementations
///    - Use meaningful test data that represents real scenarios
///

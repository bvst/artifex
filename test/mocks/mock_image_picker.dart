import 'package:image_picker/image_picker.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'mock_image_picker.mocks.dart';

export 'mock_image_picker.mocks.dart';

// Generate mocks for ImagePicker
@GenerateMocks([ImagePicker])
void main() {}

/// Mock ImagePicker for testing
class MockImagePickerHelper {
  static MockImagePicker create() => MockImagePicker();

  /// Set up mock to return a successful camera capture
  static void setupSuccessfulCameraCapture(
    MockImagePicker mockImagePicker, {
    String imagePath = '/test/captured_photo.jpg',
  }) {
    when(
      mockImagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: anyNamed('imageQuality'),
        maxWidth: anyNamed('maxWidth'),
        maxHeight: anyNamed('maxHeight'),
      ),
    ).thenAnswer((_) async => XFile(imagePath));
  }

  /// Set up mock to return a successful gallery selection
  static void setupSuccessfulGallerySelection(
    MockImagePicker mockImagePicker, {
    String imagePath = '/test/gallery_photo.jpg',
  }) {
    when(
      mockImagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: anyNamed('imageQuality'),
        maxWidth: anyNamed('maxWidth'),
        maxHeight: anyNamed('maxHeight'),
      ),
    ).thenAnswer((_) async => XFile(imagePath));
  }

  /// Set up mock to simulate user cancellation (null return)
  static void setupUserCancellation(MockImagePicker mockImagePicker) {
    when(
      mockImagePicker.pickImage(
        source: anyNamed('source'),
        imageQuality: anyNamed('imageQuality'),
        maxWidth: anyNamed('maxWidth'),
        maxHeight: anyNamed('maxHeight'),
      ),
    ).thenAnswer((_) async => null);
  }

  /// Set up mock to throw an exception (permission denied, etc.)
  static void setupException(
    MockImagePicker mockImagePicker,
    Exception exception,
  ) {
    when(
      mockImagePicker.pickImage(
        source: anyNamed('source'),
        imageQuality: anyNamed('imageQuality'),
        maxWidth: anyNamed('maxWidth'),
        maxHeight: anyNamed('maxHeight'),
      ),
    ).thenThrow(exception);
  }
}

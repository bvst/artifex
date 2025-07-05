# Test-Driven Development (TDD) Guide for Artifex

## TDD Workflow

### The Three Laws of TDD
1. **You may not write production code until you have written a failing test**
2. **You may not write more of a test than is sufficient to fail**
3. **You may not write more production code than is sufficient to pass the test**

### Red-Green-Refactor Cycle
1. 🔴 **Red**: Write a failing test
2. 🟢 **Green**: Write minimal code to make it pass
3. 🔵 **Refactor**: Improve the code while keeping tests green

## TDD in Practice

### Example 1: Adding a New Feature
```dart
// 1. RED: Write the test first
test('should calculate photo file size in human readable format', () {
  final photo = Photo(
    id: '1',
    path: '/test.jpg',
    name: 'test.jpg',
    size: 1536, // 1.5 KB
    createdAt: DateTime.now(),
  );
  
  expect(photo.readableSize, equals('1.5 KB'));
});

// 2. GREEN: Add minimal implementation
extension PhotoExtensions on Photo {
  String get readableSize {
    if (size < 1024) return '$size B';
    if (size < 1048576) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / 1048576).toStringAsFixed(1)} MB';
  }
}

// 3. REFACTOR: Improve code quality
extension PhotoExtensions on Photo {
  static const _units = ['B', 'KB', 'MB', 'GB'];
  static const _unitSize = 1024;
  
  String get readableSize {
    var sizeValue = size.toDouble();
    var unitIndex = 0;
    
    while (sizeValue >= _unitSize && unitIndex < _units.length - 1) {
      sizeValue /= _unitSize;
      unitIndex++;
    }
    
    return '${sizeValue.toStringAsFixed(1)} ${_units[unitIndex]}';
  }
}
```

### Example 2: Integration Test for New Flow
```dart
// FIRST: Write integration test for the entire flow
testWidgets('user can change app theme from settings', (tester) async {
  // Arrange
  await tester.pumpWidget(createTestApp());
  await tester.pumpAndSettle();
  
  // Navigate to settings
  await tester.tap(find.byIcon(Icons.settings));
  await tester.pumpAndSettle();
  
  // Find and tap theme toggle
  await tester.tap(find.byIcon(Icons.dark_mode));
  await tester.pumpAndSettle();
  
  // Verify theme changed
  final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
  expect(materialApp.theme?.brightness, equals(Brightness.dark));
});

// THEN: Implement the feature step by step with unit tests
```

## Test Types and When to Use Them

### 1. Unit Tests
**When**: Testing pure business logic, calculations, utilities
```dart
// Test file: test/unit/photo_size_calculator_test.dart
test('should calculate correct size for photo', () {
  final result = PhotoSizeCalculator.calculate(width: 100, height: 200);
  expect(result, equals(20000));
});
```

### 2. Widget Tests  
**When**: Testing UI components in isolation
```dart
// Test file: test/widget/photo_thumbnail_test.dart
testWidgets('should display photo thumbnail', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: PhotoThumbnail(photo: testPhoto),
    ),
  );
  
  expect(find.byType(Image), findsOneWidget);
});
```

### 3. Integration Tests
**When**: Testing complete user flows
```dart
// Test file: test/integration/photo_editing_flow_test.dart
testWidgets('complete photo editing flow', (tester) async {
  // Test the entire flow from capture to save
});
```

## TDD Best Practices for Artifex

### 1. Start with Integration Tests for New Features
```dart
// When planning: "Add photo filters feature"
// FIRST write: test/integration/photo_filter_flow_test.dart
testWidgets('user can apply and save photo filter', (tester) async {
  // This test defines the expected behavior
  // It will fail initially (RED phase)
});
```

### 2. Test Naming Convention
```dart
// Pattern: should_expectedBehavior_when_condition
test('should return error when photo file not found', () {});
test('should display loading indicator when fetching photos', () {});
test('should navigate to home when onboarding completed', () {});
```

### 3. Arrange-Act-Assert Pattern
```dart
test('should update photo metadata', () {
  // Arrange
  final photo = createTestPhoto();
  final repository = MockPhotoRepository();
  when(repository.update(any)).thenAnswer((_) async => Right(photo));
  
  // Act
  final result = await UpdatePhotoUseCase(repository)(photo);
  
  // Assert
  expect(result.isRight(), isTrue);
  verify(repository.update(photo)).called(1);
});
```

### 4. Test Data Builders
```dart
// test/helpers/test_data_builders.dart
class PhotoBuilder {
  String id = '1';
  String path = '/test.jpg';
  String name = 'test.jpg';
  int size = 1000;
  DateTime createdAt = DateTime(2024, 1, 1);
  
  PhotoBuilder withId(String id) {
    this.id = id;
    return this;
  }
  
  PhotoBuilder withSize(int size) {
    this.size = size;
    return this;
  }
  
  Photo build() => Photo(
    id: id,
    path: path,
    name: name,
    size: size,
    createdAt: createdAt,
  );
}

// Usage
final largePhoto = PhotoBuilder().withSize(10485760).build();
```

## Mocking External Services

### Overview
When practicing TDD in Flutter, external services must be mocked to ensure tests are fast, reliable, and deterministic. Artifex provides comprehensive mock helpers for all external dependencies.

### Mock Infrastructure

#### 1. Image Picker Mocking (`test/mocks/mock_image_picker.dart`)
```dart
// Mock camera capture
final mockImagePicker = MockImagePickerHelper.create();
MockImagePickerHelper.setupSuccessfulCameraCapture(
  mockImagePicker,
  imagePath: '/test/photo.jpg',
);

// Mock user cancellation
MockImagePickerHelper.setupUserCancellation(mockImagePicker);

// Mock permission errors
MockImagePickerHelper.setupException(
  mockImagePicker,
  Exception('Camera permission denied'),
);
```

#### 2. Photo Data Source Mocking (`test/mocks/mock_photo_datasource.dart`)
```dart
final mockDataSource = MockPhotoDataSourceHelper.create();
final testPhoto = PhotoModel(
  id: 'test-id',
  name: 'test.jpg',
  path: '/test/path.jpg',
  size: 1024,
  createdAt: DateTime.now(),
);

// Mock successful operations
MockPhotoDataSourceHelper.setupSuccessfulCapture(mockDataSource, testPhoto);
MockPhotoDataSourceHelper.setupRecentPhotos(mockDataSource, [testPhoto]);

// Mock failures
MockPhotoDataSourceHelper.setupException(
  mockDataSource,
  const FileException('Storage full'),
  forCapture: true,
);
```

#### 3. AI Service Mocking (`test/mocks/mock_ai_datasource.dart`)
```dart
final mockAIDataSource = MockAIDataSourceHelper.create();
final mockResult = TransformationResultModel(
  id: 'transformation-id',
  imageUrl: 'https://example.com/transformed.jpg',
  thumbnailUrl: 'https://example.com/thumbnail.jpg',
  prompt: 'Make it cyberpunk',
  style: 'cyberpunk',
  createdAt: DateTime.now(),
);

MockAIDataSourceHelper.setupSuccessfulTransformation(mockAIDataSource, mockResult);
MockAIDataSourceHelper.setupHealthyService(mockAIDataSource);
```

#### 4. SharedPreferences Mocking (`test/mocks/mock_shared_preferences.dart`)
```dart
final mockPrefs = MockSharedPreferencesHelper.create();

// Mock app settings
MockSharedPreferencesHelper.setupAppSettings(
  mockPrefs,
  onboardingComplete: true,
  locale: 'en',
);

// Mock empty preferences (fresh install)
MockSharedPreferencesHelper.setupEmpty(mockPrefs);

// Mock write failures
MockSharedPreferencesHelper.setupWriteFailures(mockPrefs);
```

### TDD with Mocks Example

```dart
// 1. RED: Write failing test with mocks
testWidgets('should show error when photo capture fails', (tester) async {
  // Arrange
  final mockImagePicker = MockImagePickerHelper.create();
  MockImagePickerHelper.setupException(
    mockImagePicker,
    Exception('Camera permission denied'),
  );
  
  // Act
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        imagePickerProvider.overrideWith((_) => mockImagePicker),
      ],
      child: const PhotoCaptureScreen(),
    ),
  );
  
  await tester.tap(find.byIcon(Icons.camera));
  await tester.pump();
  
  // Assert
  expect(find.text('Camera permission denied'), findsOneWidget);
});

// 2. GREEN: Implement error handling
// 3. REFACTOR: Improve error UX
```

### Best Practices for Mocking

1. **Always mock external dependencies**
   - Camera/Gallery (ImagePicker)
   - Network calls (Dio, API clients)
   - File system operations
   - Platform services (SharedPreferences)

2. **Use helper methods for common scenarios**
   ```dart
   // Good: Reusable mock setup
   MockImagePickerHelper.setupSuccessfulCameraCapture(mock);
   
   // Avoid: Inline mock setup in every test
   when(mock.pickImage(...)).thenAnswer(...);
   ```

3. **Test all scenarios**
   - Success cases
   - Failure cases (network errors, permissions)
   - Edge cases (cancellation, empty data)

4. **Inject mocks properly**
   ```dart
   // For unit tests
   final dataSource = PhotoLocalDataSourceImpl(imagePicker: mockImagePicker);
   
   // For widget tests
   ProviderScope(
     overrides: [
       photoDataSourceProvider.overrideWith((_) => mockDataSource),
     ],
     child: MyWidget(),
   );
   ```

## Common TDD Scenarios

### Scenario 1: Adding Validation
```dart
// 1. Write failing test
test('should reject photo larger than 10MB', () {
  final photo = PhotoBuilder().withSize(11 * 1024 * 1024).build();
  final result = PhotoValidator.validate(photo);
  expect(result.isLeft(), isTrue);
  expect(result.leftOrNull(), isA<ValidationFailure>());
});

// 2. Implement validator
// 3. Test passes
// 4. Add more edge cases
```

### Scenario 2: Async Operations
```dart
// 1. Test the happy path
test('should upload photo successfully', () async {
  final uploader = PhotoUploader(mockApi);
  when(mockApi.upload(any)).thenAnswer((_) async => Response(200));
  
  final result = await uploader.upload(testPhoto);
  expect(result.isRight(), isTrue);
});

// 2. Test error cases
test('should retry upload on network error', () async {
  // Test retry logic
});
```

### Scenario 3: State Management
```dart
// 1. Test initial state
test('should start with no photos', () {
  final provider = PhotoListProvider();
  expect(provider.state, equals([]));
});

// 2. Test state transitions
test('should add photo to list', () {
  final provider = PhotoListProvider();
  provider.add(testPhoto);
  expect(provider.state, contains(testPhoto));
});
```

## TDD Checklist for New Features

- [ ] Write integration test describing the complete user flow
- [ ] Run test - verify it fails for the right reason
- [ ] Break down into smaller unit tests
- [ ] Implement each unit with minimal code
- [ ] Refactor when all tests pass
- [ ] Run `dart run artifex:check --all` before committing
- [ ] Update documentation if needed

## Benefits of TDD in Artifex

1. **Living Documentation**: Tests describe what the code does
2. **Confidence**: Refactor without fear of breaking things
3. **Design**: TDD forces better, more testable design
4. **Focus**: Work on one thing at a time
5. **Progress**: See immediate feedback on implementation

## Common Pitfalls to Avoid

1. **Testing Implementation Details**: Test behavior, not how it's done
2. **Brittle Tests**: Don't test exact strings, pixels, or timing
3. **Large Tests**: Keep tests focused on one concept
4. **Skipping Refactor**: The third step is crucial
5. **Writing Tests After**: That's not TDD, that's just testing

## Resources

- [Test-Driven Development by Example](https://www.amazon.com/Test-Driven-Development-Kent-Beck/dp/0321146530) - Kent Beck
- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Mockito for Dart](https://pub.dev/packages/mockito)
- [Flutter TDD Clean Architecture Course](https://resocoder.com/flutter-clean-architecture-tdd/)

## Example TDD Session

```bash
# 1. Create test file first
touch test/features/photo_filters/domain/usecases/apply_filter_test.dart

# 2. Write failing test
# 3. Run test - see it fail
flutter test test/features/photo_filters/domain/usecases/apply_filter_test.dart

# 4. Create minimal implementation
touch lib/features/photo_filters/domain/usecases/apply_filter.dart

# 5. Run test - see it pass
# 6. Refactor if needed
# 7. Commit when done
```

Remember: **No production code without a failing test first!**
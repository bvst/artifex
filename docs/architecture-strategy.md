# Architecture Strategy - Artifex

## Overview
This document outlines the comprehensive architecture strategy for Artifex, an AI-powered photo transformation mobile application built with Flutter.

## 1. State Management: Riverpod

**Why Riverpod?**
- Type-safe, compile-time dependency injection
- Excellent testing support
- Better performance than Provider
- Automatic disposal of resources

**Structure**: Feature-based providers for UI state, data fetching, and business logic

```dart
// Example: photo_providers.dart
final photoRepositoryProvider = Provider<PhotoRepository>((ref) => PhotoRepositoryImpl());
final transformationStateProvider = StateNotifierProvider<TransformationNotifier, TransformationState>(
  (ref) => TransformationNotifier(ref.read(photoRepositoryProvider))
);
```

## 2. Architecture Pattern: Clean Architecture + Repository Pattern

```
lib/
├── core/
│   ├── errors/                 # Custom error classes and failure handling
│   ├── network/               # HTTP client setup, interceptors
│   ├── constants/             # App-wide constants
│   └── utils/                 # Helper functions and utilities
├── features/
│   ├── photo_capture/
│   │   ├── data/              # Repositories, data sources, models
│   │   ├── domain/            # Entities, use cases, repository interfaces
│   │   └── presentation/      # Screens, widgets, providers
│   ├── photo_transformation/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── social_sharing/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── onboarding/
│       ├── data/
│       ├── domain/
│       └── presentation/
└── shared/
    ├── widgets/               # Reusable UI components
    ├── themes/               # App theming and styling
    └── services/             # Platform services (camera, storage, etc.)
```

## 3. Critical Dependencies

```yaml
dependencies:
  # State Management
  flutter_riverpod: ^2.4.0
  riverpod_annotation: ^2.3.0
  
  # Networking & API
  dio: ^5.3.0
  retrofit: ^4.0.0
  json_annotation: ^4.8.0
  
  # Image Processing
  image_picker: ^1.0.4
  cached_network_image: ^3.3.0
  image: ^4.1.0
  photo_view: ^0.14.0
  
  # Storage
  shared_preferences: ^2.2.0
  sqflite: ^2.3.0
  path_provider: ^2.1.0
  
  # Error Handling
  dartz: ^0.10.1
  
  # Logging & Debugging
  logger: ^2.0.0
  flutter_logs: ^2.1.0
  
  # Navigation
  go_router: ^12.0.0
  
  # UI Enhancement
  flutter_animate: ^4.2.0
  shimmer: ^3.0.0
  
  # Permissions
  permission_handler: ^11.0.0
  
  # Utilities
  uuid: ^4.0.0
  intl: ^0.18.0

dev_dependencies:
  # Code Generation
  riverpod_generator: ^2.3.0
  retrofit_generator: ^7.0.0
  json_serializable: ^6.7.0
  build_runner: ^2.4.0
  
  # Testing
  mockito: ^5.4.0
  fake_async: ^1.3.0
```

## 4. Key Design Patterns

### Repository Pattern
```dart
abstract class PhotoRepository {
  Future<Either<Failure, Photo>> capturePhoto();
  Future<Either<Failure, List<Photo>>> getPhotosFromGallery();
  Future<Either<Failure, TransformedPhoto>> transformPhoto(Photo photo, String prompt);
  Future<Either<Failure, void>> saveTransformedPhoto(TransformedPhoto photo);
}

class PhotoRepositoryImpl implements PhotoRepository {
  final PhotoLocalDataSource localDataSource;
  final PhotoRemoteDataSource remoteDataSource;
  
  PhotoRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });
  
  @override
  Future<Either<Failure, TransformedPhoto>> transformPhoto(Photo photo, String prompt) async {
    try {
      final result = await remoteDataSource.transformPhoto(photo, prompt);
      await localDataSource.cacheTransformedPhoto(result);
      return Right(result);
    } on ServerException {
      return Left(ServerFailure());
    } on NetworkException {
      return Left(NetworkFailure());
    }
  }
}
```

### Use Case Pattern
```dart
class TransformPhotoUseCase {
  final PhotoRepository repository;
  
  TransformPhotoUseCase(this.repository);
  
  Future<Either<Failure, TransformedPhoto>> call(TransformPhotoParams params) {
    return repository.transformPhoto(params.photo, params.prompt);
  }
}

class TransformPhotoParams {
  final Photo photo;
  final String prompt;
  final TransformationStyle style;
  
  TransformPhotoParams({
    required this.photo,
    required this.prompt,
    required this.style,
  });
}
```

### Provider Pattern with Riverpod
```dart
@riverpod
class TransformationNotifier extends _$TransformationNotifier {
  @override
  TransformationState build() => const TransformationState.initial();
  
  Future<void> transformPhoto(Photo photo, String prompt) async {
    state = state.copyWith(isLoading: true, error: null);
    
    final result = await ref.read(transformPhotoUseCaseProvider).call(
      TransformPhotoParams(photo: photo, prompt: prompt)
    );
    
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false, 
        error: _mapFailureToMessage(failure)
      ),
      (transformedPhoto) => state = state.copyWith(
        isLoading: false,
        transformedPhoto: transformedPhoto,
      ),
    );
  }
}
```

## 5. Error Handling Strategy

### Failure Classes
```dart
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure([String message = 'Server error occurred']) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'Network connection failed']) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure([String message = 'Cache operation failed']) : super(message);
}
```

### Global Error Handling
```dart
class ErrorHandler {
  static String mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Something went wrong with the server';
      case NetworkFailure:
        return 'Please check your internet connection';
      case CacheFailure:
        return 'Unable to save data locally';
      default:
        return 'Unexpected error occurred';
    }
  }
}
```

## 6. Null Safety Strategy

### Near-Null-Free Programming
Artifex follows a near-null-free programming approach to minimize runtime null reference errors and improve code safety.

### Key Principles
- **Prefer Option<T>**: Use `Option<T>` from Dartz for truly optional values
- **Safe defaults**: Provide sensible defaults instead of null values
- **Either pattern**: Replace nullable returns with `Either<Failure, Success>`
- **Functional composition**: Chain operations safely without null checks

### Implementation Examples
```dart
// Instead of nullable fields
class Photo {
  final int? width;  // Still needed for optional data
  
  // But provide safe accessors
  Option<int> get widthOption => width != null ? some(width!) : none();
  bool get hasDimensions => width != null && height != null;
  String get displayDimensions => hasDimensions ? '${width}x$height' : 'Unknown';
}

// Instead of nullable returns
Either<Failure, Photo> capturePhoto(); // Not: Photo? capturePhoto()

// Safe configuration with defaults
static const String apiKey = String.fromEnvironment('API_KEY', defaultValue: '');
static bool get hasApiKey => apiKey.isNotEmpty;
```

### Extension Methods for Safety
```dart
// Convert nullable to Option
extension NullableToOption<T> on T? {
  Option<T> get toOption => this != null ? some(this as T) : none();
}

// Safe operations
extension SafeOperations<T> on T? {
  T orElse(T defaultValue) => this ?? defaultValue;
  void ifPresent(void Function(T) action) {
    if (this != null) action(this as T);
  }
}
```

## 7. Performance Optimizations

### Image Handling
- **Caching**: Use `cached_network_image` for network images
- **Compression**: Compress images before uploading
- **Lazy loading**: Implement `ListView.builder` for photo galleries
- **Memory management**: Proper disposal of image resources

### Background Processing
```dart
// Use Isolates for heavy image processing
Future<Uint8List> processImageInBackground(Uint8List imageBytes) async {
  return await compute(_processImage, imageBytes);
}

Uint8List _processImage(Uint8List imageBytes) {
  // Heavy image processing logic
  return processedBytes;
}
```

## 7. Testing Strategy

### Test Structure
```
test/
├── unit/
│   ├── features/
│   │   ├── photo_capture/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   └── photo_transformation/
│   └── core/
├── widget/
│   ├── screens/
│   └── widgets/
├── integration/
│   ├── user_flows/
│   └── api_tests/
└── helpers/
    ├── test_helpers.dart
    └── mock_data.dart
```

### Testing Providers
```dart
void main() {
  group('TransformationNotifier', () {
    late ProviderContainer container;
    late MockTransformPhotoUseCase mockUseCase;
    
    setUp(() {
      mockUseCase = MockTransformPhotoUseCase();
      container = ProviderContainer(
        overrides: [
          transformPhotoUseCaseProvider.overrideWithValue(mockUseCase),
        ],
      );
    });
    
    tearDown(() {
      container.dispose();
    });
    
    test('should emit loading then success when transformation succeeds', () async {
      // Test implementation
    });
  });
}
```

## 8. Security Considerations

### API Key Management
```dart
class ApiConfig {
  static const String baseUrl = String.fromEnvironment('API_BASE_URL');
  static const String dalleApiKey = String.fromEnvironment('DALLE_API_KEY');
  
  static bool get isProduction => const bool.fromEnvironment('dart.vm.product');
}
```

### Image Validation
```dart
class ImageValidator {
  static const int maxFileSizeBytes = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedExtensions = ['jpg', 'jpeg', 'png'];
  
  static Either<ValidationFailure, void> validateImage(File imageFile) {
    if (imageFile.lengthSync() > maxFileSizeBytes) {
      return Left(ValidationFailure('Image size too large'));
    }
    
    final extension = path.extension(imageFile.path).toLowerCase();
    if (!allowedExtensions.contains(extension.substring(1))) {
      return Left(ValidationFailure('Invalid image format'));
    }
    
    return const Right(null);
  }
}
```

## 9. Offline Support

### Local Database Schema
```dart
class DatabaseHelper {
  static const String tableTransformedPhotos = 'transformed_photos';
  
  static const String createTransformedPhotosTable = '''
    CREATE TABLE $tableTransformedPhotos (
      id TEXT PRIMARY KEY,
      originalPhotoPath TEXT NOT NULL,
      transformedPhotoPath TEXT NOT NULL,
      prompt TEXT NOT NULL,
      style TEXT NOT NULL,
      createdAt INTEGER NOT NULL,
      syncStatus INTEGER NOT NULL DEFAULT 0
    )
  ''';
}
```

### Sync Strategy
```dart
@riverpod
class SyncNotifier extends _$SyncNotifier {
  @override
  SyncState build() => const SyncState.idle();
  
  Future<void> syncPendingUploads() async {
    final pendingPhotos = await ref.read(localDataSourceProvider).getPendingUploads();
    
    for (final photo in pendingPhotos) {
      try {
        await ref.read(remoteDataSourceProvider).uploadPhoto(photo);
        await ref.read(localDataSourceProvider).markAsSynced(photo.id);
      } catch (e) {
        // Log error and continue with next photo
      }
    }
  }
}
```

## 10. Navigation Architecture

### Go Router Setup
```dart
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: '/camera',
            builder: (context, state) => const CameraScreen(),
          ),
          GoRoute(
            path: '/transformation',
            builder: (context, state) => TransformationScreen(
              photo: state.extra as Photo,
            ),
          ),
        ],
      ),
    ],
  );
});
```

## Implementation Priority

1. **Foundation** (High Priority)
   - Set up Riverpod state management
   - Implement repository pattern structure
   - Add error handling framework
   - Set up dependency injection

2. **Core Features** (High Priority)
   - Photo capture and gallery selection
   - API integration for AI transformation
   - Image caching and optimization
   - Navigation setup

3. **Enhancement** (Medium Priority)
   - Offline support and sync
   - Comprehensive logging
   - Performance optimizations
   - Advanced error recovery

4. **Polish** (Low Priority)
   - Advanced animations
   - Detailed analytics
   - A/B testing framework
   - Advanced caching strategies

This architecture provides a solid foundation for building a scalable, maintainable, and robust AI-powered photo transformation application.
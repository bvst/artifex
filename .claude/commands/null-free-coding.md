# Near-Null-Free Programming Guidelines

## Core Principle
Minimize null usage throughout the Artifex codebase to improve safety and reduce runtime errors.

## Required Patterns

### 1. Use Option<T> for Optional Values
```dart
// ✅ Good
Option<int> get widthOption => width != null ? some(width!) : none();

// ❌ Avoid
int? getWidth() => someValue;
```

### 2. Provide Safe Defaults
```dart
// ✅ Good
static const String apiKey = String.fromEnvironment('API_KEY', defaultValue: '');
static bool get hasApiKey => apiKey.isNotEmpty;

// ❌ Avoid
static const String? apiKey = String.fromEnvironment('API_KEY');
```

### 3. Use Either<Failure, Success> Instead of Nullable Returns
```dart
// ✅ Good
Future<Either<Failure, Photo>> capturePhoto();

// ❌ Avoid
Future<Photo?> capturePhoto();
```

### 4. Create Safe Accessor Methods
```dart
// ✅ Good
class Photo {
  final int? width;
  final int? height;
  
  bool get hasDimensions => width != null && height != null;
  String get displayDimensions => hasDimensions ? '${width}x$height' : 'Unknown';
  double get aspectRatio => hasDimensions ? (width! / height!) : 1.0;
}
```

### 5. Use Extension Methods for Safety
```dart
// ✅ Good
extension SafeOperations<T> on T? {
  T orElse(T defaultValue) => this ?? defaultValue;
  void ifPresent(void Function(T) action) {
    if (this != null) action(this as T);
  }
}
```

## When Nullable Types Are Acceptable
- Database fields that can genuinely be missing
- API responses with optional fields
- Widget parameters that have sensible defaults
- **Always provide safe accessors even for nullable fields**

## Code Review Checklist
- [ ] Are there any nullable returns that could be Either<Failure, Success>?
- [ ] Do nullable fields have safe accessor methods?
- [ ] Are constants using safe defaults instead of null?
- [ ] Are optional values using Option<T> pattern where appropriate?
- [ ] Is null checking minimized through safe design?

## Remember
Every nullable type should come with safe accessor methods or be wrapped in Option<T> for functional composition.
# Testing Best Practices for Artifex

## Core Testing Principles

### ✅ **DO Test**
- **User behavior and interactions** (taps, navigation, form input)
- **Business logic and state changes** (providers, use cases, repositories)
- **Error handling and edge cases** (network failures, validation errors)
- **Widget presence and structure** (components exist, layout works)
- **Loading and success states** (async operations work correctly)

### ❌ **DON'T Test**
- **Specific text content** (breaks with internationalization)
- **Exact pixel values or colors** (brittle to design changes)
- **Internal implementation details** (private methods, widget internals)
- **Flutter framework functionality** (already tested by Flutter team)
- **Third-party library behavior** (trust external libraries work)

## Language-Agnostic Testing

### **Instead of text-based finders:**
```dart
// ❌ BAD: Will break with i18n
expect(find.text('Welcome to Artifex'), findsOneWidget);
expect(find.text('Take a Photo'), findsOneWidget);

// ✅ GOOD: Use structural/semantic finders
expect(find.byType(WelcomeSection), findsOneWidget);
expect(find.byIcon(Icons.camera_alt_rounded), findsOneWidget);
```

### **For button identification:**
```dart
// ❌ BAD: Text-dependent
final button = find.widgetWithText(ElevatedButton, 'Submit');

// ✅ GOOD: Icon or structure-based
final button = find.ancestor(
  of: find.byIcon(Icons.camera_alt_rounded),
  matching: find.byType(InkWell),
);
```

### **For error testing:**
```dart
// ❌ BAD: Specific error messages will change
expect(state.error, equals('Invalid camera settings'));

// ✅ GOOD: Test error state, not message
expect(state.hasError, isTrue);
expect(state.error, isNotNull);
expect(find.byType(SnackBar), findsOneWidget); // Error displayed
```

## Robust Widget Testing

### **Test Behavior, Not Implementation**
```dart
// ❌ BAD: Testing implementation details
expect(padding.padding, const EdgeInsets.all(24.0));
expect(spacer.height, 40);
expect(titleText.style?.fontSize, 24.0);

// ✅ GOOD: Test structure and behavior
expect(find.byType(Padding), findsAtLeastNWidgets(1));
expect(find.byType(SizedBox), findsAtLeastNWidgets(1));
expect(titleText.style, isNotNull);
```

### **Use Semantic Finders**
```dart
// Create semantic finder utilities
class TestFinders {
  static Finder buttonByIcon(IconData icon) {
    return find.ancestor(
      of: find.byIcon(icon),
      matching: find.byWidgetPredicate(
        (widget) => widget is InkWell || widget is ElevatedButton,
      ),
    );
  }
  
  static Finder primaryActionButton() => find.byType(ElevatedButton);
  static Finder loadingIndicator() => find.byType(CircularProgressIndicator);
  static Finder errorDisplay() => find.byType(SnackBar);
}
```

## Provider Testing Patterns

### **Test State Transitions, Not Messages**
```dart
// ✅ GOOD: Test loading flow
test('should show loading then success state', () async {
  // Initial state
  expect(container.read(provider).isLoading, isFalse);
  
  // Trigger action
  final future = notifier.someAction();
  
  // Should be loading
  expect(container.read(provider).isLoading, isTrue);
  
  // Wait for completion
  await future;
  
  // Should have data
  final state = container.read(provider);
  expect(state.hasValue, isTrue);
  expect(state.value, isNotNull);
});
```

### **Test Error States Without Specific Messages**
```dart
// ✅ GOOD: Error handling without message dependency
test('should handle validation errors correctly', () async {
  when(mockRepository.someAction())
    .thenAnswer((_) async => left(ValidationFailure('Some error')));

  await notifier.someAction();
  
  final state = container.read(provider);
  expect(state.hasError, isTrue);
  expect(state.error, isNotNull); // Don't test specific message
});
```

## Test Organization

### **Group Tests by Concern**
```dart
group('Photo Capture Feature', () {
  group('User Interactions', () {
    // Test taps, gestures, navigation
  });
  
  group('State Management', () {
    // Test provider states, loading, errors
  });
  
  group('Error Scenarios', () {
    // Test all failure modes
  });
});
```

### **Use Descriptive Test Names**
```dart
// ✅ GOOD: Describes behavior
testWidgets('should navigate to photo editing when photo captured');
testWidgets('should show error state when camera permission denied');

// ❌ BAD: Describes implementation
testWidgets('should have correct padding');
testWidgets('should display text');
```

## Test Setup Patterns

### **Use Consistent Setup Utilities**
```dart
// Use existing test utilities
await tester.pumpAppWidget(MyWidget());
await tester.pumpAppScreen(MyScreen());

// Use builders for complex setup
final widget = TestScenarios
  .widgetWithPhotoRepository(mockRepository)
  .theme(customTheme)
  .build();
```

### **Create Reusable Test Data**
```dart
// Use TestData factories
final photo = TestData.createCameraPhoto();
final failure = TestData.validationFailure;
```

## Integration Test Guidelines

### **Test Complete User Flows**
```dart
testWidgets('complete photo capture flow works', (tester) async {
  // Navigate to home
  await waitForSplashNavigation(tester);
  
  // Find camera button by icon (not text)
  final cameraButton = find.ancestor(
    of: find.byIcon(Icons.camera_alt_rounded),
    matching: find.byType(InkWell),
  );
  
  // Test interaction
  await tester.tap(cameraButton);
  await tester.pump();
  
  // Verify behavior (not specific UI details)
  expect(cameraButton, findsOneWidget); // Still functional
});
```

## Before Committing Tests

### **Checklist**
- [ ] All tests are language-agnostic (no text finders)
- [ ] Tests focus on behavior, not implementation details
- [ ] Error tests don't check specific error messages
- [ ] No exact pixel/color value testing
- [ ] All new code has corresponding tests
- [ ] Tests pass: `dart run artifex:check`

### **Quick Test Quality Check**
```bash
# Search for problematic patterns in tests
rg "find\.text\(" test/ -n          # Should return minimal results
rg "expect.*equals.*'" test/ -n     # Check for hard-coded strings
rg "fontSize|padding.*\(" test/ -n  # Check for implementation details
```

## Test File Structure

### **Follow Source Structure**
```
lib/features/home/presentation/screens/home_screen.dart
 ↓
test/features/home/presentation/screens/home_screen_test.dart
```

### **Use Consistent Imports**
```dart
// Standard test imports
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Test utilities
import '../../../../fixtures/test_data.dart';
import '../../../../helpers/test_builders.dart';
import '../../../../extensions/test_extensions.dart';
```

## Remember

**Write tests that will survive:**
- 🌍 **Internationalization** (multiple languages)
- 🎨 **Design changes** (colors, fonts, spacing)
- 🔄 **Refactoring** (internal implementation changes)
- 📱 **Platform differences** (iOS vs Android)
- 🔮 **Future requirements** (new features, changes)

**Your tests should read like user stories, not implementation details.**
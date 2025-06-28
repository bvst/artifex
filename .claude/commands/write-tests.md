# Writing Tests - Step-by-Step Guide

## When to Write Tests
**ALWAYS** write tests when:
- Creating any new file (widget, provider, repository, use case)
- Adding new functionality to existing code
- Fixing bugs (write test that reproduces bug first)
- Refactoring code (ensure behavior stays same)

## Test Creation Workflow

### 1. Identify Test Type Needed
```dart
// lib/features/photo/presentation/widgets/photo_card.dart
// → Need: Widget test

// lib/features/photo/domain/use_cases/capture_photo.dart  
// → Need: Unit test

// lib/features/photo/presentation/screens/photo_screen.dart
// → Need: Widget test + Integration test (if new screen)

// lib/features/photo/presentation/providers/photo_provider.dart
// → Need: Unit test (provider logic)
```

### 2. Create Test File
```bash
# Mirror the source file structure exactly
lib/features/photo/presentation/widgets/photo_card.dart
 ↓
test/features/photo/presentation/widgets/photo_card_test.dart
```

### 3. Use Standard Test Template

#### **Widget Test Template**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:artifex/features/photo/presentation/widgets/photo_card.dart';
import '../../../../extensions/test_extensions.dart';

void main() {
  group('PhotoCard Widget Tests', () {
    
    group('Rendering', () {
      testWidgets('displays photo content correctly', (tester) async {
        // ARRANGE: Setup test data
        const testPhoto = Photo(id: 'test', path: '/test.jpg');
        
        // ACT: Render widget
        await tester.pumpAppWidget(PhotoCard(photo: testPhoto));
        
        // ASSERT: Test behavior, not implementation
        expect(find.byType(Image), findsOneWidget);
        expect(find.byType(PhotoCard), findsOneWidget);
        // DON'T test specific text/colors/sizes
      });
    });
    
    group('Interactions', () {
      testWidgets('handles tap correctly', (tester) async {
        bool wasTapped = false;
        
        await tester.pumpAppWidget(
          PhotoCard(
            photo: testPhoto,
            onTap: () => wasTapped = true,
          ),
        );
        
        // Find by widget type or icon, not text
        await tester.tap(find.byType(InkWell));
        
        expect(wasTapped, isTrue);
      });
    });
  });
}
```

#### **Provider Test Template**
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';

void main() {
  group('PhotoProvider Tests', () {
    late ProviderContainer container;
    late MockPhotoRepository mockRepository;

    setUp(() {
      mockRepository = MockPhotoRepository();
      container = TestScenarios
        .containerWithPhotoRepository(mockRepository)
        .build();
    });

    tearDown(() {
      container.dispose();
    });

    group('photo loading', () {
      test('should handle loading states correctly', () async {
        when(mockRepository.getPhoto('test'))
          .thenAnswer((_) async => right(TestData.createPhoto()));

        final notifier = container.read(photoProvider.notifier);
        
        // Test loading flow without checking specific states
        final future = notifier.loadPhoto('test');
        expect(container.read(photoProvider).isLoading, isTrue);
        
        await future;
        expect(container.read(photoProvider).hasValue, isTrue);
      });

      test('should handle errors without checking specific messages', () async {
        when(mockRepository.getPhoto('test'))
          .thenAnswer((_) async => left(TestData.networkFailure));

        final notifier = container.read(photoProvider.notifier);
        await notifier.loadPhoto('test');
        
        final state = container.read(photoProvider);
        expect(state.hasError, isTrue);
        expect(state.error, isNotNull);
        // DON'T test specific error message
      });
    });
  });
}
```

#### **Integration Test Template**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:artifex/main.dart';

void main() {
  group('Photo Flow Integration Tests', () {
    
    testWidgets('complete photo capture flow works', (tester) async {
      await tester.pumpWidget(
        ProviderScope(child: ArtifexApp(splashDuration: Duration(milliseconds: 1))),
      );

      // Wait for app to load
      await tester.pumpAndSettle();

      // Navigate using semantic finders (icons, types)
      final cameraButton = find.ancestor(
        of: find.byIcon(Icons.camera_alt_rounded),
        matching: find.byType(InkWell),
      );
      
      await tester.tap(cameraButton);
      await tester.pump();

      // Test behavior, not specific UI details
      expect(cameraButton, findsOneWidget); // Still functional
    });
  });
}
```

## Testing Checklist

### ✅ **Required for Every Test**
- [ ] **No `find.text()` usage** - use icons/types instead
- [ ] **No specific error message testing** - test `hasError` only
- [ ] **No pixel-perfect testing** - test structure, not exact values
- [ ] **Test user behavior** - what user sees/does, not implementation
- [ ] **Use TestData factories** - consistent test data
- [ ] **Proper async handling** - await all futures
- [ ] **Clean setup/teardown** - dispose resources

### ❌ **Avoid These Patterns**
```dart
// ❌ Text-dependent (breaks with i18n)
expect(find.text('Submit'), findsOneWidget);

// ❌ Implementation details (brittle)
expect(padding.padding, EdgeInsets.all(16));
expect(color, Colors.blue);

// ❌ Specific error messages (will change)
expect(state.error, equals('Network connection failed'));

// ❌ Exact widget counts (fragile)
expect(find.byType(Text), findsNWidgets(3));
```

### ✅ **Use These Patterns Instead**
```dart
// ✅ Semantic/structural (robust)
expect(find.byIcon(Icons.send), findsOneWidget);
expect(find.byType(ElevatedButton), findsOneWidget);

// ✅ Behavior testing (stable)
expect(find.byType(Padding), findsAtLeastNWidgets(1));
expect(widget.decoration, isNotNull);

// ✅ Error state testing (i18n-ready)
expect(state.hasError, isTrue);
expect(find.byType(SnackBar), findsOneWidget);

// ✅ Flexible counts (maintainable)
expect(find.byType(Text), findsAtLeastNWidgets(1));
```

## Common Test Scenarios

### **Testing Button Interactions**
```dart
// Find button by icon, not text
final submitButton = find.ancestor(
  of: find.byIcon(Icons.check),
  matching: find.byType(ElevatedButton),
);

await tester.tap(submitButton);
expect(callbackWasCalled, isTrue);
```

### **Testing Form Validation**
```dart
// Test validation behavior, not specific messages
await tester.enterText(find.byType(TextField), 'invalid@');
await tester.tap(find.byType(ElevatedButton));

expect(find.byType(SnackBar), findsOneWidget); // Error shown
// DON'T test specific validation message
```

### **Testing Navigation**
```dart
await tester.tap(find.byIcon(Icons.arrow_forward));
await tester.pumpAndSettle();

expect(find.byType(NextScreen), findsOneWidget);
```

### **Testing Loading States**
```dart
// Trigger async operation
final future = controller.loadData();

// Should show loading
expect(find.byType(CircularProgressIndicator), findsOneWidget);

await future;

// Should show content
expect(find.byType(DataWidget), findsOneWidget);
```

## Running Tests

### **Individual Test File**
```bash
flutter test test/features/photo/presentation/widgets/photo_card_test.dart
```

### **Feature Tests**
```bash
flutter test test/features/photo/
```

### **All Tests + Analysis**
```bash
dart run artifex:check
```

### **Test with Coverage**
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## Test Performance Tips

- **Use TestData factories** for consistent data
- **Mock external dependencies** (network, file system)
- **Avoid real timers** - use fake timers when needed
- **Minimal widget trees** - test smallest possible scope
- **Batch similar tests** - group related tests together

## Remember

**Your tests are documentation of how the app should behave.**

Write them as if someone else will read them in 6 months and need to understand:
1. What the feature does
2. How users interact with it  
3. What happens when things go wrong
4. How the feature should evolve

**Test the contract, not the implementation.**
# Race Conditions and Concurrency in Artifex

## What is a Race Condition?

A **race condition** occurs when two or more operations compete to access or modify shared resources, and the outcome depends on the unpredictable order of execution. This leads to non-deterministic behavior that can cause bugs, crashes, or data corruption.

### Simple Analogy
Imagine two people trying to go through the same door simultaneously:
- If Person A goes first → Person B waits → ✅ Works correctly
- If Person B goes first → Person A waits → ✅ Works correctly  
- If both try at once → They collide → ❌ Problem!

## Race Conditions We Fixed

### 1. SharedPreferences Initialization (FIXED)
**Problem**: App tried to read SharedPreferences before it was initialized

**Issue A - App Startup**: App tried to use settings before SharedPreferences was ready
```dart
// RACE CONDITION:
main() async {
  _initializeApp(); // Starts initialization (async)
  runApp(ArtifexApp()); // Immediately tries to use SharedPreferences!
}
```

**Solution A**: Wait for initialization to complete
```dart
main() async {
  await _initializeApp(); // WAIT for completion
  runApp(ArtifexApp()); // Now safe to use
}
```

**Issue B - Language Switching**: updateLocale() synchronously read providers before SharedPreferences was ready
```dart
// RACE CONDITION in settings_provider.dart:51:
final useCase = ref.read(updateLocaleUseCaseProvider); // Could fail!
```

**Solution B**: Wait for SharedPreferences before reading use case
```dart
// Wait for SharedPreferences to be available before reading use case
await ref.read(sharedPreferencesProvider.future);
final useCase = ref.read(updateLocaleUseCaseProvider); // Now safe!
```

**Test Coverage**: Added TDD test to catch language switching race condition

### 2. Database Singleton Pattern (FIXED)
**Problem**: Multiple concurrent calls could create multiple database instances
```dart
// RACE CONDITION:
if (_database != null) return _database!;
_database = await _initDatabase(); // Multiple threads could enter here!
```

**Solution**: Use Completer for thread-safe initialization
```dart
static Completer<Database>? _databaseCompleter;

static Future<Database> getDatabase() async {
  if (_database != null) return _database!;
  
  // Only one thread can start initialization
  if (_databaseCompleter != null) {
    return _databaseCompleter!.future;
  }
  
  _databaseCompleter = Completer<Database>();
  // ... initialization logic
}
```

### 3. Photo Capture Operations (FIXED)
**Problem**: Rapid button taps could trigger multiple simultaneous operations
```dart
// User rapidly taps camera button → Multiple captures!
Future<void> captureFromCamera() async {
  state = AsyncValue.loading();
  // ... capture logic
}
```

**Solution**: Check loading state before starting new operation
```dart
Future<void> captureFromCamera() async {
  if (state.isLoading) return; // Prevent concurrent operations
  state = AsyncValue.loading();
  // ... capture logic
}
```

## Potential Race Conditions Still in Codebase

### 1. Settings Provider Initialization
- **Risk**: Medium
- **Issue**: `_loadSettings()` called but not awaited in build()
- **Impact**: UI flicker, wrong initial locale

### 2. File System Operations
- **Risk**: Low  
- **Issue**: Directory creation and file operations not synchronized
- **Impact**: Possible conflicts with concurrent photo saves

### 3. Navigation State
- **Risk**: Low
- **Issue**: Multiple navigation pushes possible (e.g., double-tap Skip)
- **Impact**: Navigation stack corruption

## Best Practices to Prevent Race Conditions

### 1. Always Await Async Operations
```dart
// ❌ Bad
void someMethod() {
  _initializeSomething(); // Fire and forget
  useSomething(); // Might not be ready!
}

// ✅ Good
Future<void> someMethod() async {
  await _initializeSomething();
  useSomething(); // Guaranteed to be ready
}
```

### 2. Use Synchronization Primitives
- **Completer**: For one-time initialization
- **Lock/Mutex**: For exclusive access (use `synchronized` package)
- **State Checks**: For preventing duplicate operations

### 3. Design Patterns
- **Singleton with Lazy Initialization**: Use Completer pattern
- **Operation Queuing**: Process one operation at a time
- **Optimistic Locking**: Check version before updating

### 4. Testing for Race Conditions
```dart
test('concurrent operations should be handled safely', () async {
  // Start multiple operations simultaneously
  final futures = List.generate(10, (_) => someAsyncOperation());
  
  // Wait for all
  final results = await Future.wait(futures);
  
  // Verify no conflicts occurred
  expect(results, ...);
});
```

## Tools and Techniques

### 1. Dart Isolates
For CPU-intensive work that shouldn't block the main thread:
```dart
final result = await Isolate.run(() => expensiveOperation());
```

### 2. Stream Controllers
For managing event flows:
```dart
final _controller = StreamController<Event>.broadcast();
```

### 3. Riverpod State Management
Riverpod helps prevent some race conditions by:
- Managing provider lifecycle
- Caching computed values
- Handling disposal automatically

## Common Scenarios and Solutions

### Scenario 1: Database Migrations
**Problem**: Multiple app instances trying to migrate
**Solution**: Use database transaction locks

### Scenario 2: Network Request Deduplication  
**Problem**: Same request triggered multiple times
**Solution**: Cache in-flight requests

### Scenario 3: UI State Updates
**Problem**: Stale updates overwriting fresh data
**Solution**: Version/timestamp checking

## Debugging Race Conditions

1. **Add Logging**: Track operation start/end times
2. **Use Delays**: Artificially slow operations to expose races
3. **Stress Testing**: Run operations in loops
4. **Thread Analysis**: Use Flutter DevTools

## References
- [Dart Concurrency](https://dart.dev/guides/language/concurrency)
- [Flutter Threading](https://docs.flutter.dev/development/platform-integration/platform-channels#threads)
- [Riverpod AsyncValue](https://riverpod.dev/docs/concepts/providers#asyncvalue)
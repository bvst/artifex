# Code Review Checklist

## Before Writing Code

### Planning Check
- [ ] **Feature requirements understood** - Clear acceptance criteria
- [ ] **Architecture pattern decided** - Clean Architecture + Repository pattern
- [ ] **Test strategy planned** - Unit, widget, and integration tests needed
- [ ] **I18n considerations** - Will this need translation?

## While Writing Code

### Code Quality
- [ ] **Follow Clean Architecture** - Proper separation of concerns
- [ ] **Use @riverpod annotations** - For dependency injection
- [ ] **Implement Either pattern** - For error handling
- [ ] **Near-null-free programming** - Prefer Option<T>, safe defaults
- [ ] **Meaningful variable names** - Self-documenting code
- [ ] **Single responsibility** - Each class/method does one thing

### Testing Requirements
- [ ] **Test file created** - Mirror source structure exactly
- [ ] **Language-agnostic tests** - No `find.text()` usage
- [ ] **Behavior testing** - Test what user sees/does, not implementation
- [ ] **Error handling tested** - Test `hasError`, not specific messages
- [ ] **Async states covered** - Loading, success, error states
- [ ] **Edge cases covered** - Null values, empty lists, network failures

## Before Committing

### Code Review
- [ ] **No hardcoded strings** - Use constants or i18n keys
- [ ] **No magic numbers** - Use named constants
- [ ] **Proper error handling** - All failures mapped to user-friendly states
- [ ] **No console logs** - Use proper logging with levels
- [ ] **Remove debug code** - No temporary debugging code

### Testing Validation
- [ ] **All tests pass** - `dart run artifex:check`
- [ ] **No test text dependencies** - Search: `rg "find\.text\(" test/`
- [ ] **No implementation testing** - No pixel values, exact counts
- [ ] **Coverage adequate** - New code should be well-tested

### Documentation
- [ ] **PLAN.md updated** - Document what was completed
- [ ] **Comments for complex logic** - Explain why, not what
- [ ] **API documentation** - For public methods/classes

## Architecture Verification

### Clean Architecture Compliance
```
✅ Domain layer (entities, repositories, use cases)
   - No Flutter/UI dependencies
   - Pure business logic
   - Tested with unit tests

✅ Data layer (models, data sources, repository implementations)
   - Implements domain repositories
   - Handles external data (API, database, cache)
   - Tested with unit tests

✅ Presentation layer (screens, widgets, providers)
   - UI logic only
   - Uses domain layer through providers
   - Tested with widget tests
```

### Dependency Flow
- [ ] **Inward dependencies only** - Presentation → Domain ← Data
- [ ] **Abstractions, not concretions** - Depend on interfaces
- [ ] **Riverpod providers** - For dependency injection

## Testing Anti-Patterns to Avoid

### ❌ **Don't Do This**
```dart
// Text-dependent (breaks with i18n)
expect(find.text('Submit'), findsOneWidget);

// Implementation details (brittle)
expect(padding.padding, EdgeInsets.all(16));
expect(container.color, Colors.blue);

// Specific error messages (will change)
expect(error, equals('Network connection failed'));

// Exact widget counts (fragile)
expect(find.byType(Text), findsNWidgets(3));

// Testing private methods
expect(widget._privateMethod(), 'value');
```

### ✅ **Do This Instead**
```dart
// Structure-based (robust)
expect(find.byIcon(Icons.send), findsOneWidget);
expect(find.byType(ElevatedButton), findsOneWidget);

// Behavior testing (stable)
expect(find.byType(Padding), findsAtLeastNWidgets(1));
expect(decoration, isNotNull);

// Error state testing (i18n-ready)
expect(state.hasError, isTrue);
expect(find.byType(SnackBar), findsOneWidget);

// Flexible assertions (maintainable)
expect(find.byType(Text), findsAtLeastNWidgets(1));

// Testing public behavior
expect(widget.isEnabled, isTrue);
```

## Performance Considerations

### Widget Performance
- [ ] **Const constructors** - Use const wherever possible
- [ ] **Efficient rebuilds** - Minimize widget tree rebuilds
- [ ] **Image optimization** - Proper image caching and sizing
- [ ] **List performance** - Use ListView.builder for long lists

### Provider Performance
- [ ] **Selective watching** - Watch specific provider properties
- [ ] **Dispose resources** - Properly dispose of controllers/streams
- [ ] **Avoid unnecessary providers** - Don't over-engineer state

## Security & Privacy

### Data Handling
- [ ] **No sensitive data in logs** - Sanitize all logging
- [ ] **Secure API keys** - Use environment variables
- [ ] **Validate all inputs** - Never trust user input
- [ ] **Handle permissions properly** - Graceful permission failures

## Pre-Release Checklist

### Production Readiness
- [ ] **All TODOs resolved** - No temporary code
- [ ] **Error states handled** - User-friendly error messages
- [ ] **Loading states** - Appropriate loading indicators
- [ ] **Offline behavior** - Graceful offline handling
- [ ] **Performance tested** - No frame drops or ANRs

### Quality Gates
- [ ] **Code analysis passes** - `flutter analyze`
- [ ] **All tests pass** - `flutter test`
- [ ] **Manual testing done** - Key flows tested on device
- [ ] **Accessibility tested** - Screen reader compatible

## Tools & Commands

### Quality Check
```bash
# Full quality check
dart run artifex:check

# Find problematic test patterns
rg "find\.text\(" test/ -n
rg "expect.*equals.*'" test/ -n
rg "fontSize|padding.*\(" test/ -n
```

### Coverage Analysis
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Performance Profiling
```bash
flutter run --profile
# Use Flutter Inspector for widget rebuild analysis
```

## Remember

**Code review is not just about finding bugs - it's about:**
1. **Maintainability** - Will this be easy to change?
2. **Testability** - Can this be tested reliably?
3. **Readability** - Will the next developer understand this?
4. **Performance** - Will this scale and perform well?
5. **User Experience** - Does this provide value to users?

**When in doubt, ask:**
- Will this work in Norwegian language?
- Will this work on different screen sizes?
- Will this work when the network is slow?
- Will this work when the user makes mistakes?
# Artifex Test Suite

## Test Structure

```
test/
├── unit/          # Unit tests for business logic
├── widget/        # Widget tests for UI components
├── integration/   # Integration tests for full app flows
├── mocks/         # Mock services and utilities
├── fixtures/      # Test data and fixtures
├── test_config.dart  # Shared test configuration
└── widget_test.dart  # Default Flutter test (can be removed)
```

## Running Tests

### All Tests
```bash
flutter test
```

### Specific Test Types
```bash
# Unit tests only
flutter test test/unit/

# Widget tests only
flutter test test/widget/

# Integration tests
flutter test test/integration/
```

### Single Test File
```bash
flutter test test/unit/example_unit_test.dart
```

### With Coverage
```bash
flutter test --coverage
```

## Writing Tests

### Unit Tests
Place in `test/unit/` for:
- Business logic
- Data models
- Utilities
- Services (with mocks)

### Widget Tests
Place in `test/widget/` for:
- Individual UI components
- Screen layouts
- User interactions
- Widget state changes

### Integration Tests
Place in `test/integration/` for:
- Complete user flows
- Multi-screen navigation
- Real API interactions (in test environment)
- End-to-end scenarios

## Best Practices

1. **Naming Convention**: Use descriptive test names that explain what is being tested
2. **AAA Pattern**: Arrange, Act, Assert
3. **One Assertion Per Test**: Keep tests focused
4. **Use Groups**: Organize related tests
5. **Mock External Dependencies**: Use the mocks/ directory
6. **Test Data**: Keep test data in fixtures/
7. **Timeouts**: Use appropriate timeouts from test_config.dart
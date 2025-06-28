# Development Workflow Commands

## Standard Development Flow
When working on Artifex, follow this workflow:

### 1. Before Starting Work
```bash
cd /home/bv/git/artifex
flutter pub get
flutter analyze
flutter test
```

### 2. During Development
- Follow Clean Architecture patterns (features/[name]/{data,domain,presentation})
- Use @riverpod annotations for dependency injection
- Implement Either<Failure, Success> pattern for error handling
- **CRITICAL: Write tests for ALL new code - no exceptions!**
  - Widget tests for all UI components (language-agnostic)
  - Unit tests for business logic and utilities
  - Integration tests for user flows (structure-based)
  - **Follow testing best practices** - see .claude/commands/testing-best-practices.md
  - Aim for 100% test coverage on new code

### 3. After Code Changes
```bash
# If you modified @riverpod providers:
flutter packages pub run build_runner build --delete-conflicting-outputs

# Check code quality (includes formatting, analysis, and tests):
dart run artifex:check

# OR run individually:
flutter analyze
flutter test
dart format .
```

### 4. Before Committing
1. **Run complete quality check**: `dart run artifex:check` (includes formatting, analysis, tests)
2. **UPDATE PLAN.md** with session progress
3. Commit with clear message

**Note**: `dart run artifex:check` now includes automatic code formatting!

## Feature Development Pattern
1. Create feature folder: `lib/features/[feature_name]/`
2. Implement domain layer first (entities, repositories, use cases)
   - **Use near-null-free programming**: Option<T>, Either<L,R>, safe defaults
   - Write unit tests for all domain logic
3. Implement data layer (models, datasources, repository implementations)
   - **Avoid nullable returns**: Use Either<Failure, Success> pattern
   - Write unit tests for repositories and data sources
4. Create presentation layer (screens, widgets, providers)
   - **Provide safe accessors** for any nullable fields
   - Write widget tests for ALL UI components
   - Write integration tests for screen flows
5. **Verify test coverage** - ensure all new code has tests
6. Update PLAN.md with completed work

## Testing Requirements
- **Every new file MUST have a corresponding test file**
- **Follow testing best practices** - see .claude/commands/testing-best-practices.md
- **Write language-agnostic tests** - no text content dependencies
- **Test behavior, not implementation details** - no exact pixels/colors
- Test file structure should mirror source file structure
- Example: `lib/features/home/presentation/screens/home_screen.dart`
  → `test/features/home/presentation/screens/home_screen_test.dart`
- Run `dart run artifex:check` before committing any changes
- Never merge code without tests

### Testing Quality Checklist
- [ ] No `find.text()` finders (use icons/types instead)
- [ ] No specific error message testing
- [ ] No exact padding/font size testing
- [ ] Tests focus on user behavior
- [ ] All async states tested (loading, success, error)

## Quick References
- **Architecture**: See docs/architecture-strategy.md
- **Requirements**: See docs/artifex-checklist.md
- **Brand Guidelines**: See docs/brand-guidelines.md
- **Current Plan**: See docs/PLAN.md
- **Testing Guidelines**: See .claude/commands/testing-best-practices.md
- **Test Strategy**: See test/TEST_STRATEGY.md
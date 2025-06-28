# Claude Context - Artifex

## Project Overview
- **Type**: AI-powered photo transformation mobile application
- **Framework**: Flutter with Dart
- **Target Platforms**: iOS and Android (mobile only)
- **Location**: Repository root
- **Git**: Repository initialized with proper .gitignore

## User Context
- **Background**: Experienced C# developer with Angular and React knowledge
- **Environment**: Windows with WSL (Ubuntu)
- **Goal**: Learn cross-platform mobile development with a thriving community
- **Working Style**: Solo developer

## Project Requirements
- Mobile-only deployment (iOS/Android)
- AI-powered photo transformation using DALL-E 3 API
- Camera integration for photo capture
- Photo upload from gallery
- Filter-based transformations
- Social sharing capabilities

## Brand Identity
- **Name**: Artifex
- **Tagline**: "Your World, Reimagined"
- **Mission**: Empower everyone to become a digital artist by transforming everyday photos into extraordinary works of art with AI
- **Primary Colors**: 
  - Artifex Amethyst (#1E192B)
  - Generative Glow (#E6007A)
  - Canvas White (#F4F4F6)

## Technical Decisions
- **Flutter chosen because**:
  - Single codebase for both platforms
  - Near-native performance suitable for games
  - Excellent sensor/camera support
  - Strong typing (similar to C#)
  - Hot reload for fast development
  - Google-backed with massive community

## Architecture Implementation
- **State Management**: Riverpod with code generation (@riverpod annotations)
- **Architecture Pattern**: Clean Architecture + Repository Pattern
- **Project Structure**: Feature-based organization (features/[feature_name]/{data,domain,presentation})
- **Error Handling**: Flutter global error handlers + Either pattern with Dartz, custom Failure classes
- **Null Safety**: Near-null-free programming with Option pattern and safe defaults
- **Networking**: Dio client with interceptors, retry logic, and environment-based configuration
- **Dependency Injection**: Riverpod providers with generated code
- **Logging**: Logger package with environment-based levels and structured output
- **Database**: SQLite for production, PostgreSQL v3 for integration testing with transactions
- **Testing**: Language-agnostic tests, 142 tests passing, integration tests with database isolation

## Project Structure
```
/home/bv/git/artifex/
├── .git/                    # Git repository
├── .gitignore              # Flutter-specific gitignore
├── CLAUDE.md               # This file
├── lib/                    # Dart source files
│   ├── core/               # Core infrastructure
│   │   ├── errors/         # Custom failures and exceptions
│   │   ├── network/        # Dio client and network setup
│   │   ├── constants/      # App-wide constants
│   │   └── utils/          # Utilities (logger, etc.)
│   ├── features/           # Feature-based organization
│   │   └── photo_capture/  # Photo capture feature
│   │       ├── data/       # Data layer (repositories, datasources, models)
│   │       ├── domain/     # Domain layer (entities, use cases, interfaces)
│   │       └── presentation/ # UI layer (screens, widgets, providers)
│   ├── screens/            # Legacy screens (to be moved to features)
│   ├── widgets/            # Shared UI components
│   └── utils/              # Legacy utils (to be moved to core)
├── android/                # Android platform files
├── ios/                   # iOS platform files
├── test/                  # Test files
│   ├── integration/       # Database integration tests
│   └── ...               # Unit and widget tests
├── docker/                # Database containers for development
│   ├── docker-compose.yml # Container orchestration
│   ├── Makefile          # Database management commands
│   ├── init-dev.sql      # Development database setup
│   ├── init-test.sql     # Test database setup
│   └── README.md         # Docker setup documentation
├── scripts/               # Utility scripts
│   └── test-containers.sh # Container testing script
├── bin/                   # Custom Flutter commands
│   └── check.dart        # Custom test + analyze command
├── pubspec.yaml           # Dependencies
└── docs/                  # Documentation
    ├── PLAN.md             # Development plan and progress tracking
    ├── architecture-strategy.md # Comprehensive architecture guide
    ├── artifex-checklist.md # Feature requirements
    └── brand-guidelines.md # Brand identity guide
```

## Commands to Remember
```bash
# Navigate to project
cd /home/bv/git/artifex

# Run the app
flutter run

# Get dependencies
flutter pub get

# Quality Assurance (CUSTOM COMMANDS)
dart run artifex:check           # Fast mode (format, analyze, unit/widget tests ~30s)
dart run artifex:check --all     # Full mode (includes dependencies, integration tests ~2min)

# Individual Commands
flutter test                     # Run all tests (unit, widget, integration)
flutter test test/features       # Run only feature tests
flutter test test/unit           # Run only unit tests  
flutter test test/widget         # Run only widget tests
flutter test test/integration/   # Run only integration tests (needs database)
flutter analyze                 # Static code analysis only
dart format .                    # Format code only

# Integration Testing (Database Required)
cd docker && make test-up       # Start test database container
flutter test test/integration/  # Run integration tests
cd docker && make test-down     # Stop test database container

# Dependency Management
flutter pub get                 # Install dependencies
flutter pub outdated           # Check for outdated packages
flutter pub upgrade            # Update compatible versions
flutter pub deps               # Show dependency tree

# Build for release
flutter build apk --release        # Android APK
flutter build appbundle --release  # Android App Bundle
flutter build ios --release        # iOS

# Clean build cache (useful after project restructuring)
flutter clean

# Code generation (for Riverpod providers, JSON serialization)
flutter packages pub run build_runner build --delete-conflicting-outputs

# Watch mode for code generation during development
flutter packages pub run build_runner watch --delete-conflicting-outputs

# Database Development Commands
cd docker
make dev-up      # Start development database (with sample data)
make test-up     # Start test database (clean)
make dev-down    # Stop development database
make test-down   # Stop test database
make clean       # Remove all containers and volumes
make reset-dev   # Reset development database with fresh sample data
make logs        # View database logs

# Test database containers
./scripts/test-containers.sh
```

## Flutter Best Practices

### Project Structure (Updated Architecture)
- **lib/core/** - Core infrastructure and utilities
  - `errors/` - Custom failure classes and exceptions
  - `network/` - Dio client setup with interceptors
  - `constants/` - App-wide configuration constants
  - `utils/` - Logging and helper utilities
- **lib/features/** - Feature-based organization
  - `[feature_name]/data/` - Models, datasources, repository implementations
  - `[feature_name]/domain/` - Entities, use cases, repository interfaces
  - `[feature_name]/presentation/` - UI screens, widgets, Riverpod providers
- **lib/shared/** - Shared components across features
  - `widgets/` - Reusable UI components
  - `themes/` - App theming
- **Generated files** - Build runner creates `.g.dart` files for providers

### Code Style
- Use `const` constructors whenever possible for performance
- Prefer composition over inheritance
- Extract widgets into separate files when > 100 lines
- Use meaningful widget names (not Widget1, Widget2)
- Follow Dart naming conventions:
  - Classes: PascalCase
  - Files/folders: snake_case
  - Variables/functions: camelCase
- Use `@riverpod` annotations for dependency injection
- Implement Either<Failure, Success> pattern for error handling
- **Near-null-free programming**: Minimize null usage with Option pattern and safe defaults

### State Management (Implemented)
- **Riverpod** with code generation (@riverpod annotations)
- Provider-based dependency injection for clean testing
- Separate providers for different concerns (data, business logic, UI state)
- StateNotifier pattern for complex state management

### Performance
- Use `const` widgets to prevent rebuilds
- Implement `ListView.builder` for long lists
- Cache images with `cached_network_image`
- Avoid rebuilding entire widget tree

### Testing
- Write widget tests for UI components
- Unit test business logic
- Integration tests for critical user flows
- Aim for 70%+ code coverage

### Dependencies
- Only add packages you need
- Check package maintenance/popularity
- Prefer official Google/Dart packages
- Lock versions in pubspec.yaml

### Git Workflow
- Feature branches for new work
- Commit often with clear messages
- Run tests before pushing
- Use conventional commits

### Pre-commit Checklist
Always run these before committing:
```bash
dart run artifex:check      # Fast check (recommended for development)
dart run artifex:check --all # Full check (recommended before commits)
# OR individually:
dart format .           # Format code
flutter analyze         # Check for code issues
flutter test           # Run all tests
# If you've modified @riverpod providers, run:
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Testing Guidelines
**CRITICAL: ALL new code must have tests following these rules:**
- **Language-agnostic tests**: No `find.text()` - use `find.byIcon()`, `find.byType()`
- **Test behavior, not implementation**: No exact pixels, colors, or padding values
- **Error testing without messages**: Test `hasError`, not specific error strings
- **Semantic finders**: Find buttons by icons, not text content
- **See detailed guidelines**: `.claude/commands/testing-best-practices.md`

**Test Quality Checklist:**
- [ ] No text content dependencies (i18n-ready)
- [ ] No implementation detail testing
- [ ] Focus on user behavior and interactions
- [ ] All async states tested (loading, success, error)
- [ ] Tests pass: `dart run artifex:check --all`

## CI/CD Status
- ✅ GitHub Actions configured with enhanced reporting
- ✅ Automated testing on push (unit, widget, integration)
- ✅ PostgreSQL v3 integration testing in CI
- ✅ Dependency vulnerability scanning
- ✅ Outdated package reporting
- ✅ APK builds for Android
- ✅ iOS builds (unsigned)
- ✅ Static analysis with strict linting rules (Very Good Analysis standards)

## Version Management & Dependencies
- Flutter version: 3.32.4 (specified in `.flutter-version`)
- All direct dependencies up to date
- Major updates completed: go_router v15.2.4, intl v0.20.2, postgres v3.5.6
- Removed unused dependencies for cleaner builds
- GitHub Actions automatically syncs with Flutter version

## Configuration Files
- `.flutter-version` - Flutter SDK version specification
- `analysis_options.yaml` - Strict linting rules (86.2% of Very Good Analysis rules enabled)
- `pubspec.yaml` - Clean dependency management, no unused packages
- `.gitignore` - Properly configured for Flutter projects
- `.github/workflows/flutter-ci.yml` - Enhanced CI/CD with warning capture
- `bin/check.dart` - Custom quality assurance command with fast/full modes

## Notes
- User prefers concise responses
- Focus on practical implementation
- Keep documentation minimal unless requested
- **ALWAYS update docs/PLAN.md** after completing work (see .claude/commands/update-plan.md)
- **Use near-null-free programming**: Prefer Option<T>, Either<L,R>, and safe defaults over nullable types
- Run `flutter clean` after major project restructuring to clear CMake cache
- **CRITICAL: Write tests for ALL new code - NO EXCEPTIONS!**
  - Every new file must have corresponding test file
  - Test structure mirrors source: `lib/[path]` → `test/[path]`
  - **Follow testing best practices**: `.claude/commands/testing-best-practices.md`
  - **Language-agnostic tests**: No text dependencies, use semantic finders
  - Current test count: 142 tests (all passing, all i18n-ready)
# Claude Context - Hello App World

## Project Overview
- **Type**: Cross-platform mobile application
- **Framework**: Flutter with Dart
- **Target Platforms**: iOS and Android (mobile only)
- **Location**: `/src/hello_app_world/`
- **Git**: Repository initialized with proper .gitignore

## User Context
- **Background**: Experienced C# developer with Angular and React knowledge
- **Environment**: Windows with WSL (Ubuntu)
- **Goal**: Learn cross-platform mobile development with a thriving community
- **Working Style**: Solo developer

## Project Requirements
- Mobile-only deployment (iOS/Android)
- Should support simple game development
- Camera and sensor integration needed
- Performance not critical initially but game-capable

## Technical Decisions
- **Flutter chosen because**:
  - Single codebase for both platforms
  - Near-native performance suitable for games
  - Excellent sensor/camera support
  - Strong typing (similar to C#)
  - Hot reload for fast development
  - Google-backed with massive community

## Project Structure
```
/home/bv/git/hello-app-world/
├── .git/                    # Git repository
├── .gitignore              # Flutter-specific gitignore
├── CLAUDE.md               # This file
└── src/
    └── hello_app_world/    # Flutter project root
        ├── lib/            # Dart source files
        ├── android/        # Android platform files
        ├── ios/           # iOS platform files
        ├── test/          # Test files
        └── pubspec.yaml   # Dependencies
```

## Commands to Remember
```bash
# Navigate to project
cd /home/bv/git/hello-app-world/src/hello_app_world

# Run the app
flutter run

# Get dependencies
flutter pub get

# Run tests
flutter test

# Analyze code
flutter analyze

# Build for release
flutter build apk --release        # Android APK
flutter build appbundle --release  # Android App Bundle
flutter build ios --release        # iOS
```

## Flutter Best Practices

### Project Structure
- **lib/** - All Dart code goes here
  - `main.dart` - App entry point only
  - `screens/` - Full page widgets
  - `widgets/` - Reusable UI components
  - `models/` - Data models
  - `services/` - API, database, device services
  - `utils/` - Helper functions and constants
  - `providers/` or `blocs/` - State management

### Code Style
- Use `const` constructors whenever possible for performance
- Prefer composition over inheritance
- Extract widgets into separate files when > 100 lines
- Use meaningful widget names (not Widget1, Widget2)
- Follow Dart naming conventions:
  - Classes: PascalCase
  - Files/folders: snake_case
  - Variables/functions: camelCase

### State Management
- Options: Provider, Riverpod, Bloc, GetX
- Start simple with Provider or Riverpod
- Keep business logic separate from UI

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

## CI/CD Status
- ✅ GitHub Actions configured
- ✅ Automated testing on push
- ✅ APK builds for Android
- ✅ iOS builds (unsigned)

## Notes
- User prefers concise responses
- Focus on practical implementation
- Keep documentation minimal unless requested
- Update docs/progress.md for session continuity
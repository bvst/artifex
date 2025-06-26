# Artifex

*Your World, Reimagined.*

AI-powered photo transformation app that empowers everyone to become a digital artist.

## Overview

Artifex transforms everyday photos into extraordinary works of art using the power of AI. With sophisticated image generation technology, we make creative transformation feel effortless, intuitive, and magical.

## Features

- **Camera Integration**: Capture photos directly within the app
- **Gallery Upload**: Transform existing photos from your device
- **AI-Powered Filters**: Multiple creative transformation styles
- **Easy Sharing**: Share your creations with the world

## Getting Started

### Prerequisites

- Flutter SDK (^3.8.1)
- Dart SDK
- Android Studio / Xcode for platform-specific development

### Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/artifex.git

# Navigate to project directory
cd artifex

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Development

```bash
# Run tests
flutter test

# Analyze code
flutter analyze

# Build for production
flutter build apk --release        # Android
flutter build ios --release        # iOS
```

## Tech Stack

- **Framework**: Flutter
- **Language**: Dart
- **AI**: OpenAI DALL-E 3 API
- **State Management**: TBD (Provider/Riverpod)
- **Storage**: SharedPreferences

## Project Structure

```
artifex/
├── lib/
│   ├── main.dart           # App entry point
│   ├── screens/            # Full page widgets
│   ├── widgets/            # Reusable UI components
│   ├── models/             # Data models
│   ├── services/           # API and device services
│   └── utils/              # Helper functions
├── test/                   # Test files
├── android/                # Android platform files
├── ios/                    # iOS platform files
└── docs/                   # Documentation
```

## Contributing

This is currently a solo learning project, but suggestions and feedback are welcome!

## License

This project is private and not licensed for public use.

## Contact

For questions or feedback, please open an issue in the repository.
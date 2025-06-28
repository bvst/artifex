import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';

import 'package:artifex/features/photo_capture/domain/repositories/photo_repository.dart';
import 'package:artifex/features/photo_capture/presentation/providers/photo_providers.dart';
import 'package:artifex/shared/themes/app_theme.dart';

/// Builder pattern for creating consistent test widgets with providers
class TestWidgetBuilder {
  Widget? _child;
  final List<Override> _overrides = [];
  ThemeData? _theme;
  bool _wrapInScaffold = true;

  TestWidgetBuilder child(Widget child) {
    _child = child;
    return this;
  }

  TestWidgetBuilder overridePhotoRepository(PhotoRepository repository) {
    _overrides.add(photoRepositoryProvider.overrideWithValue(repository));
    return this;
  }

  TestWidgetBuilder theme(ThemeData theme) {
    _theme = theme;
    return this;
  }

  TestWidgetBuilder noScaffold() {
    _wrapInScaffold = false;
    return this;
  }

  Widget build() {
    assert(_child != null, 'Child widget must be provided');

    Widget app = MaterialApp(
      theme: _theme ?? AppTheme.lightTheme,
      home: _wrapInScaffold ? Scaffold(body: _child!) : _child!,
    );

    if (_overrides.isNotEmpty) {
      app = ProviderScope(overrides: _overrides, child: app);
    }

    return app;
  }
}

/// Builder for creating Riverpod provider containers for testing
class ProviderContainerBuilder {
  final List<Override> _overrides = [];

  ProviderContainerBuilder overridePhotoRepository(PhotoRepository repository) {
    _overrides.add(photoRepositoryProvider.overrideWithValue(repository));
    return this;
  }

  ProviderContainer build() {
    return ProviderContainer(overrides: _overrides);
  }
}

/// Utility extensions for cleaner test setup
extension TestSetupExtensions on Mock {
  /// Helper to setup common photo repository mock responses
  void setupPhotoRepositoryDefaults() {
    // Add default mock setups here if needed
  }
}

/// Factory methods for common test scenarios
class TestScenarios {
  /// Creates a widget with photo repository mocked
  static TestWidgetBuilder widgetWithPhotoRepository(
    Widget child,
    PhotoRepository mockRepository,
  ) {
    return TestWidgetBuilder()
        .child(child)
        .overridePhotoRepository(mockRepository);
  }

  /// Creates a provider container with photo repository mocked
  static ProviderContainerBuilder containerWithPhotoRepository(
    PhotoRepository mockRepository,
  ) {
    return ProviderContainerBuilder().overridePhotoRepository(mockRepository);
  }
}

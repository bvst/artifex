import 'package:artifex/features/photo_capture/domain/entities/photo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Custom matchers for domain-specific assertions
/// This is very Flutter/Dart idiomatic for testing

/// Matcher for Photo entities
Matcher isPhotoWith({
  String? id,
  String? name,
  int? size,
  DateTime? createdAt,
}) => _PhotoMatcher(id: id, name: name, size: size, createdAt: createdAt);

class _PhotoMatcher extends Matcher {
  const _PhotoMatcher({this.id, this.name, this.size, this.createdAt});
  final String? id;
  final String? name;
  final int? size;
  final DateTime? createdAt;

  @override
  bool matches(Object? item, Map<dynamic, dynamic> matchState) {
    if (item is! Photo) return false;

    if (id != null && item.id != id) return false;
    if (name != null && item.name != name) return false;
    if (size != null && item.size != size) return false;
    if (createdAt != null && item.createdAt != createdAt) return false;

    return true;
  }

  @override
  Description describe(Description description) {
    final parts = <String>[];
    if (id != null) parts.add('id: $id');
    if (name != null) parts.add('name: $name');
    if (size != null) parts.add('size: $size');
    if (createdAt != null) parts.add('createdAt: $createdAt');

    return description.add('Photo with ${parts.join(', ')}');
  }
}

/// Matcher for AsyncValue states
Matcher isAsyncData<T>(T data) => _AsyncDataMatcher<T>(data);
Matcher get isAsyncLoading => const _AsyncLoadingMatcher();
Matcher isAsyncError(Object error) => _AsyncErrorMatcher(error);

class _AsyncDataMatcher<T> extends Matcher {
  const _AsyncDataMatcher(this.expectedData);
  final T expectedData;

  @override
  bool matches(Object? item, Map<dynamic, dynamic> matchState) =>
      item is AsyncData<T> && item.value == expectedData;

  @override
  Description describe(Description description) =>
      description.add('AsyncData with value $expectedData');
}

class _AsyncLoadingMatcher extends Matcher {
  const _AsyncLoadingMatcher();

  @override
  bool matches(Object? item, Map<dynamic, dynamic> matchState) =>
      item is AsyncLoading;

  @override
  Description describe(Description description) =>
      description.add('AsyncLoading state');
}

class _AsyncErrorMatcher extends Matcher {
  const _AsyncErrorMatcher(this.expectedError);
  final Object expectedError;

  @override
  bool matches(Object? item, Map<dynamic, dynamic> matchState) =>
      item is AsyncError && item.error == expectedError;

  @override
  Description describe(Description description) =>
      description.add('AsyncError with error $expectedError');
}

/// Widget-specific matchers
Matcher hasText(String text) => _HasTextMatcher(text);
Matcher hasTextContaining(String substring) =>
    _HasTextContainingMatcher(substring);
Matcher isEnabled() => const _IsEnabledMatcher();
Matcher isDisabled() => const _IsDisabledMatcher();

class _HasTextMatcher extends Matcher {
  const _HasTextMatcher(this.expectedText);
  final String expectedText;

  @override
  bool matches(Object? item, Map<dynamic, dynamic> matchState) {
    if (item is Text) {
      return item.data == expectedText;
    }
    return false;
  }

  @override
  Description describe(Description description) =>
      description.add('Text widget with text "$expectedText"');
}

class _HasTextContainingMatcher extends Matcher {
  const _HasTextContainingMatcher(this.substring);
  final String substring;

  @override
  bool matches(Object? item, Map<dynamic, dynamic> matchState) {
    if (item is Text && item.data != null) {
      return item.data!.contains(substring);
    }
    return false;
  }

  @override
  Description describe(Description description) =>
      description.add('Text widget containing "$substring"');
}

class _IsEnabledMatcher extends Matcher {
  const _IsEnabledMatcher();

  @override
  bool matches(Object? item, Map<dynamic, dynamic> matchState) {
    if (item is ButtonStyleButton) {
      return item.enabled;
    }
    if (item is InkWell) {
      return item.onTap != null;
    }
    return false;
  }

  @override
  Description describe(Description description) =>
      description.add('enabled widget');
}

class _IsDisabledMatcher extends Matcher {
  const _IsDisabledMatcher();

  @override
  bool matches(Object? item, Map<dynamic, dynamic> matchState) {
    if (item is ButtonStyleButton) {
      return !item.enabled;
    }
    if (item is InkWell) {
      return item.onTap == null;
    }
    return false;
  }

  @override
  Description describe(Description description) =>
      description.add('disabled widget');
}

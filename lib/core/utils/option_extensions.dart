// Enhanced Option/Maybe pattern extensions for Artifex
// Helps minimize null usage by providing functional alternatives

import 'package:dartz/dartz.dart';

// Extension to convert nullable values to Option
extension NullableToOption<T> on T? {
  Option<T> get toOption => this != null ? some(this as T) : none();
}

// Extension for safe operations on nullable values
extension SafeOperations<T> on T? {
  // Transform nullable value
  U? map<U>(U Function(T) transform) {
    return this != null ? transform(this as T) : null;
  }
  
  // Provide default value
  T orElse(T defaultValue) {
    return this ?? defaultValue;
  }
  
  // Lazy default value
  T orElseGet(T Function() defaultValue) {
    return this ?? defaultValue();
  }
  
  // Conditional execution
  void ifPresent(void Function(T) action) {
    if (this != null) action(this as T);
  }
}

// Extension for List operations without nulls
extension SafeListOperations<T> on List<T> {
  Option<T> get headOption => isEmpty ? none() : some(first);
  Option<T> get lastOption => isEmpty ? none() : some(last);
  
  Option<T> getOption(int index) {
    return index >= 0 && index < length ? some(this[index]) : none();
  }
  
  List<T> whereNotNull() {
    return where((item) => item != null).toList();
  }
}

// Extension for Map operations
extension SafeMapOperations<K, V> on Map<K, V> {
  Option<V> getOption(K key) {
    return containsKey(key) ? some(this[key] as V) : none();
  }
}

// Extension for String operations
extension SafeStringOperations on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
  bool get isNotNullOrEmpty => !isNullOrEmpty;
  
  String get orEmpty => this ?? '';
  
  Option<String> get nonEmptyOption {
    return isNullOrEmpty ? none() : some(this!);
  }
}
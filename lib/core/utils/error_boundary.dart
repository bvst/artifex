import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ErrorBoundary extends ConsumerWidget {
  const ErrorBoundary({required this.child, super.key, this.onError});

  final Widget child;
  final void Function(Object error, StackTrace stackTrace)? onError;

  @override
  Widget build(BuildContext context, WidgetRef ref) => child; // For now, just return the child directly
  // TODO(artifex): Implement proper error boundary when Flutter provides better APIs
}

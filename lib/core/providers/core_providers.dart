import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:sqflite/sqflite.dart';
import '../network/dio_client.dart';
import '../database/database_helper.dart';
import '../utils/logger.dart';

part 'core_providers.g.dart';

/// Provider for Dio HTTP client
@riverpod
Dio dioClient(Ref ref) {
  final client = DioClient();
  client.initialize();
  return client.dio;
}

/// Provider for SQLite database
@riverpod
Future<Database> database(Ref ref) async {
  return DatabaseHelper.getDatabase();
}

/// Provider for AppLogger
@riverpod
AppLogger appLogger(Ref ref) {
  return AppLogger();
}
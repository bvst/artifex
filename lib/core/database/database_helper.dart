import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../utils/logger.dart';
import 'database_config.dart';

/// Database helper for SQLite operations
class DatabaseHelper {
  static const String _databaseName = DatabaseConfig.sqliteDbName;
  static const int _databaseVersion = DatabaseConfig.sqliteVersion;

  static Database? _database;

  /// Get or create database instance
  static Future<Database> getDatabase() async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    AppLogger.info('Initializing database');

    // Get database path
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);

    AppLogger.debug('Database path: $path');

    // Open database
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onOpen: _onOpen,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    AppLogger.info('Creating database tables');

    // Execute migration SQL from config
    for (final sql in DatabaseConfig.migrationSql) {
      await db.execute(sql);
    }

    // Create photos table (for local photo storage)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS photos (
        id TEXT PRIMARY KEY,
        path TEXT NOT NULL,
        name TEXT NOT NULL,
        size INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        width INTEGER,
        height INTEGER,
        mimeType TEXT
      )
    ''');

    AppLogger.info('Database tables created successfully');
  }

  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    AppLogger.info(
      'Upgrading database from version $oldVersion to $newVersion',
    );

    // Handle database upgrades here
    if (oldVersion < 2) {
      // Future migrations will go here
    }
  }

  static Future<void> _onOpen(Database db) async {
    AppLogger.debug('Database opened successfully');

    // Enable foreign key constraints
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Close database connection
  static Future<void> close() async {
    if (_database != null) {
      AppLogger.debug('Closing database connection');
      await _database!.close();
      _database = null;
    }
  }

  /// Delete database file (for testing or reset)
  static Future<void> deleteDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    final file = File(path);

    if (await file.exists()) {
      AppLogger.warning('Deleting database file: $path');
      await file.delete();
      _database = null;
    }
  }
}

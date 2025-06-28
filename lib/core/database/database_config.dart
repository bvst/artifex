/// Database configuration for different environments
class DatabaseConfig {
  static const String sqliteDbName = 'artifex.db';
  static const int sqliteVersion = 1;

  // PostgreSQL configuration for development/testing
  static const String postgresHost = 'localhost';
  static const int postgresDevPort = 5430;
  static const int postgresTestPort = 5433;
  static const String postgresDevDb = 'artifex_dev';
  static const String postgresTestDb = 'artifex_test';
  static const String postgresDevUser = 'artifex_user';
  static const String postgresTestUser = 'artifex_test_user';
  static const String postgresDevPassword = 'artifex_dev_password';
  static const String postgresTestPassword = 'artifex_test_password';

  /// SQL to create transformations table (compatible with both SQLite and PostgreSQL)
  static const String createTransformationsTable = '''
    CREATE TABLE IF NOT EXISTS transformations (
      id TEXT PRIMARY KEY,
      imageUrl TEXT NOT NULL,
      thumbnailUrl TEXT NOT NULL,
      prompt TEXT NOT NULL,
      style TEXT NOT NULL,
      createdAt TEXT NOT NULL,
      localPath TEXT
    );
  ''';

  /// SQL to create indexes
  static const String createTransformationsIndexes = '''
    CREATE INDEX IF NOT EXISTS idx_transformations_created_at ON transformations(createdAt);
    CREATE INDEX IF NOT EXISTS idx_transformations_style ON transformations(style);
  ''';

  /// Get the table creation SQL for the current environment
  static List<String> get migrationSql => [
    createTransformationsTable,
    createTransformationsIndexes,
  ];
}

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:postgres/postgres.dart';

void main() {
  group('Database Container Integration Tests', () {
    late Connection connection;

    setUpAll(() async {
      // Wait for test database to be ready
      await _waitForDatabase();
    });

    setUp(() async {
      // Connect to test database
      connection = await Connection.open(
        Endpoint(
          host: 'localhost',
          port: 5433,
          database: 'artifex_test',
          username: 'artifex_test_user',
          password: 'artifex_test_password',
        ),
        settings: const ConnectionSettings(sslMode: SslMode.disable),
      );

      // Clean up any existing data
      await connection.execute('DELETE FROM transformations');
    });

    tearDown(() async {
      await connection.close();
    });

    group('Transformation Storage', () {
      test('should save and retrieve transformation', () async {
        // Arrange
        const transformationData = {
          'id': 'test_transformation_1',
          'imageUrl': 'https://example.com/image.png',
          'thumbnailUrl': 'https://example.com/thumb.png',
          'prompt': 'A beautiful sunset',
          'style': 'artistic',
          'createdAt': '2023-12-13T10:30:00.000Z',
          'localPath': null,
        };

        // Act - Insert transformation
        await connection.execute(
          Sql.named('''
            INSERT INTO transformations (id, imageUrl, thumbnailUrl, prompt, style, createdAt, localPath)
            VALUES (@id, @imageUrl, @thumbnailUrl, @prompt, @style, @createdAt, @localPath)
          '''),
          parameters: transformationData,
        );

        // Act - Retrieve transformation
        final result = await connection.execute(
          Sql.named('SELECT * FROM transformations WHERE id = @id'),
          parameters: {'id': 'test_transformation_1'},
        );

        // Assert
        expect(result.length, 1);
        final row = result.first;
        expect(row[0], 'test_transformation_1'); // id
        expect(row[1], 'https://example.com/image.png'); // imageUrl
        expect(row[2], 'https://example.com/thumb.png'); // thumbnailUrl
        expect(row[3], 'A beautiful sunset'); // prompt
        expect(row[4], 'artistic'); // style
      });

      test(
        'should retrieve transformations in descending order by date',
        () async {
          // Arrange - Insert transformations with different timestamps
          final transformations = [
            {
              'id': 'test_1',
              'imageUrl': 'https://example.com/image1.png',
              'thumbnailUrl': 'https://example.com/thumb1.png',
              'prompt': 'First transformation',
              'style': 'artistic',
              'createdAt': '2023-12-13T08:00:00.000Z',
              'localPath': null,
            },
            {
              'id': 'test_2',
              'imageUrl': 'https://example.com/image2.png',
              'thumbnailUrl': 'https://example.com/thumb2.png',
              'prompt': 'Second transformation',
              'style': 'vintage',
              'createdAt': '2023-12-13T10:00:00.000Z',
              'localPath': null,
            },
            {
              'id': 'test_3',
              'imageUrl': 'https://example.com/image3.png',
              'thumbnailUrl': 'https://example.com/thumb3.png',
              'prompt': 'Third transformation',
              'style': 'futuristic',
              'createdAt': '2023-12-13T12:00:00.000Z',
              'localPath': null,
            },
          ];

          for (final transformation in transformations) {
            await connection.execute(
              Sql.named('''
                INSERT INTO transformations (id, imageUrl, thumbnailUrl, prompt, style, createdAt, localPath)
                VALUES (@id, @imageUrl, @thumbnailUrl, @prompt, @style, @createdAt, @localPath)
              '''),
              parameters: transformation,
            );
          }

          // Act - Retrieve transformations ordered by createdAt DESC
          final result = await connection.execute(
            'SELECT id FROM transformations ORDER BY createdAt DESC',
          );

          // Assert - Should be ordered newest first
          expect(result.length, 3);
          expect(result[0][0], 'test_3'); // newest
          expect(result[1][0], 'test_2'); // middle
          expect(result[2][0], 'test_1'); // oldest
        },
      );

      test('should update transformation with local path', () async {
        // Arrange - Insert initial transformation
        await connection.execute(
          Sql.named('''
            INSERT INTO transformations (id, imageUrl, thumbnailUrl, prompt, style, createdAt, localPath)
            VALUES (@id, @imageUrl, @thumbnailUrl, @prompt, @style, @createdAt, @localPath)
          '''),
          parameters: {
            'id': 'test_update',
            'imageUrl': 'https://example.com/image.png',
            'thumbnailUrl': 'https://example.com/thumb.png',
            'prompt': 'Test transformation',
            'style': 'artistic',
            'createdAt': '2023-12-13T10:30:00.000Z',
            'localPath': null,
          },
        );

        // Act - Update with local path
        await connection.execute(
          Sql.named(
            'UPDATE transformations SET localPath = @localPath WHERE id = @id',
          ),
          parameters: {
            'id': 'test_update',
            'localPath': '/local/cached/image.png',
          },
        );

        // Assert
        final result = await connection.execute(
          Sql.named('SELECT localPath FROM transformations WHERE id = @id'),
          parameters: {'id': 'test_update'},
        );

        expect(result.length, 1);
        expect(result.first[0], '/local/cached/image.png');
      });

      test('should delete transformation from database', () async {
        // Arrange - Insert two transformations
        final transformations = [
          {
            'id': 'test_delete_1',
            'imageUrl': 'https://example.com/image1.png',
            'thumbnailUrl': 'https://example.com/thumb1.png',
            'prompt': 'First transformation',
            'style': 'artistic',
            'createdAt': '2023-12-13T10:00:00.000Z',
            'localPath': null,
          },
          {
            'id': 'test_delete_2',
            'imageUrl': 'https://example.com/image2.png',
            'thumbnailUrl': 'https://example.com/thumb2.png',
            'prompt': 'Second transformation',
            'style': 'vintage',
            'createdAt': '2023-12-13T11:00:00.000Z',
            'localPath': null,
          },
        ];

        for (final transformation in transformations) {
          await connection.execute(
            Sql.named('''
              INSERT INTO transformations (id, imageUrl, thumbnailUrl, prompt, style, createdAt, localPath)
              VALUES (@id, @imageUrl, @thumbnailUrl, @prompt, @style, @createdAt, @localPath)
            '''),
            parameters: transformation,
          );
        }

        // Act - Delete one transformation
        await connection.execute(
          Sql.named('DELETE FROM transformations WHERE id = @id'),
          parameters: {'id': 'test_delete_1'},
        );

        // Assert
        final result = await connection.execute(
          'SELECT id FROM transformations',
        );
        expect(result.length, 1);
        expect(result.first[0], 'test_delete_2');
      });
    });

    group('Database Schema', () {
      test('should have correct table structure', () async {
        // Act - Query table info
        final result = await connection.execute('''
          SELECT column_name, data_type, is_nullable
          FROM information_schema.columns
          WHERE table_name = 'transformations'
          ORDER BY ordinal_position
        ''');

        // Assert - Check required columns exist
        final columns = result.map((row) => row[0] as String).toList();
        expect(columns, contains('id'));
        expect(columns, contains('imageurl'));
        expect(columns, contains('thumbnailurl'));
        expect(columns, contains('prompt'));
        expect(columns, contains('style'));
        expect(columns, contains('createdat'));
        expect(columns, contains('localpath'));
      });

      test('should enforce primary key constraint', () async {
        // Arrange - Insert first transformation
        await connection.execute(
          Sql.named('''
            INSERT INTO transformations (id, imageUrl, thumbnailUrl, prompt, style, createdAt, localPath)
            VALUES (@id, @imageUrl, @thumbnailUrl, @prompt, @style, @createdAt, @localPath)
          '''),
          parameters: {
            'id': 'duplicate_id',
            'imageUrl': 'https://example.com/image.png',
            'thumbnailUrl': 'https://example.com/thumb.png',
            'prompt': 'Test transformation',
            'style': 'artistic',
            'createdAt': '2023-12-13T10:30:00.000Z',
            'localPath': null,
          },
        );

        // Act & Assert - Try to insert duplicate ID
        expect(
          () => connection.execute(
            Sql.named('''
              INSERT INTO transformations (id, imageUrl, thumbnailUrl, prompt, style, createdAt, localPath)
              VALUES (@id, @imageUrl, @thumbnailUrl, @prompt, @style, @createdAt, @localPath)
            '''),
            parameters: {
              'id': 'duplicate_id', // Same ID
              'imageUrl': 'https://example.com/different.png',
              'thumbnailUrl': 'https://example.com/different_thumb.png',
              'prompt': 'Different transformation',
              'style': 'vintage',
              'createdAt': '2023-12-13T11:30:00.000Z',
              'localPath': null,
            },
          ),
          throwsA(isA<ServerException>()),
        );

        // Verify only one record exists
        final result = await connection.execute(
          Sql.named('SELECT COUNT(*) FROM transformations WHERE id = @id'),
          parameters: {'id': 'duplicate_id'},
        );
        expect(result.first[0], 1);
      });
    });
  });
}

/// Wait for the test database container to be ready
Future<void> _waitForDatabase() async {
  const maxAttempts = 30;
  const delayBetweenAttempts = Duration(seconds: 2);

  for (var attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      final connection = await Connection.open(
        Endpoint(
          host: 'localhost',
          port: 5433,
          database: 'artifex_test',
          username: 'artifex_test_user',
          password: 'artifex_test_password',
        ),
        settings: const ConnectionSettings(sslMode: SslMode.disable),
      );

      // Test the connection
      await connection.execute('SELECT 1');
      await connection.close();

      // Use testWidgets print which is allowed in tests
      debugPrint('✅ Test database is ready!');
      return;
    } on Exception {
      if (attempt == maxAttempts) {
        throw Exception(
          'Failed to connect to test database after $maxAttempts attempts. '
          'Make sure the database container is running: "make test-up"',
        );
      }

      debugPrint(
        '⏳ Waiting for test database... (attempt $attempt/$maxAttempts)',
      );
      await Future<void>.delayed(delayBetweenAttempts);
    }
  }
}

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:sqflite/sqflite.dart';
import 'package:artifex/core/errors/exceptions.dart';
import 'package:artifex/core/utils/logger.dart';
import '../models/transformation_result_model.dart';

/// Local data source for AI transformation operations
class AITransformationLocalDataSource {
  final Database _database;
  final Dio _dio;

  const AITransformationLocalDataSource({
    required Database database,
    required Dio dio,
  }) : _database = database, _dio = dio;

  static const String _tableName = 'transformations';

  /// Save transformation result to local database
  Future<void> saveTransformation(TransformationResultModel transformation) async {
    try {
      AppLogger.info('Saving transformation to local database: ${transformation.id}');
      
      await _database.insert(
        _tableName,
        transformation.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      AppLogger.debug('Transformation saved successfully');
    } catch (e) {
      AppLogger.error('Failed to save transformation: $e');
      throw CacheException('Failed to save transformation: ${e.toString()}');
    }
  }

  /// Get all transformations from local database
  Future<List<TransformationResultModel>> getTransformationHistory() async {
    try {
      AppLogger.info('Fetching transformation history from local database');
      
      final List<Map<String, dynamic>> maps = await _database.query(
        _tableName,
        orderBy: 'createdAt DESC',
      );
      
      final transformations = maps
          .map((map) => TransformationResultModel.fromJson(map))
          .toList();
      
      AppLogger.info('Found ${transformations.length} transformations in history');
      return transformations;
    } catch (e) {
      AppLogger.error('Failed to fetch transformation history: $e');
      throw CacheException('Failed to fetch transformation history: ${e.toString()}');
    }
  }

  /// Download and cache transformed image locally
  Future<String> downloadTransformedImage(
    String imageUrl,
    String transformationId,
  ) async {
    try {
      AppLogger.info('Downloading transformed image: $transformationId');
      
      // Get app documents directory
      final documentsDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${documentsDir.path}/transformed_images');
      
      // Create directory if it doesn't exist
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }
      
      // Generate local file path
      final fileName = '${transformationId}_transformed.jpg';
      final localPath = '${imagesDir.path}/$fileName';
      
      // Download image
      AppLogger.debug('Downloading from: $imageUrl');
      AppLogger.debug('Saving to: $localPath');
      
      await _dio.download(
        imageUrl,
        localPath,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
        ),
      );
      
      // Verify file was created
      final file = File(localPath);
      if (!await file.exists()) {
        throw const CacheException('Downloaded file does not exist');
      }
      
      final fileSize = await file.length();
      AppLogger.info('Image downloaded successfully: $fileName ($fileSize bytes)');
      
      return localPath;
    } on DioException catch (e) {
      AppLogger.error('Failed to download image: ${e.message}', e);
      throw NetworkException('Failed to download image: ${e.message ?? 'Unknown error'}');
    } catch (e) {
      AppLogger.error('Unexpected error downloading image: $e');
      throw CacheException('Failed to download image: ${e.toString()}');
    }
  }

  /// Delete transformation from local database and file system
  Future<void> deleteTransformation(String transformationId) async {
    try {
      AppLogger.info('Deleting transformation: $transformationId');
      
      // Get transformation to find local file path
      final transformations = await _database.query(
        _tableName,
        where: 'id = ?',
        whereArgs: [transformationId],
      );
      
      if (transformations.isNotEmpty) {
        final transformation = TransformationResultModel.fromJson(transformations.first);
        
        // Delete local file if it exists
        if (transformation.localPath != null) {
          final file = File(transformation.localPath!);
          if (await file.exists()) {
            await file.delete();
            AppLogger.debug('Deleted local file: ${transformation.localPath}');
          }
        }
      }
      
      // Delete from database
      final deletedRows = await _database.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [transformationId],
      );
      
      if (deletedRows > 0) {
        AppLogger.info('Transformation deleted successfully');
      } else {
        AppLogger.warning('No transformation found with id: $transformationId');
      }
    } catch (e) {
      AppLogger.error('Failed to delete transformation: $e');
      throw CacheException('Failed to delete transformation: ${e.toString()}');
    }
  }

  /// Update transformation with local path after download
  Future<void> updateTransformationLocalPath(
    String transformationId,
    String localPath,
  ) async {
    try {
      AppLogger.info('Updating transformation local path: $transformationId');
      
      await _database.update(
        _tableName,
        {'localPath': localPath},
        where: 'id = ?',
        whereArgs: [transformationId],
      );
      
      AppLogger.debug('Local path updated successfully');
    } catch (e) {
      AppLogger.error('Failed to update transformation local path: $e');
      throw CacheException('Failed to update local path: ${e.toString()}');
    }
  }
}
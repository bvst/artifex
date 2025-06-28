import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:artifex/features/photo_capture/domain/entities/photo.dart';

class PhotoModel extends Photo {
  const PhotoModel({
    required super.id,
    required super.path,
    required super.name,
    required super.size,
    required super.createdAt,
    super.width,
    super.height,
    super.mimeType,
  });

  factory PhotoModel.fromFile(File file, {int? width, int? height}) {
    final stat = file.statSync();
    const uuid = Uuid();

    return PhotoModel(
      id: uuid.v4(),
      path: file.path,
      name: file.path.split('/').last,
      size: stat.size,
      createdAt: stat.modified,
      width: width,
      height: height,
      mimeType: _getMimeTypeFromPath(file.path),
    );
  }

  factory PhotoModel.fromJson(Map<String, dynamic> json) {
    return PhotoModel(
      id: json['id'] as String,
      path: json['path'] as String,
      name: json['name'] as String,
      size: json['size'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      width: json['width'] as int?,
      height: json['height'] as int?,
      mimeType: json['mime_type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'path': path,
      'name': name,
      'size': size,
      'created_at': createdAt.toIso8601String(),
      'width': width,
      'height': height,
      'mime_type': mimeType,
    };
  }

  Photo toEntity() {
    return Photo(
      id: id,
      path: path,
      name: name,
      size: size,
      createdAt: createdAt,
      width: width,
      height: height,
      mimeType: mimeType,
    );
  }

  static String? _getMimeTypeFromPath(String path) {
    final extension = path.toLowerCase().split('.').last;
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return null;
    }
  }
}

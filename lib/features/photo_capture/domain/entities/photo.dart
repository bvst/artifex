import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';

class Photo extends Equatable {
  const Photo({
    required this.id,
    required this.path,
    required this.name,
    required this.size,
    required this.createdAt,
    this.width,
    this.height,
    this.mimeType,
  });

  final String id;
  final String path;
  final String name;
  final int size;
  final DateTime createdAt;
  final int? width;
  final int? height;
  final String? mimeType;
  
  // Null-safe accessors using Option pattern
  Option<int> get widthOption => width != null ? some(width!) : none();
  Option<int> get heightOption => height != null ? some(height!) : none();
  Option<String> get mimeTypeOption => mimeType != null ? some(mimeType!) : none();
  
  // Safe dimension operations
  bool get hasDimensions => width != null && height != null;
  
  String get displayDimensions {
    return hasDimensions ? '${width}x$height' : 'Unknown dimensions';
  }
  
  double get aspectRatio {
    return hasDimensions ? (width! / height!) : 1.0;
  }

  @override
  List<Object?> get props => [
    id,
    path,
    name,
    size,
    createdAt,
    width,
    height,
    mimeType,
  ];

  Photo copyWith({
    String? id,
    String? path,
    String? name,
    int? size,
    DateTime? createdAt,
    int? width,
    int? height,
    String? mimeType,
  }) {
    return Photo(
      id: id ?? this.id,
      path: path ?? this.path,
      name: name ?? this.name,
      size: size ?? this.size,
      createdAt: createdAt ?? this.createdAt,
      width: width ?? this.width,
      height: height ?? this.height,
      mimeType: mimeType ?? this.mimeType,
    );
  }
}
import 'package:equatable/equatable.dart';

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
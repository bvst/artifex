import 'package:equatable/equatable.dart';
import '../../domain/entities/photo.dart';

sealed class PhotoState extends Equatable {
  const PhotoState();

  @override
  List<Object?> get props => [];
}

class PhotoInitial extends PhotoState {
  const PhotoInitial();
}

class PhotoLoading extends PhotoState {
  const PhotoLoading();
}

class PhotoSuccess extends PhotoState {
  const PhotoSuccess(this.photo);

  final Photo photo;

  @override
  List<Object?> get props => [photo];
}

class PhotoRecentPhotos extends PhotoState {
  const PhotoRecentPhotos(this.photos);

  final List<Photo> photos;

  @override
  List<Object?> get props => [photos];
}

class PhotoError extends PhotoState {
  const PhotoError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

// Extension methods for easier state checking
extension PhotoStateExtensions on PhotoState {
  bool get isInitial => this is PhotoInitial;
  bool get isLoading => this is PhotoLoading;
  bool get isSuccess => this is PhotoSuccess;
  bool get isError => this is PhotoError;
  bool get hasRecentPhotos => this is PhotoRecentPhotos;

  Photo? get photo =>
      this is PhotoSuccess ? (this as PhotoSuccess).photo : null;
  List<Photo>? get photos =>
      this is PhotoRecentPhotos ? (this as PhotoRecentPhotos).photos : null;
  String? get errorMessage =>
      this is PhotoError ? (this as PhotoError).message : null;
}

// Factory methods for cleaner code
extension PhotoStateFactory on PhotoState {
  static PhotoState initial() => const PhotoInitial();
  static PhotoState loading() => const PhotoLoading();
  static PhotoState success(Photo photo) => PhotoSuccess(photo);
  static PhotoState recentPhotos(List<Photo> photos) =>
      PhotoRecentPhotos(photos);
  static PhotoState error(String message) => PhotoError(message);
}

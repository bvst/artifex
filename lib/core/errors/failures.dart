import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure([this.message = 'An unexpected error occurred']);

  final String message;

  @override
  List<Object> get props => [message];
}

// General failures
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error occurred']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network connection failed']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache operation failed']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validation failed']);
}

// Authentication failures
class AuthenticationFailure extends Failure {
  const AuthenticationFailure([super.message = 'Authentication failed']);
}

// Permission failures
class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'Permission denied']);
}

// Image processing failures
class ImageProcessingFailure extends Failure {
  const ImageProcessingFailure([super.message = 'Image processing failed']);
}

class FileNotFoundFailure extends Failure {
  const FileNotFoundFailure([super.message = 'File not found']);
}

// User action failures (not actually errors)
class UserCancelledFailure extends Failure {
  const UserCancelledFailure([super.message = 'User cancelled operation']);
}

// API specific failures
class ApiFailure extends Failure {
  const ApiFailure([super.message = 'API request failed']);

  const ApiFailure.rateLimited() : super('Rate limit exceeded');
  const ApiFailure.unauthorized() : super('Unauthorized access');
  const ApiFailure.badRequest() : super('Invalid request');
}

class APIFailure extends Failure {
  const APIFailure([super.message = 'API request failed']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unknown error occurred']);
}

class ServerException implements Exception {
  const ServerException({required this.message, this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() =>
      'ServerException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

class NetworkException implements Exception {
  const NetworkException(this.message);
  final String message;

  @override
  String toString() => 'NetworkException: $message';
}

class CacheException implements Exception {
  const CacheException(this.message);
  final String message;

  @override
  String toString() => 'CacheException: $message';
}

class ValidationException implements Exception {
  const ValidationException({required this.message, this.errors});
  final String message;
  final Map<String, String>? errors;

  @override
  String toString() =>
      'ValidationException: $message${errors != null ? ' Errors: $errors' : ''}';
}

class FileException implements Exception {
  const FileException(this.message);
  final String message;

  @override
  String toString() => 'FileException: $message';
}

class PermissionException implements Exception {
  const PermissionException(this.message);
  final String message;

  @override
  String toString() => 'PermissionException: $message';
}

class APIException implements Exception {
  const APIException(this.message, [this.statusCode]);
  final String message;
  final int? statusCode;

  @override
  String toString() =>
      'APIException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({required this.message, this.statusCode});

  @override
  String toString() =>
      'ServerException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

class NetworkException implements Exception {
  final String message;

  const NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

class CacheException implements Exception {
  final String message;

  const CacheException(this.message);

  @override
  String toString() => 'CacheException: $message';
}

class ValidationException implements Exception {
  final String message;
  final Map<String, String>? errors;

  const ValidationException({required this.message, this.errors});

  @override
  String toString() =>
      'ValidationException: $message${errors != null ? ' Errors: $errors' : ''}';
}

class FileException implements Exception {
  final String message;

  const FileException(this.message);

  @override
  String toString() => 'FileException: $message';
}

class PermissionException implements Exception {
  final String message;

  const PermissionException(this.message);

  @override
  String toString() => 'PermissionException: $message';
}

class APIException implements Exception {
  final String message;
  final int? statusCode;

  const APIException(this.message, [this.statusCode]);

  @override
  String toString() =>
      'APIException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

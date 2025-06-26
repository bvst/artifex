class TestData {
  static const Map<String, dynamic> sampleUser = {
    'id': '123',
    'name': 'Test User',
    'email': 'test@artifex.app',
    'avatarUrl': 'https://example.com/avatar.png',
  };

  static const Map<String, dynamic> sampleTransformation = {
    'id': '456',
    'userId': '123',
    'originalImageUrl': 'https://example.com/original.jpg',
    'transformedImageUrl': 'https://example.com/transformed.jpg',
    'filter': 'artistic',
    'createdAt': '2025-06-26T12:00:00Z',
  };

  static const List<String> availableFilters = [
    'artistic',
    'vintage',
    'modern',
    'abstract',
    'watercolor',
    'oil_painting',
    'sketch',
    'cartoon',
  ];

  static const Map<String, dynamic> errorResponse = {
    'error': 'Something went wrong',
    'code': 'ERROR_001',
  };
}
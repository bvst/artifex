class MockApiService {
  final Map<String, dynamic> _mockResponses = {};

  void setMockResponse(String endpoint, dynamic response) {
    _mockResponses[endpoint] = response;
  }

  Future<dynamic> get(String endpoint) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    if (_mockResponses.containsKey(endpoint)) {
      return _mockResponses[endpoint];
    }
    
    throw Exception('No mock response set for endpoint: $endpoint');
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    if (_mockResponses.containsKey(endpoint)) {
      return _mockResponses[endpoint];
    }
    
    throw Exception('No mock response set for endpoint: $endpoint');
  }

  void reset() {
    _mockResponses.clear();
  }
}
// Examples of minimizing null usage in Artifex

import 'package:dartz/dartz.dart';

// 1. Use Either instead of nullable returns
Either<String, User> findUser(String id) {
  // Instead of: User? findUser(String id)
  return left('User not found'); // or right(user)
}

// 2. Use sealed classes for state management
sealed class LoadingState<T> {
  const LoadingState();
}

class Loading<T> extends LoadingState<T> {
  const Loading();
}

class Success<T> extends LoadingState<T> {
  final T data;
  const Success(this.data);
}

class Error<T> extends LoadingState<T> {
  final String message;
  const Error(this.message);
}

// 3. Use factory constructors with defaults
class AppConfig {
  final String apiUrl;
  final int timeout;
  final bool debugMode;
  
  const AppConfig({
    required this.apiUrl,
    required this.timeout,
    required this.debugMode,
  });
  
  // Factory with sensible defaults
  factory AppConfig.defaultConfig() {
    return const AppConfig(
      apiUrl: 'https://api.openai.com/v1',
      timeout: 30000,
      debugMode: false,
    );
  }
}

// 4. Use extension methods for safe operations
extension SafeList<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
  T? get lastOrNull => isEmpty ? null : last;
  
  // Better: Use Option/Maybe pattern
  Option<T> get firstOption => isEmpty ? none() : some(first);
}

// 5. Use builders and required parameters
class UserProfile {
  final String name;
  final String email;
  final int age;
  
  const UserProfile({
    required this.name,
    required this.email,
    required this.age,
  });
  
  // Use copyWith instead of nullable parameters
  UserProfile copyWith({
    String? name,
    String? email, 
    int? age,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
    );
  }
}

// 6. Use Option type from dartz for truly optional values
class DatabaseRepository {
  Option<User> findUserById(String id) {
    // Instead of returning null, return none() or some(user)
    return none(); // or some(user)
  }
  
  // Use fold to handle both cases
  String getUserName(String id) {
    return findUserById(id).fold(
      () => 'Unknown User',        // none case
      (user) => user.name,         // some case
    );
  }
}

// 7. Use late for deferred initialization (sparingly)
class ServiceLocator {
  late final ApiService apiService;
  late final DatabaseService databaseService;
  
  void initialize() {
    apiService = ApiService();
    databaseService = DatabaseService();
  }
}

class User {
  final String name;
  final String email;
  
  const User({required this.name, required this.email});
}

class ApiService {
  // Implementation
}

class DatabaseService {
  // Implementation
}
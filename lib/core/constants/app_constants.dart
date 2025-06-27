class AppConstants {
  // API Configuration - No nulls, always have defaults
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.openai.com/v1',
  );
  
  static const String dalleApiKey = String.fromEnvironment(
    'DALLE_API_KEY',
    defaultValue: '', // Default to empty string instead of null
  );
  
  // Safe API key access
  static bool get hasApiKey => dalleApiKey.isNotEmpty;
  static String get safeApiKey => hasApiKey ? dalleApiKey : throw Exception('DALLE_API_KEY not configured');
  
  // Image Configuration
  static const int maxImageSizeBytes = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageExtensions = ['jpg', 'jpeg', 'png', 'webp'];
  static const int maxImageWidth = 1024;
  static const int maxImageHeight = 1024;
  
  // Cache Configuration
  static const Duration cacheTimeout = Duration(hours: 24);
  static const int maxCacheSize = 100; // Number of cached images
  
  // Network Configuration
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 60);
  static const Duration sendTimeout = Duration(seconds: 30);
  
  // Retry Configuration
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  
  // SharedPreferences Keys
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keySelectedTheme = 'selected_theme';
  static const String keyUserPreferences = 'user_preferences';
  
  // Database Configuration
  static const String databaseName = 'artifex.db';
  static const int databaseVersion = 1;
  
  // Feature Flags
  static const bool enableOfflineMode = true;
  static const bool enableAnalytics = bool.fromEnvironment('ENABLE_ANALYTICS', defaultValue: false);
  static const bool enableCrashReporting = bool.fromEnvironment('ENABLE_CRASH_REPORTING', defaultValue: false);
  
  // Computed flags
  static bool get enableDebugAnalytics => isDebug && enableAnalytics;
  
  // Environment
  static bool get isProduction => const bool.fromEnvironment('dart.vm.product');
  static bool get isDebug => !isProduction;
}
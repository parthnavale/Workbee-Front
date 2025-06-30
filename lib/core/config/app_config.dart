/// Application configuration for managing API settings and environment variables
class AppConfig {
  // API Configuration
  static const String apiBaseUrl = 'http://localhost:8000';
  static const String apiVersion = 'v1';
  
  // Timeout settings
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Feature flags
  static const bool useApiRepository = true; // Set to false to use mock repository
  static const bool enableLogging = true;
  
  // API Endpoints
  static const String jobsEndpoint = '/job';
  static const String businessOwnersEndpoint = '/owner';
  static const String workersEndpoint = '/worker';
  static const String subscriptionsEndpoint = '/subscription';
  static const String usersEndpoint = '/users';
  static const String postsEndpoint = '/posts';
  
  /// Get the full API URL for a given endpoint
  static String getApiUrl(String endpoint) {
    return '$apiBaseUrl$endpoint';
  }
  
  /// Get the full API URL with version
  static String getApiUrlWithVersion(String endpoint) {
    return '$apiBaseUrl/$apiVersion$endpoint';
  }
  
  /// Check if we should use the API repository
  static bool shouldUseApiRepository() {
    return useApiRepository;
  }
  
  /// Get connection timeout
  static Duration getConnectionTimeout() {
    return connectionTimeout;
  }
  
  /// Get receive timeout
  static Duration getReceiveTimeout() {
    return receiveTimeout;
  }
} 
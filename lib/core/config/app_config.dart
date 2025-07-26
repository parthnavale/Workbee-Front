/// Application configuration for managing API settings and environment variables
class AppConfig {
  // API Configuration - Production
  static const String apiBaseUrl = 'https://myworkbee.duckdns.org';
  static const String apiVersion = 'v1';

  // Timeout settings
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // API Endpoints - Updated to match FastAPI backend
  static const String jobsEndpoint = '/jobs/';
  static const String businessOwnersEndpoint = '/business-owners/';
  static const String workersEndpoint = '/workers/';
  static const String applicationsEndpoint = '/applications/';
  static const String usersEndpoint = '/users/';
  static const String authEndpoint = '/users/';

  /// Get the full API URL for a given endpoint
  static String getApiUrl(String endpoint) {
    return '$apiBaseUrl$endpoint';
  }

  /// Get the full API URL with version
  static String getApiUrlWithVersion(String endpoint) {
    return '$apiBaseUrl/$apiVersion$endpoint';
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

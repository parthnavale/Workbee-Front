import '../repositories/job_repository.dart';
import '../repositories/api_job_repository.dart';
import '../services/job_service.dart';
import '../services/api_service.dart';
import '../../providers/auth_provider.dart';

/// Service Locator pattern implementation for dependency injection
/// This provides a centralized way to manage dependencies and makes testing easier
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  // Repositories
  JobRepository? _jobRepository;
  
  // Services
  JobService? _jobService;
  ApiService? _apiService;
  
  // Auth Provider
  AuthProvider? _authProvider;

  /// Initialize the service locator with dependencies
  void initialize({AuthProvider? authProvider}) {
    _authProvider = authProvider;
    
    // Create API service with auth provider
    _apiService = ApiService(authProvider: authProvider);
    
    // Always use the API repository with authenticated API service
    _jobRepository = ApiJobRepository(apiService: _apiService);
    _jobService = JobService(_jobRepository!);
  }

  /// Get the job repository
  JobRepository get jobRepository {
    if (_jobRepository == null) {
      throw StateError('ServiceLocator not initialized. Call initialize() first.');
    }
    return _jobRepository!;
  }

  /// Get the job service
  JobService get jobService {
    if (_jobService == null) {
      throw StateError('ServiceLocator not initialized. Call initialize() first.');
    }
    return _jobService!;
  }

  /// Get the API service
  ApiService get apiService {
    if (_apiService == null) {
      throw StateError('ServiceLocator not initialized. Call initialize() first.');
    }
    return _apiService!;
  }

  /// Get the auth provider
  AuthProvider? get authProvider => _authProvider;

  /// Reset all dependencies (useful for testing)
  void reset() {
    _jobRepository = null;
    _jobService = null;
    _apiService = null;
    _authProvider = null;
  }
}

/// Global instance for easy access
final serviceLocator = ServiceLocator(); 
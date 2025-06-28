import '../repositories/job_repository.dart';
import '../repositories/mock_job_repository.dart';
import '../services/job_service.dart';

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

  /// Initialize the service locator with dependencies
  void initialize() {
    // Initialize repositories
    _jobRepository = MockJobRepository();
    
    // Initialize services with repositories
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

  /// Replace the job repository (useful for testing)
  void replaceJobRepository(JobRepository repository) {
    _jobRepository = repository;
    _jobService = JobService(_jobRepository!);
  }

  /// Reset all dependencies (useful for testing)
  void reset() {
    _jobRepository = null;
    _jobService = null;
  }
}

/// Global instance for easy access
final serviceLocator = ServiceLocator(); 
import 'job_repository.dart';
import '../../models/job.dart';

/// Mock implementation of JobRepository for development and testing
/// This maintains the current in-memory data management approach
class MockJobRepository implements JobRepository {
  final List<Job> _jobs = [];
  final List<JobApplication> _applications = [];

  @override
  Future<List<Job>> getJobs() async {
    // Load sample jobs if empty
    if (_jobs.isEmpty) {
      _jobs.addAll([
        Job(
          id: '1',
          businessId: 'business1',
          businessName: 'ABC Retail Store',
          title: 'Cashier',
          description: 'Looking for an experienced cashier for our retail store. Must be good with customers and have basic math skills.',
          requiredSkills: ['Cashier', 'Customer Service'],
          location: 'Mumbai',
          address: '123 Main Street',
          state: 'Maharashtra',
          city: 'Mumbai',
          pinCode: '400001',
          hourlyRate: 150.0,
          estimatedHours: 8,
          postedDate: DateTime.now().subtract(Duration(days: 2)),
          contactPerson: 'John Doe',
          contactPhone: '9876543210',
          contactEmail: 'john@abcretail.com',
        ),
        Job(
          id: '2',
          businessId: 'business2',
          businessName: 'XYZ Supermarket',
          title: 'Store Associate',
          description: 'Need a store associate to help with inventory management and customer service.',
          requiredSkills: ['Store Associate', 'Inventory Management', 'Customer Service'],
          location: 'Delhi',
          address: '456 Park Avenue',
          state: 'Delhi',
          city: 'New Delhi',
          pinCode: '110001',
          hourlyRate: 180.0,
          estimatedHours: 6,
          postedDate: DateTime.now().subtract(Duration(days: 1)),
          contactPerson: 'Jane Smith',
          contactPhone: '9876543211',
          contactEmail: 'jane@xyzsupermarket.com',
        ),
      ]);
    }
    return _jobs;
  }

  @override
  Future<List<Job>> getJobsByBusiness(String businessId) async {
    final allJobs = await getJobs();
    return allJobs.where((job) => job.businessId == businessId).toList();
  }

  @override
  Future<List<Job>> getJobsByWorker(String workerId) async {
    final workerApplications = _applications.where((app) => app.workerId == workerId).toList();
    final jobIds = workerApplications.map((app) => app.jobId).toSet();
    final allJobs = await getJobs();
    return allJobs.where((job) => jobIds.contains(job.id)).toList();
  }

  @override
  Future<Job?> getJobById(String jobId) async {
    final allJobs = await getJobs();
    try {
      return allJobs.firstWhere((job) => job.id == jobId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> postJob(Job job) async {
    _jobs.add(job);
    // Simulate API delay
    await Future.delayed(Duration(milliseconds: 500));
  }

  @override
  Future<void> updateJob(Job job) async {
    final index = _jobs.indexWhere((j) => j.id == job.id);
    if (index != -1) {
      _jobs[index] = job;
    }
    await Future.delayed(Duration(milliseconds: 300));
  }

  @override
  Future<void> deleteJob(String jobId) async {
    _jobs.removeWhere((job) => job.id == jobId);
    await Future.delayed(Duration(milliseconds: 300));
  }

  @override
  Future<void> applyForJob(JobApplication application) async {
    _applications.add(application);
    
    // Update the job with the new application
    final jobIndex = _jobs.indexWhere((job) => job.id == application.jobId);
    if (jobIndex != -1) {
      final job = _jobs[jobIndex];
      final updatedApplications = [...job.applications, application];
      _jobs[jobIndex] = job.copyWith(applications: updatedApplications);
    }
    
    await Future.delayed(Duration(milliseconds: 500));
  }

  @override
  Future<void> respondToApplication(
    String jobId, 
    String applicationId, 
    ApplicationStatus status,
    {String? message}
  ) async {
    // Update application
    final appIndex = _applications.indexWhere((app) => app.id == applicationId);
    if (appIndex != -1) {
      _applications[appIndex] = _applications[appIndex].copyWith(
        status: status,
        respondedDate: DateTime.now(),
        message: message,
      );
    }

    // Update job applications
    final jobIndex = _jobs.indexWhere((job) => job.id == jobId);
    if (jobIndex != -1) {
      final job = _jobs[jobIndex];
      final updatedApplications = job.applications.map((app) {
        if (app.id == applicationId) {
          return app.copyWith(
            status: status,
            respondedDate: DateTime.now(),
            message: message,
          );
        }
        return app;
      }).toList();
      
      _jobs[jobIndex] = job.copyWith(applications: updatedApplications);
    }

    await Future.delayed(Duration(milliseconds: 500));
  }

  @override
  Future<void> updateJobStatus(String jobId, JobStatus status) async {
    final jobIndex = _jobs.indexWhere((job) => job.id == jobId);
    if (jobIndex != -1) {
      _jobs[jobIndex] = _jobs[jobIndex].copyWith(status: status);
    }
    await Future.delayed(Duration(milliseconds: 300));
  }

  @override
  Future<List<JobApplication>> getApplicationsForJob(String jobId) async {
    return _applications.where((app) => app.jobId == jobId).toList();
  }

  @override
  Future<List<JobApplication>> getApplicationsByWorker(String workerId) async {
    return _applications.where((app) => app.workerId == workerId).toList();
  }

  /// Clear all data (for testing/logout)
  void clearData() {
    _jobs.clear();
    _applications.clear();
  }
} 
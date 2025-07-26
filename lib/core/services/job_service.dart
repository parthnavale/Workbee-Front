import '../repositories/job_repository.dart';
import '../../models/job.dart';

/// Service layer for job-related business logic
/// This separates business logic from data access and UI logic
class JobService {
  final JobRepository _repository;

  JobService(this._repository);

  /// Get all open jobs for workers to browse
  Future<List<Job>> getOpenJobs() async {
    final jobs = await _repository.getJobs();
    return jobs.where((job) => job.status == JobStatus.open).toList();
  }

  /// Get jobs posted by a specific business
  Future<List<Job>> getBusinessJobs(String businessId) async {
    return await _repository.getJobsByBusiness(businessId);
  }

  /// Get jobs that a worker has applied to
  Future<List<Job>> getWorkerJobs(String workerId) async {
    return await _repository.getJobsByWorker(workerId);
  }

  /// Get a specific job with validation
  Future<Job?> getJobById(String jobId) async {
    if (jobId.isEmpty) return null;
    return await _repository.getJobById(jobId);
  }

  /// Post a new job with validation
  Future<void> postJob(Job job) async {
    // Business validation
    if (job.title.isEmpty) {
      throw ArgumentError('Job title cannot be empty');
    }
    if (job.hourlyRate <= 0) {
      throw ArgumentError('Hourly rate must be positive');
    }
    if (job.estimatedHours <= 0) {
      throw ArgumentError('Estimated hours must be positive');
    }
    if (job.requiredSkills.isEmpty) {
      throw ArgumentError('At least one skill is required');
    }

    await _repository.postJob(job);
  }

  /// Update an existing job
  Future<void> updateJob(Job job) async {
    final existingJob = await _repository.getJobById(job.id);
    if (existingJob == null) {
      throw ArgumentError('Job not found');
    }

    await _repository.updateJob(job);
  }

  /// Delete a job with validation
  Future<void> deleteJob(String jobId, String businessId) async {
    final job = await _repository.getJobById(jobId);
    if (job == null) {
      throw ArgumentError('Job not found');
    }
    if (job.businessId != businessId) {
      throw ArgumentError('Only the job owner can delete the job');
    }

    await _repository.deleteJob(jobId);
  }

  /// Apply for a job with validation
  Future<void> applyForJob(JobApplication application) async {
    // Validate job exists and is open
    final job = await _repository.getJobById(application.jobId);
    if (job == null) {
      throw ArgumentError('Job not found');
    }
    if (job.status != JobStatus.open) {
      throw ArgumentError('Job is not open for applications');
    }

    // Remove duplicate check here; let backend handle it
    await _repository.applyForJob(application);
  }

  /// Respond to an application with validation
  Future<void> respondToApplication(
    String jobId,
    String applicationId,
    ApplicationStatus status,
    String businessId, {
    String? message,
  }) async {
    try {
      await _repository.respondToApplication(
        jobId,
        applicationId,
        status,
        message: message,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Update job status with validation
  Future<void> updateJobStatus(
    String jobId,
    JobStatus status,
    String businessId,
  ) async {
    final job = await _repository.getJobById(jobId);
    if (job == null) {
      throw ArgumentError('Job not found');
    }
    if (job.businessId != businessId) {
      throw ArgumentError('Only the job owner can update job status');
    }

    await _repository.updateJobStatus(jobId, status);
  }

  /// Get applications for a job with validation
  Future<List<JobApplication>> getApplicationsForJob(
    String jobId,
    String businessId,
  ) async {
    final job = await _repository.getJobById(jobId);
    if (job == null) {
      throw ArgumentError('Job not found');
    }
    if (job.businessId != businessId) {
      throw ArgumentError('Only the job owner can view applications');
    }

    return await _repository.getApplicationsForJob(jobId);
  }

  /// Get applications by worker
  Future<List<JobApplication>> getWorkerApplications(String workerId) async {
    return await _repository.getApplicationsByWorker(workerId);
  }

  /// Get pending applications count for a business
  Future<int> getPendingApplicationsCount(String businessId) async {
    final jobs = await _repository.getJobsByBusiness(businessId);
    int count = 0;

    for (final job in jobs) {
      final pendingApps = job.applications.where(
        (app) => app.status == ApplicationStatus.pending,
      );
      count += pendingApps.length;
    }

    return count;
  }

  /// Check if a worker has applied for a specific job
  Future<bool> hasWorkerAppliedForJob(String jobId, String workerId) async {
    final applications = await _repository.getApplicationsForJob(jobId);
    return applications.any((app) => app.workerId == workerId);
  }

  /// Get worker's application for a specific job
  Future<JobApplication?> getWorkerApplicationForJob(
    String jobId,
    String workerId,
  ) async {
    final applications = await _repository.getApplicationsForJob(jobId);
    try {
      return applications.firstWhere((app) => app.workerId == workerId);
    } catch (e) {
      return null;
    }
  }
}

import '../../models/job.dart';

/// Abstract repository interface for job operations
/// This follows the Repository pattern for better testability and extensibility
abstract class JobRepository {
  /// Get all jobs
  Future<List<Job>> getJobs();

  /// Get jobs by business ID
  Future<List<Job>> getJobsByBusiness(String businessId);

  /// Get jobs by worker applications
  Future<List<Job>> getJobsByWorker(String workerId);

  /// Get a specific job by ID
  Future<Job?> getJobById(String jobId);

  /// Post a new job
  Future<void> postJob(Job job);

  /// Update an existing job
  Future<void> updateJob(Job job);

  /// Delete a job
  Future<void> deleteJob(String jobId);

  /// Apply for a job
  Future<void> applyForJob(JobApplication application);

  /// Respond to an application
  Future<void> respondToApplication(
    String jobId,
    String applicationId,
    ApplicationStatus status, {
    String? message,
  });

  /// Update job status
  Future<void> updateJobStatus(String jobId, JobStatus status);

  /// Get applications for a job
  Future<List<JobApplication>> getApplicationsForJob(String jobId);

  /// Get applications by worker
  Future<List<JobApplication>> getApplicationsByWorker(String workerId);
}

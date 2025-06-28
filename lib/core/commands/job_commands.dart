import '../services/job_service.dart';
import '../../models/job.dart';

/// Abstract command interface following the Command pattern
/// This allows for complex operations to be encapsulated and queued
abstract class JobCommand {
  Future<void> execute();
}

/// Command to post a new job
class PostJobCommand implements JobCommand {
  final Job job;
  final JobService _jobService;

  PostJobCommand(this.job, this._jobService);

  @override
  Future<void> execute() async {
    await _jobService.postJob(job);
  }
}

/// Command to apply for a job
class ApplyForJobCommand implements JobCommand {
  final JobApplication application;
  final JobService _jobService;

  ApplyForJobCommand(this.application, this._jobService);

  @override
  Future<void> execute() async {
    await _jobService.applyForJob(application);
  }
}

/// Command to respond to an application
class RespondToApplicationCommand implements JobCommand {
  final String jobId;
  final String applicationId;
  final ApplicationStatus status;
  final String businessId;
  final String? message;
  final JobService _jobService;

  RespondToApplicationCommand(
    this.jobId,
    this.applicationId,
    this.status,
    this.businessId,
    this._jobService,
    {this.message}
  );

  @override
  Future<void> execute() async {
    await _jobService.respondToApplication(
      jobId,
      applicationId,
      status,
      businessId,
      message: message,
    );
  }
}

/// Command to update job status
class UpdateJobStatusCommand implements JobCommand {
  final String jobId;
  final JobStatus status;
  final String businessId;
  final JobService _jobService;

  UpdateJobStatusCommand(
    this.jobId,
    this.status,
    this.businessId,
    this._jobService,
  );

  @override
  Future<void> execute() async {
    await _jobService.updateJobStatus(jobId, status, businessId);
  }
}

/// Command invoker that can queue and execute commands
class JobCommandInvoker {
  final List<JobCommand> _commandQueue = [];

  /// Add a command to the queue
  void addCommand(JobCommand command) {
    _commandQueue.add(command);
  }

  /// Execute all commands in the queue
  Future<void> executeAll() async {
    for (final command in _commandQueue) {
      await command.execute();
    }
    _commandQueue.clear();
  }

  /// Execute a single command immediately
  Future<void> executeCommand(JobCommand command) async {
    await command.execute();
  }

  /// Clear the command queue
  void clearQueue() {
    _commandQueue.clear();
  }

  /// Get the number of commands in the queue
  int get queueLength => _commandQueue.length;
} 
import 'job_repository.dart';
import '../services/api_service.dart';
import '../../models/job.dart';
import 'dart:convert';
import '../config/app_config.dart';

/// API implementation of JobRepository that connects to the FastAPI backend
class ApiJobRepository implements JobRepository {
  final ApiService _apiService;

  ApiJobRepository({ApiService? apiService}) 
      : _apiService = apiService ?? ApiService();

  @override
  Future<List<Job>> getJobs() async {
    try {
      final apiJobs = await _apiService.getJobs();
      return apiJobs.map((jobData) => _mapApiJobToFlutterJob(jobData)).toList();
    } catch (e) {
      // Fallback to empty list if API fails
      return [];
    }
  }

  @override
  Future<List<Job>> getJobsByBusiness(String businessId) async {
    try {
      // Use backend filtering instead of fetching all jobs
      final apiJobs = await _apiService.getJobsByBusiness(businessId);
      return apiJobs.map((jobData) => _mapApiJobToFlutterJob(jobData)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<Job>> getJobsByWorker(String workerId) async {
    try {
      // This would need a specific API endpoint for worker applications
      // For now, we'll return jobs that the worker has applied to
      final allJobs = await getJobs();
      return allJobs.where((job) => 
        job.applications.any((app) => app.workerId == workerId)
      ).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<Job?> getJobById(String jobId) async {
    try {
      final jobData = await _apiService.getJobById(int.parse(jobId));
      if (jobData != null) {
        return _mapApiJobToFlutterJob(jobData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> postJob(Job job) async {
    try {
      final jobData = _mapFlutterJobToApiJob(job);
      await _apiService.createJob(jobData);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateJob(Job job) async {
    try {
      final jobData = _mapFlutterJobToApiJob(job);
      await _apiService.updateJob(int.parse(job.id), jobData);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteJob(String jobId) async {
    try {
      await _apiService.deleteJob(int.parse(jobId));
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> applyForJob(JobApplication application) async {
    try {
      final applicationData = {
        'job_id': int.tryParse(application.jobId) ?? 1,
        'worker_id': int.tryParse(application.workerId) ?? 1,
        'message': application.coverLetter, // Use coverLetter as message
      };
      await _apiService.createApplication(applicationData);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> respondToApplication(
    String jobId, 
    String applicationId, 
    ApplicationStatus status,
    {String? message}
  ) async {
    try {
      final applicationData = {
        'status': status.toString().split('.').last,
        'message': message ?? '',
      };
      await _apiService.updateApplication(int.parse(applicationId), applicationData);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateJobStatus(String jobId, JobStatus status) async {
    try {
      final jobData = {
        'status': status.toString().split('.').last,
      };
      await _apiService.updateJob(int.parse(jobId), jobData);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<JobApplication>> getApplicationsForJob(String jobId) async {
    try {
      // Use backend filtering instead of fetching all applications
      final applications = await _apiService.getApplicationsByJob(jobId);
      return applications.map((appData) => _mapApiApplicationToFlutterApplication(appData)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<JobApplication>> getApplicationsByWorker(String workerId) async {
    try {
      // Use backend filtering instead of fetching all applications
      final applications = await _apiService.getApplicationsByWorker(workerId);
      return applications.map((appData) => _mapApiApplicationToFlutterApplication(appData)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Map API job data to Flutter Job model
  Job _mapApiJobToFlutterJob(Map<String, dynamic> apiJob) {
    return Job(
      id: apiJob['id'].toString(),
      businessId: apiJob['business_owner_id'].toString(),
      businessName: apiJob['business_name'] ?? 'Unknown Business',
      title: apiJob['title'] ?? 'Job',
      description: apiJob['description'] ?? '',
      requiredSkills: _parseSkills(apiJob['required_skills']),
      location: apiJob['location'] ?? '',
      address: apiJob['address'] ?? '',
      state: apiJob['state'] ?? '',
      city: apiJob['city'] ?? '',
      pinCode: apiJob['pincode'].toString(),
      hourlyRate: (apiJob['hourly_rate'] ?? 150.0).toDouble(),
      estimatedHours: apiJob['estimated_hours'] ?? 8,
      postedDate: _parseDateTime(apiJob['posted_date']),
      startDate: apiJob['start_date'] != null ? _parseDateTime(apiJob['start_date']) : null,
      status: _parseJobStatus(apiJob['status']),
      applications: [], // Will be populated when API supports it
      contactPerson: apiJob['contact_person'] ?? 'Contact Person',
      contactPhone: apiJob['contact_phone'] ?? '1234567890',
      contactEmail: apiJob['contact_email'] ?? 'contact@example.com',
    );
  }

  /// Map Flutter Job model to API job data
  Map<String, dynamic> _mapFlutterJobToApiJob(Job job) {
    return {
      'business_owner_id': int.tryParse(job.businessId) ?? 1,
      'title': job.title,
      'description': job.description,
      'required_skills': job.requiredSkills.join(','),
      'location': job.location,
      'address': job.address,
      'state': job.state,
      'city': job.city,
      'pincode': job.pinCode,
      'hourly_rate': job.hourlyRate,
      'estimated_hours': job.estimatedHours,
      'start_date': job.startDate?.toIso8601String(),
      'contact_person': job.contactPerson,
      'contact_phone': job.contactPhone,
      'contact_email': job.contactEmail,
    };
  }

  /// Parse skills from API response
  List<String> _parseSkills(dynamic skills) {
    if (skills is List) {
      return skills.cast<String>();
    } else if (skills is String) {
      try {
        final parsed = json.decode(skills);
        if (parsed is List) {
          return parsed.cast<String>();
        }
      } catch (e) {
        // If JSON parsing fails, treat as comma-separated string
        return skills.split(',').map((s) => s.trim()).toList();
      }
    }
    return ['General'];
  }

  /// Parse datetime from API response
  DateTime _parseDateTime(dynamic dateTime) {
    if (dateTime is String) {
      try {
        return DateTime.parse(dateTime);
      } catch (e) {
        return DateTime.now();
      }
    } else if (dateTime is DateTime) {
      return dateTime;
    }
    return DateTime.now();
  }

  /// Parse job status from API response
  JobStatus _parseJobStatus(dynamic status) {
    if (status is String) {
      switch (status.toLowerCase()) {
        case 'open':
          return JobStatus.open;
        case 'inprogress':
        case 'in_progress':
          return JobStatus.inProgress;
        case 'completed':
          return JobStatus.completed;
        case 'cancelled':
          return JobStatus.cancelled;
        default:
          return JobStatus.open;
      }
    }
    return JobStatus.open;
  }

  /// Map API application data to Flutter JobApplication model
  JobApplication _mapApiApplicationToFlutterApplication(Map<String, dynamic> apiApplication) {
    return JobApplication(
      id: apiApplication['id'].toString(),
      jobId: apiApplication['job_id'].toString(),
      workerId: apiApplication['worker_id'].toString(),
      coverLetter: apiApplication['message'] ?? '', // API returns 'message' as cover letter
      expectedSalary: (apiApplication['expected_salary'] ?? 0.0).toDouble(),
      availabilityDate: apiApplication['availability_date'] != null 
          ? _parseDateTime(apiApplication['availability_date']) 
          : null,
      status: _parseApplicationStatus(apiApplication['status']),
      appliedDate: _parseDateTime(apiApplication['applied_date']),
      message: null, // Response messages are not stored in the API yet
    );
  }

  /// Parse application status from API response
  ApplicationStatus _parseApplicationStatus(dynamic status) {
    if (status is String) {
      switch (status.toLowerCase()) {
        case 'pending':
          return ApplicationStatus.pending;
        case 'accepted':
          return ApplicationStatus.accepted;
        case 'rejected':
          return ApplicationStatus.rejected;
        case 'withdrawn':
          return ApplicationStatus.withdrawn;
        default:
          return ApplicationStatus.pending;
      }
    }
    return ApplicationStatus.pending;
  }

  void dispose() {
    _apiService.dispose();
  }
} 
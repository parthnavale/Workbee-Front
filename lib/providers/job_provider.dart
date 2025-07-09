import 'package:flutter/foundation.dart';
import '../models/job.dart';
import 'package:flutter/material.dart';
import '../core/di/service_locator.dart';

class JobProvider with ChangeNotifier {
  List<Job> _jobs = [];
  final List<JobApplication> _myApplications = [];
  final List<Job> _myPostedJobs = [];

  // Getters
  List<Job> get jobs => _jobs;
  List<JobApplication> get myApplications => _myApplications;
  List<Job> get myPostedJobs => _myPostedJobs;
  
  // Get open jobs for workers to browse
  List<Job> get openJobs => _jobs.where((job) => job.status == JobStatus.open).toList();
  
  // Get jobs with pending applications for business owners
  List<Job> get jobsWithPendingApplications => _myPostedJobs
      .where((job) => job.applications.any((app) => app.status == ApplicationStatus.pending))
      .toList();

  // Post a new job (Business Owner)
  Future<void> postJob(Job job) async {
    await serviceLocator.jobService.postJob(job);
    await fetchJobs();
    notifyListeners();
  }

  // Apply for a job (Worker)
  Future<void> applyForJob(JobApplication application) async {
    await serviceLocator.jobService.applyForJob(application);
    await fetchJobs();
    notifyListeners();
  }

  // Accept/Reject application (Business Owner)
  Future<void> respondToApplication(
    String jobId, 
    String applicationId, 
    ApplicationStatus status,
    {String? message}
  ) async {
    
    try {
      // Get the business owner ID from the auth provider
      final authProvider = serviceLocator.authProvider;
      if (authProvider == null) {
        throw Exception('Auth provider not found. Please log in again.');
      }
      
      final businessOwnerId = authProvider.businessOwnerId;
      
      if (businessOwnerId == null) {
        throw Exception('Business owner ID not found. Please log in again.');
      }
      
      await serviceLocator.jobService.respondToApplication(jobId, applicationId, status, businessOwnerId.toString(), message: message);
      
      await fetchJobs();
      
      notifyListeners();
      
    } catch (e) {
      rethrow;
    }
  }

  // Update job status (Business Owner)
  Future<void> updateJobStatus(String jobId, JobStatus status) async {
    await serviceLocator.jobService.updateJobStatus(jobId, status, '');
    await fetchJobs();
    notifyListeners();
  }

  // Get job by ID
  Job? getJobById(String jobId) {
    try {
      return _jobs.firstWhere((job) => job.id == jobId);
    } catch (e) {
      return null;
    }
  }

  // Get my application for a specific job
  JobApplication? getMyApplicationForJob(String jobId) {
    try {
      return _myApplications.firstWhere((app) => app.jobId == jobId);
    } catch (e) {
      return null;
    }
  }

  // Check if I've already applied for a job
  bool hasAppliedForJob(String jobId) {
    return _myApplications.any((app) => app.jobId == jobId);
  }

  // Get pending applications count for a business owner
  int _pendingApplicationsCount = 0;
  
  int getPendingApplicationsCount() {
    return _pendingApplicationsCount;
  }

  // Fetch pending applications count for a business owner
  Future<void> fetchPendingApplicationsCount(String businessOwnerId) async {
    try {
      int totalPending = 0;
      for (final job in _myPostedJobs) {
        // Use applications that are already loaded in the job
        totalPending += job.applications.where((app) => app.status == ApplicationStatus.pending).length;
      }
      _pendingApplicationsCount = totalPending;
      notifyListeners();
    } catch (e) {
      _pendingApplicationsCount = 0;
    }
  }

  // Fetch jobs from API
  Future<void> fetchJobs() async {
    _jobs = await serviceLocator.jobService.getOpenJobs();
    notifyListeners();
  }

  // Fetch business owner's posted jobs
  Future<void> fetchBusinessOwnerJobs(String businessOwnerId) async {
    _myPostedJobs.clear();
    final jobs = await serviceLocator.jobService.getBusinessJobs(businessOwnerId);
    
    // Batch load applications for each job in parallel
    final List<Future<Job>> jobFutures = jobs.map((job) async {
      try {
        final applications = await serviceLocator.jobService.getApplicationsForJob(job.id, businessOwnerId);
        return job.copyWith(applications: applications);
      } catch (e) {
        // If there's an error loading applications, add the job without applications
        return job;
      }
    }).toList();
    final updatedJobs = await Future.wait(jobFutures);
    
    // Only update and notify if data actually changed
    bool changed = _myPostedJobs.length != updatedJobs.length || !_myPostedJobs.asMap().entries.every((entry) => entry.value == updatedJobs[entry.key]);
    if (changed) {
      _myPostedJobs
        ..clear()
        ..addAll(updatedJobs);
      notifyListeners();
    }
  }

  // Fetch worker's applications
  Future<void> fetchWorkerApplications(String workerId) async {
    _myApplications.clear();
    final applications = await serviceLocator.jobService.getWorkerApplications(workerId);
    _myApplications.addAll(applications);
    notifyListeners();
  }

  // Fetch applications for a specific job
  Future<List<JobApplication>> getApplicationsForJob(String jobId, String businessId) async {
    final applications = await serviceLocator.jobService.getApplicationsForJob(jobId, businessId);
    return applications;
  }

  // Fetch application count for a specific job
  Future<int> fetchJobApplicationsCount(String jobId) async {
    try {
      final applications = await serviceLocator.jobService.getApplicationsForJob(jobId, '');
      return applications.length;
    } catch (e) {
      return 0;
    }
  }

  // Clear data (for logout)
  void clearData() {
    _jobs.clear();
    _myApplications.clear();
    _myPostedJobs.clear();
    notifyListeners();
  }
}

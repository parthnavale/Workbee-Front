import 'package:flutter/foundation.dart';
import '../models/job.dart';
import 'package:flutter/material.dart';

class JobProvider with ChangeNotifier {
  List<Job> _jobs = [];
  List<JobApplication> _myApplications = [];
  List<Job> _myPostedJobs = [];

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
    // In a real app, this would make an API call
    _jobs.add(job);
    _myPostedJobs.add(job);
    notifyListeners();
    
    // Simulate API delay
    await Future.delayed(Duration(milliseconds: 500));
  }

  // Apply for a job (Worker)
  Future<void> applyForJob(JobApplication application) async {
    // In a real app, this would make an API call
    _myApplications.add(application);
    
    // Add application to the job
    final jobIndex = _jobs.indexWhere((job) => job.id == application.jobId);
    if (jobIndex != -1) {
      _jobs[jobIndex] = _jobs[jobIndex].copyWith(
        applications: [..._jobs[jobIndex].applications, application],
      );
    }
    
    // Update my posted jobs if this is one of them
    final myJobIndex = _myPostedJobs.indexWhere((job) => job.id == application.jobId);
    if (myJobIndex != -1) {
      _myPostedJobs[myJobIndex] = _myPostedJobs[myJobIndex].copyWith(
        applications: [..._myPostedJobs[myJobIndex].applications, application],
      );
    }
    
    notifyListeners();
    
    // Simulate API delay
    await Future.delayed(Duration(milliseconds: 500));
  }

  // Accept/Reject application (Business Owner)
  Future<void> respondToApplication(
    String jobId, 
    String applicationId, 
    ApplicationStatus status,
    {String? message}
  ) async {
    // Update application status
    final jobIndex = _jobs.indexWhere((job) => job.id == jobId);
    if (jobIndex != -1) {
      final updatedApplications = _jobs[jobIndex].applications.map((app) {
        if (app.id == applicationId) {
          return app.copyWith(
            status: status,
            respondedDate: DateTime.now(),
            message: message,
          );
        }
        return app;
      }).toList();
      
      _jobs[jobIndex] = _jobs[jobIndex].copyWith(applications: updatedApplications);
    }

    // Update my posted jobs
    final myJobIndex = _myPostedJobs.indexWhere((job) => job.id == jobId);
    if (myJobIndex != -1) {
      final updatedApplications = _myPostedJobs[myJobIndex].applications.map((app) {
        if (app.id == applicationId) {
          return app.copyWith(
            status: status,
            respondedDate: DateTime.now(),
            message: message,
          );
        }
        return app;
      }).toList();
      
      _myPostedJobs[myJobIndex] = _myPostedJobs[myJobIndex].copyWith(applications: updatedApplications);
    }

    // Update my applications if I'm the worker
    final myAppIndex = _myApplications.indexWhere((app) => app.id == applicationId);
    if (myAppIndex != -1) {
      _myApplications[myAppIndex] = _myApplications[myAppIndex].copyWith(
        status: status,
        respondedDate: DateTime.now(),
        message: message,
      );
    }

    notifyListeners();
    
    // Simulate API delay
    await Future.delayed(Duration(milliseconds: 500));
  }

  // Update job status (Business Owner)
  Future<void> updateJobStatus(String jobId, JobStatus status) async {
    final jobIndex = _jobs.indexWhere((job) => job.id == jobId);
    if (jobIndex != -1) {
      _jobs[jobIndex] = _jobs[jobIndex].copyWith(status: status);
    }

    final myJobIndex = _myPostedJobs.indexWhere((job) => job.id == jobId);
    if (myJobIndex != -1) {
      _myPostedJobs[myJobIndex] = _myPostedJobs[myJobIndex].copyWith(status: status);
    }

    notifyListeners();
    
    // Simulate API delay
    await Future.delayed(Duration(milliseconds: 500));
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
  int getPendingApplicationsCount() {
    return _myPostedJobs.fold(0, (count, job) {
      return count + job.applications.where((app) => app.status == ApplicationStatus.pending).length;
    });
  }

  // Load jobs from API (simulated)
  Future<void> loadJobs() async {
    // In a real app, this would fetch from API
    // For now, we'll add some sample jobs
    if (_jobs.isEmpty) {
      _jobs = [
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
      ];
      notifyListeners();
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

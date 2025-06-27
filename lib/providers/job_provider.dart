import 'package:flutter/foundation.dart';
import '../models/job.dart';
import 'package:flutter/material.dart';

class JobProvider with ChangeNotifier {
  final List<Job> _jobs = [];

  List<Job> get jobs => _jobs;

  List<Job> get activeJobs => _jobs.where((job) => job.status == JobStatus.active).toList();
  List<Job> get historyJobs => _jobs.where((job) => job.status == JobStatus.cancelled).toList();

  void addJob(Job job) {
    _jobs.add(job);
    notifyListeners();
  }

  void cancelJob(Job job) {
    final idx = _jobs.indexOf(job);
    if (idx != -1) {
      _jobs[idx].status = JobStatus.cancelled;
      notifyListeners();
    }
  }
}

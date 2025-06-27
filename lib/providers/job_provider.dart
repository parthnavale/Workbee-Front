import 'package:flutter/foundation.dart';
import '../models/job.dart';
import 'package:flutter/material.dart';

class JobProvider with ChangeNotifier {
  final List<Job> _jobs = [];

  List<Job> get jobs => _jobs;

  void addJob(Job job) {
    _jobs.add(job);
    notifyListeners();
  }
}

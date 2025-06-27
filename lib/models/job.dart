enum JobStatus { active, cancelled }

class Job {
  final String title;
  final String description;
  final String location;
  final String designation;
  JobStatus status;

  Job({
    required this.title,
    required this.description,
    required this.location,
    required this.designation,
    this.status = JobStatus.active,
  });
}


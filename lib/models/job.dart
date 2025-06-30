enum JobStatus {
  open,
  inProgress,
  completed,
  cancelled,
}

enum ApplicationStatus {
  pending,
  accepted,
  rejected,
}

class Job {
  final String id;
  final String businessId;
  final String businessName;
  final String title;
  final String description;
  final List<String> requiredSkills;
  final String location;
  final String address;
  final String state;
  final String city;
  final String pinCode;
  final double hourlyRate;
  final int estimatedHours;
  final DateTime postedDate;
  final DateTime? startDate;
  final JobStatus status;
  final List<JobApplication> applications;
  final String contactPerson;
  final String contactPhone;
  final String contactEmail;

  Job({
    required this.id,
    required this.businessId,
    required this.businessName,
    required this.title,
    required this.description,
    required this.requiredSkills,
    required this.location,
    required this.address,
    required this.state,
    required this.city,
    required this.pinCode,
    required this.hourlyRate,
    required this.estimatedHours,
    required this.postedDate,
    this.startDate,
    this.status = JobStatus.open,
    this.applications = const [],
    required this.contactPerson,
    required this.contactPhone,
    required this.contactEmail,
  });

  Job copyWith({
    String? id,
    String? businessId,
    String? businessName,
    String? title,
    String? description,
    List<String>? requiredSkills,
    String? location,
    String? address,
    String? state,
    String? city,
    String? pinCode,
    double? hourlyRate,
    int? estimatedHours,
    DateTime? postedDate,
    DateTime? startDate,
    JobStatus? status,
    List<JobApplication>? applications,
    String? contactPerson,
    String? contactPhone,
    String? contactEmail,
  }) {
    return Job(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      businessName: businessName ?? this.businessName,
      title: title ?? this.title,
      description: description ?? this.description,
      requiredSkills: requiredSkills ?? this.requiredSkills,
      location: location ?? this.location,
      address: address ?? this.address,
      state: state ?? this.state,
      city: city ?? this.city,
      pinCode: pinCode ?? this.pinCode,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      postedDate: postedDate ?? this.postedDate,
      startDate: startDate ?? this.startDate,
      status: status ?? this.status,
      applications: applications ?? this.applications,
      contactPerson: contactPerson ?? this.contactPerson,
      contactPhone: contactPhone ?? this.contactPhone,
      contactEmail: contactEmail ?? this.contactEmail,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'businessId': businessId,
      'businessName': businessName,
      'title': title,
      'description': description,
      'requiredSkills': requiredSkills,
      'location': location,
      'address': address,
      'state': state,
      'city': city,
      'pinCode': pinCode,
      'hourlyRate': hourlyRate,
      'estimatedHours': estimatedHours,
      'postedDate': postedDate.toIso8601String(),
      'startDate': startDate?.toIso8601String(),
      'status': status.toString(),
      'applications': applications.map((app) => app.toJson()).toList(),
      'contactPerson': contactPerson,
      'contactPhone': contactPhone,
      'contactEmail': contactEmail,
    };
  }

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'],
      businessId: json['businessId'],
      businessName: json['businessName'],
      title: json['title'],
      description: json['description'],
      requiredSkills: List<String>.from(json['requiredSkills']),
      location: json['location'],
      address: json['address'],
      state: json['state'],
      city: json['city'],
      pinCode: json['pinCode'],
      hourlyRate: json['hourlyRate'].toDouble(),
      estimatedHours: json['estimatedHours'],
      postedDate: DateTime.parse(json['postedDate']),
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      status: JobStatus.values.firstWhere((e) => e.toString() == json['status']),
      applications: (json['applications'] as List)
          .map((app) => JobApplication.fromJson(app))
          .toList(),
      contactPerson: json['contactPerson'],
      contactPhone: json['contactPhone'],
      contactEmail: json['contactEmail'],
    );
  }
}

class JobApplication {
  final String id;
  final String jobId;
  final String workerId;
  final String workerName;
  final String workerEmail;
  final String workerPhone;
  final List<String> workerSkills;
  final int yearsOfExperience;
  final String previousWorkExperience;
  final ApplicationStatus status;
  final DateTime appliedDate;
  final DateTime? respondedDate;
  final String? message;

  JobApplication({
    required this.id,
    required this.jobId,
    required this.workerId,
    required this.workerName,
    required this.workerEmail,
    required this.workerPhone,
    required this.workerSkills,
    required this.yearsOfExperience,
    required this.previousWorkExperience,
    this.status = ApplicationStatus.pending,
    required this.appliedDate,
    this.respondedDate,
    this.message,
  });

  JobApplication copyWith({
    String? id,
    String? jobId,
    String? workerId,
    String? workerName,
    String? workerEmail,
    String? workerPhone,
    List<String>? workerSkills,
    int? yearsOfExperience,
    String? previousWorkExperience,
    ApplicationStatus? status,
    DateTime? appliedDate,
    DateTime? respondedDate,
    String? message,
  }) {
    return JobApplication(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      workerId: workerId ?? this.workerId,
      workerName: workerName ?? this.workerName,
      workerEmail: workerEmail ?? this.workerEmail,
      workerPhone: workerPhone ?? this.workerPhone,
      workerSkills: workerSkills ?? this.workerSkills,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      previousWorkExperience: previousWorkExperience ?? this.previousWorkExperience,
      status: status ?? this.status,
      appliedDate: appliedDate ?? this.appliedDate,
      respondedDate: respondedDate ?? this.respondedDate,
      message: message ?? this.message,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jobId': jobId,
      'workerId': workerId,
      'workerName': workerName,
      'workerEmail': workerEmail,
      'workerPhone': workerPhone,
      'workerSkills': workerSkills,
      'yearsOfExperience': yearsOfExperience,
      'previousWorkExperience': previousWorkExperience,
      'status': status.toString(),
      'appliedDate': appliedDate.toIso8601String(),
      'respondedDate': respondedDate?.toIso8601String(),
      'message': message,
    };
  }

  factory JobApplication.fromJson(Map<String, dynamic> json) {
    return JobApplication(
      id: json['id'],
      jobId: json['jobId'],
      workerId: json['workerId'],
      workerName: json['workerName'],
      workerEmail: json['workerEmail'],
      workerPhone: json['workerPhone'],
      workerSkills: List<String>.from(json['workerSkills']),
      yearsOfExperience: json['yearsOfExperience'],
      previousWorkExperience: json['previousWorkExperience'],
      status: ApplicationStatus.values.firstWhere((e) => e.toString() == json['status']),
      appliedDate: DateTime.parse(json['appliedDate']),
      respondedDate: json['respondedDate'] != null ? DateTime.parse(json['respondedDate']) : null,
      message: json['message'],
    );
  }
}


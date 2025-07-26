enum JobStatus { open, inProgress, completed, cancelled }

enum ApplicationStatus { pending, accepted, rejected, withdrawn }

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
  final String? contactPerson;
  final String? contactPhone;
  final String? contactEmail;
  final double? latitude;
  final double? longitude;

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
    this.contactPerson,
    this.contactPhone,
    this.contactEmail,
    this.latitude,
    this.longitude,
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
    double? latitude,
    double? longitude,
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
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
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
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'].toString(),
      businessId: (json['business_owner_id'] ?? json['businessId'] ?? '')
          .toString(),
      businessName: (json['businessName'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      requiredSkills: json['requiredSkills'] != null
          ? List<String>.from(json['requiredSkills'])
          : (json['required_skills'] != null
                ? (json['required_skills'] as String)
                      .split(',')
                      .map((s) => s.trim())
                      .toList()
                : []),
      location: (json['location'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      state: (json['state'] ?? '').toString(),
      city: (json['city'] ?? '').toString(),
      pinCode: (json['pinCode'] ?? json['pincode'] ?? '').toString(),
      hourlyRate: (json['hourlyRate'] ?? json['hourly_rate'] ?? 0).toDouble(),
      estimatedHours:
          (json['estimatedHours'] ?? json['estimated_hours'] ?? 0) is int
          ? (json['estimatedHours'] ?? json['estimated_hours'] ?? 0)
          : int.tryParse(
                  (json['estimatedHours'] ?? json['estimated_hours'] ?? '0')
                      .toString(),
                ) ??
                0,
      postedDate: DateTime.parse(json['postedDate'] ?? json['posted_date']),
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : (json['start_date'] != null
                ? DateTime.parse(json['start_date'])
                : null),
      status: JobStatus.values.firstWhere(
        (e) => e.toString() == (json['status'] ?? 'JobStatus.open'),
        orElse: () => JobStatus.open,
      ),
      applications:
          (json['applications'] as List?)
              ?.map((app) => JobApplication.fromJson(app))
              .toList() ??
          [],
      contactPerson: (json['contactPerson'] ?? '').toString(),
      contactPhone: (json['contactPhone'] ?? '').toString(),
      contactEmail: (json['contactEmail'] ?? '').toString(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }
}

class JobApplication {
  final String id;
  final String jobId;
  final String workerId;
  final String coverLetter;
  final double expectedSalary;
  final DateTime? availabilityDate;
  final ApplicationStatus status;
  final DateTime appliedDate;
  final String? message;

  JobApplication({
    required this.id,
    required this.jobId,
    required this.workerId,
    required this.coverLetter,
    required this.expectedSalary,
    this.availabilityDate,
    this.status = ApplicationStatus.pending,
    required this.appliedDate,
    this.message,
  });

  JobApplication copyWith({
    String? id,
    String? jobId,
    String? workerId,
    String? coverLetter,
    double? expectedSalary,
    DateTime? availabilityDate,
    ApplicationStatus? status,
    DateTime? appliedDate,
    String? message,
  }) {
    return JobApplication(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      workerId: workerId ?? this.workerId,
      coverLetter: coverLetter ?? this.coverLetter,
      expectedSalary: expectedSalary ?? this.expectedSalary,
      availabilityDate: availabilityDate ?? this.availabilityDate,
      status: status ?? this.status,
      appliedDate: appliedDate ?? this.appliedDate,
      message: message ?? this.message,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jobId': jobId,
      'workerId': workerId,
      'coverLetter': coverLetter,
      'expectedSalary': expectedSalary,
      'availabilityDate': availabilityDate?.toIso8601String(),
      'status': status.toString(),
      'appliedDate': appliedDate.toIso8601String(),
      'message': message,
    };
  }

  factory JobApplication.fromJson(Map<String, dynamic> json) {
    return JobApplication(
      id: json['id'].toString(),
      jobId: json['job_id']?.toString() ?? json['jobId']?.toString() ?? '',
      workerId:
          json['worker_id']?.toString() ?? json['workerId']?.toString() ?? '',
      coverLetter: json['message'] ?? json['coverLetter'] ?? '',
      expectedSalary: (json['expectedSalary'] ?? json['expected_salary'] ?? 0.0)
          .toDouble(),
      availabilityDate: json['availabilityDate'] != null
          ? DateTime.parse(json['availabilityDate'])
          : json['availability_date'] != null
          ? DateTime.parse(json['availability_date'])
          : null,
      status: ApplicationStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
      ),
      appliedDate: DateTime.parse(json['applied_date'] ?? json['appliedDate']),
      message: json['message'],
    );
  }
}

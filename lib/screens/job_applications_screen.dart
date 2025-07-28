import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/job.dart';
import '../providers/job_provider.dart';
import '../providers/theme_provider.dart';
import '../constants/app_colors.dart';
import '../widgets/animated_scale_button.dart';
import '../widgets/gradient_background.dart';
import '../providers/auth_provider.dart';

class JobApplicationsScreen extends StatefulWidget {
  final Job job;

  const JobApplicationsScreen({super.key, required this.job});

  @override
  State<JobApplicationsScreen> createState() => _JobApplicationsScreenState();
}

class _JobApplicationsScreenState extends State<JobApplicationsScreen> {
  String _selectedFilter = 'All';
  List<JobApplication> _applications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchApplications();
  }

  Future<void> _fetchApplications() async {
    setState(() {
      _isLoading = true;
    });
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    print('[DEBUG] _fetchApplications: businessOwnerId = ${authProvider.businessOwnerId}');
    print('[DEBUG] _fetchApplications: businessOwnerId.toString() = "${authProvider.businessOwnerId.toString()}"');
    
    final apps = await jobProvider.getApplicationsForJob(
      widget.job.id,
      authProvider.businessOwnerId.toString(),
    );
    setState(() {
      _applications = apps;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final filteredApplications = _getFilteredApplications(_applications);

    return Scaffold(
      appBar: AppBar(
        title: Text('Applications - ${widget.job.title}'),
        backgroundColor: isDarkMode
            ? AppColors.backgroundSecondary
            : AppColors.lightBackgroundSecondary,
        foregroundColor: isDarkMode
            ? AppColors.textPrimary
            : AppColors.lightTextPrimary,
        elevation: 0,
      ),
      body: GradientBackground(
        child: Column(
          children: [
            // Filter Section
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    'Filter: ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode
                          ? Colors.white
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('All', isDarkMode),
                          const SizedBox(width: 8),
                          _buildFilterChip('Pending', isDarkMode),
                          const SizedBox(width: 8),
                          _buildFilterChip('Accepted', isDarkMode),
                          const SizedBox(width: 8),
                          _buildFilterChip('Rejected', isDarkMode),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Applications List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredApplications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: isDarkMode
                                ? Colors.grey
                                : AppColors.lightTextSecondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No applications yet (${_applications.length} total)',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode
                                  ? Colors.white
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Applications will appear here when workers apply',
                            style: TextStyle(
                              color: isDarkMode
                                  ? Colors.grey
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredApplications.length,
                      itemBuilder: (context, index) {
                        final application = filteredApplications[index];
                        return _buildApplicationCard(
                          application,
                          isDarkMode,
                          Provider.of<JobProvider>(context, listen: false),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String filter, bool isDarkMode) {
    final isSelected = _selectedFilter == filter;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = filter;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDarkMode
                    ? AppColors.white.withOpacity(0.1)
                    : AppColors.lightBackgroundSecondary),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDarkMode
                      ? AppColors.grey.withOpacity(0.3)
                      : AppColors.lightBorderSecondary),
          ),
        ),
        child: Text(
          filter,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (isDarkMode ? Colors.white : AppColors.lightTextPrimary),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildApplicationCard(
    JobApplication application,
    bool isDarkMode,
    JobProvider jobProvider,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode
            ? AppColors.white.withOpacity(0.05)
            : AppColors.lightBackgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode
              ? AppColors.grey.withOpacity(0.3)
              : AppColors.lightBorderSecondary,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  'W',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Worker #${application.workerId}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode
                            ? Colors.white
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    Text(
                      'Expected Salary: ₹${application.expectedSalary.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: isDarkMode
                            ? Colors.grey
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusChip(application.status, isDarkMode),
            ],
          ),
          const SizedBox(height: 16),

          // Cover Letter
          if (application.coverLetter.isNotEmpty) ...[
            Text(
              'Cover Letter:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              application.coverLetter,
              style: TextStyle(
                color: isDarkMode ? Colors.grey : AppColors.lightTextSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Availability
          if (application.availabilityDate != null) ...[
            Row(
              children: [
                Icon(Icons.calendar_today, color: AppColors.primary, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Available from ${_formatDate(application.availabilityDate!)}',
                  style: TextStyle(
                    color: isDarkMode
                        ? Colors.grey
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 16),

          // Expected Salary
          Row(
            children: [
              Icon(Icons.attach_money, color: AppColors.primary, size: 16),
              const SizedBox(width: 8),
              Text(
                'Expected Salary: ₹${application.expectedSalary.toStringAsFixed(0)}',
                style: TextStyle(
                  color: isDarkMode
                      ? Colors.grey
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Applied Date
          Row(
            children: [
              Icon(Icons.schedule, color: AppColors.primary, size: 16),
              const SizedBox(width: 8),
              Text(
                'Applied ${_formatDate(application.appliedDate)}',
                style: TextStyle(
                  color: isDarkMode
                      ? Colors.grey
                      : AppColors.lightTextSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          // Action Buttons
          if (application.status == ApplicationStatus.pending) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AnimatedScaleButton(
                    onTap: () => _showResponseDialog(
                      application,
                      ApplicationStatus.accepted,
                      isDarkMode,
                      jobProvider,
                    ),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 40),
                    child: const Text('Accept'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AnimatedScaleButton(
                    onTap: () => _showResponseDialog(
                      application,
                      ApplicationStatus.rejected,
                      isDarkMode,
                      jobProvider,
                    ),
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 40),
                    child: const Text('Reject'),
                  ),
                ),
              ],
            ),
          ],

          // Response Message
          if (application.message != null &&
              application.message!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (application.status == ApplicationStatus.accepted
                    ? AppColors.green.withOpacity(0.1)
                    : AppColors.red.withOpacity(0.1)),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: (application.status == ApplicationStatus.accepted
                      ? AppColors.green.withOpacity(0.3)
                      : AppColors.red.withOpacity(0.3)),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    application.status == ApplicationStatus.accepted
                        ? 'Acceptance Message:'
                        : 'Rejection Message:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: application.status == ApplicationStatus.accepted
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    application.message!,
                    style: TextStyle(
                      fontSize: 12,
                      color: application.status == ApplicationStatus.accepted
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusChip(ApplicationStatus status, bool isDarkMode) {
    Color color;
    String text;

    switch (status) {
      case ApplicationStatus.pending:
        color = Colors.orange;
        text = 'Pending';
        break;
      case ApplicationStatus.accepted:
        color = Colors.green;
        text = 'Accepted';
        break;
      case ApplicationStatus.rejected:
        color = Colors.red;
        text = 'Rejected';
        break;
      case ApplicationStatus.withdrawn:
        color = Colors.grey;
        text = 'Withdrawn';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.withOpacity(color, 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showResponseDialog(
    JobApplication application,
    ApplicationStatus status,
    bool isDarkMode,
    JobProvider jobProvider,
  ) {
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            status == ApplicationStatus.accepted
                ? 'Accept Application'
                : 'Reject Application',
            style: TextStyle(
              color: isDarkMode ? Colors.white : AppColors.lightTextPrimary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Are you sure you want to ${status == ApplicationStatus.accepted ? 'accept' : 'reject'} this application?',
                style: TextStyle(
                  color: isDarkMode
                      ? Colors.grey
                      : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: messageController,
                maxLines: 3,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : AppColors.lightTextPrimary,
                ),
                decoration: InputDecoration(
                  labelText: 'Message (optional)',
                  labelStyle: TextStyle(
                    color: isDarkMode
                        ? Colors.grey
                        : AppColors.lightTextSecondary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: isDarkMode
                          ? Colors.grey
                          : AppColors.lightBorderSecondary,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDarkMode
                      ? Colors.grey
                      : AppColors.lightTextSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _respondToApplication(
                  application,
                  status,
                  messageController.text,
                  jobProvider,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: status == ApplicationStatus.accepted
                    ? Colors.green
                    : Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(
                status == ApplicationStatus.accepted ? 'Accept' : 'Reject',
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _respondToApplication(
    JobApplication application,
    ApplicationStatus status,
    String message,
    JobProvider jobProvider,
  ) async {
    try {
      await jobProvider.respondToApplication(
        widget.job.id,
        application.id,
        status,
        message: message.isNotEmpty ? message : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Application ${status == ApplicationStatus.accepted ? 'accepted' : 'rejected'} successfully!',
            ),
            backgroundColor: status == ApplicationStatus.accepted
                ? Colors.green
                : Colors.red,
          ),
        );
        // Refresh the applications list
        await _fetchApplications();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  List<JobApplication> _getFilteredApplications(
    List<JobApplication> applications,
  ) {
    List<JobApplication> result;
    switch (_selectedFilter) {
      case 'Pending':
        result = applications
            .where((app) => app.status == ApplicationStatus.pending)
            .toList();
        break;
      case 'Accepted':
        result = applications
            .where((app) => app.status == ApplicationStatus.accepted)
            .toList();
        break;
      case 'Rejected':
        result = applications
            .where((app) => app.status == ApplicationStatus.rejected)
            .toList();
        break;
      default:
        result = applications;
    }
    return result;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

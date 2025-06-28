import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/job.dart';
import '../providers/job_provider.dart';
import '../providers/theme_provider.dart';
import '../constants/app_colors.dart';
import '../widgets/gradient_background.dart';

class MyApplicationsScreen extends StatefulWidget {
  const MyApplicationsScreen({super.key});

  @override
  State<MyApplicationsScreen> createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends State<MyApplicationsScreen> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final jobProvider = Provider.of<JobProvider>(context);
    
    final applications = jobProvider.myApplications;
    final filteredApplications = _getFilteredApplications(applications);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Applications'),
        backgroundColor: isDarkMode ? AppColors.backgroundSecondary : AppColors.lightBackgroundSecondary,
        foregroundColor: isDarkMode ? AppColors.textPrimary : AppColors.lightTextPrimary,
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
                      color: isDarkMode ? Colors.white : AppColors.lightTextPrimary,
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
              child: applications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.work_off,
                            size: 64,
                            color: isDarkMode ? Colors.grey : AppColors.lightTextSecondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No applications yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : AppColors.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start by browsing and applying for jobs',
                            style: TextStyle(
                              color: isDarkMode ? Colors.grey : AppColors.lightTextSecondary,
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
                        final job = jobProvider.getJobById(application.jobId);
                        return _buildApplicationCard(application, job, isDarkMode);
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
              : (isDarkMode ? Colors.white.withOpacity(0.1) : AppColors.lightBackgroundSecondary),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? AppColors.primary 
                : (isDarkMode ? Colors.grey.withOpacity(0.3) : AppColors.lightBorderSecondary),
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

  Widget _buildApplicationCard(JobApplication application, Job? job, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withOpacity(0.05) : AppColors.lightBackgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? Colors.grey.withOpacity(0.3) : AppColors.lightBorderSecondary,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.work,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job?.title ?? 'Job #${application.jobId}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : AppColors.lightTextPrimary,
                      ),
                    ),
                    if (job != null)
                      Text(
                        job.businessName,
                        style: TextStyle(
                          color: isDarkMode ? Colors.grey : AppColors.lightTextSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              _buildStatusChip(application.status, isDarkMode),
            ],
          ),
          const SizedBox(height: 16),
          
          // Job Details
          if (job != null) ...[
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: AppColors.primary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${job.city}, ${job.state}',
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey : AppColors.lightTextSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.attach_money,
                  color: AppColors.primary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  '₹${job.hourlyRate}/hour • ${job.estimatedHours} hours',
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          
          // Application Details
          Row(
            children: [
              Icon(
                Icons.schedule,
                color: AppColors.primary,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Applied ${_formatDate(application.appliedDate)}',
                style: TextStyle(
                  color: isDarkMode ? Colors.grey : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
          
          // Response Message
          if (application.message != null && application.message!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (application.status == ApplicationStatus.accepted ? Colors.green : Colors.red).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: (application.status == ApplicationStatus.accepted ? Colors.green : Colors.red).withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    application.status == ApplicationStatus.accepted ? 'Acceptance Message:' : 'Rejection Message:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: application.status == ApplicationStatus.accepted ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    application.message!,
                    style: TextStyle(
                      fontSize: 12,
                      color: application.status == ApplicationStatus.accepted ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // Action Buttons
          if (application.status == ApplicationStatus.accepted) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Implement contact business functionality
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 40),
                    ),
                    child: const Text('Contact Business'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // TODO: Implement view job details functionality
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary),
                      minimumSize: const Size(double.infinity, 40),
                    ),
                    child: const Text('View Job'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusChip(ApplicationStatus status, bool isDarkMode) {
    Color color;
    String text;
    IconData icon;
    
    switch (status) {
      case ApplicationStatus.pending:
        color = Colors.orange;
        text = 'Pending';
        icon = Icons.schedule;
        break;
      case ApplicationStatus.accepted:
        color = Colors.green;
        text = 'Accepted';
        icon = Icons.check_circle;
        break;
      case ApplicationStatus.rejected:
        color = Colors.red;
        text = 'Rejected';
        icon = Icons.cancel;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  List<JobApplication> _getFilteredApplications(List<JobApplication> applications) {
    switch (_selectedFilter) {
      case 'Pending':
        return applications.where((app) => app.status == ApplicationStatus.pending).toList();
      case 'Accepted':
        return applications.where((app) => app.status == ApplicationStatus.accepted).toList();
      case 'Rejected':
        return applications.where((app) => app.status == ApplicationStatus.rejected).toList();
      default:
        return applications;
    }
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
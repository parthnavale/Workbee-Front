import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/job.dart';
import '../providers/job_provider.dart';
import '../providers/theme_provider.dart';
import '../constants/app_colors.dart';
import '../widgets/animated_scale_button.dart';
import '../widgets/gradient_background.dart';
import 'post_job_screen.dart';
import 'job_applications_screen.dart';
import '../providers/auth_provider.dart';

class BusinessDashboardScreen extends StatefulWidget {
  const BusinessDashboardScreen({super.key});

  @override
  State<BusinessDashboardScreen> createState() => _BusinessDashboardScreenState();
}

class _BusinessDashboardScreenState extends State<BusinessDashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadBusinessOwnerJobs();
  }

  Future<void> _loadBusinessOwnerJobs() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.businessOwnerId != null) {
      final jobProvider = Provider.of<JobProvider>(context, listen: false);
      await jobProvider.fetchBusinessOwnerJobs(authProvider.businessOwnerId.toString());
      await jobProvider.fetchPendingApplicationsCount(authProvider.businessOwnerId.toString());
    }
  }

  Future<void> _refreshData() async {
    await _loadBusinessOwnerJobs();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final jobProvider = Provider.of<JobProvider>(context);
    
    final pendingApplicationsCount = jobProvider.getPendingApplicationsCount();
    final myPostedJobs = jobProvider.myPostedJobs;
    final activeJobs = myPostedJobs.where((job) => job.status == JobStatus.open).toList();
    final completedJobs = myPostedJobs.where((job) => job.status == JobStatus.completed).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Dashboard'),
        backgroundColor: isDarkMode ? AppColors.backgroundSecondary : AppColors.lightBackgroundSecondary,
        foregroundColor: isDarkMode ? AppColors.textPrimary : AppColors.lightTextPrimary,
        elevation: 0,
        actions: [
          if (pendingApplicationsCount > 0)
            Stack(
              children: [
                IconButton(
                  icon: Icon(Icons.notifications),
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 1; // Switch to applications tab
                    });
                  },
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      pendingApplicationsCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
      body: GradientBackground(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            // Overview Tab
            _buildOverviewTab(isDarkMode, jobProvider, pendingApplicationsCount, activeJobs, completedJobs),
            // Applications Tab
            _buildApplicationsTab(isDarkMode, jobProvider),
            // Posted Jobs Tab
            _buildPostedJobsTab(isDarkMode, jobProvider),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: isDarkMode ? AppColors.backgroundSecondary : AppColors.lightBackgroundSecondary,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: isDarkMode ? Colors.grey : AppColors.lightTextSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Overview',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Applications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work),
            label: 'My Jobs',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PostJobScreen(),
            ),
          );
          // Refresh data after posting a job
          await _refreshData();
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildOverviewTab(
    bool isDarkMode,
    JobProvider jobProvider,
    int pendingApplicationsCount,
    List<Job> activeJobs,
    List<Job> completedJobs,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.whiteWithAlpha(0.05) : AppColors.lightBackgroundSecondary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDarkMode ? AppColors.greyWithAlpha(0.3) : AppColors.lightBorderSecondary,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryWithAlpha(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.business,
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
                        'Welcome back!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Manage your job postings and applications',
                        style: TextStyle(
                          color: isDarkMode ? Colors.grey : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Quick Actions
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AnimatedScaleButton(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PostJobScreen(),
                      ),
                    );
                  },
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.primaryDark,
                  minimumSize: const Size(double.infinity, 60),
                  child: Column(
                    children: [
                      Icon(Icons.add, size: 24),
                      const SizedBox(height: 4),
                      Text(
                        'Post New Job',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AnimatedScaleButton(
                  onTap: () {
                    setState(() {
                      _selectedIndex = 1;
                    });
                  },
                  backgroundColor: pendingApplicationsCount > 0 ? Colors.orange : Colors.grey,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 60),
                  child: Column(
                    children: [
                      Icon(Icons.people, size: 24),
                      const SizedBox(height: 4),
                      Text(
                        'View Applications',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),

          // Statistics
          Text(
            'Statistics',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.work,
                  title: 'Active Jobs',
                  value: activeJobs.length.toString(),
                  color: Colors.blue,
                  isDarkMode: isDarkMode,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.people,
                  title: 'Pending Applications',
                  value: pendingApplicationsCount.toString(),
                  color: Colors.orange,
                  isDarkMode: isDarkMode,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.check_circle,
                  title: 'Completed Jobs',
                  value: completedJobs.length.toString(),
                  color: Colors.green,
                  isDarkMode: isDarkMode,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.trending_up,
                  title: 'Total Applications',
                  value: jobProvider.myPostedJobs.fold(0, (sum, job) => sum + job.applications.length).toString(),
                  color: Colors.purple,
                  isDarkMode: isDarkMode,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),

          // Recent Activity
          Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 16),
          if (jobProvider.myPostedJobs.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.whiteWithAlpha(0.05) : AppColors.lightBackgroundSecondary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDarkMode ? AppColors.greyWithAlpha(0.3) : AppColors.lightBorderSecondary,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.work_off,
                    size: 48,
                    color: isDarkMode ? Colors.grey : AppColors.lightTextSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No jobs posted yet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start by posting your first job',
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            )
          else
            ...jobProvider.myPostedJobs.take(3).map((job) => _buildRecentJobCard(job, isDarkMode)),
        ],
      ),
    );
  }

  Widget _buildApplicationsTab(bool isDarkMode, JobProvider jobProvider) {
    final jobsWithApplications = jobProvider.jobsWithPendingApplications;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Job Applications',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 16),
          if (jobsWithApplications.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.whiteWithAlpha(0.05) : AppColors.lightBackgroundSecondary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDarkMode ? AppColors.greyWithAlpha(0.3) : AppColors.lightBorderSecondary,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 48,
                    color: isDarkMode ? Colors.grey : AppColors.lightTextSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No pending applications',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Applications will appear here when workers apply',
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            )
          else
            ...jobsWithApplications.map((job) => _buildJobApplicationsCard(job, isDarkMode)),
        ],
      ),
    );
  }

  Widget _buildPostedJobsTab(bool isDarkMode, JobProvider jobProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Posted Jobs',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 16),
          if (jobProvider.myPostedJobs.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.whiteWithAlpha(0.05) : AppColors.lightBackgroundSecondary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDarkMode ? AppColors.greyWithAlpha(0.3) : AppColors.lightBorderSecondary,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.work_off,
                    size: 48,
                    color: isDarkMode ? Colors.grey : AppColors.lightTextSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No jobs posted yet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start by posting your first job',
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            )
          else
            ...jobProvider.myPostedJobs.map((job) => _buildPostedJobCard(job, isDarkMode)),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required bool isDarkMode,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.whiteWithAlpha(0.05) : AppColors.lightBackgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? AppColors.greyWithAlpha(0.3) : AppColors.lightBorderSecondary,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode ? Colors.grey : AppColors.lightTextSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentJobCard(Job job, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.whiteWithAlpha(0.05) : AppColors.lightBackgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? AppColors.greyWithAlpha(0.3) : AppColors.lightBorderSecondary,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  job.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : AppColors.lightTextPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.withAlpha(_getStatusColor(job.status), 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getStatusText(job.status),
                  style: TextStyle(
                    fontSize: 12,
                    color: _getStatusColor(job.status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${job.applications.length} applications',
            style: TextStyle(
              color: isDarkMode ? Colors.grey : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobApplicationsCard(Job job, bool isDarkMode) {
    final pendingApplications = job.applications.where((app) => app.status == ApplicationStatus.pending).toList();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.whiteWithAlpha(0.05) : AppColors.lightBackgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? AppColors.greyWithAlpha(0.3) : AppColors.lightBorderSecondary,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  job.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : AppColors.lightTextPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.orangeWithAlpha(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${pendingApplications.length} pending',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...pendingApplications.take(2).map((app) => _buildApplicationItem(app, isDarkMode)),
          if (pendingApplications.length > 2)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'And ${pendingApplications.length - 2} more applications...',
                style: TextStyle(
                  color: isDarkMode ? Colors.grey : AppColors.lightTextSecondary,
                  fontSize: 12,
                ),
              ),
            ),
          const SizedBox(height: 16),
          AnimatedScaleButton(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => JobApplicationsScreen(job: job),
                ),
              );
            },
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 40),
            child: const Text('View All Applications'),
          ),
        ],
      ),
    );
  }

  Widget _buildPostedJobCard(Job job, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.whiteWithAlpha(0.05) : AppColors.lightBackgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? AppColors.greyWithAlpha(0.3) : AppColors.lightBorderSecondary,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  job.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : AppColors.lightTextPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.withAlpha(_getStatusColor(job.status), 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getStatusText(job.status),
                  style: TextStyle(
                    fontSize: 12,
                    color: _getStatusColor(job.status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '₹${job.hourlyRate}/hour • ${job.estimatedHours} hours',
            style: TextStyle(
              color: isDarkMode ? Colors.grey : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 8),
          FutureBuilder<int>(
            future: _getApplicationCount(job.id),
            builder: (context, snapshot) {
              final count = snapshot.data ?? 0;
              return Text(
                ' $count applications',
                style: TextStyle(
                  color: isDarkMode ? Colors.grey : AppColors.lightTextSecondary,
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AnimatedScaleButton(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => JobApplicationsScreen(job: job),
                      ),
                    );
                  },
                  backgroundColor: Colors.transparent,
                  foregroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 40),
                  side: BorderSide(color: AppColors.primary),
                  child: const Text('View Applications'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AnimatedScaleButton(
                  onTap: () {
                    // TODO: Implement edit job functionality
                  },
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.orange,
                  minimumSize: const Size(double.infinity, 40),
                  side: BorderSide(color: Colors.orange),
                  child: const Text('Edit Job'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationItem(JobApplication app, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.whiteWithAlpha(0.05) : AppColors.lightBackgroundSecondary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDarkMode ? AppColors.greyWithAlpha(0.3) : AppColors.lightBorderSecondary,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primaryWithAlpha(0.1),
            child: Text(
              'W',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Worker #${app.workerId}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : AppColors.lightTextPrimary,
                  ),
                ),
                Text(
                  'Expected: ₹${app.expectedSalary.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.grey : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatDate(app.appliedDate),
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode ? Colors.grey : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(JobStatus status) {
    switch (status) {
      case JobStatus.open:
        return Colors.green;
      case JobStatus.inProgress:
        return Colors.blue;
      case JobStatus.completed:
        return Colors.grey;
      case JobStatus.cancelled:
        return Colors.red;
    }
  }

  String _getStatusText(JobStatus status) {
    switch (status) {
      case JobStatus.open:
        return 'Open';
      case JobStatus.inProgress:
        return 'In Progress';
      case JobStatus.completed:
        return 'Completed';
      case JobStatus.cancelled:
        return 'Cancelled';
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
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}';
    }
  }

  Future<int> _getApplicationCount(String jobId) async {
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    return await jobProvider.fetchJobApplicationsCount(jobId);
  }
} 
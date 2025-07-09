import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/job.dart';
import '../providers/job_provider.dart';
import '../providers/theme_provider.dart';
import '../constants/app_colors.dart';
import '../widgets/animated_scale_button.dart';
import '../widgets/gradient_background.dart';
import 'job_listing_screen.dart';
import 'my_applications_screen.dart';

class SeekerHomeScreen extends StatefulWidget {
  const SeekerHomeScreen({super.key});

  @override
  State<SeekerHomeScreen> createState() => _SeekerHomeScreenState();
}

class _SeekerHomeScreenState extends State<SeekerHomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final jobProvider = Provider.of<JobProvider>(context);
    
    final myApplications = jobProvider.myApplications;
    final pendingApplications = myApplications.where((app) => app.status == ApplicationStatus.pending).toList();
    final acceptedApplications = myApplications.where((app) => app.status == ApplicationStatus.accepted).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Worker Dashboard'),
        backgroundColor: isDarkMode ? AppColors.backgroundSecondary : AppColors.lightBackgroundSecondary,
        foregroundColor: isDarkMode ? AppColors.textPrimary : AppColors.lightTextPrimary,
        elevation: 0,
        actions: [
          if (pendingApplications.isNotEmpty)
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
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      pendingApplications.length.toString(),
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
            _buildOverviewTab(isDarkMode, jobProvider, pendingApplications, acceptedApplications),
            // My Applications Tab
            _buildApplicationsTab(isDarkMode, jobProvider),
            // Profile Tab
            _buildProfileTab(isDarkMode),
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
            icon: Icon(Icons.work),
            label: 'My Applications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(
    bool isDarkMode,
    JobProvider jobProvider,
    List<JobApplication> pendingApplications,
    List<JobApplication> acceptedApplications,
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
              color: isDarkMode ? AppColors.white.withOpacity(0.05) : AppColors.lightBackgroundSecondary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDarkMode ? AppColors.grey.withOpacity(0.3) : AppColors.lightBorderSecondary,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.person,
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
                          color: isDarkMode ? AppColors.white : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Find your next opportunity',
                        style: TextStyle(
                          color: isDarkMode ? AppColors.grey : AppColors.lightTextSecondary,
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
              color: isDarkMode ? AppColors.white : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 16),
          AnimatedScaleButton(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const JobListingScreen(),
                      ),
                    );
                  },
                  backgroundColor: AppColors.primary,
            foregroundColor: AppColors.primaryDark,
                  minimumSize: const Size(double.infinity, 60),
                  child: Column(
                    children: [
                      Icon(Icons.search, size: 24),
                      const SizedBox(height: 4),
                      Text(
                        'Browse Jobs',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 30),

          // Statistics
          Text(
            'My Statistics',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? AppColors.white : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.work,
                  title: 'Total Applications',
                  value: jobProvider.myApplications.length.toString(),
                  color: Colors.blue,
                  isDarkMode: isDarkMode,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.schedule,
                  title: 'Pending',
                  value: pendingApplications.length.toString(),
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
                  title: 'Accepted',
                  value: acceptedApplications.length.toString(),
                  color: Colors.green,
                  isDarkMode: isDarkMode,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.trending_up,
                  title: 'Success Rate',
                  value: jobProvider.myApplications.isEmpty 
                      ? '0%' 
                      : '${((acceptedApplications.length / jobProvider.myApplications.length) * 100).round()}%',
                  color: Colors.purple,
                  isDarkMode: isDarkMode,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),

          // Recent Applications
          Text(
            'Recent Applications',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? AppColors.white : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 16),
          if (jobProvider.myApplications.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.white.withOpacity(0.05) : AppColors.lightBackgroundSecondary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDarkMode ? AppColors.grey.withOpacity(0.3) : AppColors.lightBorderSecondary,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.work_off,
                    size: 48,
                    color: isDarkMode ? AppColors.grey : AppColors.lightTextSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No applications yet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? AppColors.white : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start by browsing available jobs',
                    style: TextStyle(
                      color: isDarkMode ? AppColors.grey : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            )
          else
            ...jobProvider.myApplications.take(3).map((app) => _buildRecentApplicationCard(app, isDarkMode)),
        ],
      ),
    );
  }

  Widget _buildApplicationsTab(bool isDarkMode, JobProvider jobProvider) {
    return const MyApplicationsScreen();
  }

  Widget _buildProfileTab(bool isDarkMode) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.white.withOpacity(0.05) : AppColors.lightBackgroundSecondary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDarkMode ? AppColors.grey.withOpacity(0.3) : AppColors.lightBorderSecondary,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    'JD',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'John Doe',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? AppColors.white : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'john@example.com',
                        style: TextStyle(
                          color: isDarkMode ? AppColors.grey : AppColors.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '2 years experience',
                        style: TextStyle(
                          color: isDarkMode ? AppColors.grey : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Profile Actions
          Text(
            'Profile Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? AppColors.white : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildProfileActionCard(
            icon: Icons.edit,
            title: 'Edit Profile',
            subtitle: 'Update your personal information',
            onTap: () {
              // TODO: Navigate to edit profile screen
            },
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 12),
          _buildProfileActionCard(
            icon: Icons.settings,
            title: 'Settings',
            subtitle: 'Manage app preferences',
            onTap: () {
              // TODO: Navigate to settings screen
            },
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 12),
          _buildProfileActionCard(
            icon: Icons.help,
            title: 'Help & Support',
            subtitle: 'Get help and contact support',
            onTap: () {
              // TODO: Navigate to help screen
            },
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 12),
          _buildProfileActionCard(
            icon: Icons.logout,
            title: 'Logout',
            subtitle: 'Sign out of your account',
            onTap: () {
              // TODO: Implement logout
            },
            isDarkMode: isDarkMode,
            isDestructive: true,
          ),
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
        color: isDarkMode ? AppColors.white.withOpacity(0.05) : AppColors.lightBackgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? AppColors.grey.withOpacity(0.3) : AppColors.lightBorderSecondary,
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
              color: isDarkMode ? AppColors.white : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode ? AppColors.grey : AppColors.lightTextSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentApplicationCard(JobApplication app, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.white.withOpacity(0.05) : AppColors.lightBackgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? AppColors.grey.withOpacity(0.3) : AppColors.lightBorderSecondary,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Application for ${app.jobId}', // In real app, get job title
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? AppColors.white : AppColors.lightTextPrimary,
                  ),
                ),
              ),
              _buildStatusChip(app.status, isDarkMode),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Applied ${_formatDate(app.appliedDate)}',
            style: TextStyle(
              color: isDarkMode ? AppColors.grey : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDarkMode,
    bool isDestructive = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.white.withOpacity(0.05) : AppColors.lightBackgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? AppColors.grey.withOpacity(0.3) : AppColors.lightBorderSecondary,
        ),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : AppColors.primary,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Colors.red : (isDarkMode ? AppColors.white : AppColors.lightTextPrimary),
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: isDarkMode ? AppColors.grey : AppColors.lightTextSecondary,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: isDarkMode ? AppColors.grey : AppColors.lightTextSecondary,
          size: 16,
        ),
        onTap: onTap,
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
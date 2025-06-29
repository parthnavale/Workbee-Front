import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/job_provider.dart';
import '../providers/theme_provider.dart';
import '../constants/user_roles.dart';
import '../constants/app_colors.dart';
import '../widgets/app_header.dart';
import '../widgets/animated_scale_button.dart';
import '../widgets/fade_page_route.dart';
import '../widgets/gradient_background.dart';
import 'poster_home_screen.dart';
import 'seeker_home_screen.dart';
import 'post_job_screen.dart';
import '../utils/navigation_utils.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final jobProvider = Provider.of<JobProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    return Scaffold(
      appBar: AppHeader(
        onNavigation: (action) => NavigationUtils.handleNavigation(action, context),
      ),
      body: GradientBackground(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.white.withOpacity(0.1) : AppColors.lightBackgroundSecondary,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        color: AppColors.primary,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back, ${authProvider.userName ?? 'User'}!',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : AppColors.lightTextPrimary,
                              ),
                            ),
                            Text(
                              'You are logged in as ${authProvider.userRole == UserRole.poster ? 'Business' : 'Worker'}',
                              style: TextStyle(
                                fontSize: 16,
                                color: isDarkMode ? Colors.grey : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => NavigationUtils.handleNavigation('Logout', context),
                        icon: Icon(
                          Icons.logout,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Quick Actions
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 20),
            
            // Action Buttons
            if (authProvider.userRole == UserRole.poster) ...[
              // Business Actions
              AnimatedScaleButton(
                onTap: () => NavigationUtils.handleNavigation('ForBusiness', context),
                icon: Icons.business_center,
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.primaryDark,
                minimumSize: const Size(double.infinity, 50),
                child: const Text(
                  'Manage Jobs',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              AnimatedScaleButton(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PostJobScreen(),
                  ),
                ),
                icon: Icons.add,
                backgroundColor: isDarkMode ? Colors.white.withOpacity(0.1) : AppColors.lightBackgroundSecondary,
                foregroundColor: isDarkMode ? Colors.white : AppColors.lightTextPrimary,
                borderColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 50),
                child: const Text(
                  'Post New Job',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ] else if (authProvider.userRole == UserRole.seeker) ...[
              // Worker Actions
              AnimatedScaleButton(
                onTap: () => NavigationUtils.handleNavigation('For Workers', context),
                icon: Icons.search,
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.primaryDark,
                minimumSize: const Size(double.infinity, 50),
                child: const Text(
                  'Find Jobs',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              AnimatedScaleButton(
                onTap: () {
                  // Navigate to applied jobs
                },
                icon: Icons.work,
                backgroundColor: isDarkMode ? Colors.white.withOpacity(0.1) : AppColors.lightBackgroundSecondary,
                foregroundColor: isDarkMode ? Colors.white : AppColors.lightTextPrimary,
                borderColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 50),
                child: const Text(
                  'My Applications',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 30),
            
            // Statistics Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.white.withOpacity(0.05) : AppColors.lightBackgroundSecondary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Statistics',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total Jobs',
                          '${jobProvider.jobs.length}',
                          Icons.work,
                          isDarkMode,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildStatCard(
                          'Active',
                          '${jobProvider.jobs.length}',
                          Icons.check_circle,
                          isDarkMode,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withOpacity(0.1) : AppColors.lightBackgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 24,
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
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode ? Colors.grey : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
} 
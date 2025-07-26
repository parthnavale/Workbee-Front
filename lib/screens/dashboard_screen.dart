import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/job_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/notification_provider.dart';
import '../constants/user_roles.dart';
import '../constants/app_colors.dart';
import '../widgets/app_header.dart';
import '../widgets/animated_scale_button.dart';
import '../widgets/gradient_background.dart';

import '../utils/navigation_utils.dart';
import 'dart:async';
import 'my_applications_screen.dart';
import 'notifications_screen.dart';
import 'package:overlay_support/overlay_support.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Timer? _notificationTimer;
  bool _connectedToNotifications = false;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // Fetch notifications for both workers and business owners
    authProvider.fetchNotifications();
    _notificationTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      authProvider.fetchNotifications();
    });

    // Connect to notifications after first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final notificationProvider = Provider.of<NotificationProvider>(
        context,
        listen: false,
      );
      final isWorker = authProvider.userRole == UserRole.seeker;
      final isBusiness = authProvider.userRole == UserRole.poster;
      if (isWorker && authProvider.workerId != null) {
        notificationProvider.connect(authProvider.workerId!);
      } else if (isBusiness && authProvider.businessOwnerId != null) {
        notificationProvider.connect(authProvider.businessOwnerId!);
      }
    });
  }

  @override
  void dispose() {
    _notificationTimer?.cancel();
    super.dispose();
  }

  void _showNotifications(BuildContext context, AuthProvider authProvider) {
    // Navigate to the new notifications screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificationsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final jobProvider = Provider.of<JobProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final isWorker = authProvider.userRole == UserRole.seeker;
    final isBusiness = authProvider.userRole == UserRole.poster;
    final notificationProvider = Provider.of<NotificationProvider>(context);

    return Scaffold(
      appBar: AppHeader(
        onNavigation: (action) =>
            NavigationUtils.handleNavigation(action, context),
        actions: [
          if (isWorker || isBusiness)
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications),
                  onPressed: () => _showNotifications(context, authProvider),
                ),
                if (notificationProvider.unreadCount > 0)
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
                        notificationProvider.unreadCount.toString(),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showSimpleNotification(
            Text(
              "Test notification",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            background: Colors.green,
            autoDismiss: true,
            slideDismiss: true,
            duration: Duration(seconds: 4),
            leading: Icon(Icons.notifications, color: Colors.white),
          );
        },
        child: Icon(Icons.notifications),
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
                color: isDarkMode
                    ? AppColors.white.withOpacity(0.1)
                    : AppColors.lightBackgroundSecondary,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person, color: AppColors.primary, size: 32),
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
                                color: isDarkMode
                                    ? Colors.white
                                    : AppColors.lightTextPrimary,
                              ),
                            ),
                            Text(
                              'You are logged in as ${authProvider.userRole == UserRole.poster ? 'Business' : 'Worker'}',
                              style: TextStyle(
                                fontSize: 16,
                                color: isDarkMode
                                    ? Colors.grey
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () =>
                            NavigationUtils.handleNavigation('Logout', context),
                        icon: Icon(Icons.logout, color: AppColors.primary),
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
                onTap: () =>
                    NavigationUtils.handleNavigation('ForBusiness', context),
                icon: Icons.business_center,
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.primaryDark,
                minimumSize: const Size(double.infinity, 50),
                child: const Text(
                  'Manage Jobs',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 15),
              AnimatedScaleButton(
                onTap: () => NavigationUtils.navigateToAddJob(context),
                icon: Icons.add,
                backgroundColor: isDarkMode
                    ? AppColors.white.withOpacity(0.1)
                    : AppColors.lightBackgroundSecondary,
                foregroundColor: isDarkMode
                    ? Colors.white
                    : AppColors.lightTextPrimary,
                borderColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 50),
                child: const Text(
                  'Post New Job',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ] else if (authProvider.userRole == UserRole.seeker) ...[
              // Worker Actions
              AnimatedScaleButton(
                onTap: () =>
                    NavigationUtils.handleNavigation('For Workers', context),
                icon: Icons.search,
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.primaryDark,
                minimumSize: const Size(double.infinity, 50),
                child: const Text(
                  'Find Jobs',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 15),
              AnimatedScaleButton(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyApplicationsScreen(),
                    ),
                  );
                },
                icon: Icons.work,
                backgroundColor: isDarkMode
                    ? AppColors.white.withOpacity(0.1)
                    : AppColors.lightBackgroundSecondary,
                foregroundColor: isDarkMode
                    ? Colors.white
                    : AppColors.lightTextPrimary,
                borderColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 50),
                child: const Text(
                  'My Applications',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],

            const SizedBox(height: 30),

            // Statistics Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? AppColors.white.withOpacity(0.05)
                    : AppColors.lightBackgroundSecondary,
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
                      color: isDarkMode
                          ? Colors.white
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          authProvider.userRole == UserRole.poster
                              ? 'Total Jobs'
                              : 'Applications',
                          authProvider.userRole == UserRole.poster
                              ? '${jobProvider.jobs.length}'
                              : '${jobProvider.myApplications.length}',
                          authProvider.userRole == UserRole.poster
                              ? Icons.work
                              : Icons.description,
                          isDarkMode,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildStatCard(
                          'Notifications',
                          '${notificationProvider.unreadCount}',
                          Icons.notifications,
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

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode
            ? AppColors.white.withOpacity(0.1)
            : AppColors.lightBackgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
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

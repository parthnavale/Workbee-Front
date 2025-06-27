import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/job_provider.dart';
import '../constants/user_roles.dart';
import '../widgets/app_header.dart';
import '../widgets/animated_scale_button.dart';
import '../widgets/fade_page_route.dart';
import '../widgets/gradient_background.dart';
import 'poster_home_screen.dart';
import 'seeker_home_screen.dart';
import 'add_job_screen.dart';
import '../utils/navigation_utils.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final jobProvider = Provider.of<JobProvider>(context);
    
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
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEAB308), width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.person,
                        color: Color(0xFFEAB308),
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back, ${authProvider.userName ?? 'User'}!',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'You are logged in as ${authProvider.userRole == UserRole.poster ? 'Business Owner' : 'Worker'}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => NavigationUtils.handleNavigation('Logout', context),
                        icon: const Icon(
                          Icons.logout,
                          color: Color(0xFFEAB308),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Quick Actions
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            
            // Action Buttons
            if (authProvider.userRole == UserRole.poster) ...[
              // Business Owner Actions
              AnimatedScaleButton(
                onTap: () => NavigationUtils.handleNavigation('ForBusiness', context),
                icon: Icons.business_center,
                backgroundColor: const Color(0xFFEAB308),
                foregroundColor: const Color(0xFF10182B),
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
                onTap: () => NavigationUtils.navigateToAddJob(context),
                icon: Icons.add,
                backgroundColor: Colors.white.withOpacity(0.1),
                foregroundColor: Colors.white,
                borderColor: const Color(0xFFEAB308),
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
                backgroundColor: const Color(0xFFEAB308),
                foregroundColor: const Color(0xFF10182B),
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
                backgroundColor: Colors.white.withOpacity(0.1),
                foregroundColor: Colors.white,
                borderColor: const Color(0xFFEAB308),
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
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Statistics',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildStatCard(
                          'Active',
                          '${jobProvider.jobs.length}',
                          Icons.check_circle,
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

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAB308).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEAB308).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: const Color(0xFFEAB308),
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
} 
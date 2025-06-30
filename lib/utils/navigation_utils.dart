import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/business_dashboard_screen.dart';
import '../screens/seeker_home_screen.dart';
import '../screens/sign_in_screen.dart';
import '../screens/post_job_screen.dart';
import '../screens/home_screen.dart';
import '../widgets/fade_page_route.dart';
import '../providers/auth_provider.dart';
import '../constants/user_roles.dart';

class NavigationUtils {
  static void handleNavigation(String action, BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    switch (action) {
      case 'Home':
        // Already on home
        break;
      case 'ForBusiness':
        if (authProvider.isLoggedIn && authProvider.userRole == UserRole.poster) {
          // Logged in as business, go directly to business dashboard
          Navigator.of(context).push(FadePageRoute(
            page: const BusinessDashboardScreen(),
          ));
        } else {
          // Not logged in or wrong role, go to sign in with business role
          Navigator.of(context).push(FadePageRoute(
            page: const SignInScreen(preSelectedRole: UserRole.poster),
          ));
        }
        break;
      case 'For Workers':
        if (authProvider.isLoggedIn && authProvider.userRole == UserRole.seeker) {
          // Logged in as worker, go to find jobs
          Navigator.of(context).push(FadePageRoute(
            page: const SeekerHomeScreen(),
          ));
        } else {
          // Not logged in or wrong role, go to sign in with worker role
          Navigator.of(context).push(FadePageRoute(
            page: const SignInScreen(preSelectedRole: UserRole.seeker),
          ));
        }
        break;
      case 'Sign In':
        Navigator.of(context).push(FadePageRoute(
          page: const SignInScreen(),
        ));
        break;
      case 'Logout':
        authProvider.logout();
        // Navigate back to home screen (which will show LoginScreen)
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
        break;
    }
  }
  
  static void navigateToAddJob(BuildContext context) {
    Navigator.of(context).push(FadePageRoute(
      page: const PostJobScreen(),
    ));
  }
} 
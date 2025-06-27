import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/poster_home_screen.dart';
import '../screens/seeker_home_screen.dart';
import '../screens/sign_in_screen.dart';
import '../screens/add_job_screen.dart';
import '../screens/home_screen.dart';
import '../widgets/fade_page_route.dart';
import '../providers/auth_provider.dart';

class NavigationUtils {
  static void handleNavigation(String action, BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    switch (action) {
      case 'Home':
        // Already on home
        break;
      case 'ForBusiness':
        Navigator.of(context).push(FadePageRoute(
          page: const PosterHomeScreen(),
        ));
        break;
      case 'For Workers':
        Navigator.of(context).push(FadePageRoute(
          page: const SeekerHomeScreen(),
        ));
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
      page: const AddJobScreen(),
    ));
  }
} 
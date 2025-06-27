import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Check if user is signed in
        if (authProvider.isLoggedIn) {
          // After sign-in state
          return const DashboardScreen();
        } else {
          // Before sign-in state
          return const LoginScreen();
        }
      },
    );
  }
}


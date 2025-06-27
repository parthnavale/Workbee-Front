import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/job_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/home_screen.dart';

/// Flutter Job Portal App (Updated with Login, Role Separation, and Animation)
///
/// Features:
/// - Login for Job Posters and Job Seekers
/// - Separate flows and UIs for each role
/// - Professional UI with animated transitions
/// - Job posting and viewing functionality
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => JobProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WorkSwift',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        fontFamily: 'Montserrat',
      ),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
} 
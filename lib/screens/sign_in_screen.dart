import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/animated_scale_button.dart';
import '../widgets/fade_page_route.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../constants/user_roles.dart';
import '../constants/app_colors.dart';
import 'dashboard_screen.dart';
import 'sign_up_screen.dart';
import '../widgets/gradient_background.dart';
import '../widgets/loading_dialog.dart';
import '../core/services/fcm_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class SignInScreen extends StatefulWidget {
  final UserRole? preSelectedRole;

  const SignInScreen({super.key, this.preSelectedRole});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  UserRole? _selectedRole; // Track selected role
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.preSelectedRole ?? UserRole.seeker;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedRole == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select your role first'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      setState(() => _isLoading = true);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final role = _selectedRole!;
      try {
        final success = await authProvider.login(email, password, role);
        if (success) {
          // Update FCM token if user is a worker
          if (role == UserRole.seeker) {
            try {
              // Update FCM token using the FCM service
              await FCMService.updateFCMTokenForWorker(
                authProvider.workerId!,
                authProvider.accessToken!,
              );
            } catch (e) {
              print('Failed to update FCM token after login: $e');
            }
          }
          // Print FCM token if user is a business owner
          if (role == UserRole.poster) {
            try {
              String? token = await FirebaseMessaging.instance.getToken();
              print('[DEBUG] Business Owner FCM Token: ' + (token ?? 'null'));
              // Update FCM token for business owner
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              if (authProvider.businessOwnerId != null && authProvider.accessToken != null) {
                await FCMService.updateFCMTokenForBusinessOwner(
                  authProvider.businessOwnerId!,
                  authProvider.accessToken!,
                );
              } else {
                print('[DEBUG] Business owner ID or access token is null, cannot update FCM token');
              }
            } catch (e) {
              print('Failed to get or update FCM token for business owner: $e');
            }
          }
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Welcome back! You are logged in as ${role == UserRole.poster ? 'Business' : 'Worker'}',
                ),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
              FadePageRoute(page: const DashboardScreen()),
              (route) => false,
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Invalid credentials or user not registered.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('An error occurred: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
        backgroundColor: isDarkMode
            ? AppColors.backgroundSecondary
            : AppColors.lightBackgroundSecondary,
        foregroundColor: isDarkMode
            ? AppColors.textPrimary
            : AppColors.lightTextPrimary,
        elevation: 0,
      ),
      body: GradientBackground(
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo/Title
                      const SizedBox(height: 20),
                      Text(
                        'Welcome Back',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode
                              ? Colors.white
                              : AppColors.lightTextPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),

                      // Role Selection
                      Text(
                        'Select Your Role',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode
                              ? Colors.white
                              : AppColors.lightTextPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),

                      // Role Selection Buttons
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedRole = UserRole.poster;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: _selectedRole == UserRole.poster
                                      ? AppColors.primary
                                      : (isDarkMode
                                            ? AppColors.whiteWithAlpha(0.1)
                                            : AppColors
                                                  .lightBackgroundSecondary),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _selectedRole == UserRole.poster
                                        ? AppColors.primary
                                        : (isDarkMode
                                              ? Colors.grey
                                              : AppColors.lightBorderSecondary),
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.business_center,
                                      color: _selectedRole == UserRole.poster
                                          ? AppColors.primaryDark
                                          : AppColors.primary,
                                      size: 32,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Business',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: _selectedRole == UserRole.poster
                                            ? AppColors.primaryDark
                                            : (isDarkMode
                                                  ? Colors.white
                                                  : AppColors.lightTextPrimary),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedRole = UserRole.seeker;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: _selectedRole == UserRole.seeker
                                      ? AppColors.primary
                                      : (isDarkMode
                                            ? AppColors.whiteWithAlpha(0.1)
                                            : AppColors
                                                  .lightBackgroundSecondary),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _selectedRole == UserRole.seeker
                                        ? AppColors.primary
                                        : (isDarkMode
                                              ? Colors.grey
                                              : AppColors.lightBorderSecondary),
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.work,
                                      color: _selectedRole == UserRole.seeker
                                          ? AppColors.primaryDark
                                          : AppColors.primary,
                                      size: 32,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Worker',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: _selectedRole == UserRole.seeker
                                            ? AppColors.primaryDark
                                            : (isDarkMode
                                                  ? Colors.white
                                                  : AppColors.lightTextPrimary),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(
                          color: isDarkMode
                              ? Colors.white
                              : AppColors.lightTextPrimary,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(
                            color: isDarkMode
                                ? Colors.grey
                                : AppColors.lightTextSecondary,
                          ),
                          prefixIcon: Icon(
                            Icons.email,
                            color: isDarkMode
                                ? Colors.grey
                                : AppColors.lightTextSecondary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDarkMode
                                  ? Colors.grey
                                  : AppColors.lightBorderSecondary,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDarkMode
                                  ? Colors.grey
                                  : AppColors.lightBorderSecondary,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: isDarkMode
                              ? AppColors.whiteWithAlpha(0.1)
                              : AppColors.lightBackgroundSecondary,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Replace Password Field with PIN Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        style: TextStyle(
                          color: isDarkMode
                              ? Colors.white
                              : AppColors.lightTextPrimary,
                        ),
                        decoration: InputDecoration(
                          labelText: 'PIN',
                          labelStyle: TextStyle(
                            color: isDarkMode
                                ? Colors.grey
                                : AppColors.lightTextSecondary,
                          ),
                          prefixIcon: Icon(
                            Icons.pin,
                            color: isDarkMode
                                ? Colors.grey
                                : AppColors.lightTextSecondary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDarkMode
                                  ? Colors.grey
                                  : AppColors.lightBorderSecondary,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDarkMode
                                  ? Colors.grey
                                  : AppColors.lightBorderSecondary,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: isDarkMode
                              ? AppColors.whiteWithAlpha(0.1)
                              : AppColors.lightBackgroundSecondary,
                          counterText: '',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your PIN';
                          }
                          if (value.length != 6) {
                            return 'PIN must be 6 digits';
                          }
                          if (!RegExp(r'^[0-9]{6}$').hasMatch(value)) {
                            return 'PIN must contain only digits';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),

                      // Sign In Button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _signIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(200, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'Sign In',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                      const SizedBox(height: 20),

                      // Sign Up Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: TextStyle(
                              color: isDarkMode
                                  ? Colors.grey
                                  : AppColors.lightTextSecondary,
                              fontSize: 14,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const SignUpScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Forgot Password Link
                      TextButton(
                        onPressed: () {
                          // Handle forgot password
                        },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

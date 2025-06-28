import 'package:flutter/material.dart';
import '../widgets/animated_scale_button.dart';
import '../widgets/fade_page_route.dart';
import '../widgets/app_header.dart';
import '../widgets/gradient_background.dart';
import 'poster_home_screen.dart';
import 'seeker_home_screen.dart';
import 'sign_in_screen.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../constants/user_roles.dart';
import '../constants/app_colors.dart';
import '../utils/navigation_utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -0.2), 
      end: Offset.zero
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    return Scaffold(
      appBar: AppHeader(
        onNavigation: (action) => NavigationUtils.handleNavigation(action, context),
      ),
      body: GradientBackground(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                // App Logo/Title
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(
                          text: 'Find Workers\n',
                          style: TextStyle(color: isDarkMode ? Colors.white : AppColors.lightTextPrimary),
                        ),
                        TextSpan(
                          text: 'in 5 Minutes',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'India\'s Premier Job Portal',
                  style: TextStyle(
                    fontSize: 18,
                    color: isDarkMode ? Colors.grey[300] : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 40),
                // Description
                Text(
                  'Connect with verified workers and find the perfect job opportunities. '
                  'Whether you\'re hiring or seeking work, WorkBee makes it simple and secure.',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode ? Colors.grey[300] : AppColors.lightTextSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                // Statistics Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatistic('≤5 Min', 'Average Job\nFill Time', Icons.timer, isDarkMode),
                    _buildStatistic('24/7', 'Platform\nAvailability', Icons.access_time, isDarkMode),
                    _buildStatistic('100%', 'Verified\nWorkers', Icons.verified_user, isDarkMode),
                  ],
                ),
                const SizedBox(height: 40),
                // Action Buttons
                AnimatedScaleButton(
                  onTap: () {
                    final authProvider = Provider.of<AuthProvider>(context, listen: false);
                    
                    if (authProvider.isBusinessOwner()) {
                      // Already signed in as business, go to job posting
                      Navigator.of(context).push(FadePageRoute(
                        page: const PosterHomeScreen(),
                      ));
                    } else {
                      // Not signed in or signed in as worker, go to sign-in with business role
                      Navigator.of(context).push(FadePageRoute(
                        page: const SignInScreen(preSelectedRole: UserRole.poster),
                      ));
                    }
                  },
                  icon: Icons.add_business,
                  backgroundColor: AppColors.primary,
                  foregroundColor: isDarkMode ? AppColors.primaryDark : Colors.white,
                  minimumSize: const Size(250, 50),
                  child: const Text("Hire Workers"),
                  borderColor: AppColors.primary,
                ),
                const SizedBox(height: 20),
                AnimatedScaleButton(
                  onTap: () {
                    final authProvider = Provider.of<AuthProvider>(context, listen: false);
                    
                    if (authProvider.isWorker()) {
                      // Already signed in as worker, go to job search
                      Navigator.of(context).push(FadePageRoute(
                        page: const SeekerHomeScreen(),
                      ));
                    } else {
                      // Not signed in or signed in as business, go to sign-in with worker role
                      Navigator.of(context).push(FadePageRoute(
                        page: const SignInScreen(preSelectedRole: UserRole.seeker),
                      ));
                    }
                  },
                  icon: Icons.search,
                  backgroundColor: isDarkMode ? AppColors.backgroundSecondary : AppColors.lightBackgroundSecondary,
                  foregroundColor: isDarkMode ? Colors.white : AppColors.lightTextPrimary,
                  minimumSize: const Size(250, 50),
                  child: const Text("Find Work"),
                  borderColor: isDarkMode ? Colors.white : AppColors.lightBorderPrimary,
                ),
                const SizedBox(height: 60),
                // Why Choose Us Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                  decoration: BoxDecoration(
                    color: isDarkMode ? AppColors.backgroundSecondary : Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Why Choose Us?',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? AppColors.textPrimary : AppColors.lightTextPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Built for India's unique needs with cutting-edge technology and local insights",
                        style: TextStyle(
                          fontSize: 13,
                          color: isDarkMode ? AppColors.textSecondary : AppColors.lightTextSecondary,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),
                      // Features Grid
                      Column(
                        children: [
                          _buildFeatureCard(
                            'Lightning Fast',
                            'Jobs filled in 5 minutes or less with our smart matching system',
                            Icons.flash_on,
                            Colors.amberAccent,
                            isDarkMode,
                          ),
                          const SizedBox(height: 16),
                          _buildFeatureCard(
                            'Trust & Safety',
                            'Aadhaar-KYC, background-checked & rated by peers',
                            Icons.security,
                            Colors.blueAccent,
                            isDarkMode,
                          ),
                          const SizedBox(height: 16),
                          _buildFeatureCard(
                            'Work From Your City',
                            'No long drives, no extra allowances. Find work opportunities near you',
                            Icons.location_city,
                            Colors.green,
                            isDarkMode,
                          ),
                          const SizedBox(height: 16),
                          _buildFeatureCard(
                            'Instant Payments',
                            'No more cash hassles—instant UPI payout after shift',
                            Icons.payment,
                            Colors.deepPurpleAccent,
                            isDarkMode,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatistic(String value, String label, IconData icon, bool isDarkMode) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 40,
          color: isDarkMode ? Colors.white : AppColors.lightTextPrimary,
        ),
        const SizedBox(height: 10),
        Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            color: isDarkMode ? Colors.white : AppColors.lightTextPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: isDarkMode ? Colors.grey[300] : AppColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard(String title, String description, IconData icon, Color iconColor, bool isDarkMode) {
    return Column(
      children: [
        Icon(
          icon,
          size: 32,
          color: iconColor,
        ),
        const SizedBox(height: 6),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: isDarkMode ? AppColors.textPrimary : AppColors.lightTextPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          description,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: isDarkMode ? AppColors.textSecondary : AppColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }
} 
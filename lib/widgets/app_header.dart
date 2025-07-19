import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../constants/user_roles.dart';
import '../constants/app_colors.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final Function(String) onNavigation;
  final List<Widget>? actions;

  const AppHeader({
    super.key,
    required this.onNavigation,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final isLoggedIn = authProvider.isLoggedIn;
        final userRole = authProvider.userRole;
        
        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return AppBar(
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.flutter_dash,
                    color: Colors.amber,
                    size: 32,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'WorkBee',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              backgroundColor: themeProvider.isDarkMode 
                ? const Color(0xFF1E293B) 
                : const Color(0xFFF8FAFC),
              foregroundColor: themeProvider.isDarkMode ? Colors.white : const Color(0xFF1E293B),
              elevation: 0,
              actions: actions,
            );
          },
        );
      },
    );
  }
} 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../constants/user_roles.dart';
import '../constants/app_colors.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final Function(String) onNavigation;

  const AppHeader({
    super.key,
    required this.onNavigation,
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
              actions: [
                // Theme Toggle Button
                IconButton(
                  onPressed: () => themeProvider.toggleTheme(),
                  icon: Icon(
                    themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                    color: const Color(0xFFEAB308),
                  ),
                  tooltip: themeProvider.isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                ),
                Builder(
                  builder: (context) {
                    final isWide = MediaQuery.of(context).size.width > 600;
                    if (isWide) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () => onNavigation('Home'),
                            child: Text(
                              'Home',
                              style: TextStyle(
                                color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF1E293B), 
                                fontWeight: FontWeight.w500
                              ),
                            ),
                          ),
                          if (!isLoggedIn) ...[
                            TextButton(
                              onPressed: () => onNavigation('ForBusiness'),
                              child: Text(
                                'ForBusiness',
                                style: TextStyle(
                                  color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF1E293B), 
                                  fontWeight: FontWeight.w500
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => onNavigation('For Workers'),
                              child: Text(
                                'For Workers',
                                style: TextStyle(
                                  color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF1E293B), 
                                  fontWeight: FontWeight.w500
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => onNavigation('Sign In'),
                              style: TextButton.styleFrom(
                                backgroundColor: Color(0xFFEAB308),
                                foregroundColor: Color(0xFF10182B),
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(6)),
                                ),
                              ),
                              child: const Text(
                                '->] Sign In',
                                style: TextStyle(
                                  color: Color(0xFF10182B), 
                                  fontWeight: FontWeight.w500
                                ),
                              ),
                            ),
                          ] else if (userRole == UserRole.poster) ...[
                            TextButton(
                              onPressed: () => onNavigation('ForBusiness'),
                              child: const Text(
                                'Manage Jobs',
                                style: TextStyle(
                                  color: Colors.white, 
                                  fontWeight: FontWeight.w500
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => onNavigation('Logout'),
                              style: TextButton.styleFrom(
                                backgroundColor: AppColors.red.withOpacity(0.2),
                                foregroundColor: Colors.red,
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(6)),
                                ),
                              ),
                              child: const Text(
                                'Logout',
                                style: TextStyle(
                                  color: Colors.red, 
                                  fontWeight: FontWeight.w500
                                ),
                              ),
                            ),
                          ] else if (userRole == UserRole.seeker) ...[
                            TextButton(
                              onPressed: () => onNavigation('For Workers'),
                              child: const Text(
                                'Find Jobs',
                                style: TextStyle(
                                  color: Colors.white, 
                                  fontWeight: FontWeight.w500
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => onNavigation('Logout'),
                              style: TextButton.styleFrom(
                                backgroundColor: AppColors.red.withOpacity(0.2),
                                foregroundColor: Colors.red,
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(6)),
                                ),
                              ),
                              child: const Text(
                                'Logout',
                                style: TextStyle(
                                  color: Colors.red, 
                                  fontWeight: FontWeight.w500
                                ),
                              ),
                            ),
                          ],
                        ],
                      );
                    } else {
                      return PopupMenuButton<String>(
                        color: themeProvider.isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                        icon: Icon(Icons.more_vert, color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF1E293B)),
                        onSelected: onNavigation,
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'Home',
                            child: Text('Home', style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF1E293B))),
                          ),
                          if (!isLoggedIn) ...[
                            PopupMenuItem(
                              value: 'ForBusiness',
                              child: Text('ForBusiness', style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF1E293B))),
                            ),
                            PopupMenuItem(
                              value: 'For Workers',
                              child: Text('For Workers', style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF1E293B))),
                            ),
                            PopupMenuItem(
                              value: 'Sign In',
                              child: Text('->] Sign In', style: TextStyle(color: const Color(0xFFEAB308))),
                            ),
                          ] else if (userRole == UserRole.poster) ...[
                            PopupMenuItem(
                              value: 'ForBusiness',
                              child: Text('Manage Jobs', style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF1E293B))),
                            ),
                            PopupMenuItem(
                              value: 'Logout',
                              child: Text('Logout', style: TextStyle(color: themeProvider.isDarkMode ? Colors.red : Colors.red)),
                            ),
                          ] else if (userRole == UserRole.seeker) ...[
                            PopupMenuItem(
                              value: 'For Workers',
                              child: Text('Find Jobs', style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF1E293B))),
                            ),
                            PopupMenuItem(
                              value: 'Logout',
                              child: Text('Logout', style: TextStyle(color: themeProvider.isDarkMode ? Colors.red : Colors.red)),
                            ),
                          ],
                        ],
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
} 
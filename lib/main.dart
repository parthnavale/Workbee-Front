import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/job_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/notification_provider.dart';
import 'screens/home_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'constants/app_colors.dart';
import 'core/di/service_locator.dart';
import 'widgets/websocket_connection_widget.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';

/// Flutter Job Portal App (Updated with Login, Role Separation, and Animation)
///
/// Features:
/// - Login for Job Posters and Job Seekers
/// - Separate flows and UIs for each role
/// - Professional UI with animated transitions
/// - Job posting and viewing functionality
/// - Clean architecture with repository pattern
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final authProvider = AuthProvider();
  await authProvider.loadTokenAndRestoreSession();
  runApp(
    OverlaySupport.global(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => authProvider),
          ChangeNotifierProvider(create: (_) => JobProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _requireLocationService();
    _initFCM();
    _initLocalNotifications();
  }

  Future<void> _requireLocationService() async {
    Location location = Location();
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) serviceEnabled = await location.requestService();
    if (!serviceEnabled && mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Location Required'),
          content: const Text(
            'Location services must be enabled to use this app.',
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _requireLocationService();
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }
  }

  void _initLocalNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'default_channel',
          'Default',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
        );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title ?? 'New Notification',
      message.notification?.body ?? '',
      platformChannelSpecifics,
    );
  }

  Future<void> _initFCM() async {
    await FirebaseMessaging.instance.requestPermission();
    String? token = await FirebaseMessaging.instance.getToken();
    print('FCM Token: \x1B[32m$token\x1B[0m'); // Print in green for visibility
    // Send FCM token to backend if user is worker and logged in
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isWorker() &&
        authProvider.workerId != null &&
        token != null) {
      try {
        final url = Uri.parse(
          'https://myworkbee.duckdns.org/workers/${authProvider.workerId}/fcm-token',
        );
        await http.put(
          url,
          body: token,
          headers: {'Content-Type': 'text/plain'},
        );
        print('FCM token sent to backend for worker ${authProvider.workerId}');
      } catch (e) {
        print('Failed to send FCM token to backend: $e');
      }
    }
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print(
        'Received FCM message in foreground: \x1B[33m"+(message.notification?.title ?? '
        ')+" - "+(message.notification?.body ?? '
        ')+"\x1B[0m',
      );
      _showLocalNotification(message);
      // Add to notification provider (inbox)
      final notificationProvider = Provider.of<NotificationProvider>(
        context,
        listen: false,
      );
      notificationProvider.addNotificationFromFCM(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            // Initialize service locator with auth provider
            WidgetsBinding.instance.addPostFrameCallback((_) {
              serviceLocator.initialize(authProvider: authProvider);
            });

            return MaterialApp(
              title: 'WorkSwift',
              theme: _buildTheme(themeProvider.isDarkMode),
              debugShowCheckedModeBanner: false,
              home: WebSocketConnectionWidget(
                child: authProvider.isLoggedIn
                    ? DashboardScreen()
                    : LoginScreen(),
              ),
            );
          },
        );
      },
    );
  }

  ThemeData _buildTheme(bool isDarkMode) {
    if (isDarkMode) {
      return ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.indigo,
        fontFamily: 'Montserrat',
        scaffoldBackgroundColor: AppColors.backgroundPrimary,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.backgroundSecondary,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColors.textPrimary),
          bodyMedium: TextStyle(color: AppColors.textPrimary),
          bodySmall: TextStyle(color: AppColors.textSecondary),
          titleLarge: TextStyle(color: AppColors.textPrimary),
          titleMedium: TextStyle(color: AppColors.textPrimary),
          titleSmall: TextStyle(color: AppColors.textPrimary),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.backgroundSecondary,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.borderSecondary),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.borderSecondary),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.borderPrimary),
          ),
          labelStyle: const TextStyle(color: AppColors.textSecondary),
          hintStyle: const TextStyle(color: AppColors.textSecondary),
        ),
      );
    } else {
      return ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.indigo,
        fontFamily: 'Montserrat',
        scaffoldBackgroundColor: AppColors.lightBackgroundPrimary,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.lightBackgroundSecondary,
          foregroundColor: AppColors.lightTextPrimary,
          elevation: 0,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColors.lightTextPrimary),
          bodyMedium: TextStyle(color: AppColors.lightTextPrimary),
          bodySmall: TextStyle(color: AppColors.lightTextSecondary),
          titleLarge: TextStyle(color: AppColors.lightTextPrimary),
          titleMedium: TextStyle(color: AppColors.lightTextPrimary),
          titleSmall: TextStyle(color: AppColors.lightTextPrimary),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.lightBackgroundSecondary,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.lightBorderSecondary),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.lightBorderSecondary),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.lightBorderPrimary),
          ),
          labelStyle: const TextStyle(color: AppColors.lightTextSecondary),
          hintStyle: const TextStyle(color: AppColors.lightTextSecondary),
        ),
      );
    }
  }
}

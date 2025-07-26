import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/user_roles.dart';
import '../core/config/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'notification_provider.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  UserRole? _userRole;
  String? _userName;
  int? _userId;
  String? _accessToken;
  int? _businessOwnerId;
  int? _workerId;
  String? _workerName;
  String? _workerEmail;
  int? _workerYearsOfExperience;
  List<Map<String, dynamic>> _notifications = [];

  bool get isLoggedIn => _isLoggedIn;
  UserRole? get userRole => _userRole;
  String? get userName => _userName;
  int? get userId => _userId;
  String? get accessToken => _accessToken;
  int? get businessOwnerId => _businessOwnerId;
  int? get workerId => _workerId;
  String? get workerName => _workerName;
  String? get workerEmail => _workerEmail;
  int? get workerYearsOfExperience => _workerYearsOfExperience;
  int get unreadNotificationCount =>
      _notifications.where((n) => n['is_read'] == false).length;
  List<Map<String, dynamic>> get notifications => _notifications;

  Future<bool> login(String email, String password, UserRole role) async {
    try {
      final url = Uri.parse(AppConfig.getApiUrl("/users/login"));
      final response = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: json.encode({"email": email, "password": password}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _isLoggedIn = true;
        _userRole = role;
        _userName = data["username"] ?? email;
        _userId = data["id"];
        _accessToken = data["access_token"];
        await saveToken(_accessToken!); // Save token after login
        // Fetch business owner profile if role is poster
        if (_userRole == UserRole.poster) {
          await fetchBusinessOwnerProfile();
        } else {
          _businessOwnerId = null;
        }
        // Fetch worker profile if role is seeker
        if (_userRole == UserRole.seeker) {
          await fetchWorkerProfile();
          // Connect to WebSocket for real-time notifications
          _connectToWebSocket();
        } else {
          _workerId = null;
        }
        notifyListeners();
        return true;
      } else {
        _isLoggedIn = false;
        _userRole = null;
        _userName = null;
        _userId = null;
        _accessToken = null;
        _businessOwnerId = null;
        _workerId = null;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoggedIn = false;
      _userRole = null;
      _userName = null;
      _userId = null;
      _accessToken = null;
      _businessOwnerId = null;
      _workerId = null;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchBusinessOwnerProfile() async {
    if (_userId == null) return;
    final url = Uri.parse(AppConfig.getApiUrl("/business-owners/"));
    final headers = {
      "Content-Type": "application/json",
      if (_accessToken != null) "Authorization": "Bearer $_accessToken",
    };
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      // Find the business owner profile for this user
      final owner = data.firstWhere(
        (o) => o["user_id"] == _userId,
        orElse: () => null,
      );
      if (owner != null) {
        _businessOwnerId = owner["id"];
      }
    }
  }

  Future<void> fetchWorkerProfile() async {
    if (_userId == null) return;
    final url = Uri.parse(AppConfig.getApiUrl("/workers/"));
    final headers = {
      "Content-Type": "application/json",
      if (_accessToken != null) "Authorization": "Bearer $_accessToken",
    };
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      // Find the worker profile for this user
      final worker = data.firstWhere(
        (w) => w["user_id"] == _userId,
        orElse: () => null,
      );
      if (worker != null) {
        _workerId = worker["id"];
        _workerName = worker["name"];
        _workerEmail = worker["email"];
        _workerYearsOfExperience = worker["years_of_experience"];
      }
    }
  }

  Future<bool> register(
    String username,
    String email,
    String password,
    UserRole role,
  ) async {
    try {
      final url = Uri.parse(AppConfig.getApiUrl("/users/register"));
      final response = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: json.encode({
              "username": username,
              "email": email,
              "password": password,
              "role": role == UserRole.poster ? "poster" : "seeker",
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _isLoggedIn = true;
        _userRole = role;
        _userName = data["username"];
        _userId = data["id"];
        notifyListeners();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // Call this after successful login
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
  }

  // Call this on app startup
  Future<void> loadTokenAndRestoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token != null) {
      _accessToken = token;
      // Optionally, fetch user profile to validate token and set user state
      await fetchUserProfileFromToken(token);
      notifyListeners();
    }
  }

  // Connect to WebSocket for notifications
  void _connectToWebSocket() {
    if (_workerId != null) {
      // This will be called from the UI context where Provider is available
      // The actual connection will be handled in the UI layer
    }
  }

  // Remove token on logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    _isLoggedIn = false;
    _userRole = null;
    _userName = null;
    _userId = null;
    _accessToken = null;
    _businessOwnerId = null;
    _workerId = null;
    notifyListeners();
  }

  // Fetch user profile using the token (optional, for restoring session)
  Future<void> fetchUserProfileFromToken(String token) async {
    try {
      final url = Uri.parse(AppConfig.getApiUrl('/users/me'));
      final response = await http.get(
        url,
        headers: {"Authorization": "Bearer $token"},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _isLoggedIn = true;
        _userName = data["username"];
        _userId = data["id"];
        _userRole = data["role"] == "poster"
            ? UserRole.poster
            : UserRole.seeker;
        if (_userRole == UserRole.poster) {
          await fetchBusinessOwnerProfile();
        } else if (_userRole == UserRole.seeker) {
          await fetchWorkerProfile();
          // Connect to WebSocket for real-time notifications
          _connectToWebSocket();
        }
      } else {
        // Token invalid or expired
        await logout();
      }
    } catch (e) {
      await logout();
    }
  }

  bool isBusinessOwner() {
    return _isLoggedIn && _userRole == UserRole.poster;
  }

  bool isWorker() {
    return _isLoggedIn && _userRole == UserRole.seeker;
  }

  Future<void> fetchNotifications() async {
    if (_workerId == null) return;
    try {
      final url = Uri.parse(AppConfig.getApiUrl('/notifications/$_workerId'));
      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          _notifications = List<Map<String, dynamic>>.from(data);
          notifyListeners();
        }
      }
    } catch (e) {
      // ignore errors for now
    }
  }

  Future<void> markNotificationsRead(List<int> notificationIds) async {
    try {
      final url = Uri.parse(AppConfig.getApiUrl('/notifications/mark_read'));
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({"notification_ids": notificationIds}),
      );
      if (response.statusCode == 200) {
        for (final n in _notifications) {
          if (notificationIds.contains(n['id'])) n['is_read'] = true;
        }
        notifyListeners();
      }
    } catch (e) {}
  }
}

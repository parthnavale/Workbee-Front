import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/user_roles.dart';
import '../core/config/app_config.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  UserRole? _userRole;
  String? _userName;
  int? _userId;
  String? _accessToken;
  int? _businessOwnerId;
  int? _workerId;

  bool get isLoggedIn => _isLoggedIn;
  UserRole? get userRole => _userRole;
  String? get userName => _userName;
  int? get userId => _userId;
  String? get accessToken => _accessToken;
  int? get businessOwnerId => _businessOwnerId;
  int? get workerId => _workerId;

  Future<bool> login(String email, String password, UserRole role) async {
    try {
      final url = Uri.parse(AppConfig.getApiUrl("/users/login"));
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "email": email,
          "password": password,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _isLoggedIn = true;
        _userRole = role;
        _userName = data["username"] ?? email;
        _userId = data["id"];
        _accessToken = data["access_token"];
        // Fetch business owner profile if role is poster
        if (_userRole == UserRole.poster) {
          await fetchBusinessOwnerProfile();
        } else {
          _businessOwnerId = null;
        }
        // Fetch worker profile if role is seeker
        if (_userRole == UserRole.seeker) {
          await fetchWorkerProfile();
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
      }
    }
  }

  Future<bool> register(String username, String email, String password, UserRole role) async {
    try {
      final url = Uri.parse(AppConfig.getApiUrl("/users/register"));
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "username": username,
          "email": email,
          "password": password,
          "role": role == UserRole.poster ? "poster" : "seeker"
        }),
      ).timeout(const Duration(seconds: 30));

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

  void logout() {
    _isLoggedIn = false;
    _userRole = null;
    _userName = null;
    _userId = null;
    _accessToken = null;
    _businessOwnerId = null;
    _workerId = null;
    notifyListeners();
  }

  bool isBusinessOwner() {
    return _isLoggedIn && _userRole == UserRole.poster;
  }

  bool isWorker() {
    return _isLoggedIn && _userRole == UserRole.seeker;
  }
} 
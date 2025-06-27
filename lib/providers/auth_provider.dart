import 'package:flutter/foundation.dart';
import '../constants/user_roles.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  UserRole? _userRole;
  String? _userName;

  bool get isLoggedIn => _isLoggedIn;
  UserRole? get userRole => _userRole;
  String? get userName => _userName;

  void loginAsBusinessOwner(String name) {
    _isLoggedIn = true;
    _userRole = UserRole.poster;
    _userName = name;
    notifyListeners();
  }

  void loginAsWorker(String name) {
    _isLoggedIn = true;
    _userRole = UserRole.seeker;
    _userName = name;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _userRole = null;
    _userName = null;
    notifyListeners();
  }

  bool isBusinessOwner() {
    return _isLoggedIn && _userRole == UserRole.poster;
  }

  bool isWorker() {
    return _isLoggedIn && _userRole == UserRole.seeker;
  }
} 
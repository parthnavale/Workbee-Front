import 'package:flutter/material.dart';
import 'dart:convert';
import '../core/services/notification_ws_service.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationWebSocketService _wsService = NotificationWebSocketService();
  

  List<Map<String, dynamic>> _notifications = [];
  bool _isConnected = false;
  bool _isConnecting = false;
  String? _lastError;

  // Getters
  List<Map<String, dynamic>> get notifications => _notifications;
  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;
  String? get lastError => _lastError;
  int get unreadCount => _notifications.where((n) => n['is_read'] == false).length;

  NotificationProvider() {
    _initializeWebSocket();
  }

  void _initializeWebSocket() {
    _wsService.initialize();
    
    // Listen to connection status changes
    _wsService.connectionStatusStream.listen((isConnected) {
      _isConnected = isConnected;
      _isConnecting = false;
      _lastError = null;
      notifyListeners();
    });

    // Listen to incoming messages
    _wsService.messageStream.listen((message) {
      _handleIncomingMessage(message);
    });
  }

  void _handleIncomingMessage(String message) {
    try {
      final data = json.decode(message);
      if (data is Map<String, dynamic>) {
        // Add timestamp if not present
        if (!data.containsKey('timestamp')) {
          data['timestamp'] = DateTime.now().toIso8601String();
        }
        
        // Add ID if not present
        if (!data.containsKey('id')) {
          data['id'] = DateTime.now().millisecondsSinceEpoch;
        }
        
        // Mark as unread by default
        data['is_read'] = false;
        
        // Add to notifications list
        _notifications.insert(0, data);
        notifyListeners();
      }
    } catch (e) {
      // Handle as plain text message
      _notifications.insert(0, {
        'id': DateTime.now().millisecondsSinceEpoch,
        'title': 'New Message',
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
        'is_read': false,
      });
      notifyListeners();
    }
  }

  void connect(int workerId) {
    if (_isConnecting) return;
    
    _isConnecting = true;
    _lastError = null;
    notifyListeners();
    
    _wsService.connect(workerId);
  }

  void disconnect() {
    _wsService.disconnect();
    _isConnected = false;
    _isConnecting = false;
    notifyListeners();
  }

  void clearNotifications() {
    _notifications.clear();
    notifyListeners();
  }

  void markAsRead(int notificationId) {
    final index = _notifications.indexWhere((n) => n['id'] == notificationId);
    if (index != -1) {
      _notifications[index]['is_read'] = true;
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (final notification in _notifications) {
      notification['is_read'] = true;
    }
    notifyListeners();
  }

  void removeNotification(int notificationId) {
    _notifications.removeWhere((n) => n['id'] == notificationId);
    notifyListeners();
  }



  @override
  void dispose() {
    _wsService.dispose();
    super.dispose();
  }
} 
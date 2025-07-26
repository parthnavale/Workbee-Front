import 'package:flutter/material.dart';
import 'dart:convert';
import '../core/services/notification_ws_service.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationWebSocketService _wsService =
      NotificationWebSocketService();

  List<Map<String, dynamic>> _notifications = [];
  bool _isConnected = false;
  bool _isConnecting = false;
  String? _lastError;

  // Getters
  List<Map<String, dynamic>> get notifications => _notifications;
  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;
  String? get lastError => _lastError;
  int get unreadCount =>
      _notifications.where((n) => n['is_read'] == false).length;

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
      dynamic data = json.decode(message);
      // Handle double-encoded JSON
      if (data is String) {
        try {
          data = json.decode(data);
        } catch (e) {
          // ignore
        }
      }
      if (data is Map<String, dynamic>) {
        if (!data.containsKey('timestamp')) {
          data['timestamp'] = DateTime.now().toIso8601String();
        }
        if (!data.containsKey('id')) {
          data['id'] = DateTime.now().millisecondsSinceEpoch;
        }
        data['is_read'] = false;
        try {
          _notifications.insert(0, data);
        } catch (e) {}
        try {
          showSimpleNotification(
            Text(
              data['message'] ?? 'New notification',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            background: Colors.green,
            autoDismiss: true,
            slideDismiss: true,
            duration: const Duration(seconds: 4),
            leading: const Icon(Icons.notifications, color: Colors.white),
          );
        } catch (e) {}
        notifyListeners();
      } else {
        try {
          _notifications.insert(0, {
            'id': DateTime.now().millisecondsSinceEpoch,
            'title': 'New Message',
            'message': message,
            'timestamp': DateTime.now().toIso8601String(),
            'is_read': false,
          });
        } catch (e) {}
        try {
          showSimpleNotification(
            Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
            background: Colors.green,
            autoDismiss: true,
            slideDismiss: true,
            duration: const Duration(seconds: 4),
            leading: const Icon(Icons.notifications, color: Colors.white),
          );
        } catch (e) {}
        notifyListeners();
      }
    } catch (e) {
      try {
        _notifications.insert(0, {
          'id': DateTime.now().millisecondsSinceEpoch,
          'title': 'New Message',
          'message': message,
          'timestamp': DateTime.now().toIso8601String(),
          'is_read': false,
        });
      } catch (e) {}
      try {
        showSimpleNotification(
          Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
          background: Colors.green,
          autoDismiss: true,
          slideDismiss: true,
          duration: const Duration(seconds: 4),
          leading: const Icon(Icons.notifications, color: Colors.white),
        );
      } catch (e) {}
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

  void addNotificationFromFCM(RemoteMessage message) {
    final data = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'title': message.notification?.title ?? 'Notification',
      'message': message.notification?.body ?? '',
      'timestamp': DateTime.now().toIso8601String(),
      'is_read': false,
    };
    _notifications.insert(0, data);
    notifyListeners();
  }

  @override
  void dispose() {
    _wsService.dispose();
    super.dispose();
  }
}

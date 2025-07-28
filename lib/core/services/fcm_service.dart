import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  /// Print current FCM token for testing
  static Future<void> printFCMToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        print('🔥 FCM Token: $token');
        print('📋 Copy this token for testing FCM notifications');
      } else {
        print('❌ No FCM token available');
      }
    } catch (e) {
      print('❌ Failed to get FCM token: $e');
    }
  }

  /// Update FCM token for a worker
  static Future<void> updateFCMTokenForWorker(int workerId, String accessToken) async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        // Print FCM token for testing
        print('🔥 FCM Token: $token');
        print('📱 Worker ID: $workerId');
        
        final url = Uri.parse('https://myworkbee.duckdns.org/workers/$workerId/fcm-token');
        final response = await http.put(
          url,
          body: token,
          headers: {
            'Content-Type': 'text/plain',
            'Authorization': 'Bearer $accessToken',
          },
        );
        
        if (response.statusCode == 200) {
          print('✅ FCM token sent to backend successfully for worker $workerId');
        } else {
          print('❌ Failed to send FCM token to backend. Status: ${response.statusCode}');
        }
      } else {
        print('❌ No FCM token available');
      }
    } catch (e) {
      print('❌ Failed to send FCM token to backend: $e');
    }
  }

  /// Update FCM token for a business owner
  static Future<void> updateFCMTokenForBusinessOwner(int ownerId, String accessToken) async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        print('🔥 FCM Token (Business Owner): $token');
        print('🏢 Business Owner ID: $ownerId');

        final url = Uri.parse('https://myworkbee.duckdns.org/business-owners/$ownerId/fcm-token');
        final response = await http.put(
          url,
          body: '{"fcm_token": "$token"}',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        );

        if (response.statusCode == 200) {
          print('✅ FCM token sent to backend successfully for business owner $ownerId');
        } else {
          print('❌ Failed to send FCM token to backend. Status: ${response.statusCode}');
        }
      } else {
        print('❌ No FCM token available');
      }
    } catch (e) {
      print('❌ Failed to send FCM token to backend: $e');
    }
  }
} 
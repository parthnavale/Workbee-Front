import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

/// API Service for communicating with the FastAPI backend
class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Generic GET request
  Future<dynamic> get(String endpoint) async {
    try {
      final response = await _client.get(
        Uri.parse(AppConfig.getApiUrl(endpoint)),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(AppConfig.getConnectionTimeout());

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Generic POST request
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _client.post(
        Uri.parse(AppConfig.getApiUrl(endpoint)),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      ).timeout(AppConfig.getConnectionTimeout());

      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Generic DELETE request
  Future<void> delete(String endpoint) async {
    try {
      final response = await _client.delete(
        Uri.parse(AppConfig.getApiUrl(endpoint)),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(AppConfig.getConnectionTimeout());

      if (response.statusCode != 200) {
        throw Exception('Failed to delete data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Get all jobs from the API
  Future<List<Map<String, dynamic>>> getJobs() async {
    final response = await get(AppConfig.jobsEndpoint);

    if (response is List) {
      // Only keep items that are Map<String, dynamic>
      return response
          .whereType<Map<String, dynamic>>()
          .toList();
    } else if (response is Map<String, dynamic>) {
      // Single job as a map
      return [response];
    }
    // Not a list or map
    return [];
  }

  /// Get a specific job by ID
  Future<Map<String, dynamic>?> getJobById(int jobId) async {
    try {
      final response = await get('${AppConfig.jobsEndpoint}/$jobId');
      if (response is Map<String, dynamic>) {
        return response;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Create a new job
  Future<void> createJob(Map<String, dynamic> jobData) async {
    await post(AppConfig.jobsEndpoint, jobData);
  }

  /// Create a new business owner
  Future<void> createBusinessOwner(Map<String, dynamic> ownerData) async {
    await post(AppConfig.businessOwnersEndpoint, ownerData);
  }

  /// Get a business owner by ID
  Future<Map<String, dynamic>?> getBusinessOwnerById(int ownerId) async {
    try {
      final response = await get('${AppConfig.businessOwnersEndpoint}/$ownerId');
      if (response is Map<String, dynamic>) {
        return response;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Create a new worker
  Future<void> createWorker(Map<String, dynamic> workerData) async {
    await post(AppConfig.workersEndpoint, workerData);
  }

  /// Get a worker by ID
  Future<Map<String, dynamic>?> getWorkerById(int workerId) async {
    try {
      final response = await get('${AppConfig.workersEndpoint}/$workerId');
      if (response is Map<String, dynamic>) {
        return response;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Create a new subscription
  Future<void> createSubscription(Map<String, dynamic> subscriptionData) async {
    await post(AppConfig.subscriptionsEndpoint, subscriptionData);
  }

  /// Get a subscription by ID
  Future<Map<String, dynamic>?> getSubscriptionById(int subscriptionId) async {
    try {
      final response = await get('${AppConfig.subscriptionsEndpoint}/$subscriptionId');
      if (response is Map<String, dynamic>) {
        return response;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Create a new user
  Future<void> createUser(Map<String, dynamic> userData) async {
    await post(AppConfig.usersEndpoint, userData);
  }

  /// Get a user by ID
  Future<Map<String, dynamic>?> getUserById(int userId) async {
    try {
      final response = await get('${AppConfig.usersEndpoint}/$userId');
      if (response is Map<String, dynamic>) {
        return response;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Delete a user
  Future<void> deleteUser(int userId) async {
    await delete('${AppConfig.usersEndpoint}/$userId');
  }

  /// Create a new post
  Future<void> createPost(Map<String, dynamic> postData) async {
    await post(AppConfig.postsEndpoint, postData);
  }

  /// Get a post by ID
  Future<Map<String, dynamic>?> getPostById(int postId) async {
    try {
      final response = await get('${AppConfig.postsEndpoint}/$postId');
      if (response is Map<String, dynamic>) {
        return response;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Delete a post
  Future<void> deletePost(int postId) async {
    await delete('${AppConfig.postsEndpoint}/$postId');
  }

  void dispose() {
    _client.close();
  }
} 
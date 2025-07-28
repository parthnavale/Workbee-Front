import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../../providers/auth_provider.dart';

/// API Service for communicating with the FastAPI backend
class ApiService {
  final http.Client _client;
  final AuthProvider? _authProvider;

  ApiService({http.Client? client, AuthProvider? authProvider})
    : _client = client ?? http.Client(),
      _authProvider = authProvider;

  // Add this private helper for headers
  Map<String, String> _buildHeaders() {
    final headers = {'Content-Type': 'application/json'};
    if (_authProvider?.accessToken != null) {
      headers['Authorization'] = 'Bearer ${_authProvider!.accessToken}';
    }
    return headers;
  }

  // Add this private error handler
  Exception _handleHttpError(http.Response response) {
    return Exception('HTTP ${response.statusCode}: ${response.body}');
  }

  /// Generic GET request
  Future<dynamic> get(String endpoint) async {
    try {
      final url = AppConfig.getApiUrl(endpoint);
      final response = await _client
          .get(Uri.parse(url), headers: _buildHeaders())
          .timeout(AppConfig.getConnectionTimeout());
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw _handleHttpError(response);
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Generic POST request
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client
          .post(
            Uri.parse(AppConfig.getApiUrl(endpoint)),
            headers: _buildHeaders(),
            body: json.encode(data),
          )
          .timeout(AppConfig.getConnectionTimeout());
      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw _handleHttpError(response);
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Generic PUT request
  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client
          .put(
            Uri.parse(AppConfig.getApiUrl(endpoint)),
            headers: _buildHeaders(),
            body: json.encode(data),
          )
          .timeout(AppConfig.getConnectionTimeout());
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw _handleHttpError(response);
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Generic DELETE request
  Future<void> delete(String endpoint) async {
    try {
      final response = await _client
          .delete(
            Uri.parse(AppConfig.getApiUrl(endpoint)),
            headers: _buildHeaders(),
          )
          .timeout(AppConfig.getConnectionTimeout());
      if (response.statusCode != 200) {
        throw _handleHttpError(response);
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
      return response.whereType<Map<String, dynamic>>().toList();
    } else if (response is Map<String, dynamic>) {
      // Single job as a map
      return [response];
    }
    // Not a list or map
    return [];
  }

  /// Get jobs by business owner ID from the API
  Future<List<Map<String, dynamic>>> getJobsByBusiness(
    String businessId,
  ) async {
    final endpoint = '${AppConfig.jobsEndpoint}?business_owner_id=$businessId';
    final response = await get(endpoint);

    if (response is List) {
      // Only keep items that are Map<String, dynamic>
      return response.whereType<Map<String, dynamic>>().toList();
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
      // Remove trailing slash from jobsEndpoint if it exists
      final endpoint = AppConfig.jobsEndpoint.endsWith('/')
          ? '${AppConfig.jobsEndpoint.substring(0, AppConfig.jobsEndpoint.length - 1)}/$jobId'
          : '${AppConfig.jobsEndpoint}/$jobId';

      final response = await get(endpoint);
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
      final response = await get(
        '${AppConfig.businessOwnersEndpoint}/$ownerId',
      );
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
      // Avoid double slash
      final response = await get('${AppConfig.workersEndpoint}$workerId');
      if (response is Map<String, dynamic>) {
        return response;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Create a new job application
  Future<void> createApplication(Map<String, dynamic> applicationData) async {
    try {
      final url = AppConfig.getApiUrl(AppConfig.applicationsEndpoint);
      print('[DEBUG] Job Application Request URL: $url');
      print('[DEBUG] Job Application Request Body: $applicationData');
      final response = await _client
          .post(
            Uri.parse(url),
            headers: _buildHeaders(),
            body: json.encode(applicationData),
          )
          .timeout(AppConfig.getConnectionTimeout());
      print('[DEBUG] Job Application Response Status: ${response.statusCode}');
      print('[DEBUG] Job Application Response Headers: ${response.headers}');
      print('[DEBUG] Job Application Response Body: ${response.body}');
      if (response.statusCode != 201 && response.statusCode != 200) {
        throw _handleHttpError(response);
      }
    } catch (e) {
      print('[ERROR] Exception in createApplication: $e');
      rethrow;
    }
  }

  /// Get an application by ID
  Future<Map<String, dynamic>?> getApplicationById(int applicationId) async {
    try {
      final response = await get(
        '${AppConfig.applicationsEndpoint}/$applicationId',
      );
      if (response is Map<String, dynamic>) {
        return response;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get all applications
  Future<List<Map<String, dynamic>>> getApplications() async {
    final response = await get(AppConfig.applicationsEndpoint);

    if (response is List) {
      return response.whereType<Map<String, dynamic>>().toList();
    } else if (response is Map<String, dynamic>) {
      return [response];
    }
    return [];
  }

  /// Get applications by job ID from the API
  Future<List<Map<String, dynamic>>> getApplicationsByJob(String jobId) async {
    print('[DEBUG] getApplicationsByJob called with jobId: $jobId');
    final base = AppConfig.applicationsEndpoint;
    final endpoint = base.endsWith('/')
        ? '${base}job/$jobId'
        : '$base/job/$jobId';
    print('[DEBUG] Making API call to: $endpoint');
    
    final response = await get(endpoint);
    print('[DEBUG] API response type: ${response.runtimeType}');
    print('[DEBUG] API response: $response');

    if (response is List) {
      final result = response.whereType<Map<String, dynamic>>().toList();
      print('[DEBUG] Parsed ${result.length} applications from list response');
      return result;
    } else if (response is Map<String, dynamic>) {
      print('[DEBUG] Parsed 1 application from map response');
      return [response];
    }
    print('[DEBUG] No valid response format, returning empty list');
    return [];
  }

  /// Get applications by worker ID from the API
  Future<List<Map<String, dynamic>>> getApplicationsByWorker(
    String workerId,
  ) async {
    print('[DEBUG] ApiService.getApplicationsByWorker called with workerId: $workerId');
    final endpoint = '${AppConfig.applicationsEndpoint}?worker_id=$workerId';
    print('[DEBUG] ApiService.getApplicationsByWorker: endpoint = $endpoint');
    final response = await get(endpoint);
    print('[DEBUG] ApiService.getApplicationsByWorker: response = $response');
    if (response is List) {
      return response.whereType<Map<String, dynamic>>().toList();
    } else if (response is Map<String, dynamic>) {
      return [response];
    }
    return [];
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

  /// Update a job
  Future<void> updateJob(int jobId, Map<String, dynamic> jobData) async {
    await put('${AppConfig.jobsEndpoint}/$jobId', jobData);
  }

  /// Delete a job
  Future<void> deleteJob(int jobId) async {
    await delete('${AppConfig.jobsEndpoint}/$jobId');
  }

  /// Update a business owner
  Future<void> updateBusinessOwner(
    int ownerId,
    Map<String, dynamic> ownerData,
  ) async {
    await put('${AppConfig.businessOwnersEndpoint}/$ownerId', ownerData);
  }

  /// Delete a business owner
  Future<void> deleteBusinessOwner(int ownerId) async {
    await delete('${AppConfig.businessOwnersEndpoint}/$ownerId');
  }

  /// Update a worker
  Future<void> updateWorker(
    int workerId,
    Map<String, dynamic> workerData,
  ) async {
    await put('${AppConfig.workersEndpoint}$workerId', workerData);
  }

  /// Delete a worker
  Future<void> deleteWorker(int workerId) async {
    await delete('${AppConfig.workersEndpoint}/$workerId');
  }

  /// Update an application
  Future<void> updateApplication(
    int applicationId,
    Map<String, dynamic> applicationData,
  ) async {
    await put(
      '${AppConfig.applicationsEndpoint}$applicationId',
      applicationData,
    );
  }

  /// Delete an application
  Future<void> deleteApplication(int applicationId) async {
    await delete('${AppConfig.applicationsEndpoint}/$applicationId');
  }

  /// Batch fetch jobs by a list of job IDs
  Future<List<Map<String, dynamic>>> getJobsByIds(List<String> jobIds) async {
    if (jobIds.isEmpty) return [];
    final endpoint = '/jobs/batch';
    final body = {"job_ids": jobIds.map((id) => int.parse(id)).toList()};
    try {
      final response = await post(endpoint, body);
      if (response is List) {
        return (response as List).map<Map<String, dynamic>>((e) {
          if (e is Map<String, dynamic>) {
            return e;
          } else if (e is Map) {
            return Map<String, dynamic>.from(e);
          } else {
            print('[DEBUG] Unexpected item type in response: ${e.runtimeType}');
            return <String, dynamic>{};
          }
        }).toList();
      } else if (response is Map<String, dynamic>) {
        return [response];
      } else if (response is Map) {
        return [Map<String, dynamic>.from(response)];
      }
      return [];
    } catch (e) {
      print('[DEBUG] getJobsByIds error: $e');
      return [];
    }
  }

  void dispose() {
    _client.close();
  }
}

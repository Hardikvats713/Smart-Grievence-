import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

/// Standardized REST API response envelope from `/api/v1/`.
class ApiResponse<T> {
  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.statusCode = 200,
  });

  final bool success;
  final String message;
  final T? data;
  final int statusCode;
}

/// Centralized HTTP client handling JWT injection and envelope parsing.
class ApiClient {
  static const _tokenKey = 'sg_access_token';
  static const _refreshTokenKey = 'sg_refresh_token';
  static const _userRoleKey = 'sg_active_role';
  static const _userRolesListKey = 'sg_user_roles';
  static const _userDeptKey = 'sg_department_id';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<String> getActiveRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userRoleKey) ?? 'CITIZEN';
  }

  static Future<List<String>> getRoles() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_userRolesListKey) ?? [await getActiveRole()];
  }

  static Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required String activeRole,
    List<String> roles = const ['CITIZEN'],
    String? departmentId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
    await prefs.setString(_userRoleKey, activeRole);
    await prefs.setStringList(_userRolesListKey, roles);
    if (departmentId != null) {
      await prefs.setString(_userDeptKey, departmentId);
    }
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userRoleKey);
    await prefs.remove(_userRolesListKey);
    await prefs.remove(_userDeptKey);
  }

  static Future<Map<String, String>> _buildHeaders({bool includeAuth = true}) async {
    String? token;
    if (includeAuth) {
      token = await getToken();
    }
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  static Future<ApiResponse<dynamic>> get(String endpoint) async {
    try {
      final headers = await _buildHeaders();
      final uri = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 10));
      return _parseResponse(response);
    } catch (e) {
      return ApiResponse(success: false, message: 'Network error: $e', statusCode: 503);
    }
  }

  static Future<ApiResponse<dynamic>> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool includeAuth = true,
  }) async {
    try {
      final headers = await _buildHeaders(includeAuth: includeAuth);
      final uri = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');
      final response = await http
          .post(uri, headers: headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 10));
      return _parseResponse(response);
    } catch (e) {
      return ApiResponse(success: false, message: 'Network error: $e', statusCode: 503);
    }
  }

  static Future<ApiResponse<dynamic>> patch(String endpoint, Map<String, dynamic> body) async {
    try {
      final headers = await _buildHeaders();
      final uri = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');
      final response = await http
          .patch(uri, headers: headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 10));
      return _parseResponse(response);
    } catch (e) {
      return ApiResponse(success: false, message: 'Network error: $e', statusCode: 503);
    }
  }

  static ApiResponse<dynamic> _parseResponse(http.Response response) {
    try {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return ApiResponse(
        success: decoded['success'] == true,
        message: decoded['message']?.toString() ?? 'Response received',
        data: decoded['data'],
        statusCode: response.statusCode,
      );
    } catch (_) {
      return ApiResponse(
        success: false,
        message: 'Invalid server response (${response.statusCode})',
        statusCode: response.statusCode,
      );
    }
  }
}

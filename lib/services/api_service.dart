import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static Uri _getEndpoint(String path) {
    if (kIsWeb) {
      final base = Uri.base;
      final portPart = base.hasPort && base.port != 80 && base.port != 443 ? ':${base.port}' : '';
      return Uri.parse('${base.scheme}://${base.host}$portPart/api/v1$path');
    }
    return Uri.parse('http://localhost:5000/api/v1$path');
  }

  static String? authToken;

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      };

  // --- HEALTH CHECK ---
  static Future<bool> checkHealth() async {
    try {
      final res = await http.get(_getEndpoint('/../health')).timeout(const Duration(seconds: 3));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // --- ADMISSIONS ---
  static Future<Map<String, dynamic>> applyForAdmission({
    required String primaryParentName,
    required String primaryParentSurname,
    required String primaryParentPhone,
    required String primaryParentEmail,
    required String primaryParentIdNumber,
    required bool hasSecondaryParent,
    String? secondaryParentName,
    String? secondaryParentSurname,
    String? secondaryParentPhone,
    String? secondaryParentEmail,
    String? secondaryParentIdNumber,
    required List<Map<String, dynamic>> learners,
  }) async {
    try {
      final endpoint = _getEndpoint('/admissions/apply');
      final response = await http.post(
        endpoint,
        headers: _headers,
        body: jsonEncode({
          'primaryParentName': primaryParentName,
          'primaryParentSurname': primaryParentSurname,
          'primaryParentPhone': primaryParentPhone,
          'primaryParentEmail': primaryParentEmail,
          'primaryParentIdNumber': primaryParentIdNumber,
          'hasSecondaryParent': hasSecondaryParent,
          'secondaryParentName': secondaryParentName,
          'secondaryParentSurname': secondaryParentSurname,
          'secondaryParentPhone': secondaryParentPhone,
          'secondaryParentEmail': secondaryParentEmail,
          'secondaryParentIdNumber': secondaryParentIdNumber,
          'learners': learners,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }
      return {'success': false, 'message': 'HTTP ${response.statusCode}'};
    } catch (e) {
      debugPrint('⚠️ [ApiService] Backend database sync: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> approveAdmission(String applicationId, {String? notes}) async {
    final response = await http.post(
      _getEndpoint('/admissions/$applicationId/approve'),
      headers: _headers,
      body: jsonEncode({'notes': notes}),
    );
    return jsonDecode(response.body);
  }

  // --- REGISTRATION ---
  static Future<Map<String, dynamic>> registerAccount({
    required String registrationToken,
    required String parentName,
    required String parentSurname,
    required String parentEmail,
    required String parentPassword,
    required String learnerName,
    required String learnerSurname,
    required String learnerIdNumber,
  }) async {
    final response = await http.post(
      _getEndpoint('/auth/register'),
      headers: _headers,
      body: jsonEncode({
        'registrationToken': registrationToken,
        'parentName': parentName,
        'parentSurname': parentSurname,
        'parentEmail': parentEmail,
        'parentPassword': parentPassword,
        'learnerName': learnerName,
        'learnerSurname': learnerSurname,
        'learnerIdNumber': learnerIdNumber,
      }),
    );

    final data = jsonDecode(response.body);
    return data;
  }

  // --- AUTHENTICATION ---
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      _getEndpoint('/auth/login'),
      headers: _headers,
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = jsonDecode(response.body);
    if (data['token'] != null) {
      authToken = data['token'];
    }
    return data;
  }
}

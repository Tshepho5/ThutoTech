import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static String get baseUrl {
    if (kIsWeb && !kDebugMode) {
      return '/api/v1';
    }
    return 'http://localhost:5000/api/v1';
  }

  static String? authToken;

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      };

  // --- HEALTH CHECK ---
  static asyncCheckHealth() async {
    try {
      final res = await http.get(Uri.parse('http://localhost:5000/health')).timeout(const Duration(seconds: 3));
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
    required String learnerName,
    required String learnerSurname,
    required String learnerIdNumber,
    required String gradeApplyingFor,
    required String previousSchool,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admissions/apply'),
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
        'learnerName': learnerName,
        'learnerSurname': learnerSurname,
        'learnerIdNumber': learnerIdNumber,
        'gradeApplyingFor': gradeApplyingFor,
        'previousSchool': previousSchool,
      }),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> approveAdmission(String applicationId, {String? notes}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admissions/$applicationId/approve'),
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
      Uri.parse('$baseUrl/auth/register'),
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
      Uri.parse('$baseUrl/auth/login'),
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

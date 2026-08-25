import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class EmailSenderService {
  static Uri _getEndpoint(String path) {
    if (kIsWeb) {
      final base = Uri.base;
      final portPart = base.hasPort && base.port != 80 && base.port != 443 ? ':${base.port}' : '';
      return Uri.parse('${base.scheme}://${base.host}$portPart/api/v1$path');
    }
    return Uri.parse('http://localhost:5000/api/v1$path');
  }

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
      };

  /// Dispatches Real Admission Approval Email via SMTP (Gmail)
  static Future<bool> sendAdmissionApprovalEmail({
    required String recipientEmail,
    required String parentName,
    required String parentSurname,
    required String learnerName,
    required String learnerSurname,
    required String grade,
    required String homeLanguage,
    String? stream,
    required String applicationNumber,
    required String registrationToken,
  }) async {
    try {
      final endpoint = _getEndpoint('/emails/send-admission-approval');
      debugPrint('✉️ [EmailSenderService] Dispatching admission approval email to $endpoint for $recipientEmail...');
      final response = await http
          .post(
            endpoint,
            headers: _headers,
            body: jsonEncode({
              'recipientEmail': recipientEmail,
              'parentName': parentName,
              'parentSurname': parentSurname,
              'learnerName': learnerName,
              'learnerSurname': learnerSurname,
              'grade': grade,
              'homeLanguage': homeLanguage,
              'stream': stream,
              'applicationNumber': applicationNumber,
              'registrationToken': registrationToken,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('✉️ [EmailSenderService] SMTP Approval email sent: ${data["message"]}');
        return data['success'] == true;
      } else {
        debugPrint('⚠️ [EmailSenderService] SMTP Approval HTTP Error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('⚠️ [EmailSenderService] Could not reach backend SMTP service: $e');
      return false;
    }
  }

  /// Dispatches Real Learner Credentials & Registration Success Email via SMTP
  static Future<bool> sendRegistrationSuccessEmail({
    required String recipientEmail,
    required String parentName,
    required String parentSurname,
    required String learnerName,
    required String learnerSurname,
    required String learnerNumber,
    required String learnerEmail,
    required String generatedPassword,
  }) async {
    try {
      final endpoint = _getEndpoint('/emails/send-registration-success');
      debugPrint('✉️ [EmailSenderService] Dispatching registration credentials email to $endpoint for $recipientEmail...');
      final response = await http
          .post(
            endpoint,
            headers: _headers,
            body: jsonEncode({
              'recipientEmail': recipientEmail,
              'parentName': parentName,
              'parentSurname': parentSurname,
              'learnerName': learnerName,
              'learnerSurname': learnerSurname,
              'learnerNumber': learnerNumber,
              'learnerEmail': learnerEmail,
              'generatedPassword': generatedPassword,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('✉️ [EmailSenderService] SMTP Credentials email sent: ${data["message"]}');
        return data['success'] == true;
      } else {
        debugPrint('⚠️ [EmailSenderService] SMTP Credentials HTTP Error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('⚠️ [EmailSenderService] Could not reach backend SMTP service: $e');
      return false;
    }
  }

  /// Dispatches Real 6-Digit Password Reset OTP Email via SMTP
  static Future<bool> sendPasswordResetOtpEmail({
    required String recipientEmail,
    required String recipientName,
    required String otp,
    String? resetLink,
  }) async {
    try {
      final endpoint = _getEndpoint('/emails/send-otp');
      final response = await http
          .post(
            endpoint,
            headers: _headers,
            body: jsonEncode({
              'recipientEmail': recipientEmail,
              'recipientName': recipientName,
              'otp': otp,
              'resetLink': resetLink ?? '',
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('✉️ [EmailSenderService] SMTP Password Reset OTP email sent: ${data["message"]}');
        return data['success'] == true;
      } else {
        debugPrint('⚠️ [EmailSenderService] SMTP OTP HTTP Error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('⚠️ [EmailSenderService] Could not reach backend SMTP service: $e');
      return false;
    }
  }

  /// Dispatches Custom System Email via SMTP
  static Future<bool> sendCustomEmail({
    required String recipientEmail,
    String? recipientName,
    required String subject,
    String? title,
    required String body,
    String? fromName,
  }) async {
    try {
      final endpoint = _getEndpoint('/emails/send-custom');
      final response = await http
          .post(
            endpoint,
            headers: _headers,
            body: jsonEncode({
              'recipientEmail': recipientEmail,
              'recipientName': recipientName,
              'subject': subject,
              'title': title,
              'body': body,
              'fromName': fromName,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('✉️ [EmailSenderService] Custom SMTP email sent: ${data["message"]}');
        return data['success'] == true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint('⚠️ [EmailSenderService] Could not reach backend SMTP service: $e');
      return false;
    }
  }
}

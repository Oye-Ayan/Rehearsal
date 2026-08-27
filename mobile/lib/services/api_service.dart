// lib/services/api_service.dart
// Previous: Empty file (new creation)

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import 'auth_service.dart';

class ApiService {
  final AuthService _authService;

  ApiService(this._authService);

  /// Upload a resume PDF file
  Future<Map<String, dynamic>?> uploadResume(File pdfFile) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(AppConstants.resumeUploadUrl));
      request.headers.addAll({
        'Authorization': 'Bearer ${_authService.token}',
      });
      request.files.add(await http.MultipartFile.fromPath('file', pdfFile.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Create a practice session (match resume with JD & generate questions)
  Future<Map<String, dynamic>?> createSession(int resumeId, String jobDescription) async {
    try {
      final response = await http.post(
        Uri.parse(AppConstants.sessionMatchUrl),
        headers: _authService.authHeaders,
        body: jsonEncode({
          'resumeId': resumeId,
          'jobDescriptionText': jobDescription,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Fetch questions for a session
  Future<List<dynamic>?> getSessionQuestions(int sessionId) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.apiBase}/sessions/$sessionId/questions'),
        headers: _authService.authHeaders,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Fetch full session details including questions and their answers (for report)
  Future<Map<String, dynamic>?> getSessionDetails(int sessionId) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.apiBase}/sessions/$sessionId'),
        headers: _authService.authHeaders,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Fetch history of sessions
  Future<List<dynamic>?> getHistory() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.apiBase}/sessions/history'),
        headers: _authService.authHeaders,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Submit an answer with computed speech metrics
  Future<Map<String, dynamic>> submitAnswer(int questionId, Map<String, dynamic> metricsPayload) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.apiBase}/questions/$questionId/answers'),
        headers: _authService.authHeaders,
        body: jsonEncode(metricsPayload),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Server error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to submit answer: $e');
    }
  }
}

// lib/services/api_service.dart
// Previous: Empty file (new creation)

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
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

  Future<Map<String, dynamic>?> generateActionPlan(int sessionId) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.apiBase}/sessions/$sessionId/summary'),
        headers: _authService.authHeaders,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Failed to generate action plan: $e');
      return null;
    }
  }
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.apiBase}/users/me'),
        headers: _authService.authHeaders,
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Failed to get user profile: $e');
      return null;
    }
  }

  Future<String?> updateUsername(String newUsername) async {
    try {
      final response = await http.put(
        Uri.parse('${AppConstants.apiBase}/users/username'),
        headers: _authService.authHeaders,
        body: jsonEncode({'username': newUsername}),
      );
      
      if (response.statusCode == 200) {
        return null; // Success
      }
      
      return response.body; // Return error message
    } catch (e) {
      return 'Failed to connect to server: $e';
    }
  }

  /// Create a quick practice session without uploading a resume
  Future<Map<String, dynamic>?> createQuickSession(String jobDescription, String userDetails) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.apiBase}/sessions/quick-match'),
        headers: _authService.authHeaders,
        body: jsonEncode({
          'jobDescriptionText': jobDescription,
          'userDetails': userDetails,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Failed to create quick session: $e');
      return null;
    }
  }

  /// Request additional questions for an active session
  Future<List<dynamic>?> requestMoreQuestions(int sessionId) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.apiBase}/sessions/$sessionId/more-questions'),
        headers: _authService.authHeaders,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Failed to request more questions: $e');
      return null;
    }
  }

  /// Download session PDF report bytes
  Future<Uint8List?> downloadSessionPdf(int sessionId) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.apiBase}/sessions/$sessionId/export-pdf'),
        headers: _authService.authHeaders,
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
      return null;
    } catch (e) {
      debugPrint('Failed to download session PDF: $e');
      return null;
    }
  }

  /// Delete a session
  Future<bool> deleteSession(int sessionId) async {
    try {
      final response = await http.delete(
        Uri.parse('${AppConstants.apiBase}/sessions/$sessionId'),
        headers: _authService.authHeaders,
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Failed to delete session: $e');
      return false;
    }
  }

  /// Toggle pin status for a session
  Future<Map<String, dynamic>?> togglePin(int sessionId) async {
    try {
      final response = await http.put(
        Uri.parse('${AppConstants.apiBase}/sessions/$sessionId/pin'),
        headers: _authService.authHeaders,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Failed to toggle pin: $e');
      return null;
    }
  }
}


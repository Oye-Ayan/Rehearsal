// lib/core/constants.dart
// Previous: Empty file (new creation)

class AppConstants {
  static const String appName = 'Rehearsal';
  static const String baseUrl = 'http://127.0.0.1:8080';
  static const String apiBase = '$baseUrl/api';
  
  // Auth endpoints
  static const String registerUrl = '$apiBase/auth/register';
  static const String loginUrl = '$apiBase/auth/login';
  
  // Resume endpoints
  static const String resumeUploadUrl = '$apiBase/resumes/upload';
  
  // Session endpoints
  static const String sessionMatchUrl = '$apiBase/sessions/match';
  
  // Max recording duration
  static const int maxRecordingSeconds = 180; // 3 minutes
}

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConstants {
  static const String appName = 'Rehearsal';
  
  static String get baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8080';
    // Using host machine's local IP because you are using a physical device
    if (Platform.isAndroid) return 'http://10.10.20.121:8080';
    return 'http://127.0.0.1:8080'; // iOS Simulator / Desktop
  }

  static String get apiBase => '$baseUrl/api';
  
  // Auth endpoints
  static String get registerUrl => '$apiBase/auth/register';
  static String get loginUrl => '$apiBase/auth/login';
  static String get googleLoginUrl => '$apiBase/auth/google';
  
  // Resume endpoints
  static String get resumeUploadUrl => '$apiBase/resumes/upload';
  
  // Session endpoints
  static String get sessionMatchUrl => '$apiBase/sessions/match';
  
  // Max recording duration
  static const int maxRecordingSeconds = 180; // 3 minutes
}

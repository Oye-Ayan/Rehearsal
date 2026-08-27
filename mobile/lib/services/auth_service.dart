// lib/services/auth_service.dart
// Previous: Empty file (new creation)

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../core/constants.dart';

class AuthService extends ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  String? _token;
  String? _email;
  bool _isLoading = false;

  String? get token => _token;
  String? get email => _email;
  bool get isLoggedIn => _token != null;
  bool get isLoading => _isLoading;

  // Headers with JWT
  Map<String, String> get authHeaders => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $_token',
  };

  Future<void> init() async {
    _token = await _storage.read(key: 'jwt_token');
    _email = await _storage.read(key: 'user_email');
    notifyListeners();
  }

  Future<String?> register(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await http.post(
        Uri.parse(AppConstants.registerUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _email = email;
        await _storage.write(key: 'jwt_token', value: _token);
        await _storage.write(key: 'user_email', value: _email);
        _isLoading = false;
        notifyListeners();
        return null; // success
      } else {
        _isLoading = false;
        notifyListeners();
        final body = jsonDecode(response.body);
        return body['message'] ?? 'Registration failed';
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'Network error: ${e.toString()}';
    }
  }

  Future<String?> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await http.post(
        Uri.parse(AppConstants.loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _email = email;
        await _storage.write(key: 'jwt_token', value: _token);
        await _storage.write(key: 'user_email', value: _email);
        _isLoading = false;
        notifyListeners();
        return null; // success
      } else {
        _isLoading = false;
        notifyListeners();
        final body = jsonDecode(response.body);
        return body['message'] ?? 'Login failed';
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'Network error: ${e.toString()}';
    }
  }

  Future<void> logout() async {
    _token = null;
    _email = null;
    await _storage.deleteAll();
    notifyListeners();
  }
}

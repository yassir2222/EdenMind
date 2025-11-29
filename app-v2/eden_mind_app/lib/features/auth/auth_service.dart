import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthService extends ChangeNotifier {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Dynamic Base URL based on Platform
  String get _baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8081/api/auth'; // Android emulator uses 10.0.2.2 for host's localhost
    }
    return 'http://192.168.1.105:8081/api/auth';
  }

  bool _isAuthenticated = false;
  bool _isInitialized = false;
  Map<String, dynamic>? _userProfile;

  bool get isAuthenticated => _isAuthenticated;
  bool get isInitialized => _isInitialized;
  Map<String, dynamic>? get userProfile => _userProfile;

  Future<void> init() async {
    final token = await _secureStorage.read(key: 'jwt_token');
    if (token != null && !JwtDecoder.isExpired(token)) {
      _isAuthenticated = true;
      _userProfile = JwtDecoder.decode(token);
    } else {
      _isAuthenticated = false;
      _userProfile = null;
    }
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        await _saveToken(token);
      } else {
        throw Exception('Login failed: ${response.body}');
      }
    } catch (e) {
      debugPrint('Login error: $e');
      rethrow;
    }
  }

  Future<void> register(
    String firstName,
    String lastName,
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        await _saveToken(token);
      } else {
        throw Exception('Registration failed: ${response.body}');
      }
    } catch (e) {
      debugPrint('Registration error: $e');
      rethrow;
    }
  }

  Future<void> _saveToken(String token) async {
    await _secureStorage.write(key: 'jwt_token', value: token);
    _isAuthenticated = true;
    _userProfile = JwtDecoder.decode(token);
    notifyListeners();
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: 'jwt_token');
    _isAuthenticated = false;
    _userProfile = null;
    notifyListeners();
  }
}

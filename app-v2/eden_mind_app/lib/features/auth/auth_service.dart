import 'dart:convert';
import 'dart:io';

import 'package:eden_mind_app/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'dart:developer';

class AuthService extends ChangeNotifier {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Dynamic Base URL based on Platform
  String get _baseUrl {
    return '${AppConfig.baseUrl}/auth';
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
      final decodedToken = JwtDecoder.decode(token);
      _userProfile = decodedToken;

      // Try to fetch fresh user data from backend
      try {
        final userId = decodedToken['id'] ?? decodedToken['userId'];
        if (userId != null) {
          final response = await http.get(
            Uri.parse('$_baseUrl/../users/$userId'),
          );

          if (response.statusCode == 200) {
            _userProfile = jsonDecode(response.body);
            log(
              'Fetched fresh user profile: $_userProfile',
              name: 'AuthService',
            );
          }
        }
      } catch (e) {
        log('Error fetching fresh profile: $e', name: 'AuthService');
        // Fallback to token data is already done above
      }
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

  Future<String?> uploadImage(File imageFile) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/../uploads'), // Adjust path to reach /api/uploads
      );

      // Add file
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['url'];
      } else {
        throw Exception('Failed to upload image: ${response.body}');
      }
    } catch (e) {
      debugPrint('Image upload error: $e');
      rethrow;
    }
  }

  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? avatarUrl,
    String? birthday,
    String? familySituation,
    String? workType,
    String? workHours,
    int? childrenCount,
    String? country,
  }) async {
    try {
      final userId = _userProfile?['id'] ?? _userProfile?['userId'];

      if (userId == null) {
        throw Exception('User ID not found in profile');
      }

      // Fetch current user details first
      final userResponse = await http.get(
        Uri.parse('$_baseUrl/../users/$userId'),
      );
      if (userResponse.statusCode != 200) {
        throw Exception('Failed to fetch user details');
      }

      final currentUser = jsonDecode(userResponse.body);

      // Merge updates
      final Map<String, dynamic> finalData = Map.from(currentUser);
      if (firstName != null) finalData['firstName'] = firstName;
      if (lastName != null) finalData['lastName'] = lastName;
      if (avatarUrl != null) finalData['avatarUrl'] = avatarUrl;
      if (birthday != null) finalData['birthday'] = birthday;
      if (familySituation != null) {
        finalData['familySituation'] = familySituation;
      }
      if (workType != null) finalData['workType'] = workType;
      if (workHours != null) finalData['workHours'] = workHours;
      if (childrenCount != null) finalData['childrenCount'] = childrenCount;
      if (country != null) finalData['country'] = country;

      final response = await http.put(
        Uri.parse('$_baseUrl/../users/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(finalData),
      );

      if (response.statusCode == 200) {
        final updatedUser = jsonDecode(response.body);

        final newProfile = Map<String, dynamic>.from(_userProfile ?? {});
        newProfile['firstName'] = updatedUser['firstName'];
        newProfile['lastName'] = updatedUser['lastName'];
        newProfile['avatarUrl'] = updatedUser['avatarUrl'];
        newProfile['birthday'] = updatedUser['birthday'];
        newProfile['familySituation'] = updatedUser['familySituation'];
        newProfile['workType'] = updatedUser['workType'];
        newProfile['workHours'] = updatedUser['workHours'];
        newProfile['childrenCount'] = updatedUser['childrenCount'];
        newProfile['country'] = updatedUser['country'];

        _userProfile = newProfile;
        notifyListeners();
      } else {
        throw Exception('Failed to update profile: ${response.body}');
      }
    } catch (e) {
      debugPrint('Profile update error: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: 'jwt_token');
    _isAuthenticated = false;
    _userProfile = null;
    notifyListeners();
  }
}

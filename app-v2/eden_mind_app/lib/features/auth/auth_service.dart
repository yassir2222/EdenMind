import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService extends ChangeNotifier {
  final FlutterAppAuth _appAuth = const FlutterAppAuth();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Keycloak Configuration
  final String _clientId = 'client'; // Updated to match user's JSON
  final String _redirectUrl =
      'com.example.app://callback'; // Updated to match user's JSON

  // Dynamic Base URL based on Platform
  String get _baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8086';
    }
    return 'http://localhost:8086';
  }

  String get _issuer => '$_baseUrl/realms/Eden-Project';
  String get _authEndpoint => '$_issuer/protocol/openid-connect/auth';
  String get _tokenEndpoint => '$_issuer/protocol/openid-connect/token';

  bool _isAuthenticated = false;
  bool _isInitialized = false;
  Map<String, dynamic>? _userProfile;

  bool get isAuthenticated => _isAuthenticated;
  bool get isInitialized => _isInitialized;
  Map<String, dynamic>? get userProfile => _userProfile;

  Future<void> init() async {
    final storedRefreshToken = await _secureStorage.read(key: 'refresh_token');
    if (storedRefreshToken != null) {
      try {
        await _refreshToken(storedRefreshToken);
      } catch (e) {
        debugPrint('Error refreshing token: $e');
        _isAuthenticated = false;
      }
    }
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> login() async {
    try {
      // 1. Authorize (Get Code) - Browser interaction
      final AuthorizationResponse? result = await _appAuth.authorize(
        AuthorizationRequest(
          _clientId,
          _redirectUrl,
          serviceConfiguration: AuthorizationServiceConfiguration(
            authorizationEndpoint: _authEndpoint,
            tokenEndpoint: _tokenEndpoint,
          ),
          scopes: ['openid', 'profile', 'email', 'offline_access'],
        ),
      );

      if (result != null && result.authorizationCode != null) {
        // 2. Exchange Code for Token (Manual HTTP to avoid HTTPS check)
        await _exchangeCodeForToken(result.authorizationCode!);
      }
    } catch (e) {
      debugPrint('Login error: $e');
      rethrow;
    }
  }

  Future<void> _exchangeCodeForToken(String code) async {
    try {
      final response = await http.post(
        Uri.parse(_tokenEndpoint),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'authorization_code',
          'client_id': _clientId,
          'code': code,
          'redirect_uri': _redirectUrl,
          'client_secret': 'client', // Added secret from user's JSON
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        await _processTokenData(data);
      } else {
        throw Exception('Failed to exchange token: ${response.body}');
      }
    } catch (e) {
      debugPrint('Token exchange error: $e');
      rethrow;
    }
  }

  Future<void> _refreshToken(String refreshToken) async {
    try {
      final response = await http.post(
        Uri.parse(_tokenEndpoint),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'refresh_token',
          'client_id': _clientId,
          'refresh_token': refreshToken,
          'client_secret': 'client', // Added secret
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        await _processTokenData(data);
      } else {
        throw Exception('Failed to refresh token: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _secureStorage.delete(key: 'refresh_token');
      _isAuthenticated = false;
      _userProfile = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }

  Future<void> _processTokenData(Map<String, dynamic> data) async {
    final String? refreshToken = data['refresh_token'];
    final String? idToken = data['id_token'];

    if (refreshToken != null) {
      await _secureStorage.write(key: 'refresh_token', value: refreshToken);
    }

    if (idToken != null) {
      _userProfile = _parseIdToken(idToken);
    }

    _isAuthenticated = true;
    notifyListeners();
  }

  Map<String, dynamic> _parseIdToken(String idToken) {
    final parts = idToken.split('.');
    if (parts.length != 3) {
      return {};
    }

    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final resp = utf8.decode(base64Url.decode(normalized));
    final payloadMap = json.decode(resp);
    return payloadMap;
  }
}

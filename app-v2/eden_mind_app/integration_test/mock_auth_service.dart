import 'package:eden_mind_app/features/auth/auth_service.dart';
import 'package:flutter/foundation.dart';

class MockAuthService extends ChangeNotifier implements AuthService {
  bool _isAuthenticated = false;
  Map<String, dynamic>? _userProfile;

  @override
  bool get isAuthenticated => _isAuthenticated;

  @override
  bool get isInitialized => true;

  @override
  Map<String, dynamic>? get userProfile => _userProfile;

  @override
  Future<void> init() async {
    // Simulate initialization delay
    await Future.delayed(const Duration(milliseconds: 100));
    notifyListeners();
  }

  @override
  Future<void> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    if (email == 'test@example.com' && password == 'password') {
      _isAuthenticated = true;
      _userProfile = {'id': '123', 'firstName': 'TestUser', 'email': email};
      notifyListeners();
    } else {
      throw Exception('Invalid credentials');
    }
  }

  @override
  Future<void> logout() async {
    _isAuthenticated = false;
    _userProfile = null;
    notifyListeners();
  }

  // Stub other methods to avoid unimplemented errors if called incidentally
  @override
  Future<void> register(String f, String l, String e, String p) async {}

  @override
  Future<String?> uploadImage(dynamic file) async => null;

  @override
  Future<String?> uploadImageBytes(List<int> bytes, String filename) async =>
      null;

  @override
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
  }) async {}
}

import 'package:flutter/foundation.dart';
import 'package:neffils/domain/models/userLogin_model.dart';
import '../services/token/token_storage_service.dart';

class AuthProvider with ChangeNotifier {
  UserLogin? _currentUser;
  bool _isAuthenticated = false;

  UserLogin? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;

  Future<void> initialize() async {
    final accessToken = await TokenStorageService.getAccessToken();
    final refreshToken = await TokenStorageService.getRefreshToken();
    final userData = await TokenStorageService.getUserData();

    if (accessToken != null && refreshToken != null && userData != null) {
      _currentUser = UserLogin(
        username: userData['username'],
        email: userData['email'],
        role: userData['role'],
        fullName: userData['user_full_name'],
        accessToken: accessToken,
        refreshToken: refreshToken,
        isVerified: userData['is_verified'] ?? false,
        isActive: userData['is_active'] ?? true,
      );
      _isAuthenticated = true;
    }
    notifyListeners();
  }

  Future<void> login(UserLogin user) async {
    await TokenStorageService.saveTokensAndUser(
      user.accessToken,
      user.refreshToken,
      user.toJson(),
    );
    _currentUser = user;
    _isAuthenticated = true;
    notifyListeners();
  }

  Future<void> logout() async {
    await TokenStorageService.deleteAll();
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}

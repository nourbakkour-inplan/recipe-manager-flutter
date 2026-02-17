import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

/// Provides authentication state to the widget tree.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  User? _currentUser;
  String? _error;

  AuthProvider(StorageService storage)
      : _authService = AuthService(storage) {
    _currentUser = _authService.currentUser;
  }

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  String? get error => _error;

  void register(String username, String password) {
    _error = _authService.register(username, password);
    if (_error == null) {
      _currentUser = _authService.currentUser;
    }
    notifyListeners();
  }

  void login(String username, String password) {
    _error = _authService.login(username, password);
    if (_error == null) {
      _currentUser = _authService.currentUser;
    }
    notifyListeners();
  }

  void logout() {
    _authService.logout();
    _currentUser = null;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

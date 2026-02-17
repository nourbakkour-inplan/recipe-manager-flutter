import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';
import 'storage_service.dart';

/// Handles user registration, login, and session persistence.
class AuthService {
  final StorageService _storage;
  AuthService(this._storage);

  static String _hash(String password) =>
      sha256.convert(utf8.encode(password)).toString();

  /// Register a new user. Returns error string on failure, null on success.
  String? register(String username, String password) {
    if (username.trim().isEmpty) return 'Username cannot be empty.';
    if (password.length < 4) return 'Password must be at least 4 characters.';
    if (_storage.getUserByUsername(username.trim()) != null) {
      return 'Username already taken.';
    }

    final user = User(
      id: const Uuid().v4(),
      username: username.trim(),
      passwordHash: _hash(password),
      createdAt: DateTime.now(),
    );
    _storage.saveUser(user);
    _storage.saveSession(user.id);
    return null;
  }

  /// Login an existing user. Returns error string on failure, null on success.
  String? login(String username, String password) {
    final user = _storage.getUserByUsername(username.trim());
    if (user == null) return 'User not found.';
    if (user.passwordHash != _hash(password)) return 'Incorrect password.';
    _storage.saveSession(user.id);
    return null;
  }

  void logout() => _storage.clearSession();

  /// Returns the currently logged-in user, or null.
  User? get currentUser {
    final id = _storage.getSession();
    if (id == null) return null;
    return _storage.getUserById(id);
  }
}

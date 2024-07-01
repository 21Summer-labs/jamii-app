// lib/controllers/user_controller.dart

import '../models/user_model.dart';
import '../services/auth_service.dart';

class UserController {
  final AuthService _authService = AuthService();

  Stream<UserModel?> get userStream => _authService.user;

  Future<UserModel?> signIn(String email, String password) async {
    try {
      return await _authService.signInWithEmailAndPassword(email, password);
    } catch (e) {
      print('Error signing in: $e');
      rethrow;
    }
  }

  Future<UserModel?> register(String name, String email, String password) async {
    try {
      return await _authService.registerWithEmailAndPassword(name, email, password);
    } catch (e) {
      print('Error registering user: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  UserModel? getCurrentUser() {
    return _authService.getCurrentUser();
  }

  String? getCurrentUserId() {
    final user = _authService.getCurrentUser();
    return user?.id;
  }

  Future<void> updateUserProfile(String name) async {
    try {
      await _authService.updateUserProfile(name);
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }
}
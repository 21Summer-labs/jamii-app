// lib/controllers/user_controller.dart

import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class UserController extends ChangeNotifier {
  final AuthService _authService = AuthService();

  Stream<UserModel?> get userStream => _authService.user;

  Future<UserModel?> signIn(String email, String password) async {
    try {
      UserModel? user = await _authService.signInWithEmailAndPassword(email, password);
      notifyListeners();  // Notify listeners when the user signs in
      return user;
    } catch (e) {
      print('Error signing in: $e');
      rethrow;
    }
  }

  Future<UserModel?> register(String name, String email, String password) async {
    try {
      UserModel? user = await _authService.registerWithEmailAndPassword(name, email, password);
      notifyListeners();  // Notify listeners when the user registers
      return user;
    } catch (e) {
      print('Error registering user: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
      notifyListeners();  // Notify listeners when the user signs out
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
      notifyListeners();  // Notify listeners when the user profile is updated
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  Stream<List<UserModel>> getAllUsers() {
    return _authService.getAllUsers();
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _authService.deleteUser(userId);
      notifyListeners();  // Notify listeners when a user is deleted
    } catch (e) {
      print('Error deleting user: $e');
      rethrow;
    }
  }
}

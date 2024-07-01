// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Convert Firebase User to our custom UserModel
  UserModel? _userFromFirebaseUser(User? user) {
    return user != null
        ? UserModel(id: user.uid, name: user.displayName ?? '', email: user.email ?? '')
        : null;
  }

  // Auth change user stream
  Stream<UserModel?> get user {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  // Sign in with email and password
  Future<UserModel?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Register with email and password
  Future<UserModel?> registerWithEmailAndPassword(String name, String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      
      // Update the user's display name
      await user?.updateDisplayName(name);
      
      // Create a new document for the user in Firestore
      await _firestore.collection('users').doc(user?.uid).set({
        'name': name,
        'email': email,
      });
      
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }

  // Get current user
  UserModel? getCurrentUser() {
    User? user = _auth.currentUser;
    return _userFromFirebaseUser(user);
  }

  // Update user profile
  Future<void> updateUserProfile(String name) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await user.updateDisplayName(name);
      await _firestore.collection('users').doc(user.uid).update({
        'name': name,
      });
    }
  }
}
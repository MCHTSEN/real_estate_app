import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Authentication service
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Current user
  User? get currentUser => _auth.currentUser;

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    developer.log('signInWithEmailAndPassword: called with email: $email');
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      developer.log(
          'signInWithEmailAndPassword: signed in successfully. User: ${userCredential.user?.email}');
      return userCredential;
    } catch (e) {
      developer.log('signInWithEmailAndPassword: error: $e');
      rethrow;
    }
  }

  // Register with email and password
  Future<UserCredential> createUserWithEmailAndPassword(
      String email, String password) async {
    developer
        .log('createUserWithEmailAndPassword: called with email: $email');
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      developer.log(
          'createUserWithEmailAndPassword: created user successfully. User: ${userCredential.user?.email}');
      return userCredential;
    } catch (e) {
      developer.log('createUserWithEmailAndPassword: error: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    developer.log('signOut: called');
    await _auth.signOut();
    developer.log('signOut: signed out successfully');
  }
}

// Provider for the AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  developer.log('authServiceProvider: creating AuthService');
  return AuthService();
});

// Provider for the current user
final authProvider = StreamProvider<User?>((ref) {
  developer.log('authProvider: called');
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// Authentication error provider
final authErrorProvider = StateProvider<String?>((ref) {
  developer.log('authErrorProvider: initializing to null');
  return null;
});

// Loading state provider
final authLoadingProvider = StateProvider<bool>((ref) {
  developer.log('authLoadingProvider: initializing to false');
  return false;
});

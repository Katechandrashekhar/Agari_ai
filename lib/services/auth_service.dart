import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as app_user;

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  app_user.User? _currentUser;
  bool _isLoading = false;

  // Getters
  app_user.User? get currentUser => _currentUser;
  bool get isSignedIn => _currentUser != null;
  bool get isLoading => _isLoading;

  AuthService() {
    // Listen to auth state changes
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  /// Handle auth state changes
  void _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser != null) {
      // User is signed in, load their data
      await _loadUserData(firebaseUser.uid);
    } else {
      // User is signed out
      _currentUser = null;
    }
    notifyListeners();
  }

  /// Load user data from Firestore
  Future<void> _loadUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        _currentUser = app_user.User.fromFirestore(doc.data()!, doc.id);
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  /// Register with email and password
  Future<app_user.User?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String soilType,
    required double landAreaAcres,
    required String language,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Create user with Firebase Auth
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        // Create user document in Firestore
        final userData = {
          'name': name,
          'email': email,
          'phone': phone,
          'soilType': soilType,
          'landAreaAcres': landAreaAcres,
          'userType': 'farmer',
          'language': language,
          'createdAt': DateTime.now(),
        };

        await _firestore.collection('users').doc(result.user!.uid).set(userData);

        // Create User object
        final user = app_user.User(
          id: result.user!.uid,
          name: name,
          email: email,
          phone: phone,
          soilType: soilType,
          landAreaAcres: landAreaAcres,
          userType: 'farmer',
          language: language,
          createdAt: DateTime.now(),
        );

        _currentUser = user;
        notifyListeners();
        return user;
      }
    } catch (e) {
      print('Registration error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return null;
  }

  /// Sign in with email and password
  Future<app_user.User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        await _loadUserData(result.user!.uid);
        return _currentUser;
      }
    } catch (e) {
      print('Login error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return null;
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      print('Sign out error: $e');
      rethrow;
    }
  }

  /// Update user profile
  Future<void> updateUserProfile({
    String? name,
    String? phone,
    String? soilType,
    double? landAreaAcres,
    String? language,
  }) async {
    if (_currentUser == null) return;

    try {
      final Map<String, dynamic> updates = {};
      
      if (name != null) updates['name'] = name;
      if (phone != null) updates['phone'] = phone;
      if (soilType != null) updates['soilType'] = soilType;
      if (landAreaAcres != null) updates['landAreaAcres'] = landAreaAcres;
      if (language != null) updates['language'] = language;

      if (updates.isNotEmpty) {
        await _firestore.collection('users').doc(_currentUser!.id).update(updates);
        await _loadUserData(_currentUser!.id);
      }
    } catch (e) {
      print('Update profile error: $e');
      rethrow;
    }
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Reset password error: $e');
      rethrow;
    }
  }

  /// Delete user account
  Future<void> deleteAccount() async {
    if (_currentUser == null) return;

    try {
      // Delete user document from Firestore
      await _firestore.collection('users').doc(_currentUser!.id).delete();
      
      // Delete Firebase Auth account
      await _auth.currentUser?.delete();
      
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      print('Delete account error: $e');
      rethrow;
    }
  }
}
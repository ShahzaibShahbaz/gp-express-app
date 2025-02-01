import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

enum AuthState {
  initial,
  authenticating,
  authenticated,
  error,
}

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _user;
  AuthState _state = AuthState.initial;
  String? _error;
  String? _loadingMessage;

  UserModel? get user => _user;
  AuthState get state => _state;
  String? get error => _error;
  String? get loadingMessage => _loadingMessage;
  bool get isLoading => _state == AuthState.authenticating;
  bool get isAuthenticated => _user != null;
  bool get isGP => _user?.userType == UserType.gp;

  void init() {
    debugPrint("Initializing AuthProvider");
    _auth.authStateChanges().listen((User? firebaseUser) async {
      debugPrint("Auth state changed: User ${firebaseUser?.uid}");
      if (firebaseUser == null) {
        _user = null;
        _state = AuthState.initial;
      } else {
        _setLoadingState('Loading user data...');
        try {
          final docSnapshot = await _firestore
              .collection('users')
              .doc(firebaseUser.uid)
              .get();

          if (docSnapshot.exists) {
            _user = UserModel.fromMap(docSnapshot.data()!, firebaseUser.uid);
            _state = AuthState.authenticated;
            debugPrint("User authenticated: ${_user?.email}");
          } else {
            _setErrorState('User data not found');
          }
        } catch (e) {
          debugPrint("Error loading user data: $e");
          _setErrorState('Error loading user data');
        }
      }
      notifyListeners();
    });
  }

  void _setLoadingState(String message) {
    _state = AuthState.authenticating;
    _loadingMessage = message;
    _error = null;
    notifyListeners();
  }

  void _setErrorState(String errorMessage) {
    _state = AuthState.error;
    _error = errorMessage;
    _loadingMessage = null;
    notifyListeners();
  }

  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    required bool isGP,
    String? phoneNumber,
  }) async {
    try {
      debugPrint("Starting registration process"); // Add logging
      _setLoadingState('Creating account...');

      // Create user in Firebase Auth
      debugPrint("Attempting to create Firebase Auth user"); // Add logging
      final UserCredential authResult = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      debugPrint("Firebase Auth user created successfully"); // Add logging

      if (authResult.user != null) {
        debugPrint("Creating user data for Firestore"); // Add logging

        // Create user data for Firestore
        final userData = {
          'email': email,
          'fullName': fullName,
          'userType': isGP ? 'gp' : 'customer',
          'phoneNumber': phoneNumber,
          'createdAt': FieldValue.serverTimestamp(),
          'isVerified': false,
          'hasSubmittedId': false,
          'isIdVerified': false,
          'hasSeenWelcome': false,
        };

        debugPrint("Saving user data to Firestore"); // Add logging

        // Save to Firestore
        await _firestore
            .collection('users')
            .doc(authResult.user!.uid)
            .set(userData);

        debugPrint("User data saved successfully"); // Add logging

        // Create UserModel
        _user = UserModel(
          uid: authResult.user!.uid,
          email: email,
          fullName: fullName,
          userType: isGP ? UserType.gp : UserType.customer,
          phoneNumber: phoneNumber,
          createdAt: DateTime.now(),
        );

        _state = AuthState.authenticated;
        notifyListeners();
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      debugPrint("FirebaseAuthException during registration: ${e.code} - ${e.message}"); // Add logging
      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'The password provided is too weak.';
          break;
        case 'email-already-in-use':
          errorMessage = 'An account already exists for that email.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is invalid.';
          break;
        default:
          errorMessage = e.message ?? 'An error occurred during registration.';
      }
      _setErrorState(errorMessage);
      return false;
    } catch (e) {
      debugPrint("General error during registration: $e"); // Add logging
      _setErrorState(e.toString());
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
    required bool isGP,
  }) async {
    try {
      _setLoadingState('Signing in...');
      debugPrint('Attempting login with isGP: $isGP');

      final UserCredential authResult = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (authResult.user != null) {
        debugPrint('Firebase Auth successful, checking Firestore data...');

        final docSnapshot = await _firestore
            .collection('users')
            .doc(authResult.user!.uid)
            .get();

        if (!docSnapshot.exists) {
          debugPrint('No Firestore document found for user');
          await _auth.signOut();
          _setErrorState('User data not found');
          return false;
        }

        final userData = docSnapshot.data()!;
        final userType = userData['userType'] as String?;

        debugPrint('Found user type: $userType, expecting: ${isGP ? 'gp' : 'customer'}');

        if ((isGP && userType != 'gp') || (!isGP && userType != 'customer')) {
          debugPrint('User type mismatch - signing out');
          await _auth.signOut();
          _setErrorState('Invalid user type. Please select the correct user type.');
          return false;
        }

        debugPrint('Login successful, creating UserModel');
        _user = UserModel.fromMap(userData, authResult.user!.uid);
        _state = AuthState.authenticated;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Login error: $e');
      _setErrorState(e.toString());
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      _setLoadingState('Signing out...');
      await _auth.signOut();
      _user = null;  // Clear user data
      _state = AuthState.initial;
      notifyListeners();

      // Clear any cached data if needed
      // You might want to clear other providers' states here
    } catch (e) {
      _setErrorState('Error signing out: ${e.toString()}');
    }
  }

  Future<void> refreshUserData() async {
    try {
      if (_user?.uid != null) {
        final docSnapshot = await _firestore
            .collection('users')
            .doc(_user!.uid)
            .get();

        if (docSnapshot.exists) {
          _user = UserModel.fromMap(docSnapshot.data()!, _user!.uid);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error refreshing user data: $e');
    }
  }

  void clearError() {
    if (_state == AuthState.error) {
      _state = AuthState.initial;
      _error = null;
      notifyListeners();
    }
  }
}
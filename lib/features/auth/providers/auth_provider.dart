import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/auth_service.dart';
import '../models/user_model.dart';

enum AuthState {
  initial,
  authenticating,
  authenticated,
  error,
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
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
    _authService.authStateChanges.listen((User? firebaseUser) async {
      debugPrint("Auth state changed: User ${firebaseUser?.uid}");
      if (firebaseUser == null) {
        _user = null;
        _state = AuthState.initial;
      } else {
        _setLoadingState('Loading user data...');
        try {
          _user = await _authService.getUserData(firebaseUser.uid);
          _state = AuthState.authenticated;
          debugPrint("User authenticated: ${_user?.email}");
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
    required UserType userType,
    String? phoneNumber,
    bool hasSubmittedId = false,
  }) async {
    try {
      // Validate registration data
      final validationError = _validateRegistrationData(
        email: email,
        password: password,
        fullName: fullName,
        userType: userType,
        phoneNumber: phoneNumber,
      );

      if (validationError != null) {
        _setErrorState(validationError);
        return false;
      }

      _setLoadingState('Creating your account...');

      _user = await _authService.registerUser(
        email: email,
        password: password,
        fullName: fullName,
        userType: userType,
        phoneNumber: phoneNumber,
        hasSubmittedId: hasSubmittedId,
      );

      if (_user != null) {
        _state = AuthState.authenticated;
        notifyListeners();
        return true;
      } else {
        _setErrorState('Failed to create account. Please try again.');
        return false;
      }
    } catch (e) {
      _setErrorState(e.toString());
      rethrow;
    }
  }

  String? _validateRegistrationData({
    required String email,
    required String password,
    required String fullName,
    required UserType userType,
    String? phoneNumber,
  }) {
    if (email.isEmpty || !email.contains('@')) {
      return 'Please enter a valid email address';
    }
    if (password.isEmpty || password.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    if (fullName.isEmpty) {
      return 'Please enter your full name';
    }
    if (userType == UserType.gp && (phoneNumber == null || phoneNumber.isEmpty)) {
      return 'Phone number is required for GP registration';
    }
    return null;
  }


  Future<bool> isFirstTimeLogin() async {
    try {
      if (_user?.uid == null) return false;

      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .get();

      return !(docSnapshot.data()?['hasSeenWelcome'] ?? false);
    } catch (e) {
      debugPrint('Error checking first-time login: $e');
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

      _user = await _authService.signIn(
        email: email,
        password: password,
        expectedUserType: isGP ? UserType.gp : UserType.customer,
      );

      if (_user != null) {
        _state = AuthState.authenticated;
        notifyListeners();
        return true;
      } else {
        _setErrorState('Failed to sign in. Please check your credentials.');
        return false;
      }
    } catch (e) {
      _setErrorState(e.toString());
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      _setLoadingState('Signing out...');
      await _authService.signOut();
      _user = null;
      _state = AuthState.initial;
      notifyListeners();
    } catch (e) {
      _setErrorState('Error signing out: ${e.toString()}');
    }
  }



  String? _validateLoginData({
    required String email,
    required String password,
  }) {
    if (email.isEmpty || !email.contains('@')) {
      return 'Please enter a valid email address';
    }
    if (password.isEmpty) {
      return 'Please enter your password';
    }
    return null;
  }

  void clearError() {
    if (_state == AuthState.error) {
      _state = AuthState.initial;
      _error = null;
      notifyListeners();
    }
  }
}
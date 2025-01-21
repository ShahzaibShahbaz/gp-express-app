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

  void init() {
    _authService.authStateChanges.listen((User? firebaseUser) async {
      if (firebaseUser == null) {
        _user = null;
        _state = AuthState.initial;
        notifyListeners();
      } else {
        _setLoadingState('Loading user data...');
        try {
          _user = await _authService.getUserData(firebaseUser.uid);
          _state = AuthState.authenticated;
        } catch (e) {
          _setErrorState('Error loading user data: ${e.toString()}');
        }
        notifyListeners();
      }
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

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      _state = AuthState.authenticating;
      _loadingMessage = 'Signing in...';
      _error = null;
      notifyListeners();

      _user = await _authService.signIn(
        email: email,
        password: password,
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
      rethrow; // Rethrow to handle in the UI
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    required UserType userType,
    String? phoneNumber,
  }) async {
    try {
      _state = AuthState.authenticating;
      _loadingMessage = 'Creating your account...';
      _error = null;
      notifyListeners();

      _user = await _authService.registerUser(
        email: email,
        password: password,
        fullName: fullName,
        userType: userType,
        phoneNumber: phoneNumber,
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
      rethrow; // Rethrow to handle in the UI
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

  String? _validateRegistrationData({
    required String email,
    required String password,
    required String fullName,
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
    return null;
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
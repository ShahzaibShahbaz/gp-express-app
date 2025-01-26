import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/auth/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel?> getUserData(String uid) async {
    try {
      final docSnapshot = await _firestore.collection('users').doc(uid).get();
      if (docSnapshot.exists) {
        return UserModel.fromMap(docSnapshot.data()!, uid);
      }
    } catch (e) {
      print('Error getting user data: $e');
      rethrow;
    }
    return null;
  }

  Future<UserModel?> registerUser({
    required String email,
    required String password,
    required String fullName,
    required UserType userType,
    String? phoneNumber,
    bool hasSubmittedId = false,
  }) async {
    try {
      // Create user in Firebase Auth
      final UserCredential authResult = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (authResult.user != null) {
        // Create user model with additional GP fields if necessary
        final UserModel newUser = UserModel(
          uid: authResult.user!.uid,
          email: email,
          fullName: fullName,
          userType: userType,
          phoneNumber: phoneNumber,
          hasSubmittedId: hasSubmittedId,
          isIdVerified: false,
          idSubmissionDate: userType == UserType.gp ? DateTime.now().toIso8601String() : null,
        );

        // Important: Store userType as 'gp' or 'customer' string
        final userData = newUser.toMap();
        userData['userType'] = userType == UserType.gp ? 'gp' : 'customer'; // Ensure exact match with rules

        // Save user data to Firestore
        await _firestore
            .collection('users')
            .doc(authResult.user!.uid)
            .set(userData);

        return newUser;
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
    return null;
  }

  Future<UserModel?> signIn({
    required String email,
    required String password,
    required UserType expectedUserType,
  }) async {
    try {
      // First, attempt to sign in with Firebase Auth
      final UserCredential authResult = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (authResult.user != null) {
        // Get user data from Firestore
        final userData = await getUserData(authResult.user!.uid);

        if (userData == null) {
          await _auth.signOut(); // Sign out if user data not found
          throw 'User data not found';
        }

        // Verify user type matches
        if (userData.userType != expectedUserType) {
          await _auth.signOut(); // Sign out if user type doesn't match
          throw 'Invalid user type. Please select the correct user type.';
        }

        return userData;
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
    return null;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is invalid.';
      default:
        return e.message ?? 'An error occurred. Please try again.';
    }
  }
}
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/user_model.dart';

class AuthResult {
  final UserModel? user;
  final String? error;

  AuthResult({this.user, this.error});

  bool get isSuccess => error == null && user != null;
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Get current authenticated user
  User? get currentUser => _auth.currentUser;

  // Sign up with email and password
  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String username,
    String? fullName,
  }) async {
    try {
      // Check if username is already taken
      final usernameSnapshot = await _database
          .child('usernames')
          .child(username.toLowerCase())
          .get();

      if (usernameSnapshot.exists) {
        return AuthResult(error: 'Username is already taken');
      }

      // Create user with email and password
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        return AuthResult(error: 'Failed to create user');
      }

      final uid = userCredential.user!.uid;

      final userModel = UserModel(
        uid: uid,
        email: email,
        username: username,
        fullName: fullName,
        createdAt: DateTime.now(),
      );

      await _database.child('users').child(uid).set(userModel.toJson());

      await _database.child('usernames').child(username.toLowerCase()).set(uid);

      return AuthResult(user: userModel);
    } on FirebaseAuthException catch (e) {
      return AuthResult(error: _handleAuthException(e));
    } catch (e) {
      return AuthResult(error: 'An unexpected error occurred: ${e.toString()}');
    }
  }

  // Sign in with email and password
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        return AuthResult(error: 'Failed to sign in');
      }

      final uid = userCredential.user!.uid;

      // Get user data from database
      final snapshot = await _database.child('users').child(uid).get();

      if (!snapshot.exists) {
        return AuthResult(error: 'User data not found');
      }

      final userData = Map<String, dynamic>.from(
        snapshot.value as Map,
      );

      final userModel = UserModel.fromJson(userData);

      return AuthResult(user: userModel);
    } on FirebaseAuthException catch (e) {
      return AuthResult(error: _handleAuthException(e));
    } catch (e) {
      return AuthResult(error: 'An unexpected error occurred: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Password reset
  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return _handleAuthException(e);
    } catch (e) {
      return 'An unexpected error occurred: ${e.toString()}';
    }
  }

  // Helper to handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'The email address is already in use.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      default:
        return 'Authentication error: ${e.message}';
    }
  }
}

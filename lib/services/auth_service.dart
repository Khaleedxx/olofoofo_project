import '../models/user_model.dart';
import 'dart:async';
import '../utils/validators.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/firebase_db_model.dart';

// Firebase Auth User wrapper
class User {
  final String uid;
  final String? email;
  final bool emailVerified;

  User({required this.uid, this.email, this.emailVerified = false});

  factory User.fromFirebaseUser(firebase_auth.User firebaseUser) {
    return User(
      uid: firebaseUser.uid,
      email: firebaseUser.email,
      emailVerified: firebaseUser.emailVerified,
    );
  }
}

class AuthResult {
  final UserModel? user;
  final String? error;

  AuthResult({this.user, this.error});

  bool get isSuccess => error == null && user != null;
}

// Firebase Auth Service
class AuthService {
  // Singleton instance
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal() {
    // Initialize Firebase Auth
    _firebaseAuth = firebase_auth.FirebaseAuth.instance;
    _database = FirebaseDatabase.instance.ref();
    _dbModel = FirebaseDbModel();

    // Add some mock users for testing if needed
    // _addMockUsers();
  }

  // Firebase instances
  late final firebase_auth.FirebaseAuth _firebaseAuth;
  late final DatabaseReference _database;
  late final FirebaseDbModel _dbModel;

  // The Firebase Realtime Database URL
  final String _databaseUrl =
      "https://olofoofo-f4a3a-default-rtdb.firebaseio.com/";

  // Mock user data storage (for fallback/offline use)
  final Map<String, UserModel> _users = {};
  final Map<String, String> _usernames = {};
  final Map<String, String> _passwords =
      {}; // Store passwords (in a real app, these would be hashed)

  User? _currentUser;

  // Stream controller for auth state changes
  final _authStateController = StreamController<User?>.broadcast();
  Stream<User?> get authStateChanges => _authStateController.stream;

  // Get current authenticated user
  User? get currentUser {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser != null) {
      return User.fromFirebaseUser(firebaseUser);
    }
    return _currentUser;
  }

  // Add some mock users for testing
  void _addMockUsers() {
    // Mock user 1
    final user1 = UserModel(
      uid: 'user1',
      email: 'test@example.com',
      username: 'testuser',
      fullName: 'Test User',
      createdAt: DateTime.now().subtract(Duration(days: 30)),
    );
    _users[user1.uid] = user1;
    _usernames[user1.username.toLowerCase()] = user1.uid;
    _passwords[user1.email.toLowerCase()] = 'password123';

    // Mock user 2
    final user2 = UserModel(
      uid: 'user2',
      email: 'john@example.com',
      username: 'johndoe',
      fullName: 'John Doe',
      createdAt: DateTime.now().subtract(Duration(days: 15)),
    );
    _users[user2.uid] = user2;
    _usernames[user2.username.toLowerCase()] = user2.uid;
    _passwords[user2.email.toLowerCase()] = 'password123';
  }

  // Sign up with email and password
  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String username,
    String? fullName,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? gender,
  }) async {
    try {
      // Validate inputs
      final emailError = Validators.validateEmail(email);
      if (emailError != null) {
        return AuthResult(error: emailError);
      }

      final passwordError = Validators.validatePassword(password);
      if (passwordError != null) {
        return AuthResult(error: passwordError);
      }

      final usernameError = Validators.validateUsername(username);
      if (usernameError != null) {
        return AuthResult(error: usernameError);
      }

      // Check if username is already taken in Firebase
      final isAvailable = await _dbModel.isUsernameAvailable(username);
      if (!isAvailable) {
        return AuthResult(error: 'Username is already taken');
      }

      // Check if Firebase Auth is properly initialized
      if (_firebaseAuth == null) {
        print('Firebase Auth is not initialized');
        return AuthResult(
            error: 'Authentication service not initialized properly');
      }

      // Create user with Firebase Auth
      try {
        final userCredential =
            await _firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        final firebaseUser = userCredential.user;
        if (firebaseUser == null) {
          return AuthResult(error: 'Failed to create user');
        }

        // Create user model
        final userModel = UserModel(
          uid: firebaseUser.uid,
          email: email,
          username: username,
          fullName: fullName,
          firstName: firstName,
          lastName: lastName,
          phoneNumber: phoneNumber,
          gender: gender,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
          isEmailVerified: firebaseUser.emailVerified,
        );

        // Store user data in Firebase Realtime Database using our model
        await _dbModel.createUserInDb(userModel);

        // Set as current user
        _currentUser = User.fromFirebaseUser(firebaseUser);

        // Notify listeners
        _authStateController.add(_currentUser);

        // Print debug info
        printDebugInfo();

        return AuthResult(user: userModel);
      } catch (authError) {
        print('Firebase Auth Error: $authError');
        if (authError is firebase_auth.FirebaseAuthException) {
          return AuthResult(error: _handleAuthException(authError.code));
        }
        return AuthResult(
            error: 'Authentication error: ${authError.toString()}');
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('Firebase Auth Exception: ${e.code} - ${e.message}');
      return AuthResult(error: _handleAuthException(e.code));
    } catch (e) {
      print('Unexpected error: $e');
      return AuthResult(error: 'An unexpected error occurred: ${e.toString()}');
    }
  }

  // Sign in with email and password
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Validate inputs
      final emailError = Validators.validateEmail(email);
      if (emailError != null) {
        return AuthResult(error: emailError);
      }

      final passwordError = Validators.validatePassword(password);
      if (passwordError != null) {
        return AuthResult(error: passwordError);
      }

      try {
        // Sign in with Firebase Auth
        final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        final firebaseUser = userCredential.user;
        if (firebaseUser == null) {
          return AuthResult(error: 'Failed to sign in');
        }

        // Get or create user profile with reset followers
        final userModel = await _dbModel.getOrCreateUserProfile(
          firebaseUser.uid,
          email,
          email.split('@')[0], // Default username
        );

        // Set as current user
        _currentUser = User.fromFirebaseUser(firebaseUser);

        // Notify listeners
        _authStateController.add(_currentUser);

        // Update last active timestamp
        await _dbModel.updateUserStats(firebaseUser.uid, {
          'last_active': DateTime.now().millisecondsSinceEpoch,
        });

        // Print debug info
        printDebugInfo();

        return AuthResult(user: userModel);
      } on firebase_auth.FirebaseAuthException catch (e) {
        print(
            'Firebase Auth Exception during sign in: ${e.code} - ${e.message}');

        // Handle configuration-not-found error specifically
        if (e.code == 'configuration-not-found') {
          print(
              'Configuration not found error. Enabling Email/Password sign-in method is required in Firebase console.');

          // Create a mock user for testing purposes when in development
          if (email == 'test@example.com' && password == 'password123') {
            final mockUser = UserModel(
              uid: 'mock-user-id',
              email: email,
              username: 'testuser',
              fullName: 'Test User',
              createdAt: DateTime.now(),
              lastLoginAt: DateTime.now(),
              followersCount: 0,
              followingCount: 0,
              postsCount: 0,
              bio: 'Hello! I am using OFOFO',
            );

            // Set as current user (mock)
            _currentUser = User(
              uid: mockUser.uid,
              email: mockUser.email,
              emailVerified: false,
            );

            // Notify listeners
            _authStateController.add(_currentUser);

            return AuthResult(user: mockUser);
          }

          return AuthResult(
              error:
                  'Email/Password sign-in is not enabled in Firebase console. Please contact the administrator.');
        }

        return AuthResult(error: _handleAuthException(e.code));
      }
    } catch (e) {
      print('Unexpected error during sign in: $e');
      return AuthResult(error: 'An unexpected error occurred: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      // First sign out from Firebase Auth
      await _firebaseAuth.signOut();

      // Then clear local state
      _currentUser = null;

      // Notify listeners
      _authStateController.add(null);
    } catch (e) {
      print('Error during sign out: $e');
      rethrow;
    }
  }

  // Password reset
  Future<String?> resetPassword(String email) async {
    // Validate email
    final emailError = Validators.validateEmail(email);
    if (emailError != null) {
      return emailError;
    }

    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      return _handleAuthException(e.code);
    } catch (e) {
      return 'An unexpected error occurred: ${e.toString()}';
    }
  }

  // Get user profile data
  Future<Map<String, dynamic>> getUserProfile(String uid) async {
    return await _dbModel.getUserProfileFromDb(uid);
  }

  // Get user settings
  Future<Map<String, dynamic>> getUserSettings(String uid) async {
    return await _dbModel.getUserSettingsFromDb(uid);
  }

  // Get user stats
  Future<Map<String, dynamic>> getUserStats(String uid) async {
    return await _dbModel.getUserStatsFromDb(uid);
  }

  // Update user profile
  Future<void> updateProfile(String uid, Map<String, dynamic> data) async {
    await _dbModel.updateUserProfile(uid, data);
  }

  // Update user settings
  Future<void> updateSettings(String uid, Map<String, dynamic> data) async {
    await _dbModel.updateUserSettings(uid, data);
  }

  // Delete user account
  Future<void> deleteAccount(String uid, String username) async {
    try {
      // First delete the user data from the database
      await _dbModel.deleteUser(uid, username);

      // Then delete the Firebase Auth user
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.delete();
      }

      _currentUser = null;
      _authStateController.add(null);
    } catch (e) {
      print('Error deleting account: $e');
      rethrow;
    }
  }

  // Helper to handle Firebase Auth exceptions
  String _handleAuthException(String code) {
    switch (code) {
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
        return 'Email/password accounts are not enabled. Please enable Email/Password authentication in the Firebase console.';
      case 'api-key-not-valid':
        return 'The API key is not valid. Please check your Firebase configuration.';
      case 'configuration-not-found':
        return 'Authentication configuration not found. Please ensure Email/Password authentication is enabled in the Firebase console.';
      default:
        return 'Authentication error: $code';
    }
  }

  // Dispose resources
  void dispose() {
    _authStateController.close();
  }

  // Debug method to print the current state of the mock database
  void printDebugInfo() {
    print('=== DEBUG: AuthService State ===');
    print(
        'Firebase User: ${_firebaseAuth.currentUser?.uid} (${_firebaseAuth.currentUser?.email})');
    print('Current User: ${_currentUser?.uid} (${_currentUser?.email})');
    print('=============================');
  }
}

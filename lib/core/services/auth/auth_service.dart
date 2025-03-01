import 'dart:async';

/// User model representing an authenticated user
class UserModel {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;

  UserModel({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
  });

  factory UserModel.empty() {
    return UserModel(uid: '');
  }

  bool get isEmpty => uid.isEmpty;
  bool get isNotEmpty => !isEmpty;
}

/// Authentication service interface
abstract class AuthService {
  /// Stream of authentication state changes
  Stream<UserModel?> get authStateChanges;

  /// The currently authenticated user, or null if not authenticated
  UserModel? get currentUser;

  /// Sign in with email and password
  Future<UserModel> signInWithEmailAndPassword(String email, String password);

  /// Create a new user with email and password
  Future<UserModel> createUserWithEmailAndPassword(String email, String password);

  /// Sign out the current user
  Future<void> signOut();

  /// Update user profile data
  Future<void> updateProfile({String? displayName, String? photoURL});
} 
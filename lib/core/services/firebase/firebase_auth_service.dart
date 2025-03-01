import 'package:firebase_auth/firebase_auth.dart';
import '../auth/auth_service.dart';

/// Firebase implementation of AuthService
class FirebaseAuthService implements AuthService {
  final FirebaseAuth _firebaseAuth;

  FirebaseAuthService(this._firebaseAuth);

  /// Convert Firebase User to our UserModel
  UserModel? _userFromFirebase(User? user) {
    if (user == null) return null;

    return UserModel(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoURL: user.photoURL,
    );
  }

  @override
  Stream<UserModel?> get authStateChanges =>
      _firebaseAuth.authStateChanges().map(_userFromFirebase);

  @override
  UserModel? get currentUser => _userFromFirebase(_firebaseAuth.currentUser);

  @override
  Future<UserModel> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = _userFromFirebase(userCredential.user);
      if (user == null) {
        throw Exception('Failed to sign in: User is null');
      }

      return user;
    } catch (e) {
      throw Exception('Failed to sign in: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = _userFromFirebase(userCredential.user);
      if (user == null) {
        throw Exception('Failed to create user: User is null');
      }

      return user;
    } catch (e) {
      throw Exception('Failed to create user: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('No user signed in');
      }

      await user.updateDisplayName(displayName);
      await user.updatePhotoURL(photoURL);
    } catch (e) {
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }
}

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_service.dart';

class SupabaseAuthService implements AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Stream<UserModel?> get authStateChanges {
    return _supabase.auth.onAuthStateChange.map((authState) {
      final user = authState.session?.user;
      if (user == null) return null;

      return UserModel(
        uid: user.id,
        email: user.email,
        displayName: user.userMetadata?['display_name'] as String?,
        photoURL: user.userMetadata?['avatar_url'] as String?,
      );
    });
  }

  @override
  UserModel? get currentUser {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    return UserModel(
      uid: user.id,
      email: user.email,
      displayName: user.userMetadata?['display_name'] as String?,
      photoURL: user.userMetadata?['avatar_url'] as String?,
    );
  }

  @override
  Future<UserModel> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw Exception('Failed to sign in');
      }

      return UserModel(
        uid: user.id,
        email: user.email,
        displayName: user.userMetadata?['display_name'] as String?,
        photoURL: user.userMetadata?['avatar_url'] as String?,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Sign in error: $e');
      }
      rethrow;
    }
  }

  @override
  Future<UserModel> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw Exception('Failed to create user');
      }

      // Create user profile in the database
      try {
        await _createUserProfile(user.id, {
          'email': email,
          'display_name': email.split('@').first,
        });
      } catch (e) {
        if (kDebugMode) {
          print('Create profile error: $e');
        }
        // Continue even if profile creation fails
        // The user can update their profile later
      }

      return UserModel(
        uid: user.id,
        email: user.email,
        displayName: email.split('@').first,
        photoURL: null,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Sign up error: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      if (kDebugMode) {
        print('Sign out error: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user');
      }

      // Update user metadata
      Map<String, dynamic> userData = {};
      if (displayName != null) userData['display_name'] = displayName;
      if (photoURL != null) userData['avatar_url'] = photoURL;

      // Update profile in the database
      await _updateUserProfile(user.id, userData);
    } catch (e) {
      if (kDebugMode) {
        print('Update profile error: $e');
      }
      rethrow;
    }
  }

  // Helper method to create user profile in the database
  Future<void> _createUserProfile(
      String userId, Map<String, dynamic> data) async {
    try {
      if (kDebugMode) {
        print('Creating profile for user: $userId with data: $data');
      }

      // Add the id to the data
      final profileData = {
        'id': userId,
        'created_at': DateTime.now().toIso8601String(),
        ...data,
      };

      // Use RLS policy that allows users to create their own profiles
      await _supabase.from('profiles').insert(profileData);

      if (kDebugMode) {
        print('Profile created successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Create profile error: $e');
      }
      rethrow;
    }
  }

  // Helper method to update user profile in the database
  Future<void> _updateUserProfile(
      String userId, Map<String, dynamic> data) async {
    try {
      await _supabase.from('profiles').update(data).eq('id', userId);
    } catch (e) {
      if (kDebugMode) {
        print('Update profile error: $e');
      }
      rethrow;
    }
  }
}

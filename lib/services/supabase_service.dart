import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;

class SupabaseService extends ChangeNotifier {
  // Supabase client instance
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Auth state changes stream
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Sign in with email and password
  Future<AuthResponse> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      notifyListeners();
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Sign in error: $e');
      }
      rethrow;
    }
  }

  // Sign up with email and password
  Future<AuthResponse> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      notifyListeners();
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Sign up error: $e');
      }
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Sign out error: $e');
      }
      rethrow;
    }
  }

  // Password reset
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      if (kDebugMode) {
        print('Password reset error: $e');
      }
      rethrow;
    }
  }

  // Upload image to storage
  Future<String> uploadImage(dynamic imageFile, String folder) async {
    try {
      final userId = currentUser?.id ?? 'anonymous';
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName =
          '$userId-$timestamp${kIsWeb ? '.jpg' : path.extension(imageFile.path)}';
      final filePath = '$folder/$fileName';

      if (kIsWeb) {
        // Handle web file upload
        await _supabase.storage.from(folder).uploadBinary(
              fileName,
              imageFile,
              fileOptions:
                  const FileOptions(cacheControl: '3600', upsert: true),
            );
      } else {
        // Handle native file upload
        await _supabase.storage.from(folder).upload(
              fileName,
              File(imageFile.path),
              fileOptions:
                  const FileOptions(cacheControl: '3600', upsert: true),
            );
      }

      // Get public URL
      final imageUrl = _supabase.storage.from(folder).getPublicUrl(fileName);
      return imageUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Upload error: $e');
      }
      rethrow;
    }
  }

  // Create user profile
  Future<void> createUserProfile(
      String userId, Map<String, dynamic> data) async {
    try {
      if (kDebugMode) {
        print('Creating profile for user: $userId with data: $data');
      }

      // Make sure we're authenticated as this user
      if (currentUser?.id != userId) {
        if (kDebugMode) {
          print(
              'Warning: Creating profile for a different user ID than currently authenticated');
        }
      }

      // Add the id to the data
      final profileData = {
        'id': userId,
        'created_at': DateTime.now().toIso8601String(),
        ...data,
      };

      // Use upsert instead of insert to handle cases where the profile might already exist
      await _supabase.from('profiles').upsert(profileData);

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

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final data =
          await _supabase.from('profiles').select().eq('id', userId).single();
      return data;
    } catch (e) {
      if (kDebugMode) {
        print('Get profile error: $e');
      }
      return null;
    }
  }

  // Update user profile
  Future<void> updateUserProfile(
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

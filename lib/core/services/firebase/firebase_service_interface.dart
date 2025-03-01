import 'dart:typed_data';
import 'package:flutter/foundation.dart';

// Auth Service Interface
abstract class AuthServiceInterface {
  Stream<UserModel?> get authStateChanges;
  UserModel? get currentUser;
  Future<UserModel?> signInWithEmailAndPassword(String email, String password);
  Future<UserModel?> createUserWithEmailAndPassword(
      String email, String password);
  Future<void> signOut();
}

// Database Service Interface
abstract class DatabaseServiceInterface {
  Future<void> saveData(
      String collection, String docId, Map<String, dynamic> data);
  Future<Map<String, dynamic>?> getData(String collection, String docId);
  Stream<List<Map<String, dynamic>>> streamCollection(String collection);
  Future<void> deleteDocument(String collection, String docId);
}

// Storage Service Interface
abstract class StorageServiceInterface {
  Future<String> uploadFile(String path, Uint8List fileData);
  Future<Uint8List?> downloadFile(String path);
  Future<void> deleteFile(String path);
}

// Simple user model
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
}

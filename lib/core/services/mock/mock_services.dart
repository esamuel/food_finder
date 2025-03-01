import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import '../firebase/firebase_service_interface.dart';
import '../food_recognition_service.dart';

// Mock Authentication Service
class MockAuthService implements AuthServiceInterface {
  UserModel? _currentUser;
  final _authStateController = StreamController<UserModel?>.broadcast();

  MockAuthService() {
    // Initially signed out
    _currentUser = null;
    _authStateController.add(null);
  }

  @override
  Stream<UserModel?> get authStateChanges => _authStateController.stream;

  @override
  UserModel? get currentUser => _currentUser;

  @override
  Future<UserModel?> signInWithEmailAndPassword(
      String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Mock successful login with test@example.com/password
    if (email == 'test@example.com' && password == 'password') {
      final user = UserModel(
        uid: 'mock-user-123',
        email: email,
        displayName: 'Test User',
        photoURL: 'https://via.placeholder.com/150',
      );
      _currentUser = user;
      _authStateController.add(user);
      return user;
    }

    // Simulate auth error
    throw Exception('Invalid email or password');
  }

  @override
  Future<UserModel?> createUserWithEmailAndPassword(
      String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Create a mock user
    final user = UserModel(
      uid: 'mock-user-${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      displayName: email.split('@').first,
    );

    _currentUser = user;
    _authStateController.add(user);
    return user;
  }

  @override
  Future<void> signOut() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    _currentUser = null;
    _authStateController.add(null);
  }

  @override
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    if (_currentUser != null) {
      _currentUser = UserModel(
        uid: _currentUser!.uid,
        email: _currentUser!.email,
        displayName: displayName ?? _currentUser!.displayName,
        photoURL: photoURL ?? _currentUser!.photoURL,
      );
      _authStateController.add(_currentUser);
    }
  }
}

// Mock Database Service
class MockDatabaseService implements DatabaseServiceInterface {
  final Map<String, Map<String, Map<String, dynamic>>> _database = {};

  @override
  Future<void> saveData(
      String collection, String docId, Map<String, dynamic> data) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Create collection if it doesn't exist
    _database[collection] ??= {};

    // Save or update document
    _database[collection]![docId] = data;
  }

  @override
  Future<Map<String, dynamic>?> getData(String collection, String docId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    // Return null if collection or document doesn't exist
    if (!_database.containsKey(collection)) return null;
    if (!_database[collection]!.containsKey(docId)) return null;

    return _database[collection]![docId];
  }

  @override
  Stream<List<Map<String, dynamic>>> streamCollection(String collection) {
    // Create a broadcast controller for streaming
    final controller = StreamController<List<Map<String, dynamic>>>.broadcast();

    // Initial data
    if (_database.containsKey(collection)) {
      controller.add(_database[collection]!.values.toList());
    } else {
      controller.add([]);
    }

    // Simulate occasional updates
    Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_database.containsKey(collection)) {
        controller.add(_database[collection]!.values.toList());
      }
    });

    return controller.stream;
  }

  @override
  Future<void> deleteDocument(String collection, String docId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    // Delete document if it exists
    if (_database.containsKey(collection)) {
      _database[collection]!.remove(docId);
    }
  }
}

// Mock Storage Service
class MockStorageService implements StorageServiceInterface {
  final Map<String, Uint8List> _storage = {};

  @override
  Future<String> uploadFile(String path, Uint8List fileData) async {
    // Simulate network delay and upload
    await Future.delayed(const Duration(milliseconds: 1000));

    // Store the file
    _storage[path] = fileData;

    // Return a mock URL
    return 'https://storage.example.com/$path';
  }

  @override
  Future<Uint8List?> downloadFile(String path) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Return the file if it exists
    return _storage[path];
  }

  @override
  Future<void> deleteFile(String path) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Remove the file
    _storage.remove(path);
  }
}

// Mock Food Recognition Service
class MockFoodRecognitionService implements FoodRecognitionServiceInterface {
  final List<RecognitionResult> _mockResults = [
    RecognitionResult(
      label: 'Apple',
      confidence: 0.95,
      metadata: {'calories': 95, 'category': 'Fruit'},
    ),
    RecognitionResult(
      label: 'Banana',
      confidence: 0.87,
      metadata: {'calories': 105, 'category': 'Fruit'},
    ),
    RecognitionResult(
      label: 'Pizza',
      confidence: 0.92,
      metadata: {'calories': 285, 'category': 'Fast Food'},
    ),
    RecognitionResult(
      label: 'Salad',
      confidence: 0.82,
      metadata: {'calories': 120, 'category': 'Vegetables'},
    ),
    RecognitionResult(
      label: 'Sushi',
      confidence: 0.85,
      metadata: {'calories': 350, 'category': 'Seafood'},
    ),
  ];

  @override
  Future<List<RecognitionResult>> recognizeFood(Uint8List imageBytes) async {
    // Simulate processing delay
    await Future.delayed(const Duration(milliseconds: 1500));

    // Return random subset of mock results
    final random = math.Random();
    final resultsCount = random.nextInt(3) + 1; // 1-3 results

    // Shuffle and take a subset
    final results = List<RecognitionResult>.from(_mockResults)..shuffle();
    return results.take(resultsCount).toList();
  }

  @override
  Future<List<RecognitionResult>> recognizeFoodFromFile(File file) async {
    // For non-web platforms
    if (!kIsWeb) {
      final bytes = await file.readAsBytes();
      return recognizeFood(bytes);
    }

    // Should not be called on web, but provide fallback
    return recognizeFood(Uint8List(0));
  }

  @override
  Future<void> dispose() async {
    // Nothing to dispose in mock implementation
  }
}

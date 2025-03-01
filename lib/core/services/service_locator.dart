import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Service interfaces
import 'auth/auth_service.dart';
import 'database/database_service.dart';
import 'storage/storage_service.dart';
import 'food_recognition/food_recognition_service.dart';

// Firebase implementations
import 'firebase/firebase_auth_service.dart';
import 'firebase/firebase_database_service.dart';
import 'firebase/firebase_storage_service.dart';

// Mock implementations
import 'mock/mock_services.dart';

final GetIt serviceLocator = GetIt.instance;

/// Initialize the service locator with either real or mock services
Future<void> setupServiceLocator({bool useMock = false}) async {
  // Register services based on whether we're using mock or real implementations
  if (useMock) {
    _registerMockServices();
    print('🔧 Registered mock services');
  } else {
    await _registerFirebaseServices();
    print('🔧 Registered Firebase services');
  }
}

/// Register Firebase-based implementations of all services
Future<void> _registerFirebaseServices() async {
  // Register Firebase instances
  final firebaseAuth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;

  // Register services with Firebase implementations
  serviceLocator.registerSingleton<AuthService>(
    FirebaseAuthService(firebaseAuth),
  );

  serviceLocator.registerSingleton<DatabaseService>(
    FirebaseDatabaseService(firestore),
  );

  serviceLocator.registerSingleton<StorageService>(
    FirebaseStorageService(storage),
  );

  // Food recognition service would be registered here
  // This depends on your implementation - for now, we'll use a mock
  serviceLocator.registerSingleton<FoodRecognitionService>(
    MockFoodRecognitionService(),
  );
}

/// Register mock implementations of all services for testing
void _registerMockServices() {
  serviceLocator.registerSingleton<AuthService>(MockAuthService());
  serviceLocator.registerSingleton<DatabaseService>(MockDatabaseService());
  serviceLocator.registerSingleton<StorageService>(MockStorageService());
  serviceLocator
      .registerSingleton<FoodRecognitionService>(MockFoodRecognitionService());
}

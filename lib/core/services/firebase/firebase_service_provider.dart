import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

import '../mock_services.dart';
import 'firebase_auth_service.dart';
import 'firebase_database_service.dart';
import 'firebase_storage_service.dart';
import '../../viewmodels/home_screen_viewmodel.dart';
import '../food_recognition_service.dart';
import 'firebase_service_interface.dart';

/// A provider that makes Firebase services available throughout the app
class FirebaseServiceProvider extends StatelessWidget {
  final Widget child;

  const FirebaseServiceProvider({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Create actual Firebase services
    return MultiProvider(
      providers: [
        // Provide Firebase Auth Service
        Provider<AuthServiceInterface>(
          create: (context) => FirebaseAuthService(),
          dispose: (context, service) {
            // Clean up any resources if needed
          },
        ),

        // Provide Firebase Database Service
        Provider<DatabaseServiceInterface>(
          create: (context) => FirebaseDatabaseService(),
          dispose: (context, service) {
            // Clean up any resources if needed
          },
        ),

        // Provide Firebase Storage Service
        Provider<StorageServiceInterface>(
          create: (context) => FirebaseStorageService(),
          dispose: (context, service) {
            // Clean up any resources if needed
          },
        ),

        // Use platform-specific implementation for food recognition
        Provider<FoodRecognitionServiceInterface>(
          create: (context) {
            // For web, could use a cloud-based API implementation
            // For mobile, could use TFLite or MLKit implementation
            if (kIsWeb) {
              return WebFoodRecognitionService();
            } else {
              return MobileFoodRecognitionService();
            }
          },
          dispose: (context, service) async {
            await service.dispose();
          },
        ),

        // Provide HomeScreenViewModel
        ChangeNotifierProxyProvider2<AuthServiceInterface,
            DatabaseServiceInterface, HomeScreenViewModel>(
          create: (context) => HomeScreenViewModel(
            authService:
                Provider.of<AuthServiceInterface>(context, listen: false),
            databaseService:
                Provider.of<DatabaseServiceInterface>(context, listen: false),
          ),
          update: (context, authService, databaseService, previous) =>
              previous ??
              HomeScreenViewModel(
                authService: authService,
                databaseService: databaseService,
              ),
        ),
      ],
      child: child,
    );
  }
}

// Placeholder implementations - these would be replaced with actual implementations
class FirebaseAuthService implements AuthServiceInterface {
  @override
  Stream<UserModel?> get authStateChanges => throw UnimplementedError();

  @override
  UserModel? get currentUser => throw UnimplementedError();

  @override
  Future<UserModel?> createUserWithEmailAndPassword(
      String email, String password) {
    throw UnimplementedError();
  }

  @override
  Future<UserModel?> signInWithEmailAndPassword(String email, String password) {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() {
    throw UnimplementedError();
  }
}

class FirebaseDatabaseService implements DatabaseServiceInterface {
  @override
  Future<void> deleteDocument(String collection, String docId) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>?> getData(String collection, String docId) {
    throw UnimplementedError();
  }

  @override
  Future<void> saveData(
      String collection, String docId, Map<String, dynamic> data) {
    throw UnimplementedError();
  }

  @override
  Stream<List<Map<String, dynamic>>> streamCollection(String collection) {
    throw UnimplementedError();
  }
}

class FirebaseStorageService implements StorageServiceInterface {
  @override
  Future<void> deleteFile(String path) {
    throw UnimplementedError();
  }

  @override
  Future<Uint8List?> downloadFile(String path) {
    throw UnimplementedError();
  }

  @override
  Future<String> uploadFile(String path, Uint8List fileData) {
    throw UnimplementedError();
  }
}

// Placeholder implementations for food recognition services
class WebFoodRecognitionService implements FoodRecognitionServiceInterface {
  @override
  Future<void> dispose() async {
    // Cleanup resources
  }

  @override
  Future<List<RecognitionResult>> recognizeFood(Uint8List imageBytes) async {
    // This would call a cloud API service
    throw UnimplementedError();
  }

  @override
  Future<List<RecognitionResult>> recognizeFoodFromFile(File file) async {
    throw UnimplementedError();
  }
}

class MobileFoodRecognitionService implements FoodRecognitionServiceInterface {
  @override
  Future<void> dispose() async {
    // Cleanup ML resources
  }

  @override
  Future<List<RecognitionResult>> recognizeFood(Uint8List imageBytes) async {
    // This would use on-device ML
    throw UnimplementedError();
  }

  @override
  Future<List<RecognitionResult>> recognizeFoodFromFile(File file) async {
    final bytes = await file.readAsBytes();
    return recognizeFood(bytes);
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'app.dart';

/// This is the entry point for the web version of the Food Finder application.
///
/// It configures web-specific settings and initializes the app with appropriate
/// configurations for web platforms.
void main() async {
  // Enable URL strategy that uses path URLs instead of hash URLs
  // This makes web URLs cleaner (e.g., /search instead of /#/search)
  usePathUrlStrategy();

  // Initialize Flutter binding
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await _initializeFirebase();

  // Configure web-specific settings
  _configureWebApp();

  // Run the app
  runApp(const FoodFinderApp());
}

/// Configures web-specific settings for the application.
void _configureWebApp() {
  // Log that we're running in web mode
  debugPrint('Running in WEB mode');

  // Set web renderer to auto or canvaskit as needed
  // The auto renderer uses HTML elements when possible and falls back to CanvasKit
  // The canvaskit renderer provides more consistent rendering across platforms
  // but has a larger download size

  // Example web-specific configurations:

  // 1. Configure viewport meta tag for responsive design
  // This is typically done in the web/index.html file

  // 2. Set up service workers for PWA support
  // This is typically done in the web/index.html file

  // 3. Configure web-specific error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    // You could also log to a web-based logging service here
  };

  // 4. Set up web-specific analytics
  // Example: Initialize Firebase Analytics for web

  // 5. Configure browser history handling
  // This is handled by the PathUrlStrategy set above
}

Future<void> _initializeFirebase() async {
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "YOUR_API_KEY",
        authDomain: "YOUR_AUTH_DOMAIN",
        projectId: "YOUR_PROJECT_ID",
        storageBucket: "YOUR_STORAGE_BUCKET",
        messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
        appId: "YOUR_APP_ID",
      ),
    );

    if (kDebugMode) {
      print('Firebase initialized successfully');
    }

    // Initialize Firebase Auth for web
    await FirebaseAuth.instance.authStateChanges().first;

    // Set Firestore settings for web
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    // Initialize Firebase Storage for web
    FirebaseStorage.instance;
  } catch (e) {
    if (kDebugMode) {
      print('Error initializing Firebase: $e');
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:food_finder/core/services/mock_services.dart';
import 'package:food_finder/core/services/food_recognition_service.dart';
import 'package:camera/camera.dart';
import 'dart:typed_data'; // Add import for Uint8List
import 'package:food_finder/config/routes.dart'; // Add import for routes
import 'package:image_picker/image_picker.dart';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:food_finder/core/models/recognition_result.dart';

/// iOS-specific entry point for the Food Finder application.
/// This entry point is designed to avoid common iOS launch issues.
void main() async {
  // Ensure Flutter is initialized before anything else
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize camera
  List<CameraDescription> cameras = [];
  try {
    cameras = await availableCameras();
  } catch (e) {
    print('Error initializing cameras: $e');
    // Continue with empty camera list
  }

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Disable network operations during launch
  // This prevents Google Fonts and other network requests from causing issues
  final authService = MockAuthService();
  final databaseService = MockDatabaseService();
  final storageService = MockStorageService();
  final foodRecognitionService = MockFoodRecognitionService();

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthServiceInterface>.value(value: authService),
        Provider<DatabaseServiceInterface>.value(value: databaseService),
        Provider<StorageServiceInterface>.value(value: storageService),
        Provider<FoodRecognitionServiceInterface>.value(
            value: foodRecognitionService),
        // Provide camera list
        Provider<List<CameraDescription>>.value(value: cameras),
      ],
      child: const IOSFoodFinderApp(),
    ),
  );
}

class IOSFoodFinderApp extends StatelessWidget {
  const IOSFoodFinderApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Finder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
        // Use system fonts instead of Google Fonts
        fontFamily: '.SF Pro Text',
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
        // Use system fonts instead of Google Fonts
        fontFamily: '.SF Pro Text',
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}

class IOSHomeScreen extends StatelessWidget {
  const IOSHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Finder'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.restaurant,
              size: 100,
              color: Colors.green,
            ),
            const SizedBox(height: 20),
            Text(
              'Welcome to Food Finder',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Text(
              'Identify foods with your camera',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Camera functionality is mocked in this version'),
                  ),
                );
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text('Take a Photo'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () async {
                // Show loading indicator
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Opening gallery...'),
                    duration: Duration(seconds: 1),
                  ),
                );

                try {
                  // Get the mock food recognition service
                  final foodRecognitionService =
                      Provider.of<FoodRecognitionServiceInterface>(context,
                          listen: false);

                  // Create an ImagePicker instance
                  final ImagePicker picker = ImagePicker();

                  // Simulate image selection delay
                  await Future.delayed(const Duration(seconds: 1));

                  List<RecognitionResult> results;

                  if (kIsWeb) {
                    // For web, use mock results directly
                    try {
                      final XFile? pickedFile =
                          await picker.pickImage(source: ImageSource.gallery);

                      if (pickedFile == null) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('No image selected')),
                          );
                        }
                        return;
                      }

                      // For web, read as bytes
                      final bytes = await pickedFile.readAsBytes();
                      results =
                          await foodRecognitionService.recognizeFood(bytes);
                    } catch (e) {
                      // If image picking fails, use mock results
                      print('Error picking image: $e');
                      results = await foodRecognitionService
                          .recognizeFood(Uint8List(0));
                    }
                  } else {
                    // For mobile, try to pick an image
                    try {
                      final XFile? pickedFile =
                          await picker.pickImage(source: ImageSource.gallery);

                      if (pickedFile == null) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('No image selected')),
                          );
                        }
                        return;
                      }

                      // For mobile, use File
                      final File file = File(pickedFile.path);
                      results = await foodRecognitionService
                          .recognizeFoodFromFile(file);
                    } catch (e) {
                      // If image picking fails, use mock results
                      print('Error picking image: $e');
                      results = await foodRecognitionService
                          .recognizeFood(Uint8List(0));
                    }
                  }

                  // Navigate to results screen
                  if (context.mounted) {
                    Navigator.of(context).pushNamed(
                      AppRoutes.results,
                      arguments: {'results': results},
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error processing image: $e'),
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.photo_library),
              label: const Text('Choose from Gallery'),
            ),
            const SizedBox(height: 20),
            Text(
              'iOS Launch Fix Version',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

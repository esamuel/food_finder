import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:food_finder/core/services/mock_services.dart';
import 'package:food_finder/core/services/food_recognition_service.dart';
import 'package:camera/camera.dart';
import 'dart:typed_data';
import 'package:food_finder/config/routes.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:food_finder/core/models/recognition_result.dart';
import 'app.dart';
// Import the TensorFlow Lite service with conditional import
import 'core/services/food_recognition_tflite.dart'
    if (dart.library.js) 'core/services/food_recognition_web.dart';
import 'core/services/nutrition_service.dart';
import 'core/services/recipe_service.dart';
import 'core/services/user_preferences_service.dart';
import 'core/viewmodels/food_recognition_viewmodel.dart';
import 'core/viewmodels/nutrition_viewmodel.dart';
import 'core/viewmodels/recipe_viewmodel.dart';
import 'core/viewmodels/user_preferences_viewmodel.dart';
import 'ui/screens/home_screen.dart';
import 'ui/theme/app_theme.dart';

/// This is a Firebase-free entry point for the Food Finder application.
/// It uses mock services for all backend functionality.
void main() async {
  // Ensure Flutter is initialized
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

  // Initialize mock services
  final authService = MockAuthService();
  final databaseService = MockDatabaseService();
  final storageService = MockStorageService();

  // Use EnhancedMockFoodRecognitionService for food recognition
  // This is the most reliable option, especially for web platforms
  // Other options (which may have compatibility issues):
  // - ClarifaiFoodRecognitionService() for Clarifai API
  // - GoogleVisionFoodRecognitionService() for Google Cloud Vision API
  // - TFLiteFoodRecognitionService() for TensorFlow Lite (not compatible with web)
  final foodRecognitionService = EnhancedMockFoodRecognitionService();

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthServiceInterface>.value(value: authService),
        Provider<DatabaseServiceInterface>.value(value: databaseService),
        Provider<StorageServiceInterface>.value(value: storageService),
        Provider<FoodRecognitionServiceInterface>(
          // Use platform-specific implementation
          create: (_) => kIsWeb
              ? EnhancedMockFoodRecognitionService() // Use mock for web
              : TFLiteFoodRecognitionService(), // Use TFLite for mobile
          dispose: (_, service) {
            // Dispose resources if needed
            if (service is TFLiteFoodRecognitionService) {
              service.dispose();
            }
          },
        ),
        // Provide camera list
        Provider<List<CameraDescription>>.value(value: cameras),
        ChangeNotifierProxyProvider<FoodRecognitionServiceInterface,
            FoodRecognitionViewModel>(
          create: (context) => FoodRecognitionViewModel(
            Provider.of<FoodRecognitionServiceInterface>(context,
                listen: false),
          ),
          update: (context, service, previous) =>
              previous!..updateService(service),
        ),

        // Nutrition Service & ViewModel
        Provider<NutritionService>(
          create: (_) => MockNutritionService(),
        ),
        ChangeNotifierProxyProvider<NutritionService, NutritionViewModel>(
          create: (context) => NutritionViewModel(
            Provider.of<NutritionService>(context, listen: false),
          ),
          update: (context, service, previous) =>
              previous!..updateService(service),
        ),

        // Recipe Service & ViewModel
        Provider<RecipeService>(
          create: (_) => MockRecipeService(),
        ),
        ChangeNotifierProxyProvider<RecipeService, RecipeViewModel>(
          create: (context) => RecipeViewModel(
            Provider.of<RecipeService>(context, listen: false),
          ),
          update: (context, service, previous) =>
              previous!..updateService(service),
        ),

        // User Preferences Service & ViewModel
        Provider<UserPreferencesService>(
          create: (_) => MockUserPreferencesService(),
        ),
        ChangeNotifierProxyProvider<UserPreferencesService,
            UserPreferencesViewModel>(
          create: (context) => UserPreferencesViewModel(
            Provider.of<UserPreferencesService>(context, listen: false),
          ),
          update: (context, service, previous) =>
              previous!..updateService(service),
        ),
      ],
      child: const FoodFinderApp(),
    ),
  );
}

class FoodFinderApp extends StatelessWidget {
  const FoodFinderApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Finder',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRoutes.generateRoute,
      builder: (context, child) {
        // Apply additional constraints for mobile-like experience
        return MediaQuery(
          // Set a fixed device pixel ratio to ensure consistent sizing
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: 1.0,
            devicePixelRatio: 1.0,
          ),
          child: child!,
        );
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Uint8List? _selectedImageBytes;
  String? _selectedImagePath;
  bool _isAnalyzing = false;

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
            // Display selected image or default icon
            if (_selectedImageBytes != null || _selectedImagePath != null)
              Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _selectedImageBytes != null
                      ? Image.memory(
                          _selectedImageBytes!,
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          File(_selectedImagePath!),
                          fit: BoxFit.cover,
                        ),
                ),
              )
            else
              const Icon(
                Icons.restaurant,
                size: 100,
                color: Colors.green,
              ),
            const SizedBox(height: 20),
            if (_selectedImageBytes == null && _selectedImagePath == null)
              Text(
                'Welcome to Food Finder',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            const SizedBox(height: 10),
            if (_selectedImageBytes == null && _selectedImagePath == null)
              Text(
                'Identify foods with your camera',
                style: Theme.of(context).textTheme.bodyLarge,
              )
            else
              Text(
                'Ready to analyze your food',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            const SizedBox(height: 40),
            if (_isAnalyzing)
              Column(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Analyzing image...',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              )
            else if (_selectedImageBytes != null || _selectedImagePath != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _analyzeSelectedImage,
                    icon: const Icon(Icons.search),
                    label: const Text('Analyze Food'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedImageBytes = null;
                        _selectedImagePath = null;
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Choose Another'),
                  ),
                ],
              )
            else
              Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: _takePhoto,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Take a Photo'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: _pickFromGallery,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Choose from Gallery'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _takePhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        // User canceled the camera
        return;
      }

      setState(() {
        _selectedImagePath = pickedFile.path;
        _isAnalyzing = true;
      });

      debugPrint('Photo taken: ${pickedFile.path}');

      // Handle differently for web and mobile
      if (kIsWeb) {
        // For web, read as bytes
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
        });
        debugPrint('Read image bytes for web: ${bytes.length} bytes');
      }

      // Automatically analyze the image
      await _analyzeSelectedImage();
    } catch (e) {
      debugPrint('Error taking photo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error taking photo: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        // User canceled the picker
        return;
      }

      setState(() {
        _selectedImagePath = pickedFile.path;
        _isAnalyzing = true;
      });

      debugPrint('Image picked: ${pickedFile.path}');

      // Handle differently for web and mobile
      if (kIsWeb) {
        // For web, read as bytes
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
        });
        debugPrint('Read image bytes for web: ${bytes.length} bytes');
      }

      // Don't automatically analyze - let user confirm
      setState(() {
        _isAnalyzing = false;
      });
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  Future<void> _analyzeSelectedImage() async {
    if (_selectedImageBytes == null && _selectedImagePath == null) {
      debugPrint('No image selected for analysis');
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    try {
      // Get the food recognition service
      final foodRecognitionService =
          Provider.of<FoodRecognitionServiceInterface>(context, listen: false);

      // Get the database service for saving the image
      final databaseService =
          Provider.of<DatabaseServiceInterface>(context, listen: false);

      List<RecognitionResult> results;
      Uint8List? imageBytes;

      if (kIsWeb && _selectedImageBytes != null) {
        // For web or if we have bytes
        debugPrint(
            'Analyzing image from bytes: ${_selectedImageBytes!.length} bytes');
        results =
            await foodRecognitionService.recognizeFood(_selectedImageBytes!);
        imageBytes = _selectedImageBytes;
      } else if (_selectedImagePath != null) {
        // For mobile with file path
        debugPrint('Analyzing image from file: $_selectedImagePath');
        final File file = File(_selectedImagePath!);
        results = await foodRecognitionService.recognizeFoodFromFile(file);

        // Also read the bytes for display
        imageBytes = await file.readAsBytes();
        debugPrint('Read image bytes from file: ${imageBytes.length} bytes');
      } else {
        throw Exception('No image data available');
      }

      debugPrint('Recognition results: ${results.length} items');
      for (var result in results) {
        debugPrint(
            '  - ${result.label}: ${(result.confidence * 100).toStringAsFixed(1)}%');
      }

      // Save the image to the database if we have results
      if (results.isNotEmpty && imageBytes != null) {
        // In a real app, we would upload the image to storage and save the URL
        // For this mock version, we'll just log that we would save it
        debugPrint('Would save image for food: ${results.first.label}');

        // Mock saving the image to the database
        // In a real app, this would be a call to a storage service
        final mockImageUrl =
            'https://example.com/food_images/${DateTime.now().millisecondsSinceEpoch}.jpg';

        // Add the image to the food item's data
        // In a real app, this would update the food item in the database
        debugPrint('Image URL saved: $mockImageUrl');
      }

      // Navigate to results screen
      if (mounted) {
        debugPrint('Navigating to results screen with image data');
        if (imageBytes != null) {
          debugPrint('Passing image bytes: ${imageBytes.length} bytes');
        }
        if (_selectedImagePath != null) {
          debugPrint('Passing image path: $_selectedImagePath');
        }

        Navigator.of(context).pushNamed(
          AppRoutes.results,
          arguments: {
            'results': results,
            'imageBytes': imageBytes,
            'imagePath': _selectedImagePath,
          },
        );
      }
    } catch (e) {
      debugPrint('Error analyzing image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error analyzing image: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }
}

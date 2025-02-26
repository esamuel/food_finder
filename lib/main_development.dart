import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:food_finder/ui/screens/home/home_screen.dart';
import 'package:food_finder/core/services/mock_services.dart';
import 'package:food_finder/core/services/food_recognition_service.dart';
import 'package:food_finder/core/services/tflite_food_recognition_service.dart';
import 'package:food_finder/config/routes.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:camera/camera.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

// Development environment entry point
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure web plugins
  if (kIsWeb) {
    setUrlStrategy(PathUrlStrategy());
  }

  // Initialize camera for non-web platforms
  List<CameraDescription> cameras = [];
  if (!kIsWeb) {
    try {
      cameras = await availableCameras();
    } catch (e) {
      debugPrint('Error initializing cameras: $e');
    }
  }

  // Initialize services
  final authService = MockAuthService();
  final databaseService = MockDatabaseService();
  final storageService = MockStorageService();

  // Use TFLite food recognition service for non-web platforms, otherwise use mock
  final FoodRecognitionServiceInterface foodRecognitionService =
      kIsWeb ? MockFoodRecognitionService() : TFLiteFoodRecognitionService();

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthServiceInterface>.value(value: authService),
        Provider<DatabaseServiceInterface>.value(value: databaseService),
        Provider<StorageServiceInterface>.value(value: storageService),
        Provider<FoodRecognitionServiceInterface>.value(
            value: foodRecognitionService),
        Provider<List<CameraDescription>>.value(value: cameras),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Finder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system, // Respect system theme
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:food_finder/ui/screens/home/home_screen.dart';
import 'package:food_finder/core/services/mock_services.dart';
import 'package:food_finder/core/services/food_recognition_service.dart';
import 'package:food_finder/core/services/web_food_recognition_service.dart';
import 'package:food_finder/config/routes.dart';

/// Web development entry point that avoids TensorFlow Lite dependencies
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure web plugins
  setUrlStrategy(PathUrlStrategy());

  // Initialize services with web-compatible implementations
  final authService = MockAuthService();
  final databaseService = MockDatabaseService();
  final storageService = MockStorageService();

  // Use web-specific food recognition service
  final foodRecognitionService = WebFoodRecognitionService();

  // Empty camera list for web
  final cameras = [];

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthServiceInterface>.value(value: authService),
        Provider<DatabaseServiceInterface>.value(value: databaseService),
        Provider<StorageServiceInterface>.value(value: storageService),
        Provider<FoodRecognitionServiceInterface>.value(
            value: foodRecognitionService),
        Provider<List<dynamic>>.value(value: cameras),
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
      title: 'Food Finder Web',
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

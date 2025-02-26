import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:food_finder/ui/screens/home/home_screen.dart';
import 'package:food_finder/core/services/mock_services.dart';
import 'package:food_finder/core/services/food_recognition_service.dart';
import 'package:food_finder/config/routes.dart';

// Simplified iOS Development entry point
void main() {
  // Basic initialization only
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize mock services for development
  final authService = MockAuthService();
  final databaseService = MockDatabaseService();
  final storageService = MockStorageService();

  // Use MockFoodRecognitionService to avoid TFLite issues
  final foodRecognitionService = MockFoodRecognitionService();

  // Empty camera list to avoid camera initialization issues
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

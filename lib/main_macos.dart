import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:food_finder/core/services/mock_services.dart';
import 'package:food_finder/core/services/food_recognition_service.dart';
import 'package:food_finder/config/routes.dart';

/// macOS-specific entry point for the Food Finder application.
/// This entry point is designed to avoid null check issues on macOS.
void main() {
  // Basic initialization
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize mock services
  final authService = MockAuthService();
  final databaseService = MockDatabaseService();
  final storageService = MockStorageService();
  final foodRecognitionService = MockFoodRecognitionService();

  // Empty camera list for macOS
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
      child: const MacOSFoodFinderApp(),
    ),
  );
}

class MacOSFoodFinderApp extends StatelessWidget {
  const MacOSFoodFinderApp({Key? key}) : super(key: key);

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
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}

import 'package:flutter/material.dart';
import 'dart:typed_data';

// Import screens
// import '../ui/screens/home/home_screen.dart'; // Removing this conflicting import
import '../ui/screens/camera/camera_screen.dart';
import '../ui/screens/results/results_screen.dart';
import '../ui/screens/search/search_screen.dart';
import '../ui/screens/profile/profile_screen.dart';
import '../ui/screens/food_details_screen.dart';
import '../core/models/food_item.dart';
import '../core/models/recognition_result.dart';
import '../ui/screens/home/home_screen.dart';

class AppRoutes {
  // Route names
  static const String home = '/';
  static const String camera = '/camera';
  static const String results = '/results';
  static const String search = '/search';
  static const String profile = '/profile';
  static const String foodDetails = '/food_details';
  static const String settings = '/settings';
  static const String about = '/about';

  // Route generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    debugPrint('Navigating to: ${settings.name}');

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );

      case camera:
        return MaterialPageRoute(
          builder: (_) => const CameraScreen(),
        );

      case results:
        final args = settings.arguments as Map<String, dynamic>?;
        final results = args?['results'] as List<RecognitionResult>? ?? [];
        final imageBytes = args?['imageBytes'] as Uint8List?;
        final imagePath = args?['imagePath'] as String?;

        debugPrint('Routes: Passing to ResultsScreen:');
        debugPrint('  - ${results.length} recognition results');
        if (imageBytes != null) {
          debugPrint('  - imageBytes: ${imageBytes.length} bytes');
        } else {
          debugPrint('  - imageBytes: null');
        }
        debugPrint('  - imagePath: $imagePath');

        return MaterialPageRoute(
          builder: (_) => ResultsScreen(
            results: results,
            imageBytes: imageBytes,
            imagePath: imagePath,
          ),
        );

      case search:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Search Screen')),
          ),
        );

      case profile:
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
        );

      case foodDetails:
        final foodItem = settings.arguments as FoodItem?;
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Food Details: ${foodItem?.name ?? "Unknown"}'),
            ),
          ),
        );

      case '/settings':
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Settings Screen')),
          ),
        );

      case about:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('About Screen')),
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}

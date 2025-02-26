class AppConstants {
  // App info
  static const String appName = 'FoodFinder';
  static const String appVersion = '1.0.0';

  // API endpoints and keys
  static const String apiBaseUrl = 'https://api.example.com/v1';
  static const String privacyPolicyUrl = 'https://foodfinder.app/privacy';
  static const String termsOfServiceUrl = 'https://foodfinder.app/terms';
  static const String supportEmail = 'support@foodfinder.app';

  // Feature flags
  static const bool enableCloudRecognition =
      false; // Set to true to use cloud API instead of on-device

  // ML model settings
  static const String modelPath = 'assets/ml/food_recognition_model.tflite';
  static const String labelsPath = 'assets/ml/food_labels.txt';
  static const int inputSize = 224; // Model input size
  static const int maxResults = 5; // Maximum number of recognition results
  static const double confidenceThreshold = 0.6; // Minimum confidence threshold

  // Storage keys
  static const String userPrefsKey = 'user_preferences';
  static const String recentSearchesKey = 'recent_searches';
  static const String recognitionHistoryKey = 'recognition_history';

  // UI constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 12.0;
  static const double smallBorderRadius = 6.0;
  static const double largeBorderRadius = 24.0;

  // Animation durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration standardAnimationDuration = Duration(milliseconds: 350);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // Cache settings
  static const int maxCachedImages = 100;
  static const Duration cacheDuration = Duration(days: 7);

  // Rate limiting
  static const int maxApiRequestsPerMinute = 30;

  // Error messages
  static const String genericErrorMessage =
      'Something went wrong. Please try again.';
  static const String networkErrorMessage =
      'Network error. Please check your connection.';
  static const String cameraPermissionDeniedMessage =
      'Camera permission is required to identify foods.';

  // Food categories
  static const List<String> foodCategories = [
    'Fruits',
    'Vegetables',
    'Grains',
    'Protein Foods',
    'Dairy',
    'Snacks',
    'Beverages',
    'Desserts',
    'Prepared Dishes',
    'Condiments',
  ];

  // Private constructor to prevent instantiation
  const AppConstants._();
}

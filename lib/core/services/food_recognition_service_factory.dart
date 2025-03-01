import 'package:flutter/foundation.dart';
import 'mock_food_recognition_service.dart';
import 'clarifai_food_recognition_service.dart';
import 'google_vision_food_recognition_service.dart';
import '../config/api_keys.dart';

/// Enum for different food recognition service types
enum FoodRecognitionServiceType {
  /// Mock service for testing
  mock,

  /// Google Cloud Vision API
  googleVision,

  /// Clarifai API
  clarifai,
}

/// Factory for creating food recognition services
class FoodRecognitionServiceFactory {
  /// Create a food recognition service based on the specified type
  static FoodRecognitionServiceInterface create(
      FoodRecognitionServiceType type) {
    switch (type) {
      case FoodRecognitionServiceType.mock:
        return MockFoodRecognitionService();
      case FoodRecognitionServiceType.googleVision:
        return GoogleVisionFoodRecognitionService();
      case FoodRecognitionServiceType.clarifai:
        return ClarifaiFoodRecognitionService();
    }
  }

  /// Create the best available food recognition service
  ///
  /// This will try to use a real API service if API keys are set,
  /// otherwise it will fall back to the mock service.
  static FoodRecognitionServiceInterface createBestAvailable() {
    // On web, prefer Clarifai if available
    if (kIsWeb) {
      if (ApiKeys.isClarifaiApiKeySet) {
        return ClarifaiFoodRecognitionService();
      }

      if (ApiKeys.isGoogleCloudVisionApiKeySet) {
        return GoogleVisionFoodRecognitionService();
      }

      return MockFoodRecognitionService();
    }

    // On mobile, prefer Google Vision if available
    if (ApiKeys.isGoogleCloudVisionApiKeySet) {
      return GoogleVisionFoodRecognitionService();
    }

    if (ApiKeys.isClarifaiApiKeySet) {
      return ClarifaiFoodRecognitionService();
    }

    return MockFoodRecognitionService();
  }
}

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/recognition_result.dart';
import 'mock_food_recognition_service.dart';
import '../config/api_keys.dart';

/// A service that uses Google Cloud Vision API for food recognition
class GoogleVisionFoodRecognitionService
    implements FoodRecognitionServiceInterface {
  // Get API key from configuration
  final String _apiKey = ApiKeys.googleCloudVisionApiKey;

  // Google Cloud Vision API endpoint
  static const String _apiUrl =
      'https://vision.googleapis.com/v1/images:annotate';

  // Fallback service in case of errors
  final MockFoodRecognitionService _mockService = MockFoodRecognitionService();

  // Food category mapping
  final Map<String, String> _categoryMapping = {
    'apple': 'Fruit',
    'banana': 'Fruit',
    'orange': 'Fruit',
    'strawberry': 'Fruit',
    'grapes': 'Fruit',
    'pizza': 'Fast Food',
    'burger': 'Fast Food',
    'hot dog': 'Fast Food',
    'french fries': 'Fast Food',
    'pasta': 'Main Dish',
    'salad': 'Healthy',
    'chicken': 'Main Dish',
    'steak': 'Main Dish',
    'salmon': 'Main Dish',
    'rice': 'Main Dish',
    'broccoli': 'Vegetable',
    'carrot': 'Vegetable',
    'spinach': 'Vegetable',
    'ice cream': 'Dessert',
    'cake': 'Dessert',
    'donut': 'Dessert',
    'coffee': 'Beverage',
    'tea': 'Beverage',
    'juice': 'Beverage',
    // Add more mappings as needed
  };

  // Nutritional information database
  final Map<String, Map<String, double>> _nutritionalDatabase = {
    'apple': {
      'calories': 52,
      'protein': 0.3,
      'carbs': 14,
      'fat': 0.2,
      'fiber': 2.4,
      'sugar': 10.3,
    },
    'banana': {
      'calories': 89,
      'protein': 1.1,
      'carbs': 23,
      'fat': 0.3,
      'fiber': 2.6,
      'sugar': 12.2,
    },
    'orange': {
      'calories': 47,
      'protein': 0.9,
      'carbs': 12,
      'fat': 0.1,
      'fiber': 2.4,
      'sugar': 9.4,
    },
    'pizza': {
      'calories': 266,
      'protein': 11,
      'carbs': 33,
      'fat': 10,
      'fiber': 2.3,
      'sugar': 3.6,
    },
    'burger': {
      'calories': 295,
      'protein': 17,
      'carbs': 30,
      'fat': 14,
      'fiber': 1.5,
      'sugar': 6,
    },
    'pasta': {
      'calories': 158,
      'protein': 5.8,
      'carbs': 31,
      'fat': 0.9,
      'fiber': 1.8,
      'sugar': 0.6,
    },
    'salad': {
      'calories': 33,
      'protein': 1.8,
      'carbs': 7,
      'fat': 0.4,
      'fiber': 2.9,
      'sugar': 2.4,
    },
    'chicken': {
      'calories': 165,
      'protein': 31,
      'carbs': 0,
      'fat': 3.6,
      'fiber': 0,
      'sugar': 0,
    },
    'steak': {
      'calories': 271,
      'protein': 26,
      'carbs': 0,
      'fat': 19,
      'fiber': 0,
      'sugar': 0,
    },
    'rice': {
      'calories': 130,
      'protein': 2.7,
      'carbs': 28,
      'fat': 0.3,
      'fiber': 0.4,
      'sugar': 0.1,
    },
    // Add more foods as needed
  };

  @override
  Future<List<RecognitionResult>> recognizeFood(Uint8List imageData) async {
    try {
      // Check if API key is set
      if (!ApiKeys.isGoogleCloudVisionApiKeySet) {
        debugPrint('Google Cloud Vision API key not set, using mock service');
        return _mockService.recognizeFood(imageData);
      }

      // Convert image to base64
      final base64Image = base64Encode(imageData);

      // Prepare request body for Google Cloud Vision API
      final requestBody = {
        'requests': [
          {
            'image': {
              'content': base64Image,
            },
            'features': [
              {
                'type': 'LABEL_DETECTION',
                'maxResults': 15,
              },
              {
                'type': 'WEB_DETECTION',
                'maxResults': 15,
              },
            ],
          },
        ],
      };

      // Set up Dio with timeout
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 10);
      dio.options.receiveTimeout = const Duration(seconds: 10);

      // Make API request
      final response = await dio.post(
        '$_apiUrl?key=$_apiKey',
        data: jsonEncode(requestBody),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      // Check response status
      if (response.statusCode == 200) {
        final data = response.data;

        // Parse results from response
        final responses = data['responses'] as List;
        if (responses.isNotEmpty) {
          final labelAnnotations =
              responses[0]['labelAnnotations'] as List? ?? [];
          final webDetection =
              responses[0]['webDetection'] as Map<String, dynamic>? ?? {};
          final webEntities = webDetection['webEntities'] as List? ?? [];

          // Combine label annotations and web entities
          final allResults = <Map<String, dynamic>>[];

          // Add label annotations
          for (final label in labelAnnotations) {
            allResults.add({
              'description': label['description'] as String,
              'score': label['score'] as double,
              'source': 'label',
            });
          }

          // Add web entities
          for (final entity in webEntities) {
            if (entity.containsKey('description') &&
                entity.containsKey('score')) {
              allResults.add({
                'description': entity['description'] as String,
                'score': entity['score'] as double,
                'source': 'web',
              });
            }
          }

          // Filter for food-related terms
          final foodResults = allResults.where((result) {
            final description = result['description'] as String;
            return _isFoodRelated(description);
          }).toList();

          // Sort by score (highest first)
          foodResults.sort(
              (a, b) => (b['score'] as double).compareTo(a['score'] as double));

          // Convert to RecognitionResult objects
          final results = <RecognitionResult>[];

          for (final result in foodResults) {
            final label = result['description'] as String;
            final confidence = result['score'] as double;

            // Only include results with reasonable confidence
            if (confidence > 0.5) {
              // Get category and nutritional info
              final category = _getCategoryForFood(label);
              final nutritionalInfo = _getNutritionalInfo(label);

              results.add(RecognitionResult(
                label: _capitalizeFood(label),
                confidence: confidence,
                category: category,
                nutritionalInfo: nutritionalInfo,
              ));
            }
          }

          // Return top 5 results
          return results.take(5).toList();
        }
      }

      // If we get here, something went wrong with the API
      debugPrint('Error with Google Cloud Vision API: ${response.statusCode}');
      return _mockService.recognizeFood(imageData);
    } catch (e) {
      debugPrint('Error recognizing food with Google Cloud Vision: $e');
      // Fall back to mock service if there's an error
      return _mockService.recognizeFood(imageData);
    }
  }

  @override
  Future<List<RecognitionResult>> recognizeFoodFromFile(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      return recognizeFood(bytes);
    } catch (e) {
      debugPrint('Error reading image file: $e');
      return _mockService.recognizeFood(Uint8List(0));
    }
  }

  // Helper method to check if a term is food-related
  bool _isFoodRelated(String term) {
    final foodKeywords = [
      'food',
      'dish',
      'meal',
      'cuisine',
      'recipe',
      'ingredient',
      'fruit',
      'vegetable',
      'meat',
      'dessert',
      'breakfast',
      'lunch',
      'dinner',
      'snack',
      'appetizer',
      'beverage',
      'drink',
    ];

    final normalizedTerm = term.toLowerCase();

    // Check if term is in our food database
    if (_nutritionalDatabase.keys.any((key) => normalizedTerm.contains(key))) {
      return true;
    }

    // Check if term is in our category mapping
    if (_categoryMapping.keys.any((key) => normalizedTerm.contains(key))) {
      return true;
    }

    // Check if term contains any food keywords
    if (foodKeywords.any((keyword) => normalizedTerm.contains(keyword))) {
      return true;
    }

    return false;
  }

  // Helper method to get category for a food
  String _getCategoryForFood(String food) {
    final normalizedFood = food.toLowerCase();

    // Check direct mapping first
    if (_categoryMapping.containsKey(normalizedFood)) {
      return _categoryMapping[normalizedFood]!;
    }

    // Check if food contains any of the category keywords
    for (final entry in _categoryMapping.entries) {
      if (normalizedFood.contains(entry.key)) {
        return entry.value;
      }
    }

    // Default category
    return 'Other';
  }

  // Helper method to get nutritional info for a food
  Map<String, double> _getNutritionalInfo(String food) {
    final normalizedFood = food.toLowerCase();

    // Check direct mapping first
    if (_nutritionalDatabase.containsKey(normalizedFood)) {
      return _nutritionalDatabase[normalizedFood]!;
    }

    // Check if food contains any of the database keywords
    for (final entry in _nutritionalDatabase.entries) {
      if (normalizedFood.contains(entry.key)) {
        return entry.value;
      }
    }

    // Default nutritional info
    return {
      'calories': 100,
      'protein': 5,
      'carbs': 15,
      'fat': 5,
    };
  }

  // Helper method to capitalize food name
  String _capitalizeFood(String food) {
    if (food.isEmpty) return food;
    return food
        .split(' ')
        .map((word) =>
            word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '')
        .join(' ');
  }
}

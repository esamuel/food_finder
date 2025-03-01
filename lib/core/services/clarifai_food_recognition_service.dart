import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/recognition_result.dart';
import 'mock_food_recognition_service.dart';
import '../config/api_keys.dart';

/// A service that uses the Clarifai API for food recognition
class ClarifaiFoodRecognitionService
    implements FoodRecognitionServiceInterface {
  // Get API key from configuration
  final String _apiKey = ApiKeys.clarifaiApiKey;

  // Clarifai food model ID
  static const String _modelId = 'food-item-recognition';

  // Clarifai API endpoint
  static const String _apiUrl =
      'https://api.clarifai.com/v2/models/$_modelId/outputs';

  // Fallback service in case of errors
  final MockFoodRecognitionService _mockService = MockFoodRecognitionService();

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

  @override
  Future<List<RecognitionResult>> recognizeFood(Uint8List imageData) async {
    try {
      // Check if API key is set
      if (!ApiKeys.isClarifaiApiKeySet) {
        debugPrint('Clarifai API key not set, using mock service');
        return _mockService.recognizeFood(imageData);
      }

      // Convert image to base64
      final base64Image = base64Encode(imageData);

      // Prepare request body
      final requestBody = {
        'inputs': [
          {
            'data': {
              'image': {
                'base64': base64Image,
              }
            }
          }
        ]
      };

      // Set up Dio with timeout
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 10);
      dio.options.receiveTimeout = const Duration(seconds: 10);

      // Make API request
      final response = await dio.post(
        _apiUrl,
        data: jsonEncode(requestBody),
        options: Options(
          headers: {
            'Authorization': 'Key $_apiKey',
            'Content-Type': 'application/json',
          },
        ),
      );

      // Check response status
      if (response.statusCode == 200) {
        final data = response.data;

        // Parse concepts from response
        final outputs = data['outputs'] as List;
        if (outputs.isNotEmpty) {
          final concepts = outputs[0]['data']['concepts'] as List;

          // Convert to RecognitionResult objects
          final results = <RecognitionResult>[];

          for (final concept in concepts) {
            final label = concept['name'] as String;
            final confidence = concept['value'] as double;

            // Only include results with reasonable confidence
            if (confidence > 0.05) {
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

          // Sort by confidence (highest first)
          results.sort((a, b) => b.confidence.compareTo(a.confidence));

          // Return top 5 results
          return results.take(5).toList();
        }
      }

      // If we get here, something went wrong with the API
      debugPrint('Error with Clarifai API: ${response.statusCode}');
      return _mockService.recognizeFood(imageData);
    } catch (e) {
      debugPrint('Error recognizing food with Clarifai: $e');
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

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../data/food_database.dart';
import '../models/recognition_result.dart';
import 'food_recognition/food_recognition_service.dart';

// Interface for food recognition services
abstract class FoodRecognitionServiceInterface {
  Future<List<RecognitionResult>> recognizeFood(Uint8List imageData);
  Future<List<RecognitionResult>> recognizeFoodFromFile(File imageFile);
}

/// A mock implementation of the food recognition service that returns random results
/// This is useful for testing and development without using real API calls
class MockFoodRecognitionService implements FoodRecognitionServiceInterface {
  final Random _random = Random();

  @override
  Future<List<RecognitionResult>> recognizeFood(Uint8List imageBytes) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Get random foods from our database
    final allFoods = FoodDatabase.getAllFoods();
    final selectedFoods = <FoodItem>[];

    // Select 3-5 random foods
    final numResults = _random.nextInt(3) + 3; // 3 to 5 results

    // Shuffle the list and take the first numResults items
    final shuffledFoods = List<FoodItem>.from(allFoods)..shuffle(_random);
    selectedFoods.addAll(shuffledFoods.take(numResults));

    // Convert to recognition results with random confidence scores
    return selectedFoods.map((food) {
      // Generate a confidence score between 0.65 and 0.98
      final confidence = 0.65 + (_random.nextDouble() * 0.33);

      return RecognitionResult(
        label: food.name,
        confidence: confidence,
        category: food.category.displayName,
        calories: food.calories,
        nutritionalInfo: {
          'protein': '${food.protein}g',
          'carbs': '${food.carbs}g',
          'fat': '${food.fat}g',
        },
        description: food.imageDescription,
        imageUrl: food.imageUrl,
      );
    }).toList()
      // Sort by confidence (highest first)
      ..sort((a, b) => b.confidence.compareTo(a.confidence));
  }

  @override
  Future<List<RecognitionResult>> recognizeFoodFromFile(File imageFile) async {
    // Read the file as bytes and use the other method
    final bytes = await imageFile.readAsBytes();
    return recognizeFood(bytes);
  }

  @override
  Future<List<RecognitionResult>> recognizeFoodFromUrl(String imageUrl) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Just use the same implementation as recognizeFood
    return recognizeFood(Uint8List(0));
  }
}

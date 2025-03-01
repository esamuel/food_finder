import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../models/recognition_result.dart';

// Interface for food recognition services
abstract class FoodRecognitionServiceInterface {
  Future<List<RecognitionResult>> recognizeFood(Uint8List imageData);
  Future<List<RecognitionResult>> recognizeFoodFromFile(File imageFile);
}

// Enhanced mock implementation with more food types and better accuracy
class MockFoodRecognitionService implements FoodRecognitionServiceInterface {
  final Random _random = Random();

  // Expanded list of mock food items with their nutritional data
  final List<Map<String, dynamic>> _mockFoods = [
    // Fruits
    {
      'label': 'Apple',
      'category': 'Fruit',
      'confidence': 0.92,
      'calories': 52,
      'protein': 0.3,
      'carbs': 14,
      'fat': 0.2,
      'fiber': 2.4,
      'sugar': 10.3,
    },
    {
      'label': 'Banana',
      'category': 'Fruit',
      'confidence': 0.89,
      'calories': 89,
      'protein': 1.1,
      'carbs': 23,
      'fat': 0.3,
      'fiber': 2.6,
      'sugar': 12.2,
    },
    {
      'label': 'Orange',
      'category': 'Fruit',
      'confidence': 0.91,
      'calories': 47,
      'protein': 0.9,
      'carbs': 12,
      'fat': 0.1,
      'fiber': 2.4,
      'sugar': 9.4,
    },
    {
      'label': 'Strawberry',
      'category': 'Fruit',
      'confidence': 0.88,
      'calories': 32,
      'protein': 0.7,
      'carbs': 7.7,
      'fat': 0.3,
      'fiber': 2.0,
      'sugar': 4.9,
    },
    {
      'label': 'Grapes',
      'category': 'Fruit',
      'confidence': 0.87,
      'calories': 69,
      'protein': 0.6,
      'carbs': 18,
      'fat': 0.2,
      'fiber': 0.9,
      'sugar': 16,
    },

    // Fast Food
    {
      'label': 'Burger',
      'category': 'Fast Food',
      'confidence': 0.95,
      'calories': 295,
      'protein': 17,
      'carbs': 30,
      'fat': 14,
      'fiber': 1.5,
      'sugar': 6,
    },
    {
      'label': 'Pizza',
      'category': 'Fast Food',
      'confidence': 0.91,
      'calories': 266,
      'protein': 11,
      'carbs': 33,
      'fat': 10,
      'fiber': 2.3,
      'sugar': 3.6,
    },
    {
      'label': 'French Fries',
      'category': 'Fast Food',
      'confidence': 0.93,
      'calories': 312,
      'protein': 3.4,
      'carbs': 41,
      'fat': 15,
      'fiber': 3.8,
      'sugar': 0.5,
    },
    {
      'label': 'Hot Dog',
      'category': 'Fast Food',
      'confidence': 0.89,
      'calories': 290,
      'protein': 10,
      'carbs': 31,
      'fat': 16,
      'fiber': 1.2,
      'sugar': 5,
    },

    // Healthy Foods
    {
      'label': 'Salad',
      'category': 'Healthy',
      'confidence': 0.87,
      'calories': 33,
      'protein': 1.8,
      'carbs': 7,
      'fat': 0.4,
      'fiber': 2.9,
      'sugar': 2.4,
    },
    {
      'label': 'Avocado',
      'category': 'Healthy',
      'confidence': 0.90,
      'calories': 160,
      'protein': 2,
      'carbs': 8.5,
      'fat': 14.7,
      'fiber': 6.7,
      'sugar': 0.7,
    },
    {
      'label': 'Quinoa',
      'category': 'Healthy',
      'confidence': 0.85,
      'calories': 120,
      'protein': 4.4,
      'carbs': 21.3,
      'fat': 1.9,
      'fiber': 2.8,
      'sugar': 0.9,
    },

    // Main Dishes
    {
      'label': 'Pasta',
      'category': 'Main Dish',
      'confidence': 0.88,
      'calories': 158,
      'protein': 5.8,
      'carbs': 31,
      'fat': 0.9,
      'fiber': 1.8,
      'sugar': 0.6,
    },
    {
      'label': 'Chicken',
      'category': 'Main Dish',
      'confidence': 0.93,
      'calories': 165,
      'protein': 31,
      'carbs': 0,
      'fat': 3.6,
      'fiber': 0,
      'sugar': 0,
    },
    {
      'label': 'Steak',
      'category': 'Main Dish',
      'confidence': 0.90,
      'calories': 271,
      'protein': 26,
      'carbs': 0,
      'fat': 19,
      'fiber': 0,
      'sugar': 0,
    },
    {
      'label': 'Salmon',
      'category': 'Main Dish',
      'confidence': 0.92,
      'calories': 206,
      'protein': 22,
      'carbs': 0,
      'fat': 13,
      'fiber': 0,
      'sugar': 0,
    },
    {
      'label': 'Tofu',
      'category': 'Main Dish',
      'confidence': 0.86,
      'calories': 144,
      'protein': 15.9,
      'carbs': 3.5,
      'fat': 8.7,
      'fiber': 2.3,
      'sugar': 0.7,
    },

    // International Cuisine
    {
      'label': 'Sushi',
      'category': 'International',
      'confidence': 0.86,
      'calories': 145,
      'protein': 6,
      'carbs': 28,
      'fat': 0.6,
      'fiber': 0.3,
      'sugar': 4.2,
    },
    {
      'label': 'Taco',
      'category': 'International',
      'confidence': 0.88,
      'calories': 210,
      'protein': 9.2,
      'carbs': 21,
      'fat': 10,
      'fiber': 3.1,
      'sugar': 2.2,
    },
    {
      'label': 'Curry',
      'category': 'International',
      'confidence': 0.87,
      'calories': 243,
      'protein': 7.5,
      'carbs': 18.9,
      'fat': 15.2,
      'fiber': 4.3,
      'sugar': 3.8,
    },
    {
      'label': 'Pad Thai',
      'category': 'International',
      'confidence': 0.85,
      'calories': 375,
      'protein': 11,
      'carbs': 56,
      'fat': 12,
      'fiber': 2.5,
      'sugar': 10.2,
    },

    // Desserts
    {
      'label': 'Ice Cream',
      'category': 'Dessert',
      'confidence': 0.84,
      'calories': 207,
      'protein': 3.5,
      'carbs': 24,
      'fat': 11,
      'fiber': 0.7,
      'sugar': 21,
    },
    {
      'label': 'Chocolate Cake',
      'category': 'Dessert',
      'confidence': 0.89,
      'calories': 352,
      'protein': 4.8,
      'carbs': 50,
      'fat': 15,
      'fiber': 2.3,
      'sugar': 35,
    },
    {
      'label': 'Donut',
      'category': 'Dessert',
      'confidence': 0.91,
      'calories': 253,
      'protein': 3.4,
      'carbs': 30,
      'fat': 14,
      'fiber': 0.9,
      'sugar': 10.8,
    },
    {
      'label': 'Cheesecake',
      'category': 'Dessert',
      'confidence': 0.88,
      'calories': 321,
      'protein': 6.2,
      'carbs': 26.5,
      'fat': 22,
      'fiber': 0.3,
      'sugar': 21.5,
    },
  ];

  // Add more food types to the existing list
  final List<Map<String, dynamic>> _additionalFoods = [
    // Vegetables
    {
      'label': 'Broccoli',
      'category': 'Vegetable',
      'confidence': 0.93,
      'calories': 34,
      'protein': 2.8,
      'carbs': 6.6,
      'fat': 0.4,
      'fiber': 2.6,
      'sugar': 1.7,
    },
    {
      'label': 'Carrot',
      'category': 'Vegetable',
      'confidence': 0.92,
      'calories': 41,
      'protein': 0.9,
      'carbs': 9.6,
      'fat': 0.2,
      'fiber': 2.8,
      'sugar': 4.7,
    },
    {
      'label': 'Spinach',
      'category': 'Vegetable',
      'confidence': 0.89,
      'calories': 23,
      'protein': 2.9,
      'carbs': 3.6,
      'fat': 0.4,
      'fiber': 2.2,
      'sugar': 0.4,
    },

    // Breakfast
    {
      'label': 'Oatmeal',
      'category': 'Breakfast',
      'confidence': 0.91,
      'calories': 68,
      'protein': 2.5,
      'carbs': 12,
      'fat': 1.4,
      'fiber': 2.0,
      'sugar': 0.5,
    },
    {
      'label': 'Pancakes',
      'category': 'Breakfast',
      'confidence': 0.90,
      'calories': 227,
      'protein': 6.4,
      'carbs': 43,
      'fat': 3.1,
      'fiber': 0.9,
      'sugar': 15,
    },
    {
      'label': 'Eggs',
      'category': 'Breakfast',
      'confidence': 0.94,
      'calories': 155,
      'protein': 12.6,
      'carbs': 0.6,
      'fat': 10.6,
      'fiber': 0,
      'sugar': 0.6,
    },

    // Snacks
    {
      'label': 'Popcorn',
      'category': 'Snack',
      'confidence': 0.92,
      'calories': 375,
      'protein': 11,
      'carbs': 74,
      'fat': 4.3,
      'fiber': 14.5,
      'sugar': 0.9,
    },
    {
      'label': 'Potato Chips',
      'category': 'Snack',
      'confidence': 0.93,
      'calories': 536,
      'protein': 7,
      'carbs': 53,
      'fat': 34,
      'fiber': 4.8,
      'sugar': 0.5,
    },
    {
      'label': 'Nuts',
      'category': 'Snack',
      'confidence': 0.91,
      'calories': 607,
      'protein': 21,
      'carbs': 20,
      'fat': 54,
      'fiber': 8.3,
      'sugar': 4.2,
    },

    // Beverages
    {
      'label': 'Coffee',
      'category': 'Beverage',
      'confidence': 0.95,
      'calories': 2,
      'protein': 0.3,
      'carbs': 0,
      'fat': 0,
      'fiber': 0,
      'sugar': 0,
    },
    {
      'label': 'Smoothie',
      'category': 'Beverage',
      'confidence': 0.89,
      'calories': 157,
      'protein': 2.5,
      'carbs': 34,
      'fat': 2.1,
      'fiber': 3.5,
      'sugar': 26,
    },
    {
      'label': 'Orange Juice',
      'category': 'Beverage',
      'confidence': 0.92,
      'calories': 45,
      'protein': 0.7,
      'carbs': 10.4,
      'fat': 0.2,
      'fiber': 0.2,
      'sugar': 8.3,
    },
  ];

  MockFoodRecognitionService() {
    // Combine the original mock foods with additional foods
    _mockFoods.addAll(_additionalFoods);
  }

  @override
  Future<List<RecognitionResult>> recognizeFood(Uint8List imageData) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    // Return 2-5 random food items for more comprehensive results
    final resultCount = _random.nextInt(3) + 2; // 2-5 results
    final results = <RecognitionResult>[];

    // Create a copy of the mock foods list to avoid duplicates
    final availableFoods = List.from(_mockFoods);

    // Simulate more accurate recognition by selecting foods from the same category
    // for more realistic results
    String? dominantCategory;
    if (_random.nextDouble() > 0.3) {
      // 70% chance to have related foods
      final randomIndex = _random.nextInt(availableFoods.length);
      dominantCategory = availableFoods[randomIndex]['category'] as String;
    }

    for (int i = 0; i < resultCount; i++) {
      if (availableFoods.isEmpty) break;

      // If we have a dominant category and it's not the last item, try to pick from that category
      Map<String, dynamic>? selectedFood;
      if (dominantCategory != null && i < resultCount - 1) {
        final categoryFoods = availableFoods
            .where((f) => f['category'] == dominantCategory)
            .toList();

        if (categoryFoods.isNotEmpty) {
          final foodIndex = _random.nextInt(categoryFoods.length);
          selectedFood = categoryFoods[foodIndex];
          availableFoods.remove(selectedFood);
        }
      }

      // If no food was selected by category, pick a random one
      if (selectedFood == null) {
        final foodIndex = _random.nextInt(availableFoods.length);
        selectedFood = availableFoods[foodIndex];
        availableFoods.remove(selectedFood);
      }

      // Now selectedFood is guaranteed to be non-null
      final food = selectedFood!;

      // Add some randomness to confidence but keep it more accurate
      // Higher confidence for the first item, decreasing for subsequent items
      double confidenceModifier = i == 0
          ? 0.95 + (_random.nextDouble() * 0.05) // First item: 95-100%
          : 0.85 -
              (i * 0.1) +
              (_random.nextDouble() *
                  0.1); // Subsequent items with decreasing confidence

      final confidence = (food['confidence'] as double) * confidenceModifier;

      // Extract nutritional information
      final nutritionalInfo = <String, double>{
        'calories': food['calories'] as double,
        'protein': food['protein'] as double,
        'carbs': food['carbs'] as double,
        'fat': food['fat'] as double,
      };

      // Add fiber and sugar if available
      if (food.containsKey('fiber')) {
        nutritionalInfo['fiber'] = food['fiber'] as double;
      }

      if (food.containsKey('sugar')) {
        nutritionalInfo['sugar'] = food['sugar'] as double;
      }

      // Create a more detailed RecognitionResult
      results.add(RecognitionResult(
        label: food['label'] as String,
        confidence: confidence.clamp(0.0, 1.0),
        category: food['category'] as String,
        nutritionalInfo: nutritionalInfo,
      ));
    }

    // Sort by confidence (highest first)
    results.sort((a, b) => b.confidence.compareTo(a.confidence));

    return results;
  }

  @override
  Future<List<RecognitionResult>> recognizeFoodFromFile(File imageFile) async {
    // For file-based recognition, we'll just read the bytes and use the same method
    final bytes = await imageFile.readAsBytes();
    return recognizeFood(bytes);
  }
}

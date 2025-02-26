import 'dart:async';
import 'package:flutter/foundation.dart';

// Auth Service Interface and Mock Implementation
abstract class AuthServiceInterface {
  Future<bool> signIn(String email, String password);
  Future<bool> signUp(String email, String password, String name);
  Future<void> signOut();
  bool get isSignedIn;
  String? get currentUserId;
  Stream<bool> get authStateChanges;
}

class MockAuthService implements AuthServiceInterface {
  bool _isSignedIn = false;
  String? _currentUserId;
  final _authStateController = StreamController<bool>.broadcast();

  @override
  Future<bool> signIn(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    _isSignedIn = true;
    _currentUserId = 'mock-user-123';
    _authStateController.add(true);
    return true;
  }

  @override
  Future<bool> signUp(String email, String password, String name) async {
    await Future.delayed(const Duration(seconds: 1));
    _isSignedIn = true;
    _currentUserId = 'mock-user-123';
    _authStateController.add(true);
    return true;
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _isSignedIn = false;
    _currentUserId = null;
    _authStateController.add(false);
  }

  @override
  bool get isSignedIn => _isSignedIn;

  @override
  String? get currentUserId => _currentUserId;

  @override
  Stream<bool> get authStateChanges => _authStateController.stream;
}

// Database Service Interface and Mock Implementation
abstract class DatabaseServiceInterface {
  Future<List<Map<String, dynamic>>> getFoodItems();
  Future<Map<String, dynamic>?> getFoodItemById(String id);
  Future<List<Map<String, dynamic>>> searchFoodItems(String query);
  Future<void> saveFoodItem(Map<String, dynamic> foodItem);
  Future<void> updateFoodItem(String id, Map<String, dynamic> data);
  Future<void> deleteFoodItem(String id);
}

class MockDatabaseService implements DatabaseServiceInterface {
  final List<Map<String, dynamic>> _mockFoodItems = [
    {
      'id': '1',
      'name': 'Apple',
      'category': 'Fruit',
      'calories': 95,
      'imageUrl': 'https://example.com/apple.jpg',
      'description': 'A sweet, edible fruit produced by an apple tree.',
      'nutritionFacts': {
        'protein': 0.5,
        'carbs': 25.0,
        'fat': 0.3,
        'fiber': 4.0,
      }
    },
    {
      'id': '2',
      'name': 'Banana',
      'category': 'Fruit',
      'calories': 105,
      'imageUrl': 'https://example.com/banana.jpg',
      'description':
          'A long curved fruit with a yellow skin and soft sweet flesh.',
      'nutritionFacts': {
        'protein': 1.3,
        'carbs': 27.0,
        'fat': 0.4,
        'fiber': 3.1,
      }
    },
    {
      'id': '3',
      'name': 'Chicken Breast',
      'category': 'Meat',
      'calories': 165,
      'imageUrl': 'https://example.com/chicken.jpg',
      'description': 'A lean cut of meat from the breast of a chicken.',
      'nutritionFacts': {
        'protein': 31.0,
        'carbs': 0.0,
        'fat': 3.6,
        'fiber': 0.0,
      }
    },
  ];

  @override
  Future<List<Map<String, dynamic>>> getFoodItems() async {
    await Future.delayed(const Duration(seconds: 1));
    return _mockFoodItems;
  }

  @override
  Future<Map<String, dynamic>?> getFoodItemById(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockFoodItems.firstWhere(
      (item) => item['id'] == id,
      orElse: () => {},
    );
  }

  @override
  Future<List<Map<String, dynamic>>> searchFoodItems(String query) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (query.isEmpty) return _mockFoodItems;

    final lowercaseQuery = query.toLowerCase();
    return _mockFoodItems.where((item) {
      final name = (item['name'] as String).toLowerCase();
      final category = (item['category'] as String).toLowerCase();
      final description = (item['description'] as String).toLowerCase();

      return name.contains(lowercaseQuery) ||
          category.contains(lowercaseQuery) ||
          description.contains(lowercaseQuery);
    }).toList();
  }

  @override
  Future<void> saveFoodItem(Map<String, dynamic> foodItem) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _mockFoodItems.add(foodItem);
  }

  @override
  Future<void> updateFoodItem(String id, Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _mockFoodItems.indexWhere((item) => item['id'] == id);
    if (index != -1) {
      _mockFoodItems[index] = {..._mockFoodItems[index], ...data};
    }
  }

  @override
  Future<void> deleteFoodItem(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockFoodItems.removeWhere((item) => item['id'] == id);
  }
}

// Storage Service Interface and Mock Implementation
abstract class StorageServiceInterface {
  Future<String> uploadImage(Uint8List imageData, String path);
  Future<Uint8List?> downloadImage(String path);
  Future<void> deleteImage(String path);
}

class MockStorageService implements StorageServiceInterface {
  final Map<String, Uint8List> _mockStorage = {};

  @override
  Future<String> uploadImage(Uint8List imageData, String path) async {
    await Future.delayed(const Duration(seconds: 1));
    _mockStorage[path] = imageData;
    return 'https://example.com/$path';
  }

  @override
  Future<Uint8List?> downloadImage(String path) async {
    await Future.delayed(const Duration(milliseconds: 700));
    return _mockStorage[path];
  }

  @override
  Future<void> deleteImage(String path) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockStorage.remove(path);
  }
}

// Nutrition Service Interface and Mock Implementation
abstract class NutritionService {
  Future<Map<String, dynamic>> getNutritionInfo(String foodName);
}

class MockNutritionService implements NutritionService {
  final Map<String, Map<String, dynamic>> _mockNutritionData = {
    'apple': {
      'calories': 95,
      'protein': 0.5,
      'carbs': 25.0,
      'fat': 0.3,
      'fiber': 4.0,
      'vitamins': ['Vitamin C', 'Vitamin B6'],
      'minerals': ['Potassium', 'Manganese']
    },
    'banana': {
      'calories': 105,
      'protein': 1.3,
      'carbs': 27.0,
      'fat': 0.4,
      'fiber': 3.1,
      'vitamins': ['Vitamin C', 'Vitamin B6'],
      'minerals': ['Potassium', 'Magnesium']
    },
    'chicken': {
      'calories': 165,
      'protein': 31.0,
      'carbs': 0.0,
      'fat': 3.6,
      'fiber': 0.0,
      'vitamins': ['Vitamin B6', 'Vitamin B12'],
      'minerals': ['Phosphorus', 'Selenium']
    },
    'pizza': {
      'calories': 285,
      'protein': 12.0,
      'carbs': 36.0,
      'fat': 10.4,
      'fiber': 2.5,
      'vitamins': ['Vitamin A', 'Vitamin B12'],
      'minerals': ['Calcium', 'Iron']
    },
    'salad': {
      'calories': 45,
      'protein': 1.5,
      'carbs': 8.0,
      'fat': 0.5,
      'fiber': 3.0,
      'vitamins': ['Vitamin A', 'Vitamin K'],
      'minerals': ['Potassium', 'Manganese']
    },
  };

  @override
  Future<Map<String, dynamic>> getNutritionInfo(String foodName) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Convert to lowercase for case-insensitive matching
    final lowercaseFoodName = foodName.toLowerCase();
    
    // Try to find an exact match
    if (_mockNutritionData.containsKey(lowercaseFoodName)) {
      return _mockNutritionData[lowercaseFoodName]!;
    }
    
    // Try to find a partial match
    for (var key in _mockNutritionData.keys) {
      if (key.contains(lowercaseFoodName) || lowercaseFoodName.contains(key)) {
        return _mockNutritionData[key]!;
      }
    }
    
    // Return default data if no match found
    return {
      'calories': 100,
      'protein': 2.0,
      'carbs': 15.0,
      'fat': 1.5,
      'fiber': 2.0,
      'vitamins': ['Various vitamins'],
      'minerals': ['Various minerals']
    };
  }
}

// Recipe Service Interface and Mock Implementation
abstract class RecipeService {
  Future<List<Map<String, dynamic>>> getRecipesForFood(String foodName);
}

class MockRecipeService implements RecipeService {
  final Map<String, List<Map<String, dynamic>>> _mockRecipes = {
    'apple': [
      {
        'id': '1',
        'name': 'Apple Pie',
        'ingredients': [
          '6 apples', 
          '1 cup sugar', 
          '2 cups flour', 
          '1/2 cup butter'
        ],
        'instructions': 'Peel and slice apples. Mix with sugar. Prepare dough with flour and butter. Place apples on dough, cover with another layer of dough. Bake at 350°F for 45 minutes.',
        'prepTime': 30,
        'cookTime': 45,
        'servings': 8,
        'difficulty': 'Medium',
        'imageUrl': 'https://example.com/apple-pie.jpg',
      },
      {
        'id': '2',
        'name': 'Apple Smoothie',
        'ingredients': [
          '2 apples', 
          '1 cup yogurt', 
          '1 tbsp honey', 
          '1/2 cup ice'
        ],
        'instructions': 'Core and chop apples. Blend with yogurt, honey, and ice until smooth.',
        'prepTime': 10,
        'cookTime': 0,
        'servings': 2,
        'difficulty': 'Easy',
        'imageUrl': 'https://example.com/apple-smoothie.jpg',
      },
    ],
    'banana': [
      {
        'id': '3',
        'name': 'Banana Bread',
        'ingredients': [
          '3 ripe bananas', 
          '1/3 cup melted butter', 
          '1 cup sugar', 
          '1 egg', 
          '1 tsp vanilla', 
          '1 tsp baking soda', 
          '1/4 tsp salt', 
          '1 1/2 cups flour'
        ],
        'instructions': 'Preheat oven to 350°F. Mash bananas and mix with melted butter. Mix in sugar, egg, and vanilla. Sprinkle baking soda and salt. Add flour. Pour into greased loaf pan. Bake for 55-60 minutes.',
        'prepTime': 15,
        'cookTime': 60,
        'servings': 10,
        'difficulty': 'Easy',
        'imageUrl': 'https://example.com/banana-bread.jpg',
      },
    ],
    'chicken': [
      {
        'id': '4',
        'name': 'Grilled Chicken Salad',
        'ingredients': [
          '2 chicken breasts', 
          '2 cups mixed greens', 
          '1 tomato', 
          '1/2 cucumber', 
          '1/4 cup olive oil', 
          '2 tbsp lemon juice', 
          'Salt and pepper'
        ],
        'instructions': 'Season chicken with salt and pepper. Grill until cooked through. Slice and place on top of mixed greens, tomato, and cucumber. Drizzle with olive oil and lemon juice.',
        'prepTime': 15,
        'cookTime': 15,
        'servings': 2,
        'difficulty': 'Easy',
        'imageUrl': 'https://example.com/chicken-salad.jpg',
      },
    ],
  };

  @override
  Future<List<Map<String, dynamic>>> getRecipesForFood(String foodName) async {
    await Future.delayed(const Duration(seconds: 1));
    
    // Convert to lowercase for case-insensitive matching
    final lowercaseFoodName = foodName.toLowerCase();
    
    // Try to find an exact match
    if (_mockRecipes.containsKey(lowercaseFoodName)) {
      return _mockRecipes[lowercaseFoodName]!;
    }
    
    // Try to find a partial match
    for (var key in _mockRecipes.keys) {
      if (key.contains(lowercaseFoodName) || lowercaseFoodName.contains(key)) {
        return _mockRecipes[key]!;
      }
    }
    
    // Return default recipe if no match found
    return [
      {
        'id': 'default',
        'name': 'Simple $foodName Dish',
        'ingredients': [
          '$foodName', 
          'Salt and pepper', 
          'Olive oil', 
          'Garlic'
        ],
        'instructions': 'Prepare $foodName with basic seasonings. Cook until done.',
        'prepTime': 15,
        'cookTime': 20,
        'servings': 4,
        'difficulty': 'Medium',
        'imageUrl': 'https://example.com/default-dish.jpg',
      }
    ];
  }
}

// User Preferences Service Interface and Mock Implementation
abstract class UserPreferencesService {
  Future<Map<String, dynamic>> getUserPreferences();
  Future<void> updateUserPreferences(Map<String, dynamic> preferences);
}

class MockUserPreferencesService implements UserPreferencesService {
  Map<String, dynamic> _userPreferences = {
    'dietaryRestrictions': ['Vegetarian'],
    'allergies': ['Peanuts'],
    'favoriteCategories': ['Fruits', 'Vegetables', 'Grains'],
    'calorieGoal': 2000,
    'proteinGoal': 100,
    'carbsGoal': 250,
    'fatGoal': 65,
    'theme': 'system',
    'notificationsEnabled': true,
  };

  @override
  Future<Map<String, dynamic>> getUserPreferences() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _userPreferences;
  }

  @override
  Future<void> updateUserPreferences(Map<String, dynamic> preferences) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _userPreferences = {..._userPreferences, ...preferences};
  }
}

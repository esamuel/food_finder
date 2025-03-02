import 'package:flutter/material.dart';

/// A comprehensive database of common foods with detailed nutritional information
/// This can be used to improve food recognition accuracy and provide detailed information
class FoodDatabase {
  /// Get a list of all foods in the database
  static List<FoodItem> getAllFoods() {
    return [
      apple,
      banana,
      broccoli,
      salmon,
      quinoa,
      avocado,
      sweetPotato,
      spinach,
      chickenBreast,
      lentils,
      blueberries,
      oliveOil,
      oats,
      tomato,
      greekYogurt,
      almonds,
      kale,
      eggs,
      brownRice,
      bellPepper,
    ];
  }

  /// Get a food item by name
  static FoodItem? getFoodByName(String name) {
    final normalizedName = name.toLowerCase().trim();
    return getAllFoods().firstWhere(
      (food) => food.name.toLowerCase() == normalizedName,
      orElse: () => FoodItem(
        name: 'Unknown Food',
        latinName: '',
        calories: 0,
        protein: 0,
        carbs: 0,
        fat: 0,
        vitaminsAndMinerals: [],
        seasonality: 'Unknown',
        imageDescription: '',
        imageUrl: '',
        color: Colors.grey,
      ),
    );
  }

  /// Get foods by category
  static List<FoodItem> getFoodsByCategory(FoodCategory category) {
    return getAllFoods().where((food) => food.category == category).toList();
  }

  // Individual food items
  static final FoodItem apple = FoodItem(
    name: 'Apple',
    latinName: 'Malus domestica',
    calories: 52,
    protein: 0.3,
    carbs: 13.8,
    fat: 0.2,
    vitaminsAndMinerals: ['Vitamin C', 'Potassium'],
    seasonality: 'Fall (September-November)',
    imageDescription:
        'Round fruit with red, green, or yellow skin and white flesh',
    imageUrl: 'https://images.unsplash.com/photo-1568702846914-96b305d2aaeb',
    category: FoodCategory.fruits,
    color: Colors.red,
  );

  static final FoodItem banana = FoodItem(
    name: 'Banana',
    latinName: 'Musa acuminata',
    calories: 89,
    protein: 1.1,
    carbs: 22.8,
    fat: 0.3,
    vitaminsAndMinerals: ['Potassium', 'Vitamin B6', 'Vitamin C'],
    seasonality: 'Year-round (peak January-April)',
    imageDescription:
        'Elongated yellow fruit with a curved shape and creamy flesh',
    imageUrl: 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e',
    category: FoodCategory.fruits,
    color: Colors.yellow,
  );

  static final FoodItem broccoli = FoodItem(
    name: 'Broccoli',
    latinName: 'Brassica oleracea var. italica',
    calories: 34,
    protein: 2.8,
    carbs: 6.6,
    fat: 0.4,
    vitaminsAndMinerals: ['Vitamin C', 'Vitamin K', 'Folate', 'Fiber'],
    seasonality: 'Fall and Spring (October-April)',
    imageDescription:
        'Green vegetable with compact flowering head and thick stalk',
    imageUrl: 'https://images.unsplash.com/photo-1459411621453-7b03977f4bfc',
    category: FoodCategory.vegetables,
    color: Colors.green,
  );

  static final FoodItem salmon = FoodItem(
    name: 'Salmon',
    latinName: 'Salmo salar',
    calories: 206,
    protein: 22.0,
    carbs: 0.0,
    fat: 13.0,
    vitaminsAndMinerals: ['Omega-3 fatty acids', 'Vitamin D', 'B vitamins'],
    seasonality: 'Spring to Fall (May-September for wild)',
    imageDescription:
        'Pink-orange fish with silver skin and distinctive flesh color',
    imageUrl: 'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2',
    category: FoodCategory.protein,
    color: Colors.orange.shade300,
  );

  static final FoodItem quinoa = FoodItem(
    name: 'Quinoa',
    latinName: 'Chenopodium quinoa',
    calories: 368,
    protein: 14.0,
    carbs: 64.0,
    fat: 6.0,
    vitaminsAndMinerals: ['Magnesium', 'Phosphorus', 'Manganese', 'Folate'],
    seasonality: 'Harvested fall, available year-round',
    imageDescription: 'Tiny beige seeds that turn translucent when cooked',
    imageUrl: 'https://images.unsplash.com/photo-1586201375761-83865001e8ac',
    category: FoodCategory.grains,
    color: Colors.amber.shade200,
  );

  static final FoodItem avocado = FoodItem(
    name: 'Avocado',
    latinName: 'Persea americana',
    calories: 160,
    protein: 2.0,
    carbs: 8.5,
    fat: 14.7,
    vitaminsAndMinerals: ['Vitamin K', 'Folate', 'Potassium'],
    seasonality: 'Year-round (peak spring and summer)',
    imageDescription:
        'Pear-shaped fruit with green-black skin and creamy green flesh',
    imageUrl: 'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578',
    category: FoodCategory.fruits,
    color: Colors.green.shade800,
  );

  static final FoodItem sweetPotato = FoodItem(
    name: 'Sweet Potato',
    latinName: 'Ipomoea batatas',
    calories: 86,
    protein: 1.6,
    carbs: 20.0,
    fat: 0.1,
    vitaminsAndMinerals: ['Vitamin A', 'Vitamin C', 'Manganese'],
    seasonality: 'Fall and Winter (October-January)',
    imageDescription:
        'Tuberous root vegetable with orange flesh and brown skin',
    imageUrl: 'https://images.unsplash.com/photo-1596097635121-14b38c5d7530',
    category: FoodCategory.vegetables,
    color: Colors.orange.shade700,
  );

  static final FoodItem spinach = FoodItem(
    name: 'Spinach',
    latinName: 'Spinacia oleracea',
    calories: 23,
    protein: 2.9,
    carbs: 3.6,
    fat: 0.4,
    vitaminsAndMinerals: ['Vitamin K', 'Vitamin A', 'Folate', 'Iron'],
    seasonality: 'Spring and Fall (March-May, September-October)',
    imageDescription: 'Dark green leafy vegetable with soft, rounded leaves',
    imageUrl: 'https://images.unsplash.com/photo-1576045057995-568f588f82fb',
    category: FoodCategory.vegetables,
    color: Colors.green.shade900,
  );

  static final FoodItem chickenBreast = FoodItem(
    name: 'Chicken Breast',
    latinName: 'Gallus gallus domesticus',
    calories: 165,
    protein: 31.0,
    carbs: 0.0,
    fat: 3.6,
    vitaminsAndMinerals: ['Vitamin B6', 'Phosphorus', 'Niacin', 'Selenium'],
    seasonality: 'Year-round',
    imageDescription: 'White meat poultry with lean, pale flesh',
    imageUrl: 'https://images.unsplash.com/photo-1604503468506-a8da13d82791',
    category: FoodCategory.protein,
    color: Colors.amber.shade100,
  );

  static final FoodItem lentils = FoodItem(
    name: 'Lentils',
    latinName: 'Lens culinaris',
    calories: 116,
    protein: 9.0,
    carbs: 20.0,
    fat: 0.4,
    vitaminsAndMinerals: ['Iron', 'Folate', 'Manganese', 'Fiber'],
    seasonality: 'Harvested summer, available year-round',
    imageDescription:
        'Small lens-shaped legumes in green, brown, or red colors',
    imageUrl: 'https://images.unsplash.com/photo-1611575619751-9f7b7d6f5b6f',
    category: FoodCategory.legumes,
    color: Colors.brown.shade300,
  );

  static final FoodItem blueberries = FoodItem(
    name: 'Blueberries',
    latinName: 'Vaccinium corymbosum',
    calories: 57,
    protein: 0.7,
    carbs: 14.5,
    fat: 0.3,
    vitaminsAndMinerals: [
      'Vitamin C',
      'Vitamin K',
      'Manganese',
      'Antioxidants'
    ],
    seasonality: 'Summer (June-August)',
    imageDescription:
        'Small round berries with deep blue-purple skin and light flesh',
    imageUrl: 'https://images.unsplash.com/photo-1498557850523-fd3d118b962e',
    category: FoodCategory.fruits,
    color: Colors.indigo.shade700,
  );

  static final FoodItem oliveOil = FoodItem(
    name: 'Olive Oil',
    latinName: 'Olea europaea',
    calories: 119,
    protein: 0.0,
    carbs: 0.0,
    fat: 13.5,
    vitaminsAndMinerals: [
      'Vitamin E',
      'Vitamin K',
      'Healthy monounsaturated fats'
    ],
    seasonality: 'Harvested fall, available year-round',
    imageDescription: 'Golden-green liquid oil pressed from olives',
    imageUrl: 'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5',
    category: FoodCategory.oils,
    color: Colors.amber.shade700,
  );

  static final FoodItem oats = FoodItem(
    name: 'Oats',
    latinName: 'Avena sativa',
    calories: 389,
    protein: 16.9,
    carbs: 66.3,
    fat: 6.9,
    vitaminsAndMinerals: ['Manganese', 'Phosphorus', 'Magnesium', 'Fiber'],
    seasonality: 'Harvested late summer, available year-round',
    imageDescription: 'Tan cereal grain, commonly sold as rolled flakes',
    imageUrl: 'https://images.unsplash.com/photo-1614961233913-a5113a4a34ed',
    category: FoodCategory.grains,
    color: Colors.brown.shade200,
  );

  static final FoodItem tomato = FoodItem(
    name: 'Tomato',
    latinName: 'Solanum lycopersicum',
    calories: 18,
    protein: 0.9,
    carbs: 3.9,
    fat: 0.2,
    vitaminsAndMinerals: ['Vitamin C', 'Potassium', 'Vitamin K', 'Lycopene'],
    seasonality: 'Summer (June-September)',
    imageDescription:
        'Round red fruit with smooth skin and juicy flesh containing seeds',
    imageUrl: 'https://images.unsplash.com/photo-1582284540020-8acbe03f4924',
    category: FoodCategory.vegetables,
    color: Colors.red.shade700,
  );

  static final FoodItem greekYogurt = FoodItem(
    name: 'Greek Yogurt',
    latinName: 'From Bos taurus',
    calories: 59,
    protein: 10.0,
    carbs: 3.6,
    fat: 0.4,
    vitaminsAndMinerals: ['Calcium', 'Vitamin B12', 'Phosphorus', 'Probiotics'],
    seasonality: 'Year-round',
    imageDescription: 'Thick, creamy white dairy product with tangy flavor',
    imageUrl: 'https://images.unsplash.com/photo-1488477181946-6428a0291777',
    category: FoodCategory.dairy,
    color: Colors.grey.shade100,
  );

  static final FoodItem almonds = FoodItem(
    name: 'Almonds',
    latinName: 'Prunus dulcis',
    calories: 579,
    protein: 21.2,
    carbs: 21.7,
    fat: 49.9,
    vitaminsAndMinerals: ['Vitamin E', 'Magnesium', 'Fiber'],
    seasonality: 'Harvested late summer, available year-round',
    imageDescription:
        'Oval-shaped nuts with brown skin and cream-colored interior',
    imageUrl: 'https://images.unsplash.com/photo-1508061253366-f7da158b6d46',
    category: FoodCategory.nuts,
    color: Colors.brown.shade400,
  );

  static final FoodItem kale = FoodItem(
    name: 'Kale',
    latinName: 'Brassica oleracea var. sabellica',
    calories: 49,
    protein: 4.3,
    carbs: 8.8,
    fat: 0.9,
    vitaminsAndMinerals: ['Vitamin K', 'Vitamin C', 'Vitamin A', 'Manganese'],
    seasonality: 'Fall and Winter (October-February)',
    imageDescription:
        'Dark green leafy vegetable with curly or flat leaves and firm stems',
    imageUrl: 'https://images.unsplash.com/photo-1524179091875-bf99a9a6af57',
    category: FoodCategory.vegetables,
    color: Colors.green.shade700,
  );

  static final FoodItem eggs = FoodItem(
    name: 'Eggs',
    latinName: 'Gallus gallus domesticus',
    calories: 72,
    protein: 6.3,
    carbs: 0.4,
    fat: 5.0,
    vitaminsAndMinerals: ['Vitamin B12', 'Selenium', 'Choline', 'Vitamin D'],
    seasonality: 'Year-round',
    imageDescription:
        'Oval food with hard shell containing clear white and yellow yolk',
    imageUrl: 'https://images.unsplash.com/photo-1506976785307-8732e854ad03',
    category: FoodCategory.protein,
    color: Colors.amber.shade50,
  );

  static final FoodItem brownRice = FoodItem(
    name: 'Brown Rice',
    latinName: 'Oryza sativa',
    calories: 112,
    protein: 2.6,
    carbs: 23.5,
    fat: 0.9,
    vitaminsAndMinerals: ['Manganese', 'Magnesium', 'Selenium', 'Fiber'],
    seasonality: 'Harvested fall, available year-round',
    imageDescription: 'Long or short grain cereal with light brown outer layer',
    imageUrl: 'https://images.unsplash.com/photo-1536304993881-ff6e9eefa2a6',
    category: FoodCategory.grains,
    color: Colors.brown.shade300,
  );

  static final FoodItem bellPepper = FoodItem(
    name: 'Bell Pepper',
    latinName: 'Capsicum annuum',
    calories: 31,
    protein: 1.0,
    carbs: 6.0,
    fat: 0.3,
    vitaminsAndMinerals: ['Vitamin C', 'Vitamin A', 'Vitamin B6'],
    seasonality: 'Summer to early Fall (July-October)',
    imageDescription:
        'Hollow vegetable with glossy skin in green, red, yellow, or orange',
    imageUrl: 'https://images.unsplash.com/photo-1563565375-f3fdfdbefa83',
    category: FoodCategory.vegetables,
    color: Colors.red.shade500,
  );
}

/// Food categories for classification
enum FoodCategory {
  fruits,
  vegetables,
  grains,
  protein,
  dairy,
  legumes,
  nuts,
  oils,
  other
}

/// Extension to get display name for food category
extension FoodCategoryExtension on FoodCategory {
  String get displayName {
    switch (this) {
      case FoodCategory.fruits:
        return 'Fruits';
      case FoodCategory.vegetables:
        return 'Vegetables';
      case FoodCategory.grains:
        return 'Grains';
      case FoodCategory.protein:
        return 'Protein';
      case FoodCategory.dairy:
        return 'Dairy';
      case FoodCategory.legumes:
        return 'Legumes';
      case FoodCategory.nuts:
        return 'Nuts';
      case FoodCategory.oils:
        return 'Oils';
      case FoodCategory.other:
        return 'Other';
    }
  }
}

/// Model class for food items with detailed nutritional information
class FoodItem {
  final String name;
  final String latinName;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final List<String> vitaminsAndMinerals;
  final String seasonality;
  final String imageDescription;
  final String imageUrl;
  final FoodCategory category;
  final Color color;

  FoodItem({
    required this.name,
    required this.latinName,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.vitaminsAndMinerals,
    required this.seasonality,
    required this.imageDescription,
    required this.imageUrl,
    this.category = FoodCategory.other,
    this.color = Colors.grey,
  });

  /// Get the main nutrient of the food item
  String get mainNutrient {
    if (protein > carbs && protein > fat) {
      return 'Protein';
    } else if (carbs > protein && carbs > fat) {
      return 'Carbs';
    } else if (fat > protein && fat > carbs) {
      return 'Healthy Fats';
    } else if (vitaminsAndMinerals.contains('Vitamin C')) {
      return 'Vitamin C';
    } else if (vitaminsAndMinerals.contains('Fiber')) {
      return 'Fiber';
    } else if (vitaminsAndMinerals.isNotEmpty) {
      return vitaminsAndMinerals.first;
    } else {
      return 'Balanced';
    }
  }

  /// Convert to a map for database storage
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'latinName': latinName,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'vitaminsAndMinerals': vitaminsAndMinerals,
      'seasonality': seasonality,
      'imageDescription': imageDescription,
      'imageUrl': imageUrl,
      'category': category.index,
      'colorValue': color.value,
    };
  }

  /// Create a FoodItem from a map
  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      name: map['name'] ?? '',
      latinName: map['latinName'] ?? '',
      calories: (map['calories'] ?? 0).toDouble(),
      protein: (map['protein'] ?? 0).toDouble(),
      carbs: (map['carbs'] ?? 0).toDouble(),
      fat: (map['fat'] ?? 0).toDouble(),
      vitaminsAndMinerals: List<String>.from(map['vitaminsAndMinerals'] ?? []),
      seasonality: map['seasonality'] ?? '',
      imageDescription: map['imageDescription'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      category: FoodCategory.values[map['category'] ?? 0],
      color: Color(map['colorValue'] ?? 0xFF9E9E9E),
    );
  }
}

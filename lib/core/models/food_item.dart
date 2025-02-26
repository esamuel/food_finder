import 'package:equatable/equatable.dart';

class FoodItem extends Equatable {
  final String id;
  final String name;
  final String category;
  final NutritionalInfo nutritionalInfo;
  final String origin;
  final String description;
  final String seasonality;
  final String storageGuidance;
  final List<String> commonUses;
  final List<String> pairings;
  final String imageUrl;
  
  const FoodItem({
    required this.id,
    required this.name,
    required this.category,
    required this.nutritionalInfo,
    required this.origin,
    required this.description,
    required this.seasonality,
    required this.storageGuidance,
    required this.commonUses,
    required this.pairings,
    required this.imageUrl,
  });
  
  @override
  List<Object> get props => [
    id, 
    name, 
    category, 
    nutritionalInfo, 
    origin, 
    description, 
    seasonality, 
    storageGuidance, 
    commonUses, 
    pairings, 
    imageUrl
  ];
  
  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      nutritionalInfo: NutritionalInfo.fromJson(json['nutritionalInfo'] as Map<String, dynamic>),
      origin: json['origin'] as String,
      description: json['description'] as String,
      seasonality: json['seasonality'] as String,
      storageGuidance: json['storageGuidance'] as String,
      commonUses: (json['commonUses'] as List).map((e) => e as String).toList(),
      pairings: (json['pairings'] as List).map((e) => e as String).toList(),
      imageUrl: json['imageUrl'] as String,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'nutritionalInfo': nutritionalInfo.toJson(),
      'origin': origin,
      'description': description,
      'seasonality': seasonality,
      'storageGuidance': storageGuidance,
      'commonUses': commonUses,
      'pairings': pairings,
      'imageUrl': imageUrl,
    };
  }
}

class NutritionalInfo extends Equatable {
  final double calories;
  final String protein;
  final String carbs;
  final String fat;
  final Map<String, String> vitamins;
  final Map<String, String> minerals;
  
  const NutritionalInfo({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.vitamins,
    required this.minerals,
  });
  
  @override
  List<Object> get props => [calories, protein, carbs, fat, vitamins, minerals];
  
  factory NutritionalInfo.fromJson(Map<String, dynamic> json) {
    return NutritionalInfo(
      calories: json['calories'] as double,
      protein: json['protein'] as String,
      carbs: json['carbs'] as String,
      fat: json['fat'] as String,
      vitamins: Map<String, String>.from(json['vitamins'] as Map),
      minerals: Map<String, String>.from(json['minerals'] as Map),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'vitamins': vitamins,
      'minerals': minerals,
    };
  }
}
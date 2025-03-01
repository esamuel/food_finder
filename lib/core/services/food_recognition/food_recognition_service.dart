import 'dart:io';
import 'dart:typed_data';

/// Represents a recognized food item with confidence score and nutrition data
class RecognizedFood {
  final String name;
  final double confidence;
  final Map<String, dynamic> nutritionData;

  RecognizedFood({
    required this.name,
    required this.confidence,
    this.nutritionData = const {},
  });

  @override
  String toString() => 'RecognizedFood(name: $name, confidence: ${(confidence * 100).toStringAsFixed(1)}%)';
}

/// Food recognition service interface
abstract class FoodRecognitionService {
  /// Recognize food from a File (mobile platforms)
  Future<List<RecognizedFood>> recognizeFromFile(File imageFile);

  /// Recognize food from bytes (web platform)
  Future<List<RecognizedFood>> recognizeFromBytes(Uint8List imageBytes);

  /// Get nutrition information for a recognized food
  Future<Map<String, dynamic>> getNutritionData(String foodName);
} 
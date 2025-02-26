import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../models/recognition_result.dart';
import 'food_recognition_service.dart';

/// A web-compatible food recognition service that uses mock data
/// This service is specifically designed for web platforms where TFLite is not available
class WebFoodRecognitionService implements FoodRecognitionServiceInterface {
  @override
  Future<List<RecognitionResult>> recognizeFood(Uint8List imageData) async {
    // Simulate processing delay
    await Future.delayed(const Duration(seconds: 2));

    // Return mock results with different foods
    // In a real app, you might call a web API instead
    return [
      const RecognitionResult(label: 'Pizza', confidence: 0.94),
      const RecognitionResult(label: 'Italian Food', confidence: 0.87),
      const RecognitionResult(label: 'Cheese Pizza', confidence: 0.82),
      const RecognitionResult(label: 'Fast Food', confidence: 0.75),
      const RecognitionResult(label: 'Tomato Sauce', confidence: 0.68),
    ];
  }

  @override
  Future<List<RecognitionResult>> recognizeFoodFromFile(File imageFile) async {
    if (kIsWeb) {
      // This is a fallback for web since File is not fully supported in web
      return [
        const RecognitionResult(label: 'Salad', confidence: 0.91),
        const RecognitionResult(label: 'Vegetable', confidence: 0.88),
        const RecognitionResult(label: 'Healthy Food', confidence: 0.79),
      ];
    }

    final bytes = await imageFile.readAsBytes();
    return recognizeFood(bytes);
  }
}

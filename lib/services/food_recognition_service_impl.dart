import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../core/models/recognition_result.dart';
import '../core/services/food_recognition_service.dart';

class FoodRecognitionServiceImpl {
  final FoodRecognitionServiceInterface _recognitionService;

  FoodRecognitionServiceImpl(this._recognitionService);

  // Recognize food from a file (mobile platforms)
  Future<List<RecognitionResult>> recognizeFoodFromFile(File imageFile) async {
    try {
      return await _recognitionService.recognizeFoodFromFile(imageFile);
    } catch (e) {
      debugPrint('Error recognizing food from file: $e');
      return _getFallbackResults();
    }
  }

  // Recognize food from bytes (web platform)
  Future<List<RecognitionResult>> recognizeFood(Uint8List imageBytes) async {
    try {
      return await _recognitionService.recognizeFood(imageBytes);
    } catch (e) {
      debugPrint('Error recognizing food from bytes: $e');
      return _getFallbackResults();
    }
  }

  // Fallback results in case of error
  List<RecognitionResult> _getFallbackResults() {
    return [
      const RecognitionResult(
        label: 'Food Item',
        confidence: 0.7,
      ),
    ];
  }
}

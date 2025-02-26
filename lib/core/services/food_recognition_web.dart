import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../models/recognition_result.dart';
import 'food_recognition_service.dart';

/// Web-compatible version of TFLiteFoodRecognitionService
/// This is a stub implementation that uses the EnhancedMockFoodRecognitionService
/// since TensorFlow Lite is not compatible with web platforms
class TFLiteFoodRecognitionService implements FoodRecognitionServiceInterface {
  final EnhancedMockFoodRecognitionService _mockService =
      EnhancedMockFoodRecognitionService();

  TFLiteFoodRecognitionService() {
    if (kIsWeb) {
      debugPrint(
          'TFLite is not supported on web platform. Using mock service instead.');
    }
  }

  @override
  Future<List<RecognitionResult>> recognizeFood(Uint8List imageData) async {
    // On web platforms, always use the mock service
    debugPrint(
        'Web implementation: Processing image with size ${imageData.length} bytes');
    return _mockService.recognizeFood(imageData);
  }

  @override
  Future<List<RecognitionResult>> recognizeFoodFromFile(File imageFile) async {
    try {
      debugPrint('Web implementation: Reading file');
      final bytes = await imageFile.readAsBytes();
      debugPrint(
          'Web implementation: File read successfully, size: ${bytes.length} bytes');
      return recognizeFood(bytes);
    } catch (e) {
      debugPrint('Web implementation: Error reading file: $e');
      // Create an empty Uint8List as a fallback
      return _mockService.recognizeFood(Uint8List(0));
    }
  }

  void dispose() {
    // No resources to dispose on web
    debugPrint('Web implementation: dispose called (no-op)');
  }
}

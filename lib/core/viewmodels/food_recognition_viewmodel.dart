import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../models/recognition_result.dart';
import '../services/food_recognition_service.dart';

class FoodRecognitionViewModel extends ChangeNotifier {
  FoodRecognitionServiceInterface _foodRecognitionService;

  List<RecognitionResult> _recognitionResults = [];
  bool _isLoading = false;
  String? _errorMessage;
  Uint8List? _currentImageData;

  FoodRecognitionViewModel(this._foodRecognitionService);

  // Getters
  List<RecognitionResult> get recognitionResults => _recognitionResults;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Uint8List? get currentImageData => _currentImageData;

  // Update service if needed (used by Provider)
  void updateService(FoodRecognitionServiceInterface service) {
    _foodRecognitionService = service;
  }

  // Recognize food from image data
  Future<void> recognizeFood(Uint8List imageData) async {
    _setLoading(true);
    _clearError();
    _currentImageData = imageData;

    try {
      _recognitionResults =
          await _foodRecognitionService.recognizeFood(imageData);
      notifyListeners();
    } catch (e) {
      _setError('Failed to recognize food: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Recognize food from file
  Future<void> recognizeFoodFromFile(File imageFile) async {
    _setLoading(true);
    _clearError();

    try {
      final bytes = await imageFile.readAsBytes();
      _currentImageData = bytes;
      _recognitionResults =
          await _foodRecognitionService.recognizeFoodFromFile(imageFile);
      notifyListeners();
    } catch (e) {
      _setError('Failed to recognize food: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Clear results
  void clearResults() {
    _recognitionResults = [];
    _currentImageData = null;
    _clearError();
    notifyListeners();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}

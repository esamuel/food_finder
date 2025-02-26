import 'package:flutter/foundation.dart';
import '../services/mock_services.dart';

class NutritionViewModel extends ChangeNotifier {
  NutritionService _nutritionService;

  Map<String, dynamic>? _nutritionInfo;
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentFoodName;

  NutritionViewModel(this._nutritionService);

  // Getters
  Map<String, dynamic>? get nutritionInfo => _nutritionInfo;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get currentFoodName => _currentFoodName;

  // Update service if needed (used by Provider)
  void updateService(NutritionService service) {
    _nutritionService = service;
  }

  // Get nutrition information for a food
  Future<void> getNutritionInfo(String foodName) async {
    _setLoading(true);
    _clearError();
    _currentFoodName = foodName;

    try {
      _nutritionInfo = await _nutritionService.getNutritionInfo(foodName);
      notifyListeners();
    } catch (e) {
      _setError('Failed to get nutrition info: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Clear nutrition info
  void clearNutritionInfo() {
    _nutritionInfo = null;
    _currentFoodName = null;
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

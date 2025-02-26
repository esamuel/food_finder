import 'package:flutter/foundation.dart';
import '../services/mock_services.dart';

class RecipeViewModel extends ChangeNotifier {
  RecipeService _recipeService;

  List<Map<String, dynamic>> _recipes = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentFoodName;

  RecipeViewModel(this._recipeService);

  // Getters
  List<Map<String, dynamic>> get recipes => _recipes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get currentFoodName => _currentFoodName;

  // Update service if needed (used by Provider)
  void updateService(RecipeService service) {
    _recipeService = service;
  }

  // Get recipes for a food
  Future<void> getRecipesForFood(String foodName) async {
    _setLoading(true);
    _clearError();
    _currentFoodName = foodName;

    try {
      _recipes = await _recipeService.getRecipesForFood(foodName);
      notifyListeners();
    } catch (e) {
      _setError('Failed to get recipes: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Clear recipes
  void clearRecipes() {
    _recipes = [];
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

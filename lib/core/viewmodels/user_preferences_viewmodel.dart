import 'package:flutter/foundation.dart';
import '../services/mock_services.dart';

class UserPreferencesViewModel extends ChangeNotifier {
  UserPreferencesService _userPreferencesService;

  Map<String, dynamic>? _userPreferences;
  bool _isLoading = false;
  String? _errorMessage;

  UserPreferencesViewModel(this._userPreferencesService) {
    // Load preferences when the ViewModel is created
    loadUserPreferences();
  }

  // Getters
  Map<String, dynamic>? get userPreferences => _userPreferences;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Specific preference getters
  List<String> get dietaryRestrictions =>
      (_userPreferences?['dietaryRestrictions'] as List<dynamic>?)
          ?.cast<String>() ??
      [];

  List<String> get allergies =>
      (_userPreferences?['allergies'] as List<dynamic>?)?.cast<String>() ?? [];

  List<String> get favoriteCategories =>
      (_userPreferences?['favoriteCategories'] as List<dynamic>?)
          ?.cast<String>() ??
      [];

  int get calorieGoal => _userPreferences?['calorieGoal'] as int? ?? 2000;
  int get proteinGoal => _userPreferences?['proteinGoal'] as int? ?? 100;
  int get carbsGoal => _userPreferences?['carbsGoal'] as int? ?? 250;
  int get fatGoal => _userPreferences?['fatGoal'] as int? ?? 65;

  String get theme => _userPreferences?['theme'] as String? ?? 'system';
  bool get notificationsEnabled =>
      _userPreferences?['notificationsEnabled'] as bool? ?? true;

  // Update service if needed (used by Provider)
  void updateService(UserPreferencesService service) {
    _userPreferencesService = service;
  }

  // Load user preferences
  Future<void> loadUserPreferences() async {
    _setLoading(true);
    _clearError();

    try {
      _userPreferences = await _userPreferencesService.getUserPreferences();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load user preferences: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Update user preferences
  Future<void> updateUserPreferences(Map<String, dynamic> preferences) async {
    _setLoading(true);
    _clearError();

    try {
      await _userPreferencesService.updateUserPreferences(preferences);
      // Reload preferences to ensure we have the latest data
      await loadUserPreferences();
    } catch (e) {
      _setError('Failed to update user preferences: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Update specific preferences
  Future<void> updateDietaryRestrictions(List<String> restrictions) async {
    await updateUserPreferences({'dietaryRestrictions': restrictions});
  }

  Future<void> updateAllergies(List<String> allergies) async {
    await updateUserPreferences({'allergies': allergies});
  }

  Future<void> updateFavoriteCategories(List<String> categories) async {
    await updateUserPreferences({'favoriteCategories': categories});
  }

  Future<void> updateNutritionGoals({
    int? calorieGoal,
    int? proteinGoal,
    int? carbsGoal,
    int? fatGoal,
  }) async {
    final updates = <String, dynamic>{};
    if (calorieGoal != null) updates['calorieGoal'] = calorieGoal;
    if (proteinGoal != null) updates['proteinGoal'] = proteinGoal;
    if (carbsGoal != null) updates['carbsGoal'] = carbsGoal;
    if (fatGoal != null) updates['fatGoal'] = fatGoal;

    await updateUserPreferences(updates);
  }

  Future<void> updateTheme(String theme) async {
    await updateUserPreferences({'theme': theme});
  }

  Future<void> updateNotificationsEnabled(bool enabled) async {
    await updateUserPreferences({'notificationsEnabled': enabled});
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

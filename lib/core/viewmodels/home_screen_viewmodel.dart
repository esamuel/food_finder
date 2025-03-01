import 'package:flutter/material.dart';
import '../services/mock_services.dart';

class HomeScreenViewModel extends ChangeNotifier {
  final DatabaseServiceInterface _databaseService;
  final AuthServiceInterface _authService;

  HomeScreenViewModel({
    required DatabaseServiceInterface databaseService,
    required AuthServiceInterface authService,
  })  : _databaseService = databaseService,
        _authService = authService;

  // State variables
  bool _isLoading = false;
  List<Map<String, dynamic>> _featuredItems = [];
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _recentDiscoveries = [];
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get featuredItems => _featuredItems;
  List<Map<String, dynamic>> get categories => _categories;
  List<Map<String, dynamic>> get recentDiscoveries => _recentDiscoveries;
  String? get error => _error;

  // Initialize data
  Future<void> initialize() async {
    _setLoading(true);
    try {
      await Future.wait([
        _loadFeaturedItems(),
        _loadCategories(),
        _loadRecentDiscoveries(),
      ]);
      _error = null;
    } catch (e) {
      _error = 'Failed to load data: $e';
      print(_error);
    } finally {
      _setLoading(false);
    }
  }

  // Load featured items
  Future<void> _loadFeaturedItems() async {
    try {
      // In a real app, you would fetch this from Firebase
      // For now, we'll use hardcoded data
      _featuredItems = [
        {
          'title': 'Scan Food',
          'description':
              'Take a photo of any food to identify it and get nutritional information.',
          'icon': 'camera_alt',
          'color': 'blue',
        },
        {
          'title': 'Food Database',
          'description':
              'Browse our extensive database of foods and their nutritional values.',
          'icon': 'search',
          'color': 'green',
        },
        {
          'title': 'Meal Planning',
          'description':
              'Plan your meals for the week and track your nutritional intake.',
          'icon': 'calendar_today',
          'color': 'orange',
        },
      ];
    } catch (e) {
      print('Error loading featured items: $e');
      rethrow;
    }
  }

  // Load categories
  Future<void> _loadCategories() async {
    try {
      // In a real app, you would fetch this from Firebase
      // For now, we'll use hardcoded data
      final List<String> categoryNames = [
        'Fruits',
        'Vegetables',
        'Grains',
        'Protein Foods',
        'Dairy',
        'Snacks',
        'Beverages',
        'Desserts',
        'Prepared Dishes',
        'Condiments',
      ];

      _categories = categoryNames.map((name) => {'name': name}).toList();
    } catch (e) {
      print('Error loading categories: $e');
      rethrow;
    }
  }

  // Load recent discoveries
  Future<void> _loadRecentDiscoveries() async {
    try {
      final userId = _authService.currentUserId;

      if (userId != null) {
        // In a real app, you would fetch this from Firebase
        // For now, we'll use mock data
        final List<Map<String, dynamic>> foodItems =
            await _databaseService.getFoodItems();

        // Take the most recent 5 items
        _recentDiscoveries = foodItems.take(5).map((item) {
          return {
            'name': item['name'],
            'category': item['category'],
            'date': DateTime.now().subtract(const Duration(days: 1)),
            'imagePlaceholder': (item['name'] as String).substring(0, 1),
            'imageUrl': item['imageUrl'],
          };
        }).toList();
      } else {
        _recentDiscoveries = [];
      }
    } catch (e) {
      print('Error loading recent discoveries: $e');
      rethrow;
    }
  }

  // Helper method to set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import '../../../core/models/recognition_result.dart';
import '../../../core/models/food_item.dart';
import '../../../core/services/mock_services.dart';
import '../../../config/constants.dart';
import 'components/food_info_card.dart';
import 'components/recognition_item.dart';

class ResultsScreen extends StatefulWidget {
  final List<RecognitionResult> results;
  final Uint8List? imageBytes;
  final String? imagePath;

  const ResultsScreen({
    Key? key,
    required this.results,
    this.imageBytes,
    this.imagePath,
  }) : super(key: key);

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  bool _isLoading = true;
  FoodItem? _selectedFood;
  bool _imageLoadError = false;
  String? _savedImageUrl;
  bool _isSavingToHistory = false;

  @override
  void initState() {
    super.initState();
    _debugImageData();
    _loadFoodDetails();
  }

  void _debugImageData() {
    debugPrint('ResultsScreen initialized with:');
    debugPrint('  - ${widget.results.length} recognition results');
    if (widget.imageBytes != null) {
      debugPrint('  - Image bytes: ${widget.imageBytes!.length} bytes');
    } else {
      debugPrint('  - Image bytes: null');
    }
    debugPrint('  - Image path: ${widget.imagePath}');

    // Check the first result
    if (widget.results.isNotEmpty) {
      final topResult = widget.results.first;
      debugPrint(
          '  - Top result: ${topResult.label} (${(topResult.confidence * 100).toStringAsFixed(1)}%)');
    }
  }

  Future<void> _loadFoodDetails() async {
    // In a real app, this would fetch from a service
    // For now, we'll create mock data after a short delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Mock saving the image
    if (widget.imageBytes != null) {
      // In a real app, this would upload the image to storage
      _savedImageUrl =
          'https://example.com/food_images/${DateTime.now().millisecondsSinceEpoch}.jpg';
      debugPrint('Mock image saved to: $_savedImageUrl');
    }

    // Mock food data based on the top result
    if (widget.results.isNotEmpty) {
      final topResult = widget.results.first;
      debugPrint('Creating mock food data for: ${topResult.label}');

      _selectedFood = FoodItem(
        id: '1',
        name: topResult.label,
        category: _getCategoryForFood(topResult.label),
        nutritionalInfo: const NutritionalInfo(
          calories: 95,
          protein: '0.5g',
          carbs: '25g',
          fat: '0.3g',
          vitamins: {
            'Vitamin C': '14% DV',
            'Vitamin A': '2% DV',
          },
          minerals: {
            'Potassium': '6% DV',
            'Manganese': '3% DV',
          },
        ),
        origin: 'Central Asia',
        description:
            'A crisp and sweet fruit with varieties ranging from sweet to tart. Rich in fiber and vitamin C.',
        seasonality: 'Year-round, best September-November',
        storageGuidance:
            'Refrigerate for up to 6 weeks. Store away from ethylene-sensitive fruits and vegetables.',
        commonUses: const [
          'Fresh eating',
          'Baking',
          'Sauces',
          'Juices',
          'Salads',
        ],
        pairings: const [
          'Cinnamon',
          'Caramel',
          'Pork',
          'Cheese',
          'Walnuts',
        ],
        imageUrl: _savedImageUrl ?? '',
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  String _getCategoryForFood(String food) {
    final foodLower = food.toLowerCase();

    if (foodLower.contains('apple') ||
        foodLower.contains('banana') ||
        foodLower.contains('berry')) {
      return 'Fruits';
    } else if (foodLower.contains('carrot') ||
        foodLower.contains('broccoli') ||
        foodLower.contains('tomato')) {
      return 'Vegetables';
    } else if (foodLower.contains('bread') ||
        foodLower.contains('rice') ||
        foodLower.contains('pasta')) {
      return 'Grains';
    } else if (foodLower.contains('chicken') ||
        foodLower.contains('beef') ||
        foodLower.contains('fish')) {
      return 'Protein Foods';
    } else if (foodLower.contains('milk') ||
        foodLower.contains('cheese') ||
        foodLower.contains('yogurt')) {
      return 'Dairy';
    } else if (foodLower.contains('cake') ||
        foodLower.contains('cookie') ||
        foodLower.contains('ice cream')) {
      return 'Desserts';
    } else {
      return 'Other';
    }
  }

  Widget _buildNutritionRow(
      String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(value ?? ''),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Results'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isSavingToHistory ? null : _saveToHistory,
            tooltip: 'Save to History',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildResultsContent(),
    );
  }

  Future<void> _saveToHistory() async {
    if (_selectedFood == null) return;

    setState(() {
      _isSavingToHistory = true;
    });

    try {
      // In a real app, this would save to a database
      // For now, we'll just simulate a delay
      await Future.delayed(const Duration(milliseconds: 800));

      // Create a mock history entry
      final historyEntry = {
        'foodId': _selectedFood!.id,
        'foodName': _selectedFood!.name,
        'category': _selectedFood!.category,
        'imageUrl': _savedImageUrl ?? '',
        'timestamp': DateTime.now().toIso8601String(),
        'note': 'Discovered using Food Finder app',
      };

      debugPrint('Saving to history: ${historyEntry['foodName']}');

      // Show success message
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_selectedFood!.name} saved to history'),
          action: SnackBarAction(
            label: 'VIEW',
            onPressed: () {
              // Navigate to history or profile screen
              Navigator.of(context).pushNamed('/profile');
            },
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error saving to history: $e');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving to history: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSavingToHistory = false;
        });
      }
    }
  }

  Widget _buildResultsContent() {
    if (widget.results.isEmpty) {
      return const Center(
        child: Text('No food detected. Please try again with a clearer image.'),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image section
          _buildImageSection(),

          // Results section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recognition Results',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                ...widget.results.map((result) => RecognitionItem(
                      result: result,
                      isSelected: widget.results.indexOf(result) == 0,
                      onTap: () {
                        // In a real app, this would load details for the selected item
                        debugPrint('Selected: ${result.label}');
                      },
                    )),
                const SizedBox(height: 24),

                // Food details section
                if (_selectedFood != null) _buildFoodDetailsSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1),
      ),
      child: _imageLoadError
          ? const Center(
              child: Icon(
                Icons.broken_image,
                size: 64,
                color: Colors.grey,
              ),
            )
          : _buildImageContent(),
    );
  }

  Widget _buildImageContent() {
    try {
      if (widget.imageBytes != null) {
        return Image.memory(
          widget.imageBytes!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Error loading image bytes: $error');
            setState(() {
              _imageLoadError = true;
            });
            return const Center(
              child: Icon(
                Icons.broken_image,
                size: 64,
                color: Colors.grey,
              ),
            );
          },
        );
      } else if (widget.imagePath != null && !kIsWeb) {
        final file = File(widget.imagePath!);
        if (!file.existsSync()) {
          debugPrint('Image file does not exist: ${widget.imagePath}');
          return const Center(
            child: Icon(
              Icons.broken_image,
              size: 64,
              color: Colors.grey,
            ),
          );
        }

        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Error loading image file: $error');
            setState(() {
              _imageLoadError = true;
            });
            return const Center(
              child: Icon(
                Icons.broken_image,
                size: 64,
                color: Colors.grey,
              ),
            );
          },
        );
      } else {
        return const Center(
          child: Icon(
            Icons.image_not_supported,
            size: 64,
            color: Colors.grey,
          ),
        );
      }
    } catch (e) {
      debugPrint('Exception in _buildImageContent: $e');
      return const Center(
        child: Icon(
          Icons.error_outline,
          size: 64,
          color: Colors.red,
        ),
      );
    }
  }

  Widget _buildFoodDetailsSection() {
    if (_selectedFood == null) {
      return const Center(
        child: Text('Food details not available'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withAlpha(26),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withAlpha(128),
            ),
          ),
          child: Text(
            _selectedFood!.category,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Nutritional information card
        FoodInfoCard(
          title: 'Nutritional Information',
          icon: Icons.restaurant,
          child: Column(
            children: [
              _buildNutritionRow(
                'Calories',
                '${_selectedFood!.nutritionalInfo.calories} kcal',
                Icons.local_fire_department,
                Colors.orange,
              ),
              _buildNutritionRow(
                'Protein',
                _selectedFood!.nutritionalInfo.protein,
                Icons.fitness_center,
                Colors.red,
              ),
              _buildNutritionRow(
                'Carbs',
                _selectedFood!.nutritionalInfo.carbs,
                Icons.grain,
                Colors.amber,
              ),
              _buildNutritionRow(
                'Fat',
                _selectedFood!.nutritionalInfo.fat,
                Icons.opacity,
                Colors.yellow,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Description card
        if (_selectedFood!.description != null &&
            _selectedFood!.description!.isNotEmpty)
          FoodInfoCard(
            title: 'Description',
            icon: Icons.info_outline,
            child: Text(_selectedFood!.description ?? ''),
          ),

        const SizedBox(height: 16),

        // Origin & Seasonality card
        if ((_selectedFood!.origin != null &&
                _selectedFood!.origin!.isNotEmpty) ||
            (_selectedFood!.seasonality != null &&
                _selectedFood!.seasonality!.isNotEmpty))
          FoodInfoCard(
            title: 'Origin & Seasonality',
            icon: Icons.public,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_selectedFood!.origin != null &&
                    _selectedFood!.origin!.isNotEmpty)
                  _buildInfoRow('Origin:', _selectedFood!.origin),
                if (_selectedFood!.origin != null &&
                    _selectedFood!.origin!.isNotEmpty &&
                    _selectedFood!.seasonality != null &&
                    _selectedFood!.seasonality!.isNotEmpty)
                  const SizedBox(height: 8),
                if (_selectedFood!.seasonality != null &&
                    _selectedFood!.seasonality!.isNotEmpty)
                  _buildInfoRow('Seasonality:', _selectedFood!.seasonality),
              ],
            ),
          ),

        const SizedBox(height: 16),

        // Storage guidance card
        if (_selectedFood!.storageGuidance != null &&
            _selectedFood!.storageGuidance!.isNotEmpty)
          FoodInfoCard(
            title: 'Storage Guidance',
            icon: Icons.kitchen,
            child: Text(_selectedFood!.storageGuidance ?? ''),
          ),

        const SizedBox(height: 16),

        // Common uses card
        if (_selectedFood!.commonUses.isNotEmpty)
          FoodInfoCard(
            title: 'Common Uses',
            icon: Icons.restaurant_menu,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedFood!.commonUses
                  .map((use) => Chip(
                        label: Text(use),
                        backgroundColor: Theme.of(context).colorScheme.surface,
                      ))
                  .toList(),
            ),
          ),

        const SizedBox(height: 16),

        // Pairings card
        if (_selectedFood!.pairings.isNotEmpty)
          FoodInfoCard(
            title: 'Pairs Well With',
            icon: Icons.interests,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedFood!.pairings
                  .map((pairing) => Chip(
                        label: Text(pairing),
                        backgroundColor: Theme.of(context).colorScheme.surface,
                      ))
                  .toList(),
            ),
          ),
      ],
    );
  }
}

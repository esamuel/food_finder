import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../core/models/recognition_result.dart';
import '../../../core/models/food_item.dart';
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
        imageUrl: '',
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

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Identification Results'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              // Handle adding to favorites
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Added to favorites'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildResultsContent(),
      floatingActionButton: !_isLoading
          ? FloatingActionButton(
              onPressed: () {
                // Handle sharing
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sharing...'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              child: const Icon(Icons.share),
              tooltip: 'Share',
            )
          : null,
    );
  }

  Widget _buildResultsContent() {
    if (widget.results.isEmpty) {
      return const Center(
        child: Text('No results found. Try again with a clearer image.'),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display the actual food image with improved styling
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: _buildImageWidget(),
              ),
              // Add a gradient overlay at the bottom for better text visibility
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ),
              // Add the food name on the image
              if (_selectedFood != null)
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Text(
                    _selectedFood!.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 3,
                          color: Colors.black45,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          // Recognition confidence section with improved styling
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Recognition Results',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...widget.results.map((result) => RecognitionItem(
                      result: result,
                      isSelected: widget.results.indexOf(result) == 0,
                      onTap: () {
                        // In a real app, this would load details for the selected item
                      },
                    )),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Food information section with improved styling
          if (_selectedFood != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.5),
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
                  FoodInfoCard(
                    title: 'Description',
                    icon: Icons.info_outline,
                    child: Text(_selectedFood!.description),
                  ),

                  const SizedBox(height: 16),

                  // Origin & Seasonality card
                  FoodInfoCard(
                    title: 'Origin & Seasonality',
                    icon: Icons.public,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('Origin:', _selectedFood!.origin),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                            'Seasonality:', _selectedFood!.seasonality),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Storage guidance card
                  FoodInfoCard(
                    title: 'Storage Guidance',
                    icon: Icons.kitchen,
                    child: Text(_selectedFood!.storageGuidance),
                  ),

                  const SizedBox(height: 16),

                  // Common uses card
                  FoodInfoCard(
                    title: 'Common Uses',
                    icon: Icons.restaurant_menu,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _selectedFood!.commonUses
                          .map((use) => Chip(
                                label: Text(use),
                                backgroundColor:
                                    Theme.of(context).colorScheme.surface,
                              ))
                          .toList(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Pairings card
                  FoodInfoCard(
                    title: 'Pairs Well With',
                    icon: Icons.interests,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _selectedFood!.pairings
                          .map((pairing) => Chip(
                                label: Text(pairing),
                                backgroundColor:
                                    Theme.of(context).colorScheme.surface,
                              ))
                          .toList(),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Action buttons
                  Container(
                    margin: const EdgeInsets.only(top: 16, bottom: 32),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'What would you like to do?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildActionButton(
                              icon: Icons.restaurant_menu,
                              label: 'Find Recipes',
                              onTap: () {
                                // Navigate to recipes
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Finding recipes...'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                            ),
                            _buildActionButton(
                              icon: Icons.shopping_cart,
                              label: 'Where to Buy',
                              onTap: () {
                                // Show shopping options
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Finding stores...'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                            ),
                            _buildActionButton(
                              icon: Icons.more_horiz,
                              label: 'More Info',
                              onTap: () {
                                // Show additional information
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Loading more information...'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageWidget() {
    // If we have image bytes (primarily for web)
    if (widget.imageBytes != null && widget.imageBytes!.isNotEmpty) {
      debugPrint(
          'Displaying image from bytes: ${widget.imageBytes!.length} bytes');

      // Add a key to force rebuild when image changes
      return Image.memory(
        widget.imageBytes!,
        fit: BoxFit.cover,
        key: ValueKey('image-bytes-${widget.imageBytes!.length}'),
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Error displaying image from bytes: $error');
          setState(() {
            _imageLoadError = true;
          });
          return _buildImagePlaceholder();
        },
      );
    }

    // If we have an image path (primarily for mobile)
    else if (widget.imagePath != null && widget.imagePath!.isNotEmpty) {
      debugPrint('Displaying image from file: ${widget.imagePath}');
      try {
        // Add a key to force rebuild when image changes
        return Image.file(
          File(widget.imagePath!),
          fit: BoxFit.cover,
          key: ValueKey('image-file-${widget.imagePath}'),
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Error displaying image from file: $error');
            setState(() {
              _imageLoadError = true;
            });
            return _buildImagePlaceholder();
          },
        );
      } catch (e) {
        debugPrint('Exception when creating Image.file: $e');
        return _buildImagePlaceholder();
      }
    }

    // Fallback to placeholder
    else {
      debugPrint('No image data available, showing placeholder');
      return _buildImagePlaceholder();
    }
  }

  Widget _buildImagePlaceholder() {
    final String firstLetter =
        _selectedFood?.name.substring(0, 1).toUpperCase() ?? 'F';
    debugPrint('Building placeholder with letter: $firstLetter');

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            firstLetter,
            style: TextStyle(
              fontSize: 80,
              fontWeight: FontWeight.bold,
              color: Colors.grey[500],
            ),
          ),
          if (_imageLoadError)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Image could not be displayed',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

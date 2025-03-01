import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../core/models/recognition_result.dart';
import '../../core/models/scan_history_item.dart';
import '../../core/services/scan_history_service.dart';
import '../../core/services/favorites_service.dart';

class FoodRecognitionResultScreen extends StatefulWidget {
  final List<RecognitionResult> results;
  final dynamic imageData; // Can be File, Uint8List, or String (URL)
  final bool isFromCamera;

  const FoodRecognitionResultScreen({
    Key? key,
    required this.results,
    required this.imageData,
    this.isFromCamera = false,
  }) : super(key: key);

  @override
  State<FoodRecognitionResultScreen> createState() =>
      _FoodRecognitionResultScreenState();
}

class _FoodRecognitionResultScreenState
    extends State<FoodRecognitionResultScreen> {
  final ScanHistoryService _historyService = ScanHistoryService();
  final FavoritesService _favoritesService = FavoritesService();
  bool _isSaving = false;
  bool _isSaved = false;
  bool _isFavorite = false;
  bool _isAddingToFavorites = false;

  @override
  void initState() {
    super.initState();
    // Automatically save the scan when the screen is loaded
    _saveScanToHistory();
    // Check if this item is already a favorite
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    try {
      // Create a temporary item to get its ID
      final tempItem = ScanHistoryItem.fromRecognitionResults(
        results: widget.results,
        imageUrl: widget.imageData is String ? widget.imageData : null,
        imageBytes: widget.imageData is Uint8List ? widget.imageData : null,
        localImagePath: widget.imageData is File ? widget.imageData.path : null,
      );

      final isFav = await _favoritesService.isFavorite(tempItem.id);

      if (mounted) {
        setState(() {
          _isFavorite = isFav;
        });
      }
    } catch (e) {
      debugPrint('Error checking if favorite: $e');
    }
  }

  Future<void> _saveScanToHistory() async {
    if (_isSaved) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await _historyService.saveScan(
        results: widget.results,
        imageData: widget.imageData,
      );

      setState(() {
        _isSaved = true;
      });
    } catch (e) {
      debugPrint('Error saving scan: $e');
      // Show error snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save scan: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _toggleFavorite(RecognitionResult result) async {
    if (_isAddingToFavorites) return;

    setState(() {
      _isAddingToFavorites = true;
    });

    try {
      if (_isFavorite) {
        // Create a temporary item to get its ID
        final tempItem = ScanHistoryItem.fromRecognitionResults(
          results: widget.results,
          imageUrl: widget.imageData is String ? widget.imageData : null,
          imageBytes: widget.imageData is Uint8List ? widget.imageData : null,
          localImagePath:
              widget.imageData is File ? widget.imageData.path : null,
        );

        await _favoritesService.removeFromFavorites(tempItem.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Removed from favorites'),
              backgroundColor: Colors.blue,
            ),
          );
        }
      } else {
        await _favoritesService.addResultsToFavorites(
          results: widget.results,
          imageData: widget.imageData,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Added to favorites'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      setState(() {
        _isFavorite = !_isFavorite;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isAddingToFavorites = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate a reasonable image height based on screen size
    final screenWidth = MediaQuery.of(context).size.width;
    final imageSize = screenWidth > 600 ? 400.0 : screenWidth * 0.8;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recognition Results'),
        backgroundColor: Colors.green,
        elevation: 0,
        actions: [
          // Save button with status indicator
          _isSaved
              ? IconButton(
                  icon: const Icon(Icons.check_circle, color: Colors.white),
                  onPressed: null,
                  tooltip: 'Saved to history',
                )
              : _isSaving
                  ? Container(
                      padding: const EdgeInsets.all(10),
                      child: const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.save),
                      onPressed: _saveScanToHistory,
                      tooltip: 'Save to history',
                    ),
        ],
      ),
      // Use SingleChildScrollView to prevent overflow
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Image preview - Updated to be square and centered with fixed size
            Container(
              width: double.infinity,
              color: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: SizedBox(
                  width: imageSize,
                  height: imageSize,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: _buildImagePreview(),
                  ),
                ),
              ),
            ),

            // Results section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recognition Results',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Results list
                  widget.results.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Text(
                              'No results found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          // Make the ListView non-scrollable since it's inside a SingleChildScrollView
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: widget.results.length,
                          itemBuilder: (context, index) {
                            final result = widget.results[index];
                            return _buildResultCard(result);
                          },
                        ),

                  // Add some bottom padding for the FAB
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pop(context);
        },
        backgroundColor: Colors.green,
        icon: const Icon(Icons.camera_alt),
        label: const Text('Scan Again'),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (widget.imageData is File) {
      return Image.file(
        widget.imageData as File,
        fit: BoxFit.contain,
      );
    } else if (widget.imageData is Uint8List) {
      return Image.memory(
        widget.imageData as Uint8List,
        fit: BoxFit.contain,
      );
    } else if (widget.imageData is String) {
      return Image.network(
        widget.imageData as String,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Icon(Icons.broken_image, size: 64, color: Colors.white54),
          );
        },
      );
    } else {
      return const Center(
        child: Icon(Icons.image_not_supported, size: 64, color: Colors.white54),
      );
    }
  }

  Widget _buildResultCard(RecognitionResult result) {
    final confidence = result.confidence * 100;
    final color = _getConfidenceColor(result.confidence);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.label,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Display food category
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          result.category,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${confidence.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Text(
              'Confidence Level',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 8),

            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: result.confidence,
                backgroundColor: Colors.grey.shade200,
                color: color,
                minHeight: 8,
              ),
            ),

            const SizedBox(height: 16),

            // Nutritional information with enhanced display
            _buildNutritionalInfo(result),

            const SizedBox(height: 12),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: _isAddingToFavorites
                      ? null
                      : () => _toggleFavorite(result),
                  icon: _isAddingToFavorites
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.red),
                          ),
                        )
                      : Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: Colors.red,
                        ),
                  label: Text(_isFavorite ? 'Saved' : 'Save'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () {
                    // TODO: View details
                  },
                  icon: const Icon(Icons.info_outline),
                  label: const Text('Details'),
                  style: TextButton.styleFrom(foregroundColor: Colors.blue),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Updated to use the nutritional info from the RecognitionResult
  Widget _buildNutritionalInfo(RecognitionResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nutritional Information',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        // Wrap the Row in a Container with fixed height to prevent overflow
        SizedBox(
          height: 80,
          child: Row(
            children: [
              _buildNutrientItem(
                'Calories',
                result.getNutritionalValue('calories').toInt().toString(),
                'kcal',
                Colors.orange,
              ),
              _buildNutrientItem(
                'Protein',
                result.getNutritionalValue('protein').toString(),
                'g',
                Colors.red,
              ),
              _buildNutrientItem(
                'Carbs',
                result.getNutritionalValue('carbs').toString(),
                'g',
                Colors.blue,
              ),
              _buildNutrientItem(
                'Fat',
                result.getNutritionalValue('fat').toString(),
                'g',
                Colors.purple,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Additional nutrients if available
        if (result.nutritionalInfo.containsKey('fiber') ||
            result.nutritionalInfo.containsKey('sugar'))
          SizedBox(
            height: 80,
            child: Row(
              children: [
                if (result.nutritionalInfo.containsKey('fiber'))
                  _buildNutrientItem(
                    'Fiber',
                    result.getNutritionalValue('fiber').toString(),
                    'g',
                    Colors.green,
                  ),
                if (result.nutritionalInfo.containsKey('sugar'))
                  _buildNutrientItem(
                    'Sugar',
                    result.getNutritionalValue('sugar').toString(),
                    'g',
                    Colors.pink,
                  ),
                // Add empty spacers to maintain layout if not all nutrients are present
                if (!result.nutritionalInfo.containsKey('fiber') &&
                    !result.nutritionalInfo.containsKey('sugar'))
                  Expanded(child: Container()),
                if (!result.nutritionalInfo.containsKey('fiber') ||
                    !result.nutritionalInfo.containsKey('sugar'))
                  Expanded(child: Container()),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildNutrientItem(
    String label,
    String value,
    String unit,
    Color color,
  ) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.circle,
              color: color,
              size: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value + unit,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) {
      return Colors.green;
    } else if (confidence >= 0.6) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}

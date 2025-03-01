import 'package:flutter/material.dart';
import '../../core/services/food_recognition/food_recognition_service.dart';
import '../theme/app_theme.dart';

/// Card widget to display a recognized food item
class FoodResultCard extends StatelessWidget {
  final RecognizedFood food;

  const FoodResultCard({
    Key? key,
    required this.food,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate confidence percentage
    final confidencePercent = (food.confidence * 100).toStringAsFixed(1);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Food name and confidence
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    food.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getConfidenceColor(food.confidence),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$confidencePercent%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Nutrition data
            if (food.nutritionData.isNotEmpty) ...[
              const Text(
                'Nutrition Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),

              // Display nutrition data in a grid
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  if (food.nutritionData.containsKey('calories'))
                    _buildNutritionItem(
                      'Calories',
                      '${food.nutritionData['calories']}',
                      Icons.local_fire_department,
                    ),
                  if (food.nutritionData.containsKey('protein'))
                    _buildNutritionItem(
                      'Protein',
                      '${food.nutritionData['protein']}g',
                      Icons.fitness_center,
                    ),
                  if (food.nutritionData.containsKey('carbs'))
                    _buildNutritionItem(
                      'Carbs',
                      '${food.nutritionData['carbs']}g',
                      Icons.grain,
                    ),
                  if (food.nutritionData.containsKey('fat'))
                    _buildNutritionItem(
                      'Fat',
                      '${food.nutritionData['fat']}g',
                      Icons.opacity,
                    ),
                ],
              ),
            ],

            // Category if available
            if (food.nutritionData.containsKey('category')) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(
                    Icons.category,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Category: ${food.nutritionData['category']}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build a nutrition information item
  Widget _buildNutritionItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 4),
          Text(
            '$label: $value',
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// Get color based on confidence level
  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.9) {
      return Colors.green;
    } else if (confidence >= 0.7) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}

import 'package:flutter/material.dart';
import '../../core/models/food_item.dart';

class FoodDetailsScreen extends StatelessWidget {
  final FoodItem foodItem;
  
  const FoodDetailsScreen({Key? key, required this.foodItem}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(foodItem.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              // Add to favorites
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share food item
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Food image placeholder
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey[300],
              child: Center(
                child: Text(
                  foodItem.name.substring(0, 1),
                  style: TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[500],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Food name and category
            Text(
              foodItem.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              foodItem.category,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Food description
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(foodItem.description),
            
            const SizedBox(height: 24),
            
            // Nutrition information
            const Text(
              'Nutritional Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildNutritionCard(context),
            
            const SizedBox(height: 24),
            
            // More details
            const Text(
              'More information coming soon...',
              style: TextStyle(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNutritionCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildNutritionRow(
              'Calories',
              '${foodItem.nutritionalInfo.calories} kcal',
              Icons.local_fire_department,
              Colors.orange,
            ),
            const Divider(height: 16),
            _buildNutritionRow(
              'Protein',
              foodItem.nutritionalInfo.protein,
              Icons.fitness_center,
              Colors.red,
            ),
            const Divider(height: 16),
            _buildNutritionRow(
              'Carbs',
              foodItem.nutritionalInfo.carbs,
              Icons.grain,
              Colors.amber,
            ),
            const Divider(height: 16),
            _buildNutritionRow(
              'Fat',
              foodItem.nutritionalInfo.fat,
              Icons.opacity,
              Colors.yellow,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNutritionRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 24,
            color: color,
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
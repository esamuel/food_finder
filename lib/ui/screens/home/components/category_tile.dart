import 'package:flutter/material.dart';

class CategoryTile extends StatelessWidget {
  final String category;
  final VoidCallback onTap;

  const CategoryTile({
    Key? key,
    required this.category,
    required this.onTap,
  }) : super(key: key);

  // Get a color based on the category name
  Color _getCategoryColor() {
    final Map<String, Color> categoryColors = {
      'Fruits': Colors.red[300]!,
      'Vegetables': Colors.green[300]!,
      'Grains': Colors.amber[300]!,
      'Protein Foods': Colors.purple[300]!,
      'Dairy': Colors.blue[300]!,
      'Snacks': Colors.orange[300]!,
      'Beverages': Colors.teal[300]!,
      'Desserts': Colors.pink[300]!,
      'Prepared Dishes': Colors.indigo[300]!,
      'Condiments': Colors.lime[300]!,
    };

    return categoryColors[category] ?? Colors.grey[300]!;
  }

  // Get an icon based on the category name
  IconData _getCategoryIcon() {
    final Map<String, IconData> categoryIcons = {
      'Fruits': Icons.apple,
      'Vegetables': Icons.eco,
      'Grains': Icons.grain,
      'Protein Foods': Icons.egg_alt,
      'Dairy': Icons.local_drink,
      'Snacks': Icons.fastfood,
      'Beverages': Icons.local_cafe,
      'Desserts': Icons.cake,
      'Prepared Dishes': Icons.restaurant,
      'Condiments': Icons.kitchen,
    };

    return categoryIcons[category] ?? Icons.category;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getCategoryColor();
    final icon = _getCategoryIcon();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.5),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              category,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

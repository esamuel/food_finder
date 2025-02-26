import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RecentItemCard extends StatelessWidget {
  final String name;
  final String category;
  final String imagePlaceholder;
  final DateTime date;
  final VoidCallback onTap;
  final String? imageUrl;

  const RecentItemCard({
    Key? key,
    required this.name,
    required this.category,
    required this.imagePlaceholder,
    required this.date,
    required this.onTap,
    this.imageUrl,
  }) : super(key: key);

  Color _getCategoryColor() {
    final Map<String, Color> categoryColors = {
      'Fruit': Colors.red[300]!,
      'Vegetable': Colors.green[300]!,
      'Grain': Colors.amber[300]!,
      'Protein': Colors.purple[300]!,
      'Dairy': Colors.blue[300]!,
      'Snack': Colors.orange[300]!,
      'Beverage': Colors.teal[300]!,
      'Dessert': Colors.pink[300]!,
      'Seafood': Colors.lightBlue[300]!,
      'Condiment': Colors.lime[300]!,
    };

    return categoryColors[category] ?? Colors.grey[300]!;
  }

  String _formatDate() {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM d').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getCategoryColor();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image or placeholder
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Center(
                child: imageUrl != null
                    ? ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        child: Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholder(color);
                          },
                        ),
                      )
                    : _buildPlaceholder(color),
              ),
            ),

            // Food info
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              fontSize: 10,
                              color: color,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          _formatDate(),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(Color color) {
    return Text(
      imagePlaceholder,
      style: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }
}

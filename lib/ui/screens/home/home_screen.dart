import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'components/category_tile.dart';
import 'components/feature_card.dart';
import 'components/recent_item_card.dart';
import '../../../config/routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> categories = [
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

  final List<Map<String, dynamic>> featuredItems = [
    {
      'title': 'Scan Food',
      'description':
          'Take a photo of any food to identify it and get nutritional information.',
      'icon': Icons.camera_alt,
      'color': Colors.blue,
    },
    {
      'title': 'Food Database',
      'description':
          'Browse our extensive database of foods and their nutritional values.',
      'icon': Icons.search,
      'color': Colors.green,
    },
    {
      'title': 'Meal Planning',
      'description':
          'Plan your meals for the week and track your nutritional intake.',
      'icon': Icons.calendar_today,
      'color': Colors.orange,
    },
  ];

  final List<Map<String, dynamic>> recentItems = [
    {
      'name': 'Apple',
      'category': 'Fruit',
      'date': DateTime.now().subtract(const Duration(hours: 2)),
      'imagePlaceholder': 'A',
    },
    {
      'name': 'Broccoli',
      'category': 'Vegetable',
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'imagePlaceholder': 'B',
    },
    {
      'name': 'Chicken',
      'category': 'Protein',
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'imagePlaceholder': 'C',
    },
    {
      'name': 'Rice',
      'category': 'Grain',
      'date': DateTime.now().subtract(const Duration(days: 5)),
      'imagePlaceholder': 'R',
    },
  ];

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        if (kIsWeb) {
          debugPrint('Image picked: ${pickedFile.path}');
          // For web, we need to handle the image differently
          Navigator.pushNamed(
            context,
            AppRoutes.camera,
          );
        } else {
          // For mobile platforms
          Navigator.pushNamed(
            context,
            AppRoutes.camera,
          );
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _navigateToCategory(String category) {
    debugPrint('Selected category: $category');
    Navigator.pushNamed(context, AppRoutes.profile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello there,',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const Text(
                          'What are you eating?',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    CircleAvatar(
                      backgroundColor:
                          Theme.of(context).primaryColor.withOpacity(0.2),
                      child: IconButton(
                        icon: Icon(
                          Icons.person,
                          color: Theme.of(context).primaryColor,
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.profile);
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.camera_alt,
                        label: 'Take Photo',
                        color: Colors.blue,
                        onTap: () => _pickImage(ImageSource.camera),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.photo_library,
                        label: 'Gallery',
                        color: Colors.green,
                        onTap: () => _pickImage(ImageSource.gallery),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.search,
                        label: 'Search',
                        color: Colors.orange,
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.search);
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Featured Section
                const Text(
                  'Featured',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 180,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: featuredItems.length,
                    itemBuilder: (context, index) {
                      final item = featuredItems[index];
                      return FeatureCard(
                        title: item['title'],
                        description: item['description'],
                        icon: item['icon'],
                        color: item['color'],
                        onTap: () {
                          if (index == 0) {
                            Navigator.pushNamed(context, AppRoutes.camera);
                          } else if (index == 1) {
                            Navigator.pushNamed(context, AppRoutes.search);
                          } else {
                            Navigator.pushNamed(context, '/settings');
                          }
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Categories Section
                const Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 1.0,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    return CategoryTile(
                      category: categories[index],
                      onTap: () => _navigateToCategory(categories[index]),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Recent Items Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Discoveries',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.search);
                      },
                      child: Text(
                        'See All',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 160,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: recentItems.length,
                    itemBuilder: (context, index) {
                      final item = recentItems[index];
                      return RecentItemCard(
                        name: item['name'],
                        category: item['category'],
                        imagePlaceholder: item['imagePlaceholder'],
                        date: item['date'],
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.camera);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

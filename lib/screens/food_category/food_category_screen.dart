import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../food_detail/food_detail_screen.dart';

class FoodCategoryScreen extends StatefulWidget {
  final String categoryName;
  final String imageUrl;
  final Color color;

  const FoodCategoryScreen({
    Key? key,
    required this.categoryName,
    required this.imageUrl,
    required this.color,
  }) : super(key: key);

  @override
  State<FoodCategoryScreen> createState() => _FoodCategoryScreenState();
}

class _FoodCategoryScreenState extends State<FoodCategoryScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isCollapsed = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 180 && !_isCollapsed) {
      setState(() {
        _isCollapsed = true;
      });
    } else if (_scrollController.offset <= 180 && _isCollapsed) {
      setState(() {
        _isCollapsed = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: _buildCategoryInfo(),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: _buildFoodItemsGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      backgroundColor: widget.color,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.categoryName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              widget.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: widget.color,
                  child: const Icon(
                    Icons.image_not_supported,
                    color: Colors.white54,
                    size: 50,
                  ),
                );
              },
            ),
            // Gradient overlay for better text visibility
            Container(
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
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () {
            // Implement search functionality
          },
        ),
        IconButton(
          icon: const Icon(Icons.favorite_border, color: Colors.white),
          onPressed: () {
            // Implement favorites functionality
          },
        ),
      ],
    );
  }

  Widget _buildCategoryInfo() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About ${widget.categoryName}',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _getCategoryDescription(widget.categoryName),
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildInfoCard(
                Icons.eco,
                'Nutritional Value',
                'High',
                Colors.green,
              ),
              const SizedBox(width: 12),
              _buildInfoCard(
                Icons.calendar_today,
                'Seasonality',
                _getSeasonality(widget.categoryName),
                Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoCard(
                Icons.location_on,
                'Origin',
                _getOrigin(widget.categoryName),
                Colors.blue,
              ),
              const SizedBox(width: 12),
              _buildInfoCard(
                Icons.restaurant,
                'Cooking',
                _getCookingDifficulty(widget.categoryName),
                Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Popular Items',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
      IconData icon, String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodItemsGrid() {
    final foodItems = _getFoodItemsForCategory(widget.categoryName);

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = foodItems[index];
          return _buildFoodItem(item);
        },
        childCount: foodItems.length,
      ),
    );
  }

  Widget _buildFoodItem(Map<String, dynamic> food) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FoodDetailScreen(
              foodItem: food,
              categoryColor: widget.color,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: 'food-image-${food['name']}',
                      child: Image.network(
                        food['imageUrl'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                    ),
                    // Gradient overlay for better text visibility
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 60,
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
                    // Calories badge
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.local_fire_department,
                              color: Colors.orange,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${food['calories']} cal',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${food['rating']}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${food['reviews']})',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
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

  // Helper methods to get category-specific information
  String _getCategoryDescription(String category) {
    switch (category) {
      case 'Vegetables':
        return 'Vegetables are parts of plants that are consumed by humans or other animals as food. The original meaning is still commonly used and is applied to plants collectively to refer to all edible plant matter, including the flowers, fruits, stems, leaves, roots, and seeds.';
      case 'Fruits':
        return 'In botany, a fruit is the seed-bearing structure in flowering plants that is formed from the ovary after flowering. Fruits are the means by which flowering plants disseminate their seeds. Edible fruits have propagated with the movements of humans and animals in a symbiotic relationship.';
      case 'Fast Food':
        return 'Fast food is a type of mass-produced food designed for commercial resale and with a strong priority placed on "speed of service" versus other relevant factors involved in culinary science.';
      case 'Desserts':
        return 'Dessert is a course that concludes a meal. The course consists of sweet foods, such as confections, and possibly a beverage such as dessert wine and liqueur.';
      case 'Healthy':
        return 'Healthy foods are those that provide you with the nutrients you need to sustain your body\'s well-being and retain energy. Water, carbohydrates, fat, protein, vitamins, and minerals are the key nutrients that make up a healthy, balanced diet.';
      case 'Beverages':
        return 'A drink or beverage is a liquid intended for human consumption. In addition to their basic function of satisfying thirst, drinks play important roles in human culture.';
      case 'Pasta':
        return 'Pasta is a type of food typically made from an unleavened dough of wheat flour mixed with water or eggs, and formed into sheets or other shapes, then cooked by boiling or baking.';
      case 'Seafood':
        return 'Seafood is any form of sea life regarded as food by humans, prominently including fish and shellfish. Shellfish include various species of molluscs, crustaceans, and echinoderms.';
      default:
        return 'A diverse category of food items with various nutritional profiles and culinary applications.';
    }
  }

  String _getSeasonality(String category) {
    switch (category) {
      case 'Vegetables':
        return 'Year-round';
      case 'Fruits':
        return 'Seasonal';
      case 'Fast Food':
        return 'Year-round';
      case 'Desserts':
        return 'Year-round';
      case 'Healthy':
        return 'Year-round';
      case 'Beverages':
        return 'Year-round';
      case 'Pasta':
        return 'Year-round';
      case 'Seafood':
        return 'Varies';
      default:
        return 'Varies';
    }
  }

  String _getOrigin(String category) {
    switch (category) {
      case 'Vegetables':
        return 'Global';
      case 'Fruits':
        return 'Global';
      case 'Fast Food':
        return 'USA';
      case 'Desserts':
        return 'Global';
      case 'Healthy':
        return 'Global';
      case 'Beverages':
        return 'Global';
      case 'Pasta':
        return 'Italy';
      case 'Seafood':
        return 'Coastal';
      default:
        return 'Various';
    }
  }

  String _getCookingDifficulty(String category) {
    switch (category) {
      case 'Vegetables':
        return 'Easy';
      case 'Fruits':
        return 'No cooking';
      case 'Fast Food':
        return 'Easy';
      case 'Desserts':
        return 'Medium';
      case 'Healthy':
        return 'Easy';
      case 'Beverages':
        return 'Easy';
      case 'Pasta':
        return 'Easy';
      case 'Seafood':
        return 'Medium';
      default:
        return 'Varies';
    }
  }

  IconData _getIconForNutrient(String nutrient) {
    switch (nutrient) {
      case 'Protein':
        return Icons.fitness_center;
      case 'Fiber':
        return Icons.grass;
      case 'Vitamin C':
        return Icons.brightness_7;
      case 'Antioxidants':
        return Icons.shield;
      case 'Calcium':
        return Icons.spa;
      default:
        return Icons.restaurant;
    }
  }

  Color _getColorForNutrient(String nutrient) {
    switch (nutrient) {
      case 'Protein':
        return Colors.red;
      case 'Fiber':
        return Colors.green;
      case 'Vitamin C':
        return Colors.orange;
      case 'Antioxidants':
        return Colors.purple;
      case 'Calcium':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  List<Map<String, dynamic>> _getFoodItemsForCategory(String category) {
    switch (category) {
      case 'Vegetables':
        return [
          {
            'name': 'Broccoli',
            'imageUrl':
                'https://images.unsplash.com/photo-1459411621453-7b03977f4bfc',
            'calories': 55,
            'rating': 4.7,
            'reviews': 128,
            'mainNutrient': 'Vitamin C',
          },
          {
            'name': 'Spinach',
            'imageUrl':
                'https://images.unsplash.com/photo-1576045057995-568f588f82fb',
            'calories': 23,
            'rating': 4.5,
            'reviews': 96,
            'mainNutrient': 'Iron',
          },
          {
            'name': 'Bell Peppers',
            'imageUrl':
                'https://images.unsplash.com/photo-1563565375-f3fdfdbefa83',
            'calories': 30,
            'rating': 4.6,
            'reviews': 112,
            'mainNutrient': 'Vitamin C',
          },
          {
            'name': 'Carrots',
            'imageUrl':
                'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37',
            'calories': 41,
            'rating': 4.8,
            'reviews': 156,
            'mainNutrient': 'Vitamin A',
          },
          {
            'name': 'Tomatoes',
            'imageUrl':
                'https://images.unsplash.com/photo-1582284540020-8acbe03f4924',
            'calories': 18,
            'rating': 4.4,
            'reviews': 89,
            'mainNutrient': 'Antioxidants',
          },
          {
            'name': 'Kale',
            'imageUrl':
                'https://images.unsplash.com/photo-1524179091875-bf99a9a6af57',
            'calories': 33,
            'rating': 4.3,
            'reviews': 76,
            'mainNutrient': 'Vitamin K',
          },
        ];
      case 'Fruits':
        return [
          {
            'name': 'Apples',
            'imageUrl':
                'https://images.unsplash.com/photo-1568702846914-96b305d2aaeb',
            'calories': 95,
            'rating': 4.8,
            'reviews': 203,
            'mainNutrient': 'Fiber',
          },
          {
            'name': 'Bananas',
            'imageUrl':
                'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e',
            'calories': 105,
            'rating': 4.7,
            'reviews': 187,
            'mainNutrient': 'Potassium',
          },
          {
            'name': 'Strawberries',
            'imageUrl':
                'https://images.unsplash.com/photo-1464965911861-746a04b4bca6',
            'calories': 32,
            'rating': 4.9,
            'reviews': 245,
            'mainNutrient': 'Vitamin C',
          },
          {
            'name': 'Blueberries',
            'imageUrl':
                'https://images.unsplash.com/photo-1498557850523-fd3d118b962e',
            'calories': 84,
            'rating': 4.8,
            'reviews': 178,
            'mainNutrient': 'Antioxidants',
          },
          {
            'name': 'Oranges',
            'imageUrl':
                'https://images.unsplash.com/photo-1582979512210-99b6a53386f9',
            'calories': 62,
            'rating': 4.6,
            'reviews': 156,
            'mainNutrient': 'Vitamin C',
          },
          {
            'name': 'Avocados',
            'imageUrl':
                'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578',
            'calories': 240,
            'rating': 4.7,
            'reviews': 198,
            'mainNutrient': 'Healthy Fats',
          },
        ];
      case 'Fast Food':
        return [
          {
            'name': 'Burger',
            'imageUrl':
                'https://images.unsplash.com/photo-1568901346375-23c9450c58cd',
            'calories': 550,
            'rating': 4.5,
            'reviews': 312,
            'mainNutrient': 'Protein',
          },
          {
            'name': 'Pizza',
            'imageUrl':
                'https://images.unsplash.com/photo-1513104890138-7c749659a591',
            'calories': 285,
            'rating': 4.7,
            'reviews': 356,
            'mainNutrient': 'Carbs',
          },
          {
            'name': 'French Fries',
            'imageUrl':
                'https://images.unsplash.com/photo-1573080496219-bb080dd4f877',
            'calories': 365,
            'rating': 4.6,
            'reviews': 289,
            'mainNutrient': 'Carbs',
          },
          {
            'name': 'Fried Chicken',
            'imageUrl':
                'https://images.unsplash.com/photo-1626645738196-c2a7c87a8f58',
            'calories': 320,
            'rating': 4.5,
            'reviews': 276,
            'mainNutrient': 'Protein',
          },
          {
            'name': 'Tacos',
            'imageUrl':
                'https://images.unsplash.com/photo-1551504734-5ee1c4a1479b',
            'calories': 210,
            'rating': 4.8,
            'reviews': 342,
            'mainNutrient': 'Protein',
          },
          {
            'name': 'Hot Dog',
            'imageUrl':
                'https://images.unsplash.com/photo-1612392062631-94ad79778a73',
            'calories': 290,
            'rating': 4.3,
            'reviews': 198,
            'mainNutrient': 'Protein',
          },
        ];
      case 'Desserts':
        return [
          {
            'name': 'Chocolate Cake',
            'imageUrl':
                'https://images.unsplash.com/photo-1578985545062-69928b1d9587',
            'calories': 350,
            'rating': 4.8,
            'reviews': 267,
            'mainNutrient': 'Carbs',
          },
          {
            'name': 'Ice Cream',
            'imageUrl':
                'https://images.unsplash.com/photo-1563805042-7684c019e1cb',
            'calories': 270,
            'rating': 4.9,
            'reviews': 312,
            'mainNutrient': 'Calcium',
          },
          {
            'name': 'Cheesecake',
            'imageUrl':
                'https://images.unsplash.com/photo-1524351199678-941a58a3df50',
            'calories': 320,
            'rating': 4.7,
            'reviews': 245,
            'mainNutrient': 'Calcium',
          },
          {
            'name': 'Cookies',
            'imageUrl':
                'https://images.unsplash.com/photo-1499636136210-6f4ee915583e',
            'calories': 180,
            'rating': 4.6,
            'reviews': 198,
            'mainNutrient': 'Carbs',
          },
          {
            'name': 'Brownies',
            'imageUrl':
                'https://images.unsplash.com/photo-1606313564200-e75d5e30476c',
            'calories': 230,
            'rating': 4.7,
            'reviews': 213,
            'mainNutrient': 'Carbs',
          },
          {
            'name': 'Tiramisu',
            'imageUrl':
                'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9',
            'calories': 290,
            'rating': 4.8,
            'reviews': 187,
            'mainNutrient': 'Calcium',
          },
        ];
      default:
        return [
          {
            'name': 'Sample Item 1',
            'imageUrl':
                'https://images.unsplash.com/photo-1546069901-ba9599a7e63c',
            'calories': 150,
            'rating': 4.5,
            'reviews': 120,
            'mainNutrient': 'Protein',
          },
          {
            'name': 'Sample Item 2',
            'imageUrl':
                'https://images.unsplash.com/photo-1546069901-ba9599a7e63c',
            'calories': 200,
            'rating': 4.3,
            'reviews': 98,
            'mainNutrient': 'Fiber',
          },
          {
            'name': 'Sample Item 3',
            'imageUrl':
                'https://images.unsplash.com/photo-1546069901-ba9599a7e63c',
            'calories': 180,
            'rating': 4.7,
            'reviews': 145,
            'mainNutrient': 'Vitamin C',
          },
          {
            'name': 'Sample Item 4',
            'imageUrl':
                'https://images.unsplash.com/photo-1546069901-ba9599a7e63c',
            'calories': 220,
            'rating': 4.4,
            'reviews': 112,
            'mainNutrient': 'Calcium',
          },
        ];
    }
  }
}

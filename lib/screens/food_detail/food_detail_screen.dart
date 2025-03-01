import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FoodDetailScreen extends StatefulWidget {
  final Map<String, dynamic> foodItem;
  final Color categoryColor;

  const FoodDetailScreen({
    Key? key,
    required this.foodItem,
    required this.categoryColor,
  }) : super(key: key);

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  bool _isFavorite = false;
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
            child: _buildFoodDetails(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Add to cart or similar action
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.foodItem['name']} added to cart'),
              backgroundColor: widget.categoryColor,
            ),
          );
        },
        backgroundColor: widget.categoryColor,
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('Add to Cart'),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300.0,
      floating: false,
      pinned: true,
      backgroundColor: widget.categoryColor,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.foodItem['name'],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'food-image-${widget.foodItem['name']}',
              child: Image.network(
                widget.foodItem['imageUrl'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: widget.categoryColor,
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Colors.white54,
                      size: 50,
                    ),
                  );
                },
              ),
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
            // Calories badge
            Positioned(
              top: 60,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      color: Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.foodItem['calories']} cal',
                      style: const TextStyle(
                        color: Colors.white,
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
      actions: [
        IconButton(
          icon: Icon(
            _isFavorite ? Icons.favorite : Icons.favorite_border,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              _isFavorite = !_isFavorite;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _isFavorite
                      ? '${widget.foodItem['name']} added to favorites'
                      : '${widget.foodItem['name']} removed from favorites',
                ),
                backgroundColor:
                    _isFavorite ? Colors.green : Colors.grey.shade700,
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: () {
            // Share functionality
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Sharing...'),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFoodDetails() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rating and reviews
          Row(
            children: [
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < (widget.foodItem['rating'] as double).floor()
                        ? Icons.star
                        : index < (widget.foodItem['rating'] as double)
                            ? Icons.star_half
                            : Icons.star_border,
                    color: Colors.amber,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${widget.foodItem['rating']}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(${widget.foodItem['reviews']} reviews)',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Nutritional highlights
          const Text(
            'Nutritional Highlights',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildNutrientBadge(
                'Protein',
                '12g',
                Icons.fitness_center,
                Colors.red,
              ),
              _buildNutrientBadge(
                'Carbs',
                '45g',
                Icons.grain,
                Colors.amber,
              ),
              _buildNutrientBadge(
                'Fat',
                '8g',
                Icons.opacity,
                Colors.blue,
              ),
              _buildNutrientBadge(
                widget.foodItem['mainNutrient'],
                'High',
                _getIconForNutrient(widget.foodItem['mainNutrient']),
                _getColorForNutrient(widget.foodItem['mainNutrient']),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Description
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _getDescription(widget.foodItem['name']),
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 24),

          // Health benefits
          const Text(
            'Health Benefits',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildBenefitsList(),

          const SizedBox(height: 24),

          // Preparation tips
          const Text(
            'Preparation Tips',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildPreparationTips(),

          const SizedBox(height: 24),

          // Similar foods
          const Text(
            'You Might Also Like',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _getSimilarFoods().map((food) {
                return _buildSimilarFoodItem(food);
              }).toList(),
            ),
          ),

          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildNutrientBadge(
      String name, String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            name,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsList() {
    final benefits = _getHealthBenefits(widget.foodItem['name']);
    return Column(
      children: benefits.map((benefit) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.check_circle,
                color: widget.categoryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  benefit,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPreparationTips() {
    final tips = _getPreparationTips(widget.foodItem['name']);
    return Column(
      children: tips.map((tip) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: widget.categoryColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${tips.indexOf(tip) + 1}',
                  style: TextStyle(
                    color: widget.categoryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  tip,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSimilarFoodItem(Map<String, dynamic> food) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FoodDetailScreen(
              foodItem: food,
              categoryColor: widget.categoryColor,
            ),
          ),
        );
      },
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                food['imageUrl'],
                height: 70,
                width: 70,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 70,
                    width: 70,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, color: Colors.grey),
                  );
                },
              ),
            ),
            const SizedBox(height: 4),
            Text(
              food['name'],
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
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
      case 'Iron':
        return Icons.bolt;
      case 'Vitamin A':
        return Icons.visibility;
      case 'Potassium':
        return Icons.battery_full;
      case 'Healthy Fats':
        return Icons.opacity;
      case 'Carbs':
        return Icons.grain;
      case 'Vitamin K':
        return Icons.healing;
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
      case 'Iron':
        return Colors.brown;
      case 'Vitamin A':
        return Colors.orange.shade700;
      case 'Potassium':
        return Colors.teal;
      case 'Healthy Fats':
        return Colors.lightBlue;
      case 'Carbs':
        return Colors.amber;
      case 'Vitamin K':
        return Colors.green.shade700;
      default:
        return Colors.grey;
    }
  }

  String _getDescription(String foodName) {
    switch (foodName) {
      case 'Broccoli':
        return 'Broccoli is an edible green plant in the cabbage family whose large flowering head, stalk and small associated leaves are eaten as a vegetable. Broccoli is particularly high in vitamin C and dietary fiber. It also contains multiple nutrients with potent anti-cancer properties.';
      case 'Spinach':
        return 'Spinach is a leafy green flowering plant native to central and western Asia. It is of the order Caryophyllales, family Amaranthaceae. Its leaves are a common edible vegetable consumed either fresh, or after storage using preservation techniques by canning, freezing, or dehydration.';
      case 'Apples':
        return 'Apples are one of the most popular fruits — and for good reason. They\'re an exceptionally healthy fruit with many research-backed benefits. Apples are high in fiber, vitamin C, and various antioxidants. They are also very filling, considering their low calorie content.';
      case 'Bananas':
        return 'Bananas are among the most important food crops on the planet. They come from a family of plants called Musa that are native to Southeast Asia and grown in many of the warmer areas of the world. Bananas are a healthy source of fiber, potassium, vitamin B6, vitamin C, and various antioxidants and phytonutrients.';
      case 'Burger':
        return 'A hamburger is a food, typically considered a sandwich, consisting of one or more cooked patties—usually ground meat, typically beef—placed inside a sliced bread roll or bun. The patty may be pan fried, grilled, smoked or flame broiled.';
      case 'Pizza':
        return 'Pizza is a dish of Italian origin consisting of a usually round, flat base of leavened wheat-based dough topped with tomatoes, cheese, and often various other ingredients, which is then baked at a high temperature, traditionally in a wood-fired oven.';
      case 'Chocolate Cake':
        return 'Chocolate cake is a cake flavored with melted chocolate, cocoa powder, or both. It can be made with other ingredients, such as fudge, vanilla creme, and other sweeteners. The history of chocolate cake goes back to 1764, when Dr. James Baker discovered how to make chocolate by grinding cocoa beans.';
      case 'Ice Cream':
        return 'Ice cream is a sweetened frozen food typically eaten as a snack or dessert. It may be made from milk or cream and is flavoured with a sweetener, either sugar or an alternative, and a spice, such as cocoa or vanilla, or with fruit such as strawberries or peaches.';
      default:
        return 'A delicious and nutritious food item that provides various health benefits and can be prepared in multiple ways to suit different tastes and dietary preferences.';
    }
  }

  List<String> _getHealthBenefits(String foodName) {
    switch (foodName) {
      case 'Broccoli':
        return [
          'Rich in vitamins, minerals, and antioxidants',
          'May help reduce inflammation',
          'Contains powerful antioxidants that may reduce risk of chronic disease',
          'High in fiber which aids digestion',
          'May support heart health and reduce cholesterol',
        ];
      case 'Spinach':
        return [
          'Excellent source of iron and calcium',
          'Rich in vitamins A, C, and K1',
          'Contains plant compounds that boost eye health',
          'May help prevent cancer and reduce blood pressure',
          'Promotes healthy skin and hair',
        ];
      case 'Apples':
        return [
          'High in fiber and antioxidants',
          'May lower risk of heart disease',
          'Contains pectin, a prebiotic fiber that feeds good gut bacteria',
          'May help with weight loss due to fiber content',
          'Contains compounds that may help prevent cancer',
        ];
      case 'Bananas':
        return [
          'Excellent source of potassium which supports heart health',
          'Contains nutrients that moderate blood sugar levels',
          'Rich in vitamins B6 and C',
          'Support digestive health with fiber content',
          'May help reduce exercise-related muscle cramps',
        ];
      default:
        return [
          'Contains essential nutrients for overall health',
          'May support immune system function',
          'Provides energy for daily activities',
          'Contains compounds that support cellular health',
          'Part of a balanced diet for optimal nutrition',
        ];
    }
  }

  List<String> _getPreparationTips(String foodName) {
    switch (foodName) {
      case 'Broccoli':
        return [
          'Steam for 5-7 minutes to retain nutrients and achieve tender texture',
          'Roast with olive oil at 425°F (220°C) for 20-25 minutes for crispy edges',
          'Add to stir-fries in the last few minutes of cooking',
          'Blanch before freezing to preserve color and nutrients',
        ];
      case 'Spinach':
        return [
          'Sauté with garlic and olive oil for 2-3 minutes until wilted',
          'Add fresh leaves to smoothies for a nutrient boost',
          'Wilt into soups and pasta dishes at the end of cooking',
          'Massage with olive oil and lemon for raw salads to soften leaves',
        ];
      case 'Apples':
        return [
          'Store in the refrigerator to maintain freshness for up to 4-6 weeks',
          'Prevent browning by tossing sliced apples with lemon juice',
          'Pair with cheese or nut butter for a balanced snack',
          'Remove seeds and core before eating or cooking',
        ];
      case 'Bananas':
        return [
          'Store at room temperature until ripe, then refrigerate to slow ripening',
          'Freeze peeled ripe bananas for smoothies or nice cream',
          'Ripen green bananas by placing in a paper bag with an apple',
          'Use overripe bananas for baking bread or muffins',
        ];
      case 'Burger':
        return [
          'Use ground beef with 15-20% fat content for juicy burgers',
          'Handle meat minimally to avoid tough patties',
          'Make a dimple in the center to prevent bulging during cooking',
          'Let burgers rest for a few minutes after cooking',
        ];
      case 'Pizza':
        return [
          'Preheat your oven to the highest temperature for crispy crust',
          'Use a pizza stone or steel for best results',
          'Don\'t overload with toppings to ensure even cooking',
          'Let dough come to room temperature before stretching',
        ];
      default:
        return [
          'Store properly to maintain freshness and nutritional value',
          'Wash thoroughly before preparation',
          'Consider different cooking methods to enhance flavor',
          'Pair with complementary foods for balanced nutrition',
        ];
    }
  }

  List<Map<String, dynamic>> _getSimilarFoods() {
    switch (widget.foodItem['name']) {
      case 'Broccoli':
        return [
          {
            'name': 'Cauliflower',
            'imageUrl':
                'https://images.unsplash.com/photo-1510627498534-cf7e9002facc',
            'calories': 25,
            'rating': 4.5,
            'reviews': 112,
            'mainNutrient': 'Vitamin C',
          },
          {
            'name': 'Brussels Sprouts',
            'imageUrl':
                'https://images.unsplash.com/photo-1438118907704-7718ee9a191a',
            'calories': 43,
            'rating': 4.2,
            'reviews': 98,
            'mainNutrient': 'Vitamin K',
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
          {
            'name': 'Cabbage',
            'imageUrl':
                'https://images.unsplash.com/photo-1551629604-63dae6ce4069',
            'calories': 25,
            'rating': 4.1,
            'reviews': 82,
            'mainNutrient': 'Vitamin C',
          },
        ];
      case 'Apples':
        return [
          {
            'name': 'Pears',
            'imageUrl':
                'https://images.unsplash.com/photo-1514756331096-242fdeb70d4a',
            'calories': 102,
            'rating': 4.6,
            'reviews': 178,
            'mainNutrient': 'Fiber',
          },
          {
            'name': 'Peaches',
            'imageUrl':
                'https://images.unsplash.com/photo-1595743825637-cdafc8ad4173',
            'calories': 39,
            'rating': 4.7,
            'reviews': 156,
            'mainNutrient': 'Vitamin C',
          },
          {
            'name': 'Plums',
            'imageUrl':
                'https://images.unsplash.com/photo-1599943503164-2dcaab73121a',
            'calories': 46,
            'rating': 4.4,
            'reviews': 132,
            'mainNutrient': 'Vitamin A',
          },
        ];
      default:
        return [
          {
            'name': 'Similar Food 1',
            'imageUrl':
                'https://images.unsplash.com/photo-1546069901-ba9599a7e63c',
            'calories': 150,
            'rating': 4.5,
            'reviews': 120,
            'mainNutrient': 'Protein',
          },
          {
            'name': 'Similar Food 2',
            'imageUrl':
                'https://images.unsplash.com/photo-1546069901-ba9599a7e63c',
            'calories': 180,
            'rating': 4.3,
            'reviews': 98,
            'mainNutrient': 'Fiber',
          },
          {
            'name': 'Similar Food 3',
            'imageUrl':
                'https://images.unsplash.com/photo-1546069901-ba9599a7e63c',
            'calories': 200,
            'rating': 4.7,
            'reviews': 145,
            'mainNutrient': 'Vitamin C',
          },
        ];
    }
  }
}

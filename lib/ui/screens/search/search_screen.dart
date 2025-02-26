import 'package:flutter/material.dart';
import 'package:food_finder/config/constants.dart';
import 'package:food_finder/core/models/food_item.dart';
import 'package:food_finder/ui/widgets/base_layout.dart';
import 'components/search_result_item.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  String _searchQuery = '';
  List<FoodItem> _searchResults = [];
  
  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }
  
  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }
  
  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
    
    if (_searchQuery.length > 2) {
      _performSearch(_searchQuery);
    }
  }
  
  Future<void> _performSearch(String query) async {
    setState(() {
      _isLoading = true;
    });
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Mock search results
    final mockResults = [
      const FoodItem(
        id: '1',
        name: 'Apple',
        category: 'Fruits',
        nutritionalInfo: NutritionalInfo(
          calories: 95,
          protein: '0.5g',
          carbs: '25g',
          fat: '0.3g',
          vitamins: {'Vitamin C': '14% DV'},
          minerals: {'Potassium': '4% DV'},
        ),
        origin: 'Central Asia',
        description: 'A crisp and sweet fruit.',
        seasonality: 'Year-round, best September-November',
        storageGuidance: 'Refrigerate for up to 6 weeks',
        commonUses: ['Fresh eating', 'Baking'],
        pairings: ['Cinnamon', 'Caramel'],
        imageUrl: '',
      ),
      const FoodItem(
        id: '2',
        name: 'Banana',
        category: 'Fruits',
        nutritionalInfo: NutritionalInfo(
          calories: 105,
          protein: '1.3g',
          carbs: '27g',
          fat: '0.4g',
          vitamins: {'Vitamin C': '17% DV'},
          minerals: {'Potassium': '12% DV'},
        ),
        origin: 'Southeast Asia',
        description: 'A sweet, soft fruit.',
        seasonality: 'Year-round',
        storageGuidance: 'Room temperature until ripe',
        commonUses: ['Fresh eating', 'Smoothies'],
        pairings: ['Chocolate', 'Peanut butter'],
        imageUrl: '',
      ),
      const FoodItem(
        id: '3',
        name: 'Strawberry',
        category: 'Fruits',
        nutritionalInfo: NutritionalInfo(
          calories: 32,
          protein: '0.7g',
          carbs: '7.7g',
          fat: '0.3g',
          vitamins: {'Vitamin C': '97% DV'},
          minerals: {'Manganese': '19% DV'},
        ),
        origin: 'Europe and Americas',
        description: 'Sweet, juicy berries with seeds on the surface.',
        seasonality: 'Spring and early summer',
        storageGuidance: 'Refrigerate for up to 5 days',
        commonUses: ['Fresh eating', 'Desserts'],
        pairings: ['Cream', 'Chocolate'],
        imageUrl: '',
      ),
    ];
    
    // Filter based on query
    final filteredResults = mockResults.where((food) {
      return food.name.toLowerCase().contains(query.toLowerCase()) ||
             food.category.toLowerCase().contains(query.toLowerCase());
    }).toList();
    
    setState(() {
      _searchResults = filteredResults;
      _isLoading = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      showBottomNav: false,
      title: 'Search Foods',
      body: Column(
        children: [
          // Search input
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search for foods...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchResults = [];
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          
          // Divider
          const Divider(height: 1),
          
          // Search results or suggestions
          Expanded(
            child: _buildSearchContent(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSearchContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_searchQuery.isEmpty) {
      return _buildSearchSuggestions();
    }
    
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No foods found for "$_searchQuery"',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try using different keywords or categories',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final food = _searchResults[index];
        return SearchResultItem(
          food: food,
          onTap: () {
            Navigator.of(context).pushNamed(
              '/food_details',
              arguments: food,
            );
          },
        );
      },
    );
  }
  
  Widget _buildSearchSuggestions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Suggested Categories',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConstants.foodCategories.map((category) {
              return ActionChip(
                label: Text(category),
                onPressed: () {
                  _searchController.text = category;
                  _performSearch(category);
                },
              );
            }).toList(),
          ),
          
          const SizedBox(height: 24),
          
          const Text(
            'Recent Searches',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Mock recent searches
          _buildRecentSearchItem('Apple'),
          _buildRecentSearchItem('Bread'),
          _buildRecentSearchItem('Chicken'),
          
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () {
                // Clear recent searches
              },
              child: const Text('Clear Recent Searches'),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRecentSearchItem(String searchTerm) {
    return ListTile(
      leading: const Icon(Icons.history),
      title: Text(searchTerm),
      trailing: const Icon(Icons.north_west, size: 16),
      contentPadding: EdgeInsets.zero,
      onTap: () {
        _searchController.text = searchTerm;
        _performSearch(searchTerm);
      },
    );
  }
}
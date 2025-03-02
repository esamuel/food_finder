import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import '../../services/supabase_service.dart';
import '../../core/services/auth/auth_service.dart';
import '../../core/services/google_vision_food_recognition_service.dart';
import '../food_recognition/camera_screen.dart';
import '../food_recognition/food_recognition_result_screen.dart';
import '../../../core/services/scan_history_service.dart';
import '../../../core/models/scan_history_item.dart';
import '../../core/services/favorites_service.dart';
import '../../core/services/food_recognition_service_factory.dart';
import '../food_category/food_category_screen.dart';
import '../profile/profile_edit_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  FoodRecognitionServiceType _selectedService = FoodRecognitionServiceType.mock;
  List<FoodRecognitionServiceType> _availableServices = [];

  final List<Widget> _screens = [
    const DashboardTab(),
    const FavoritesTab(),
    const HistoryTab(),
    const ProfileTab(),
  ];

  @override
  void initState() {
    super.initState();
    _loadAvailableServices();
  }

  void _loadAvailableServices() {
    setState(() {
      _availableServices = FoodRecognitionServiceFactory.getAvailableServices();
      // Set the default to the best available service
      if (_availableServices
          .contains(FoodRecognitionServiceType.googleVision)) {
        _selectedService = FoodRecognitionServiceType.googleVision;
      } else if (_availableServices
          .contains(FoodRecognitionServiceType.clarifai)) {
        _selectedService = FoodRecognitionServiceType.clarifai;
      } else {
        _selectedService = FoodRecognitionServiceType.mock;
      }
    });
  }

  // Build the service selector widget
  Widget _buildServiceSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Recognition Service:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          DropdownButton<FoodRecognitionServiceType>(
            value: _selectedService,
            underline: const SizedBox(),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.green),
            items: _availableServices.map((service) {
              return DropdownMenuItem<FoodRecognitionServiceType>(
                value: service,
                child: Text(
                  FoodRecognitionServiceFactory.getServiceName(service),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedService = value;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 0
          ? null
          : AppBar(
              title: Text(
                _selectedIndex == 1
                    ? 'Favorites'
                    : _selectedIndex == 2
                        ? 'History'
                        : 'Profile',
              ),
              backgroundColor: Colors.green,
              elevation: 0,
              actions: [
                if (_selectedIndex != 0)
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      showSearch(
                        context: context,
                        delegate: FoodSearchDelegate(),
                      );
                    },
                  ),
              ],
            ),
      body: _screens[_selectedIndex],
      floatingActionButton: _selectedIndex == 0
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildServiceSelector(),
                const SizedBox(height: 16),
                FloatingActionButton.extended(
                  onPressed: _showFoodRecognitionOptions,
                  backgroundColor: Colors.green,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Scan Food'),
                ),
              ],
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  // Show options for food recognition (camera or gallery)
  void _showFoodRecognitionOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.green),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                _takePicture();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.green),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
          ],
        ),
      ),
    );
  }

  // Take a picture with the camera
  Future<void> _takePicture() async {
    try {
      // Get available cameras
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        _showErrorSnackBar('No cameras available on this device');
        return;
      }

      // Navigate to camera screen
      final result = await Navigator.push<XFile?>(
        context,
        MaterialPageRoute(
          builder: (context) => CameraScreen(camera: cameras.first),
        ),
      );

      if (result != null) {
        if (kIsWeb) {
          final bytes = await result.readAsBytes();
          _processImageBytes(bytes, result.name, true);
        } else {
          _processImage(File(result.path), true);
        }
      }
    } catch (e) {
      _showErrorSnackBar('Error accessing camera: $e');
    }
  }

  // Pick an image from the gallery
  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();

      // Show loading indicator while checking gallery access
      if (!kIsWeb && Platform.isIOS) {
        _showLoadingDialog(message: 'Accessing gallery...');
      }

      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200, // Limit image size for better performance
        maxHeight: 1200,
        imageQuality: 85, // Slightly compress to improve performance
      );

      // Hide loading if it was shown
      if (!kIsWeb && Platform.isIOS && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (image != null) {
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          _processImageBytes(bytes, image.name, false);
        } else {
          _processImage(File(image.path), false);
        }
      }
    } catch (e) {
      // Hide loading if it was shown
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      String errorMessage = 'Error picking image';

      // Provide more specific error messages for common issues
      if (e.toString().contains('permission')) {
        errorMessage =
            'Photo library access denied. Please enable photo access in your device settings.';
      } else if (e.toString().contains('photo_access_denied')) {
        errorMessage =
            'Photo access denied. Please enable photo access in your device settings.';
      }

      _showErrorSnackBar('$errorMessage: ${e.toString().split('\n').first}');
    }
  }

  // Process an image file for food recognition
  Future<void> _processImage(File imageFile, bool isFromCamera) async {
    try {
      // Show loading indicator
      _showLoadingDialog();

      // Get the selected food recognition service
      final foodRecognitionService =
          FoodRecognitionServiceFactory.create(_selectedService);

      // Recognize the food
      final results =
          await foodRecognitionService.recognizeFoodFromFile(imageFile);

      // Hide loading indicator
      Navigator.pop(context);

      // Navigate to results screen
      if (results.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FoodRecognitionResultScreen(
              results: results,
              imageData: imageFile,
              isFromCamera: isFromCamera,
            ),
          ),
        );
      } else {
        _showErrorSnackBar('No food detected in the image');
      }
    } catch (e) {
      // Hide loading indicator if it's showing
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      _showErrorSnackBar('Error processing image: $e');
    }
  }

  // Process image bytes for food recognition (web platform)
  Future<void> _processImageBytes(
      Uint8List bytes, String fileName, bool isFromCamera) async {
    try {
      // Show loading indicator
      _showLoadingDialog();

      // Get the selected food recognition service
      final foodRecognitionService =
          FoodRecognitionServiceFactory.create(_selectedService);

      // Recognize the food
      final results = await foodRecognitionService.recognizeFood(bytes);

      // Hide loading indicator
      Navigator.pop(context);

      // Navigate to results screen
      if (results.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FoodRecognitionResultScreen(
              results: results,
              imageData: bytes,
              isFromCamera: isFromCamera,
            ),
          ),
        );
      } else {
        _showErrorSnackBar('No food detected in the image');
      }
    } catch (e) {
      // Hide loading indicator if it's showing
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      _showErrorSnackBar('Error processing image: $e');
    }
  }

  // Show a loading dialog
  void _showLoadingDialog({String message = 'Processing image...'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
                const SizedBox(width: 20),
                Text(message),
              ],
            ),
          ),
        );
      },
    );
  }

  // Show an error snackbar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class FoodSearchDelegate extends SearchDelegate {
  final List<String> _suggestions = [
    'Apple',
    'Banana',
    'Burger',
    'Pizza',
    'Salad',
    'Pasta',
    'Chicken',
    'Rice',
    'Steak',
    'Sushi',
  ];

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Center(
      child: Text(
        'Search results for: $query',
        style: const TextStyle(fontSize: 18),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = query.isEmpty
        ? _suggestions
        : _suggestions
            .where((food) => food.toLowerCase().contains(query.toLowerCase()))
            .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.fastfood),
          title: Text(suggestions[index]),
          onTap: () {
            query = suggestions[index];
            showResults(context);
          },
        );
      },
    );
  }
}

class DashboardTab extends StatefulWidget {
  const DashboardTab({Key? key}) : super(key: key);

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  final ScanHistoryService _historyService = ScanHistoryService();
  List<ScanHistoryItem> _recentScans = [];
  bool _isLoadingHistory = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRecentScans();
  }

  Future<void> _loadRecentScans() async {
    setState(() {
      _isLoadingHistory = true;
    });

    try {
      final history = await _historyService.getHistory();
      setState(() {
        // Take only the 5 most recent scans
        _recentScans = history.take(5).toList();
      });
    } catch (e) {
      debugPrint('Error loading recent scans: $e');
    } finally {
      setState(() {
        _isLoadingHistory = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser;
    final displayName = user?.displayName ?? 'Food Lover';
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search foods',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    onTap: () {
                      showSearch(
                        context: context,
                        delegate: FoodSearchDelegate(),
                      );
                    },
                    readOnly: true,
                  ),
                ),
              ),

              // Featured carousel
              SizedBox(
                height: 180,
                child: PageView(
                  children: [
                    _buildFeatureCard(
                      'How to identify foods easily with FoodFinder',
                      'https://images.unsplash.com/photo-1546069901-ba9599a7e63c',
                    ),
                    _buildFeatureCard(
                      'Discover nutritional information for any food',
                      'https://images.unsplash.com/photo-1505253758473-96b7015fcd40',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Horizontal scrollable food categories
              Padding(
                padding:
                    const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
                child: Text(
                  'Food Categories',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),

              SizedBox(
                height: 120,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildHorizontalCategoryItem(
                        'Vegetables', Colors.green, Icons.eco),
                    _buildHorizontalCategoryItem(
                        'Fruits', Colors.orange, Icons.apple),
                    _buildHorizontalCategoryItem(
                        'Fast Food', Colors.red, Icons.fastfood),
                    _buildHorizontalCategoryItem(
                        'Desserts', Colors.pink, Icons.cake),
                    _buildHorizontalCategoryItem(
                        'Healthy', Colors.teal, Icons.spa),
                    _buildHorizontalCategoryItem(
                        'Beverages', Colors.blue, Icons.local_drink),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Popular Foods section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Popular Foods',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Food categories grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    _buildCategoryCard('Vegetables', Colors.green,
                        'https://images.unsplash.com/photo-1540420773420-3366772f4999'),
                    _buildCategoryCard('Fruits', Colors.teal,
                        'https://images.unsplash.com/photo-1619566636858-adf3ef46400b'),
                    _buildCategoryCard('Fast Food', Colors.orange,
                        'https://images.unsplash.com/photo-1561758033-d89a9ad46330'),
                    _buildCategoryCard('Desserts', Colors.pink,
                        'https://images.unsplash.com/photo-1563729784474-d77dbb933a9e'),
                    _buildCategoryCard('Healthy', Colors.lightBlue,
                        'https://images.unsplash.com/photo-1546069901-ba9599a7e63c'),
                    _buildCategoryCard('Beverages', Colors.purple,
                        'https://images.unsplash.com/photo-1544145945-f90425340c7e'),
                    _buildCategoryCard('Pasta', Colors.amber,
                        'https://images.unsplash.com/photo-1563379926898-05f4575a45d8'),
                    _buildCategoryCard('Seafood', Colors.blue,
                        'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351'),
                  ],
                ),
              ),

              const SizedBox(height: 100), // Space for FAB
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(String title, String imageUrl) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Image with fallback
          Positioned.fill(
            child: Image.network(
              imageUrl.startsWith('assets')
                  ? 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c' // Fallback image
                  : imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, size: 50, color: Colors.grey),
                );
              },
            ),
          ),
          // Gradient overlay
          Positioned.fill(
            child: Container(
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
          // Text
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String title, Color color, String imageUrl) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FoodCategoryScreen(
              categoryName: title,
              imageUrl: imageUrl,
              color: color,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: color,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Image
            Positioned.fill(
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: color.withOpacity(0.3),
                  );
                },
              ),
            ),
            // Gradient overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    colors: [
                      Colors.transparent,
                      color.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),
            // Text
            Positioned(
              bottom: 16,
              left: 16,
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalCategoryItem(
      String title, Color color, IconData icon) {
    return GestureDetector(
      onTap: () {
        // Get a default image URL for the category
        String imageUrl =
            'https://images.unsplash.com/photo-1546069901-ba9599a7e63c';

        // Try to find a better image URL based on the category
        switch (title) {
          case 'Vegetables':
            imageUrl =
                'https://images.unsplash.com/photo-1540420773420-3366772f4999';
            break;
          case 'Fruits':
            imageUrl =
                'https://images.unsplash.com/photo-1619566636858-adf3ef46400b';
            break;
          case 'Fast Food':
            imageUrl =
                'https://images.unsplash.com/photo-1561758033-d89a9ad46330';
            break;
          case 'Desserts':
            imageUrl =
                'https://images.unsplash.com/photo-1563729784474-d77dbb933a9e';
            break;
          case 'Healthy':
            imageUrl =
                'https://images.unsplash.com/photo-1546069901-ba9599a7e63c';
            break;
          case 'Beverages':
            imageUrl =
                'https://images.unsplash.com/photo-1544145945-f90425340c7e';
            break;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FoodCategoryScreen(
              categoryName: title,
              imageUrl: imageUrl,
              color: color,
            ),
          ),
        );
      },
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: color,
                size: 35,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class FavoritesTab extends StatefulWidget {
  const FavoritesTab({Key? key}) : super(key: key);

  @override
  State<FavoritesTab> createState() => _FavoritesTabState();
}

class _FavoritesTabState extends State<FavoritesTab> {
  final FavoritesService _favoritesService = FavoritesService();
  final ScanHistoryService _historyService = ScanHistoryService();
  List<ScanHistoryItem> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final favorites = await _favoritesService.getFavorites();
      setState(() {
        _favorites = favorites;
      });
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _removeFromFavorites(String id) async {
    try {
      await _favoritesService.removeFromFavorites(id);
      await _loadFavorites();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from favorites'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error removing from favorites: $e');
    }
  }

  Future<void> _clearAllFavorites() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Favorites'),
        content: const Text('Are you sure you want to clear all favorites?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _favoritesService.clearFavorites();
        await _loadFavorites();
      } catch (e) {
        debugPrint('Error clearing favorites: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header with title and clear button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Favorites',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_favorites.isNotEmpty)
                  TextButton.icon(
                    onPressed: _clearAllFavorites,
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    label: const Text(
                      'Clear All',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),

          // Favorites grid
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _favorites.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.favorite_border,
                              size: 80,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No favorites yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Your favorite foods will appear here',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadFavorites,
                        child: GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.8,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: _favorites.length,
                          itemBuilder: (context, index) {
                            final item = _favorites[index];
                            return _buildFavoriteItem(item);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteItem(ScanHistoryItem item) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to food details
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: SizedBox(
                    height: 120,
                    width: double.infinity,
                    child: Builder(builder: (context) {
                      // Try to get image from cache first (immediate display)
                      final cachedImage =
                          _favoritesService.getImageForFavorite(item.id);
                      if (cachedImage != null) {
                        return Image.memory(
                          cachedImage,
                          fit: BoxFit.cover,
                        );
                      }

                      // Fall back to loading from history service if not in cache
                      return FutureBuilder<Uint8List?>(
                        future: _historyService.loadImageForHistoryItem(item),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            );
                          }

                          if (snapshot.hasData && snapshot.data != null) {
                            return Image.memory(
                              snapshot.data!,
                              fit: BoxFit.cover,
                            );
                          }

                          return Container(
                            color: Colors.grey.shade200,
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ),
                // Favorite button
                Positioned(
                  top: 8,
                  right: 8,
                  child: InkWell(
                    onTap: () => _removeFromFavorites(item.id),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Details
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.foodName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.category,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.calories.toStringAsFixed(0)} cal',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HistoryTab extends StatefulWidget {
  const HistoryTab({Key? key}) : super(key: key);

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  final ScanHistoryService _historyService = ScanHistoryService();
  List<ScanHistoryItem> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final history = await _historyService.getHistory();
      setState(() {
        _history = history;
      });
    } catch (e) {
      debugPrint('Error loading history: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteHistoryItem(String id) async {
    try {
      await _historyService.deleteHistoryItem(id);
      await _loadHistory();
    } catch (e) {
      debugPrint('Error deleting history item: $e');
    }
  }

  Future<void> _clearAllHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text('Are you sure you want to clear all scan history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _historyService.clearHistory();
        await _loadHistory();
      } catch (e) {
        debugPrint('Error clearing history: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header with title and clear button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Scan History',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_history.isNotEmpty)
                  TextButton.icon(
                    onPressed: _clearAllHistory,
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    label: const Text(
                      'Clear All',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),

          // History list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _history.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history,
                              size: 80,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No scan history yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Your scanned foods will appear here',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadHistory,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _history.length,
                          itemBuilder: (context, index) {
                            final item = _history[index];
                            return _buildHistoryItem(item);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(ScanHistoryItem item) {
    return Dismissible(
      key: Key(item.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        _deleteHistoryItem(item.id);
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () {
            // Navigate to detail view or recognition result screen
            // TODO: Implement navigation to detail view
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: FutureBuilder<Uint8List?>(
                      future: _historyService.loadImageForHistoryItem(item),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        }

                        if (snapshot.hasData && snapshot.data != null) {
                          return Image.memory(
                            snapshot.data!,
                            fit: BoxFit.cover,
                          );
                        }

                        return Container(
                          color: Colors.grey.shade200,
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.foodName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.displayDate,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          // Calories
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${item.calories.toStringAsFixed(0)} cal',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.orange,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Category
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              item.category,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Options
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    // Show options menu
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.delete),
                            title: const Text('Delete'),
                            onTap: () {
                              Navigator.pop(context);
                              _deleteHistoryItem(item.id);
                            },
                          ),
                          // Add more options as needed
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    final user = authService.currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Profile header
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.green.shade100,
                    child: Text(
                      (user?.displayName?.isNotEmpty == true)
                          ? user!.displayName![0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.displayName ?? 'User',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user?.email ?? 'No email',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to edit profile
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileEditScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text('Edit Profile'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Stats section
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Stats',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      StatItem(
                        icon: Icons.camera_alt,
                        value: '24',
                        label: 'Scans',
                      ),
                      StatItem(
                        icon: Icons.favorite,
                        value: '12',
                        label: 'Favorites',
                      ),
                      StatItem(
                        icon: Icons.restaurant,
                        value: '8',
                        label: 'Recipes',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Settings section
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const SettingsItem(
                    icon: Icons.notifications,
                    title: 'Notifications',
                  ),
                  const Divider(),
                  const SettingsItem(
                    icon: Icons.language,
                    title: 'Language',
                  ),
                  const Divider(),
                  const SettingsItem(
                    icon: Icons.dark_mode,
                    title: 'Dark Mode',
                  ),
                  const Divider(),
                  const SettingsItem(
                    icon: Icons.help,
                    title: 'Help & Support',
                  ),
                  const Divider(),
                  const SettingsItem(
                    icon: Icons.privacy_tip,
                    title: 'Privacy Policy',
                  ),
                  const Divider(),
                  SettingsItem(
                    icon: Icons.logout,
                    title: 'Logout',
                    onTap: () async {
                      // Show confirmation dialog
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Logout'),
                          content:
                              const Text('Are you sure you want to logout?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Logout'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await authService.signOut();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const StatItem({
    Key? key,
    required this.icon,
    required this.value,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.green),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const SettingsItem({
    Key? key,
    required this.icon,
    required this.title,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      contentPadding: EdgeInsets.zero,
      onTap: onTap ??
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$title coming soon!')),
            );
          },
    );
  }
}

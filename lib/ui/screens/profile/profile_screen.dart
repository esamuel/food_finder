import 'package:flutter/material.dart';
import '../../../config/constants.dart';
import '../../../core/models/user_profile.dart';
import '../../widgets/base_layout.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  UserProfile? _userProfile;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Mock user profile
    _userProfile = UserProfile(
      id: '1',
      displayName: 'John Doe',
      email: 'john.doe@example.com',
      photoUrl: '',
      favoriteItems: const ['1', '2', '3'],
      historyItems: [
        UserHistory(
          foodId: '1',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          note: 'Discovered at the farmers market',
        ),
        UserHistory(
          foodId: '2',
          timestamp: DateTime.now().subtract(const Duration(days: 3)),
        ),
        UserHistory(
          foodId: '3',
          timestamp: DateTime.now().subtract(const Duration(days: 5)),
        ),
      ],
      preferences: const UserPreferences(
        darkMode: false,
        dietaryRestriction: 'Vegetarian',
        allergies: ['Peanuts', 'Shellfish'],
        notificationsEnabled: true,
      ),
    );

    setState(() {
      _isLoading = false;
      _isDarkMode = _userProfile?.preferences.darkMode ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      currentItem: NavigationItem.profile,
      title: 'Profile',
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildProfileContent(),
    );
  }

  Widget _buildProfileContent() {
    if (_userProfile == null) {
      return const Center(
        child: Text('User profile not found'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info section
          _buildUserInfoSection(),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),

          // Preferences section
          _buildPreferencesSection(),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),

          // Activity section
          _buildActivitySection(),

          const SizedBox(height: 32),

          // Logout button
          Center(
            child: OutlinedButton.icon(
              onPressed: () {
                // Handle logout
              },
              icon: const Icon(Icons.logout),
              label: const Text('Log Out'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // App version
          Center(
            child: Text(
              'App Version: ${AppConstants.appVersion}',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildUserInfoSection() {
    return Center(
      child: Column(
        children: [
          // Profile image
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: _userProfile!.photoUrl != null &&
                    _userProfile!.photoUrl!.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      _userProfile!.photoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.person,
                        size: 50,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  )
                : Icon(
                    Icons.person,
                    size: 50,
                    color: Theme.of(context).colorScheme.primary,
                  ),
          ),

          const SizedBox(height: 16),

          // User name
          Text(
            _userProfile!.displayName ?? 'User',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          // User email
          Text(
            _userProfile!.email ?? '',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 16),

          // Edit profile button
          TextButton.icon(
            onPressed: () {
              // Navigate to edit profile
            },
            icon: const Icon(Icons.edit, size: 16),
            label: const Text('Edit Profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Preferences',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 16),

        // Dark mode toggle
        SwitchListTile(
          title: const Text('Dark Mode'),
          subtitle: const Text('Toggle between light and dark themes'),
          value: _isDarkMode,
          onChanged: (value) {
            setState(() {
              _isDarkMode = value;
            });
            // In a real app, this would update the theme
          },
          secondary: const Icon(Icons.brightness_4),
        ),

        // Notifications toggle
        SwitchListTile(
          title: const Text('Notifications'),
          subtitle: const Text('Receive updates and recommendations'),
          value: _userProfile!.preferences.notificationsEnabled,
          onChanged: (value) {
            // Update notifications setting
          },
          secondary: const Icon(Icons.notifications),
        ),

        const SizedBox(height: 16),

        // Dietary restrictions
        ListTile(
          leading: const Icon(Icons.restaurant),
          title: const Text('Dietary Restrictions'),
          subtitle:
              Text(_userProfile!.preferences.dietaryRestriction ?? 'None'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // Navigate to dietary restrictions page
          },
        ),

        // Allergies
        ListTile(
          leading: const Icon(Icons.health_and_safety),
          title: const Text('Allergies'),
          subtitle: Text(
            _userProfile!.preferences.allergies.isNotEmpty
                ? _userProfile!.preferences.allergies.join(', ')
                : 'None',
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // Navigate to allergies page
          },
        ),
      ],
    );
  }

  Widget _buildActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Activity',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 16),

        // Favorites
        ListTile(
          leading: const Icon(Icons.favorite, color: Colors.red),
          title: const Text('Favorites'),
          subtitle: Text('${_userProfile!.favoriteItems.length} items'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // Navigate to favorites page
          },
        ),

        // History
        ListTile(
          leading: const Icon(Icons.history),
          title: const Text('History'),
          subtitle: Text('${_userProfile!.historyItems.length} items'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // Navigate to history page
          },
        ),

        // Saved recipes
        const ListTile(
          leading: Icon(Icons.menu_book),
          title: Text('Saved Recipes'),
          subtitle: Text('0 recipes'),
          trailing: Icon(Icons.chevron_right),
        ),

        // Statistics
        ListTile(
          leading: Icon(Icons.bar_chart, color: Colors.purple[400]),
          title: const Text('Statistics'),
          subtitle: const Text('View your food discovery trends'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // Navigate to statistics page
          },
        ),
      ],
    );
  }
}

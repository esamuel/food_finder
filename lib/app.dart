import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/theme.dart';
import 'config/routes.dart';
import 'config/constants.dart';

// These will be implemented later
// import 'core/services/food_recognition_service.dart';
// import 'core/services/food_database_service.dart';
// import 'common/bloc/settings/settings_bloc.dart';

class FoodFinderApp extends StatefulWidget {
  const FoodFinderApp({Key? key}) : super(key: key);

  @override
  State<FoodFinderApp> createState() => _FoodFinderAppState();
}

class _FoodFinderAppState extends State<FoodFinderApp> {
  // Default to light theme initially
  ThemeMode _themeMode = ThemeMode.light;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDarkMode = prefs.getBool('dark_mode') ?? false;
      
      setState(() {
        _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
        _isInitialized = true;
      });
    } catch (e) {
      print('Failed to load settings: $e');
      setState(() {
        _isInitialized = true;
      });
    }
  }

  void _updateThemeMode(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
    
    // Save the preference
    SharedPreferences.getInstance().then(
      (prefs) => prefs.setBool('dark_mode', themeMode == ThemeMode.dark),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator until initialization is complete
    if (!_isInitialized) {
      return const MaterialApp(
        title: AppConstants.appName,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme(context),
      darkTheme: AppTheme.darkTheme(context),
      themeMode: _themeMode,
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRoutes.generateRoute,
      debugShowCheckedModeBanner: false,
      // We'll add BLoC providers later
      // home: BlocProvider(
      //   create: (context) => SettingsBloc()..add(LoadSettings()),
      //   child: HomeScreen(
      //     onThemeChanged: _updateThemeMode,
      //   ),
      // ),
    );
  }
}
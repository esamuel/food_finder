import 'package:flutter/material.dart';
import 'app.dart';

// Web environment entry point
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // On the web, we don't need to set preferred orientations
  // as orientation is controlled by the browser
  
  // Skip Firebase initialization for now
  // This allows development without Firebase setup
  
  runApp(const FoodFinderApp());
}
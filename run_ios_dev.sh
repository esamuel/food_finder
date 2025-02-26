#!/bin/bash

# Clean the project
echo "Cleaning the project..."
flutter clean

# Get dependencies
echo "Getting dependencies..."
flutter pub get

# Run the app with the iOS development entry point
echo "Running the app with the iOS development entry point..."
flutter run --target lib/main_ios_dev.dart 
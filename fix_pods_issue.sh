#!/bin/bash

# Navigate to the iOS directory
echo "Navigating to iOS directory..."
cd ios

# Clean CocoaPods cache
echo "Cleaning CocoaPods cache..."
pod cache clean --all

# Remove existing Pods directory and Podfile.lock
echo "Removing existing Pods directory and Podfile.lock..."
rm -rf Pods
rm -f Podfile.lock

# Install pods with verbose output
echo "Installing pods with verbose output..."
pod install --verbose

# Return to project root
cd ..

# Clean Flutter project
echo "Cleaning Flutter project..."
flutter clean

# Get Flutter dependencies
echo "Getting Flutter dependencies..."
flutter pub get

# Run the app with the fixed iOS development entry point
echo "Running the app with the fixed iOS development entry point..."
flutter run --target lib/main_ios_dev_fixed.dart 
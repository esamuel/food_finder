#!/bin/bash

# Clean the project
echo "Cleaning the project..."
flutter clean

# Get dependencies
echo "Getting dependencies..."
flutter pub get

# Kill any existing Xcode processes
echo "Killing any existing Xcode processes..."
killall Xcode || true
killall Simulator || true

# Wait a moment
sleep 2

# Run the app with the fixed iOS development entry point
echo "Running the app with the fixed iOS development entry point..."
flutter run --target lib/main_ios_dev_fixed.dart 
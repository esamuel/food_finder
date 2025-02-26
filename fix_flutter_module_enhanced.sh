#!/bin/bash

# Navigate to the project root
cd "$(dirname "$0")"

echo "===== ENHANCED FIX FOR 'NO SUCH MODULE FLUTTER' ERROR ====="

# Step 1: Clean Flutter project
echo "Step 1: Cleaning Flutter project..."
flutter clean

# Step 2: Get Flutter dependencies
echo "Step 2: Getting Flutter dependencies..."
flutter pub get

# Step 3: Delete Flutter/ephemeral directory if it exists
echo "Step 3: Deleting Flutter/ephemeral directory if it exists..."
rm -rf ios/Flutter/Flutter.framework
rm -rf ios/Flutter/ephemeral

# Step 4: Precache iOS artifacts
echo "Step 4: Precaching iOS artifacts..."
flutter precache --ios

# Step 5: Generate Flutter.framework directly
echo "Step 5: Generating Flutter.framework directly..."
mkdir -p ios/Flutter/ephemeral
flutter build ios-framework --no-profile --no-release --output=ios/Flutter/ephemeral

# Step 6: Navigate to iOS directory
echo "Step 6: Navigating to iOS directory..."
cd ios

# Step 7: Clean CocoaPods
echo "Step 7: Cleaning CocoaPods..."
rm -rf Pods Podfile.lock
pod cache clean --all

# Step 8: Install pods
echo "Step 8: Installing pods..."
pod install --verbose

# Step 9: Return to project root
echo "Step 9: Returning to project root..."
cd ..

# Step 10: Build iOS app without codesigning
echo "Step 10: Building iOS app without codesigning..."
flutter build ios --no-codesign

# Step 11: Run the app with the fixed entry point
echo "Step 11: Running the app with the fixed entry point..."
echo "You can now run the app with: flutter run --target lib/main_no_firebase.dart"
echo ""
echo "Would you like to run the app now? (y/n)"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
  flutter run --target lib/main_no_firebase.dart
else
  echo "You can run the app later with: flutter run --target lib/main_no_firebase.dart"
fi 
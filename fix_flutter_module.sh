#!/bin/bash

# Navigate to the project root
cd "$(dirname "$0")"

echo "===== FIXING 'NO SUCH MODULE FLUTTER' ERROR ====="

# Step 1: Clean Flutter project
echo "Step 1: Cleaning Flutter project..."
flutter clean

# Step 2: Get Flutter dependencies
echo "Step 2: Getting Flutter dependencies..."
flutter pub get

# Step 3: Delete Flutter/ephemeral directory
echo "Step 3: Deleting Flutter/ephemeral directory..."
rm -rf ios/Flutter/Flutter.framework
rm -rf ios/Flutter/ephemeral

# Step 4: Regenerate Flutter.framework
echo "Step 4: Regenerating Flutter.framework..."
flutter build ios --no-codesign

# Step 5: Navigate to iOS directory
echo "Step 5: Navigating to iOS directory..."
cd ios

# Step 6: Clean CocoaPods
echo "Step 6: Cleaning CocoaPods..."
rm -rf Pods Podfile.lock
pod cache clean --all

# Step 7: Install pods
echo "Step 7: Installing pods..."
pod install --verbose

# Step 8: Return to project root
echo "Step 8: Returning to project root..."
cd ..

# Step 9: Run the app with the fixed entry point
echo "Step 9: Running the app with the fixed entry point..."
echo "You can now run the app with: flutter run --target lib/main_ios_dev_fixed.dart"
echo ""
echo "Would you like to run the app now? (y/n)"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
  flutter run --target lib/main_ios_dev_fixed.dart
else
  echo "You can run the app later with: flutter run --target lib/main_ios_dev_fixed.dart"
fi 
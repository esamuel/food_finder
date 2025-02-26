#!/bin/bash

# Navigate to the project root
cd "$(dirname "$0")"

echo "===== FIXING IOS BUILD ISSUES ====="

# Step 1: Clean Flutter project
echo "Step 1: Cleaning Flutter project..."
flutter clean

# Step 2: Get Flutter dependencies
echo "Step 2: Getting Flutter dependencies..."
flutter pub get

# Step 3: Navigate to iOS directory
echo "Step 3: Navigating to iOS directory..."
cd ios

# Step 4: Update Podfile with fixes
echo "Step 4: Updating Podfile with fixes..."
if [ -f "Podfile.new" ]; then
  echo "Using prepared Podfile.new..."
  mv Podfile.new Podfile
else
  echo "Backing up original Podfile..."
  cp Podfile Podfile.bak
  
  # Add use_modular_headers! to Podfile
  echo "Adding use_modular_headers! to Podfile..."
  sed -i '' 's/use_frameworks!/use_frameworks!\n  use_modular_headers!/g' Podfile
  
  # Add Xcode 15 fix
  echo "Adding Xcode 15 fix to Podfile..."
  sed -i '' '/IPHONEOS_DEPLOYMENT_TARGET/a\'$'\n      # Fix for Xcode 15 and CocoaPods issue\
  config.build_settings['\''ENABLE_USER_SCRIPT_SANDBOXING'\''] = '\''NO'\''\
  \
  # Fix for arm64 architecture issues\
  config.build_settings['\''EXCLUDED_ARCHS[sdk=iphonesimulator*]'\''] = '\''arm64'\''' Podfile
fi

# Step 5: Clean CocoaPods
echo "Step 5: Cleaning CocoaPods..."
rm -rf Pods Podfile.lock
pod cache clean --all

# Step 6: Install pods
echo "Step 6: Installing pods..."
pod install --verbose

# Step 7: Return to project root
echo "Step 7: Returning to project root..."
cd ..

# Step 8: Run the app with the fixed entry point
echo "Step 8: Running the app with the fixed entry point..."
echo "You can now run the app with: flutter run --target lib/main_ios_dev_fixed.dart"
echo ""
echo "Would you like to run the app now? (y/n)"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
  flutter run --target lib/main_ios_dev_fixed.dart
else
  echo "You can run the app later with: flutter run --target lib/main_ios_dev_fixed.dart"
fi 
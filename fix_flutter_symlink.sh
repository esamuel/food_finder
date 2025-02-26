#!/bin/bash

# Navigate to the project root
cd "$(dirname "$0")"

echo "===== CREATING SYMBOLIC LINK FOR FLUTTER FRAMEWORK ====="

# Step 1: Check if the Flutter.xcframework exists
if [ -d "ios/Flutter/ephemeral/Debug/Flutter.xcframework" ]; then
  echo "✅ Flutter.xcframework found!"
else
  echo "❌ Flutter.xcframework not found. Running build first..."
  flutter build ios-framework --no-profile --no-release --output=ios/Flutter/ephemeral
fi

# Step 2: Create a symbolic link to the Flutter.framework
echo "Step 2: Creating symbolic link to Flutter.framework..."
if [ -d "ios/Flutter/ephemeral/Debug/Flutter.xcframework/ios-arm64/Flutter.framework" ]; then
  # Remove existing Flutter.framework if it exists
  rm -rf ios/Flutter/ephemeral/Flutter.framework
  
  # Create symbolic link
  ln -sf Debug/Flutter.xcframework/ios-arm64/Flutter.framework ios/Flutter/ephemeral/Flutter.framework
  echo "✅ Symbolic link created successfully!"
else
  echo "❌ Source Flutter.framework not found!"
  exit 1
fi

# Step 3: Clean and reinstall pods
echo "Step 3: Cleaning and reinstalling pods..."
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..

echo "✅ Fix completed! Try building your app now."
echo "If you still encounter issues, try running the app with:"
echo "flutter run --target lib/main_no_firebase.dart" 
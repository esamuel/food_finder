#!/bin/bash

# Navigate to the project root
cd "$(dirname "$0")"

echo "===== DIRECT FIX FOR 'NO SUCH MODULE FLUTTER' ERROR ====="

# Step 1: Create the ephemeral directory if it doesn't exist
echo "Step 1: Creating ephemeral directory..."
mkdir -p ios/Flutter/ephemeral

# Step 2: Generate Flutter.framework directly
echo "Step 2: Generating Flutter.framework directly..."
flutter build ios-framework --no-profile --no-release --output=ios/Flutter/ephemeral

# Step 3: Verify the framework was created
echo "Step 3: Verifying Flutter.framework..."
if [ -d "ios/Flutter/ephemeral/Flutter.framework" ]; then
  echo "✅ Flutter.framework successfully created!"
else
  echo "❌ Flutter.framework creation failed!"
  exit 1
fi

# Step 4: Clean and reinstall pods
echo "Step 4: Cleaning and reinstalling pods..."
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..

echo "✅ Fix completed! Try building your app now."
echo "If you still encounter issues, try running the app with:"
echo "flutter run --target lib/main_no_firebase.dart" 
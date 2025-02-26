#!/bin/bash

# Navigate to the project root
cd "$(dirname "$0")"

echo "===== COMPREHENSIVE iOS LAUNCH ISSUE FIX ====="

# Kill any existing Xcode processes
echo "Step 1: Killing any existing Xcode processes..."
killall Xcode || true
killall Simulator || true

# Wait a moment
sleep 2

# Clean the project
echo "Step 2: Cleaning the project..."
flutter clean
flutter pub get

# Fix Info.plist
echo "Step 3: Fixing Info.plist..."
if [ -f "ios/Runner/Info.plist.fix" ]; then
  # Backup the original Info.plist if not already backed up
  if [ ! -f "ios/Runner/Info.plist.bak" ]; then
    cp ios/Runner/Info.plist ios/Runner/Info.plist.bak
  fi
  # Replace Info.plist with the fixed version
  cp ios/Runner/Info.plist.fix ios/Runner/Info.plist
  echo "✅ Info.plist has been updated with additional permissions."
else
  echo "⚠️ Info.plist.fix not found. Skipping this step."
fi

# Fix Flutter framework symlink
echo "Step 4: Creating Flutter framework symlink..."
if [ -d "ios/Flutter/ephemeral/Debug/Flutter.xcframework" ]; then
  echo "✅ Flutter.xcframework found!"
  # Remove existing Flutter.framework if it exists
  rm -rf ios/Flutter/ephemeral/Flutter.framework
  
  # Create symbolic link
  ln -sf Debug/Flutter.xcframework/ios-arm64/Flutter.framework ios/Flutter/ephemeral/Flutter.framework
  echo "✅ Symbolic link created successfully!"
else
  echo "❌ Flutter.xcframework not found. Running build first..."
  flutter build ios-framework --no-profile --no-release --output=ios/Flutter/ephemeral
  
  # Try creating the symlink again
  if [ -d "ios/Flutter/ephemeral/Debug/Flutter.xcframework" ]; then
    rm -rf ios/Flutter/ephemeral/Flutter.framework
    ln -sf Debug/Flutter.xcframework/ios-arm64/Flutter.framework ios/Flutter/ephemeral/Flutter.framework
    echo "✅ Symbolic link created successfully!"
  else
    echo "❌ Failed to create Flutter framework symlink."
  fi
fi

# Fix iOS permissions
echo "Step 5: Reinstalling CocoaPods..."
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..

# Make sure the device is connected via USB
echo "Step 6: Checking for connected iOS devices..."
echo "Please ensure your iPhone is connected via USB cable."
echo "Check that you've trusted this computer on your iPhone."
echo "Disable 'Personal Hotspot' if it's enabled."
flutter devices

# Run the app with the iOS launch fix entry point
echo "Step 7: Running the app with iOS launch fix..."
echo "Would you like to run the app now? (y/n)"
read -r answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
  flutter run --target lib/main_ios_launch_fix.dart --no-fast-start
else
  echo "You can run the app later with: ./run_ios_launch_fix.sh"
fi

echo "If the app still doesn't launch, try running it directly from Xcode:"
echo "./open_in_xcode.sh" 
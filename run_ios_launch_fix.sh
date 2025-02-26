#!/bin/bash

# Navigate to the project root
cd "$(dirname "$0")"

echo "===== RUNNING FOOD FINDER WITH iOS LAUNCH FIX ====="

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

# Fix iOS permissions
echo "Step 3: Fixing iOS permissions..."
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..

# Make sure the device is connected via USB
echo "Step 4: Checking for connected iOS devices..."
echo "Please ensure your iPhone is connected via USB cable."
echo "Check that you've trusted this computer on your iPhone."
echo "Disable 'Personal Hotspot' if it's enabled."

# Run the app with the iOS launch fix entry point
echo "Step 5: Running the app with iOS launch fix..."
flutter run --target lib/main_ios_launch_fix.dart --no-fast-start

echo "If the app still doesn't launch, try running it directly from Xcode:"
echo "./open_in_xcode.sh" 
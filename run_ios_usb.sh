#!/bin/bash

# Navigate to the project root
cd "$(dirname "$0")"

echo "===== RUNNING FOOD FINDER VIA USB CONNECTION ====="

# Kill any existing Xcode processes
echo "Killing any existing Xcode processes..."
killall Xcode || true
killall Simulator || true

# Wait a moment
sleep 2

# Make sure the device is connected via USB
echo "Please ensure your iPhone is connected via USB cable."
echo "Check that you've trusted this computer on your iPhone."
echo "Disable 'Personal Hotspot' if it's enabled."

# Verify USB connection
echo "Checking for connected iOS devices..."
flutter devices

# Run the app with the no-firebase entry point via USB
echo "Running the app with USB connection..."
flutter run --target lib/main_no_firebase.dart --device-id $(flutter devices | grep -i "iphone" | grep -v "wireless" | awk '{print $2}' | head -1)

# If no direct device ID is found, let the user select
if [ $? -ne 0 ]; then
  echo "No direct USB connection found. Running with device selection..."
  flutter run --target lib/main_no_firebase.dart
fi 
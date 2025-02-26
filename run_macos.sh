#!/bin/bash

# Navigate to the project root
cd "$(dirname "$0")"

echo "===== RUNNING FOOD FINDER ON MACOS ====="

# Kill any existing Xcode processes
echo "Killing any existing Xcode processes..."
killall Xcode || true
killall Simulator || true

# Wait a moment
sleep 2

# Run the app with the macOS-specific entry point
echo "Running the app with macOS-specific entry point..."
flutter run --target lib/main_macos.dart -d macos

echo "✅ Done!" 
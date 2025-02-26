#!/bin/bash

# Navigate to the project root
cd "$(dirname "$0")"

echo "===== OPENING FOOD FINDER IN XCODE ====="

# Kill any existing Xcode processes
echo "Killing any existing Xcode processes..."
killall Xcode || true
sleep 2

# Open the project in Xcode
echo "Opening the project in Xcode..."
open ios/Runner.xcworkspace

echo "✅ Project opened in Xcode."
echo ""
echo "To run the app from Xcode:"
echo "1. Select your connected iPhone from the device dropdown at the top"
echo "2. Click the Play button or press Cmd+R"
echo "3. If prompted, trust the developer certificate on your iPhone"
echo ""
echo "If you encounter build errors in Xcode:"
echo "1. Go to Product > Clean Build Folder"
echo "2. Close Xcode"
echo "3. Run: flutter clean && flutter pub get"
echo "4. Reopen Xcode and try again" 
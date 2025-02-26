#!/bin/bash

# Navigate to the project root
cd "$(dirname "$0")"

echo "===== FIXING iOS INFO.PLIST ====="

# Check if the fixed Info.plist exists
if [ ! -f "ios/Runner/Info.plist.fix" ]; then
  echo "❌ Error: ios/Runner/Info.plist.fix not found!"
  exit 1
fi

# Backup the original Info.plist if not already backed up
if [ ! -f "ios/Runner/Info.plist.bak" ]; then
  echo "Step 1: Backing up original Info.plist..."
  cp ios/Runner/Info.plist ios/Runner/Info.plist.bak
else
  echo "Step 1: Original Info.plist already backed up."
fi

# Replace Info.plist with the fixed version
echo "Step 2: Replacing Info.plist with fixed version..."
cp ios/Runner/Info.plist.fix ios/Runner/Info.plist

echo "✅ Info.plist has been updated with additional permissions."
echo "You can now run the app with: ./run_ios_launch_fix.sh" 
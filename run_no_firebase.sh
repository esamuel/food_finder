#!/bin/bash

# Navigate to the project root
cd "$(dirname "$0")"

echo "===== RUNNING FOOD FINDER WITHOUT FIREBASE ====="

# Run the app with the no-firebase entry point
flutter run --target lib/main_no_firebase.dart "$@" 
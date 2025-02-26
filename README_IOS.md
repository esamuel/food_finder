# Food Finder iOS Development Guide

This guide provides instructions for running the Food Finder app on iOS devices during development.

## iOS Development Setup

The main entry point (`lib/main.dart`) includes Firebase initialization, which may cause issues if Firebase is not properly configured. For development purposes, we've created an alternative entry point that doesn't rely on Firebase.

## Running the App on iOS

To run the app on an iOS device or simulator without Firebase dependencies:

```bash
flutter run -d <device_name> --target lib/main_ios_dev.dart
```

For example:

```bash
flutter run -d iPhone --target lib/main_ios_dev.dart
```

## iOS Implementation Details

### Entry Point

The `lib/main_ios_dev.dart` file serves as the iOS-specific entry point for development. This file:

- Initializes the Flutter binding
- Sets preferred orientations and system UI styles
- Initializes the camera
- Sets up mock services for development
- Uses the `MockFoodRecognitionService` instead of the TensorFlow Lite implementation

### Mock Services

In development mode, the app uses mock implementations of various services:

- `MockAuthService` for authentication
- `MockDatabaseService` for database operations
- `MockStorageService` for storage operations
- `MockFoodRecognitionService` for food recognition

This allows you to test the app's functionality without requiring backend services to be fully configured.

## Food Recognition in iOS Development Mode

In development mode, the app uses the `MockFoodRecognitionService` which returns predefined food recognition results. This allows you to test the UI and user flow without requiring a trained TensorFlow Lite model.

## Troubleshooting iOS Development

### Common Issues

1. **Build Errors**: If you encounter build errors, try:
   ```bash
   flutter clean
   flutter pub get
   ```

2. **Invalid Depfile**: If you see "Invalid depfile" errors, run:
   ```bash
   flutter clean
   ```

3. **Xcode Issues**: Ensure you have the latest version of Xcode installed and that your iOS development certificates are properly configured.

## Moving to Production

When moving to production:

1. Properly configure Firebase for iOS
2. Implement a real TensorFlow Lite model for food recognition
3. Replace mock services with real implementations
4. Use the main entry point (`lib/main.dart`) instead of the development entry point

## Future iOS Improvements

- Implement Core ML support for better performance on iOS devices
- Add iOS-specific UI enhancements using Cupertino widgets
- Implement local storage for offline capabilities
- Add support for iOS-specific features like Shortcuts and Widgets 
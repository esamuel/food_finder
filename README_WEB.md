# Food Finder Web Setup

This document provides instructions for running the Food Finder app on web browsers.

## Web Compatibility

The Food Finder app uses TensorFlow Lite for food recognition, which is not directly compatible with web platforms. To address this, we've created web-specific implementations that use mock data for food recognition when running in a web browser.

## Running the App on Web

To run the app on a web browser, use the following command:

```bash
flutter run -d chrome --target lib/main_web_dev.dart
```

This command uses a web-specific entry point that:
1. Avoids TensorFlow Lite dependencies that are incompatible with web
2. Uses a web-compatible food recognition service
3. Configures the app appropriately for web platforms

## Web Implementation Details

### Web-Specific Entry Point

The `lib/main_web_dev.dart` file serves as the entry point for web development. It:
- Initializes web-specific configurations
- Uses mock services for authentication, database, and storage
- Uses the `WebFoodRecognitionService` instead of the TensorFlow Lite implementation

### Web Food Recognition Service

The `WebFoodRecognitionService` provides a web-compatible implementation of the food recognition interface. In a production environment, you might want to:
1. Call a backend API for food recognition
2. Use a web-compatible machine learning model (like TensorFlow.js)
3. Implement a more sophisticated mock for testing

## Limitations in Web Mode

When running in web mode, the following limitations apply:
1. Camera access may be limited or require explicit user permission
2. Food recognition uses mock data instead of real ML-based recognition
3. File system access is restricted to browser APIs

## Future Web Improvements

To improve the web experience, consider:
1. Implementing a TensorFlow.js-based food recognition service
2. Creating a backend API for food recognition
3. Optimizing the UI for web platforms
4. Adding PWA (Progressive Web App) support for offline capabilities 
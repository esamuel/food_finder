# Food Finder App

A Flutter application for identifying foods and providing nutritional information.

## Features

- Food recognition using camera or gallery images
- Detailed nutritional information for identified foods
- Favorites system to save foods you like
- History tracking of all scanned foods
- Beautiful UI with food categories and detailed food information

## Web Deployment

This app can be deployed as a web application using Vercel. Follow these steps:

### Option 1: Deploy with Vercel CLI

1. Install Vercel CLI:
   ```
   npm install -g vercel
   ```

2. Build the Flutter web app:
   ```
   flutter build web
   ```

3. Deploy to Vercel:
   ```
   cd build/web
   vercel
   ```

### Option 2: Deploy with Vercel Dashboard

1. Push your code to a GitHub repository
2. Create a new project on Vercel and connect to your GitHub repository
3. Configure the build settings:
   - Build Command: `flutter/bin/flutter build web --release`
   - Output Directory: `build/web`
   - Install Command: `if cd flutter; then git pull && cd .. ; else git clone https://github.com/flutter/flutter.git; fi && ls && flutter/bin/flutter doctor && flutter/bin/flutter clean && flutter/bin/flutter config --enable-web`

4. Deploy your project

## Local Development

1. Clone the repository
2. Install dependencies:
   ```
   flutter pub get
   ```
3. Run the app:
   ```
   flutter run
   ```

## Supabase Integration

This app uses Supabase for authentication and data storage. Make sure to set up your Supabase project and update the configuration in `lib/main.dart`.

## License

MIT

## Acknowledgments

- Flutter team for the amazing framework
- TensorFlow team for the machine learning tools
- All contributors to this project

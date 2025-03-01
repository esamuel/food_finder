/// API keys for various services
class ApiKeys {
  /// Google Cloud Vision API key
  static const String googleCloudVisionApiKey =
      'AIzaSyD_tIYy5a-g95ryO5pOc8wWzEjanQR-mRc';

  /// Clarifai API key
  static const String clarifaiApiKey = '498734a628d0459aadf651fd8318f42a';

  /// Check if Google Cloud Vision API key is set
  static bool get isGoogleCloudVisionApiKeySet =>
      googleCloudVisionApiKey != 'YOUR_GOOGLE_CLOUD_VISION_API_KEY';

  /// Check if Clarifai API key is set
  static bool get isClarifaiApiKeySet =>
      clarifaiApiKey != 'YOUR_CLARIFAI_API_KEY';
}

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
// Conditionally import TensorFlow Lite only for non-web platforms
import 'package:flutter/services.dart';
import '../models/recognition_result.dart';
import '../../config/api_keys.dart';

// Import TensorFlow Lite only for non-web platforms
import 'food_recognition_tflite.dart'
    if (dart.library.js) 'food_recognition_web.dart';

abstract class FoodRecognitionServiceInterface {
  Future<List<RecognitionResult>> recognizeFood(Uint8List imageData);
  Future<List<RecognitionResult>> recognizeFoodFromFile(File imageFile);
}

class MockFoodRecognitionService implements FoodRecognitionServiceInterface {
  @override
  Future<List<RecognitionResult>> recognizeFood(Uint8List imageData) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 2));

    // Return mock results with more variety
    return [
      const RecognitionResult(label: 'Apple', confidence: 0.92),
      const RecognitionResult(label: 'Red Delicious Apple', confidence: 0.85),
      const RecognitionResult(label: 'Fruit', confidence: 0.76),
    ];
  }

  @override
  Future<List<RecognitionResult>> recognizeFoodFromFile(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    return recognizeFood(bytes);
  }
}

// Enhanced mock service with more variety of foods
class EnhancedMockFoodRecognitionService
    implements FoodRecognitionServiceInterface {
  // Use a fixed seed for consistent results during debugging
  final int _debugSeed = 42;

  // Mock result sets for different foods
  final List<List<RecognitionResult>> _mockResultSets = [
    // Fruits
    [
      const RecognitionResult(label: 'Apple', confidence: 0.92),
      const RecognitionResult(label: 'Red Delicious Apple', confidence: 0.85),
      const RecognitionResult(label: 'Fruit', confidence: 0.76),
    ],
    [
      const RecognitionResult(label: 'Banana', confidence: 0.94),
      const RecognitionResult(label: 'Yellow Fruit', confidence: 0.88),
      const RecognitionResult(label: 'Tropical Fruit', confidence: 0.79),
    ],
    [
      const RecognitionResult(label: 'Orange', confidence: 0.91),
      const RecognitionResult(label: 'Citrus Fruit', confidence: 0.87),
      const RecognitionResult(label: 'Fruit', confidence: 0.75),
    ],
    // Vegetables
    [
      const RecognitionResult(label: 'Broccoli', confidence: 0.93),
      const RecognitionResult(label: 'Green Vegetable', confidence: 0.86),
      const RecognitionResult(label: 'Cruciferous Vegetable', confidence: 0.78),
    ],
    [
      const RecognitionResult(label: 'Carrot', confidence: 0.95),
      const RecognitionResult(label: 'Root Vegetable', confidence: 0.89),
      const RecognitionResult(label: 'Orange Vegetable', confidence: 0.77),
    ],
    // Dishes
    [
      const RecognitionResult(label: 'Pizza', confidence: 0.96),
      const RecognitionResult(label: 'Italian Food', confidence: 0.90),
      const RecognitionResult(label: 'Fast Food', confidence: 0.82),
    ],
    [
      const RecognitionResult(label: 'Hamburger', confidence: 0.94),
      const RecognitionResult(label: 'Fast Food', confidence: 0.88),
      const RecognitionResult(label: 'American Food', confidence: 0.80),
    ],
    [
      const RecognitionResult(label: 'Sushi', confidence: 0.93),
      const RecognitionResult(label: 'Japanese Food', confidence: 0.87),
      const RecognitionResult(label: 'Seafood', confidence: 0.79),
    ],
    [
      const RecognitionResult(label: 'Pasta', confidence: 0.92),
      const RecognitionResult(label: 'Italian Food', confidence: 0.86),
      const RecognitionResult(label: 'Carbohydrate', confidence: 0.78),
    ],
    [
      const RecognitionResult(label: 'Salad', confidence: 0.91),
      const RecognitionResult(label: 'Healthy Food', confidence: 0.85),
      const RecognitionResult(label: 'Vegetable Dish', confidence: 0.77),
    ],
  ];

  @override
  Future<List<RecognitionResult>> recognizeFood(Uint8List imageData) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    // For debugging, always return the same result set
    // In production, you might want to use a random selection
    // final random = DateTime.now().millisecondsSinceEpoch % _mockResultSets.length;

    // Use a fixed index for consistent results during debugging
    final index = _debugSeed % _mockResultSets.length;

    debugPrint(
        'EnhancedMockFoodRecognitionService: Returning result set $index');
    return _mockResultSets[index];
  }

  @override
  Future<List<RecognitionResult>> recognizeFoodFromFile(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      debugPrint(
          'EnhancedMockFoodRecognitionService: Processing file with size ${bytes.length} bytes');
      return recognizeFood(bytes);
    } catch (e) {
      debugPrint('EnhancedMockFoodRecognitionService: Error reading file: $e');
      // Return a default result set if there's an error
      return _mockResultSets[0];
    }
  }
}

// Keep the API-based services for future use
class ClarifaiFoodRecognitionService
    implements FoodRecognitionServiceInterface {
  // Get API key from configuration
  final String _apiKey = ApiKeys.clarifaiApiKey;

  // Clarifai Food Model ID
  static const String _modelId = 'food-item-recognition';
  final String _apiUrl = 'https://api.clarifai.com/v2/models/$_modelId/outputs';

  @override
  Future<List<RecognitionResult>> recognizeFood(Uint8List imageData) async {
    try {
      // Resize and compress the image to reduce upload size
      final resizedImage = await _resizeImage(imageData);

      // Convert image to base64
      final base64Image = base64Encode(resizedImage);

      // Prepare request body
      final requestBody = {
        "inputs": [
          {
            "data": {
              "image": {"base64": base64Image}
            }
          }
        ]
      };

      // Create request
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Authorization': 'Key $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      // Check if the request was successful
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return _parseClarifaiResponse(jsonResponse);
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to recognize food: ${response.statusCode}');
      }
    } catch (e) {
      print('Error recognizing food: $e');
      // Fall back to enhanced mock results if there's an error
      return EnhancedMockFoodRecognitionService().recognizeFood(imageData);
    }
  }

  @override
  Future<List<RecognitionResult>> recognizeFoodFromFile(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    return recognizeFood(bytes);
  }

  Future<Uint8List> _resizeImage(Uint8List imageData) async {
    // Use compute to run in a separate isolate for better performance
    return compute(_resizeImageIsolate, imageData);
  }

  List<RecognitionResult> _parseClarifaiResponse(
      Map<String, dynamic> jsonResponse) {
    try {
      final outputs = jsonResponse['outputs'] as List;
      if (outputs.isEmpty) return [];

      final data = outputs[0];
      final concepts = data['data']['concepts'] as List;

      return concepts.map<RecognitionResult>((concept) {
        return RecognitionResult(
          label: concept['name'] as String,
          confidence: concept['value'] as double,
        );
      }).toList();
    } catch (e) {
      print('Error parsing Clarifai response: $e');
      return [];
    }
  }
}

// Google Cloud Vision API implementation
class GoogleVisionFoodRecognitionService
    implements FoodRecognitionServiceInterface {
  // Get API key from configuration
  final String _apiKey = ApiKeys.googleCloudApiKey;
  final String _apiUrl = 'https://vision.googleapis.com/v1/images:annotate';

  @override
  Future<List<RecognitionResult>> recognizeFood(Uint8List imageData) async {
    try {
      // Resize and compress the image to reduce upload size
      final resizedImage = await _resizeImage(imageData);

      // Convert image to base64
      final base64Image = base64Encode(resizedImage);

      // Prepare request body
      final requestBody = {
        "requests": [
          {
            "image": {"content": base64Image},
            "features": [
              {"type": "LABEL_DETECTION", "maxResults": 10}
            ]
          }
        ]
      };

      // Create request
      final response = await http.post(
        Uri.parse('$_apiUrl?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      // Check if the request was successful
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return _parseGoogleVisionResponse(jsonResponse);
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to recognize food: ${response.statusCode}');
      }
    } catch (e) {
      print('Error recognizing food: $e');
      // Fall back to enhanced mock results if there's an error
      return EnhancedMockFoodRecognitionService().recognizeFood(imageData);
    }
  }

  @override
  Future<List<RecognitionResult>> recognizeFoodFromFile(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    return recognizeFood(bytes);
  }

  Future<Uint8List> _resizeImage(Uint8List imageData) async {
    // Use compute to run in a separate isolate for better performance
    return compute(_resizeImageIsolate, imageData);
  }

  List<RecognitionResult> _parseGoogleVisionResponse(
      Map<String, dynamic> jsonResponse) {
    try {
      final responses = jsonResponse['responses'] as List;
      if (responses.isEmpty) return [];

      final labelAnnotations = responses[0]['labelAnnotations'] as List;

      // Filter results to only include food-related labels
      final foodKeywords = [
        'food',
        'dish',
        'cuisine',
        'fruit',
        'vegetable',
        'meat',
        'dessert',
        'breakfast',
        'lunch',
        'dinner'
      ];

      return labelAnnotations.map<RecognitionResult>((annotation) {
        return RecognitionResult(
          label: annotation['description'] as String,
          confidence: annotation['score'] as double,
        );
      }).where((result) {
        // Check if the label contains any food-related keyword
        return foodKeywords.any((keyword) =>
            result.label.toLowerCase().contains(keyword.toLowerCase()));
      }).toList();
    } catch (e) {
      print('Error parsing Google Vision response: $e');
      return [];
    }
  }
}

// Function to be run in isolate
Uint8List _resizeImageIsolate(Uint8List imageData) {
  // Decode the image
  final image = img.decodeImage(imageData);
  if (image == null) return imageData;

  // Resize the image to a reasonable size (e.g., max 800px width/height)
  final maxDimension = 800;
  img.Image resized;

  if (image.width > maxDimension || image.height > maxDimension) {
    if (image.width > image.height) {
      resized = img.copyResize(
        image,
        width: maxDimension,
        height: (image.height * maxDimension / image.width).round(),
      );
    } else {
      resized = img.copyResize(
        image,
        width: (image.width * maxDimension / image.height).round(),
        height: maxDimension,
      );
    }
  } else {
    resized = image;
  }

  // Encode as JPEG with quality 85 to reduce size
  return Uint8List.fromList(img.encodeJpg(resized, quality: 85));
}

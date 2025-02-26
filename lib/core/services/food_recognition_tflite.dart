import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import '../models/recognition_result.dart';
import 'food_recognition_service.dart';

// TensorFlow Lite-based food recognition service that works locally
class TFLiteFoodRecognitionService implements FoodRecognitionServiceInterface {
  static const String _modelPath = 'assets/ml/food_model.tflite';
  static const String _labelsPath = 'assets/ml/food_labels.txt';

  Interpreter? _interpreter;
  List<String>? _labels;
  bool _isInitialized = false;

  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;

    try {
      // Load the model
      final interpreterOptions = InterpreterOptions();
      _interpreter = await Interpreter.fromAsset(
        _modelPath,
        options: interpreterOptions,
      );

      // Load labels
      final labelsData = await rootBundle.loadString(_labelsPath);
      _labels =
          labelsData.split('\n').where((label) => label.isNotEmpty).toList();

      _isInitialized = true;
    } catch (e) {
      print('Error initializing TFLite model: $e');
      // If we can't load the model, we'll use mock data
    }
  }

  @override
  Future<List<RecognitionResult>> recognizeFood(Uint8List imageData) async {
    try {
      await _ensureInitialized();

      if (_interpreter == null || _labels == null) {
        throw Exception('TFLite model not initialized');
      }

      // Preprocess the image
      final processedImage = await _preprocessImage(imageData);

      // Run inference
      final outputBuffer = List<List<double>>.filled(
        1,
        List<double>.filled(_labels!.length, 0),
      );

      _interpreter!.run(processedImage, outputBuffer);

      // Process results
      return _processResults(outputBuffer);
    } catch (e) {
      print('Error recognizing food with TFLite: $e');
      // Fall back to enhanced mock results
      return EnhancedMockFoodRecognitionService().recognizeFood(imageData);
    }
  }

  @override
  Future<List<RecognitionResult>> recognizeFoodFromFile(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    return recognizeFood(bytes);
  }

  Future<List<dynamic>> _preprocessImage(Uint8List imageData) async {
    // Decode the image
    final image = img.decodeImage(imageData);
    if (image == null) throw Exception('Failed to decode image');

    // Resize to the input size expected by the model (typically 224x224 for food models)
    final resized = img.copyResize(
      image,
      width: 224,
      height: 224,
    );

    // Create a 3D array for the input (1 x 224 x 224 x 3)
    final inputArray = List<List<List<double>>>.filled(
      224,
      List<List<double>>.filled(
        224,
        List<double>.filled(3, 0),
      ),
    );

    // Fill the input array with normalized pixel values
    for (var y = 0; y < 224; y++) {
      for (var x = 0; x < 224; x++) {
        // Get pixel color values
        final pixel = resized.getPixel(x, y);
        final r = pixel.r.toDouble() / 255.0;
        final g = pixel.g.toDouble() / 255.0;
        final b = pixel.b.toDouble() / 255.0;

        inputArray[y][x][0] = r; // R
        inputArray[y][x][1] = g; // G
        inputArray[y][x][2] = b; // B
      }
    }

    return [inputArray];
  }

  List<RecognitionResult> _processResults(List<List<double>> outputBuffer) {
    if (_labels == null) return [];

    final results = <RecognitionResult>[];
    final output = outputBuffer[0];

    // Create a list of (index, confidence) pairs
    final indexedConfidences = List.generate(
      output.length,
      (index) => MapEntry(index, output[index]),
    );

    // Sort by confidence (descending)
    indexedConfidences.sort((a, b) => b.value.compareTo(a.value));

    // Take top 5 results
    for (var i = 0; i < 5 && i < indexedConfidences.length; i++) {
      final index = indexedConfidences[i].key;
      final confidence = indexedConfidences[i].value;

      // Only include results with reasonable confidence
      if (confidence > 0.05 && index < _labels!.length) {
        results.add(RecognitionResult(
          label: _labels![index],
          confidence: confidence,
        ));
      }
    }

    return results;
  }

  void dispose() {
    _interpreter?.close();
  }
}

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import '../models/recognition_result.dart';
import 'food_recognition_service.dart';

class TFLiteFoodRecognitionService implements FoodRecognitionServiceInterface {
  static const String _modelPath = 'assets/ml/food_model.tflite';
  static const String _labelsPath = 'assets/ml/food_labels.txt';

  Interpreter? _interpreter;
  List<String>? _labels;
  bool _isInitialized = false;
  final MockFoodRecognitionService _mockService = MockFoodRecognitionService();

  Future<bool> _ensureInitialized() async {
    if (_isInitialized) return true;

    try {
      // Always use mock service on web
      if (kIsWeb) {
        debugPrint('Running on web, using mock service');
        return false;
      }

      // Load the model
      final interpreterOptions = InterpreterOptions();

      // Load model from assets
      try {
        _interpreter = await Interpreter.fromAsset(
          _modelPath,
          options: interpreterOptions,
        );
      } catch (e) {
        debugPrint('Error loading TFLite model: $e');
        return false;
      }

      // Load labels
      try {
        final labelsData = await rootBundle.loadString(_labelsPath);
        _labels =
            labelsData.split('\n').where((label) => label.isNotEmpty).toList();
      } catch (e) {
        debugPrint('Error loading labels: $e');
        return false;
      }

      _isInitialized = true;
      return true;
    } catch (e) {
      debugPrint('Error initializing TFLite model: $e');
      return false;
    }
  }

  @override
  Future<List<RecognitionResult>> recognizeFood(Uint8List imageData) async {
    try {
      // Try to initialize, but fall back to mock if it fails
      final initialized = await _ensureInitialized();
      if (!initialized) {
        debugPrint('TFLite initialization failed, using mock service');
        return _mockService.recognizeFood(imageData);
      }

      if (_interpreter == null || _labels == null) {
        debugPrint(
            'TFLite interpreter or labels not initialized, using mock service');
        return _mockService.recognizeFood(imageData);
      }

      // Decode and preprocess the image
      final image = img.decodeImage(imageData);
      if (image == null) {
        debugPrint('Failed to decode image, using mock service');
        return _mockService.recognizeFood(imageData);
      }

      // Resize image to match model input size (typically 224x224 for MobileNet)
      final processedImage = _preprocessImage(image);

      // Run inference
      final outputBuffer = _createOutputBuffer();
      _interpreter!.run(processedImage, outputBuffer);

      // Process results
      return _processResults(outputBuffer);
    } catch (e) {
      debugPrint('Error recognizing food with TFLite: $e');
      // Fall back to mock service if there's an error
      return _mockService.recognizeFood(imageData);
    }
  }

  @override
  Future<List<RecognitionResult>> recognizeFoodFromFile(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      return recognizeFood(bytes);
    } catch (e) {
      debugPrint('Error reading image file: $e');
      return _mockService.recognizeFood(Uint8List(0));
    }
  }

  List<List<List<List<double>>>> _preprocessImage(img.Image image) {
    // Resize to model input size (e.g., 224x224)
    final inputSize = 224;
    final resizedImage = img.copyResize(
      image,
      width: inputSize,
      height: inputSize,
    );

    // Create input tensor
    final input = List.generate(
      1,
      (_) => List.generate(
        inputSize,
        (_) => List.generate(
          inputSize,
          (_) => List.filled(3, 0.0),
        ),
      ),
    );

    // Normalize pixel values and fill input tensor
    for (var y = 0; y < inputSize; y++) {
      for (var x = 0; x < inputSize; x++) {
        final pixel = resizedImage.getPixel(x, y);
        // Extract RGB values and normalize to [0, 1]
        input[0][y][x][0] = pixel.r / 255.0;
        input[0][y][x][1] = pixel.g / 255.0;
        input[0][y][x][2] = pixel.b / 255.0;
      }
    }

    return input;
  }

  List<List<double>> _createOutputBuffer() {
    // Create output buffer based on model output shape
    // Typically for classification, it's [1, num_classes]
    final numClasses = _labels?.length ?? 1001; // Default to 1001 for MobileNet
    return List.generate(1, (_) => List.filled(numClasses, 0.0));
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

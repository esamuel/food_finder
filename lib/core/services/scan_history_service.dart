import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/scan_history_item.dart';
import '../models/recognition_result.dart';

class ScanHistoryService {
  static const String _scanHistoryKey = 'scan_history';
  static const String _imageDir = 'scan_images';

  // Singleton instance
  static final ScanHistoryService _instance = ScanHistoryService._internal();

  factory ScanHistoryService() => _instance;

  ScanHistoryService._internal();

  // In-memory cache of scan history
  List<ScanHistoryItem>? _cachedHistory;

  // Save a new scan to history
  Future<void> saveScan({
    required List<RecognitionResult> results,
    dynamic imageData, // Can be File, Uint8List, or String (URL)
  }) async {
    if (results.isEmpty) return;

    String? imageUrl;
    String? localImagePath;
    Uint8List? imageBytes;

    // Process image data based on its type
    if (imageData != null) {
      if (imageData is String) {
        // It's already a URL
        imageUrl = imageData;
      } else if (imageData is File) {
        // Save the file locally and store the path
        localImagePath = await _saveImageFile(imageData);
        // Also keep the bytes for immediate display
        imageBytes = await imageData.readAsBytes();
      } else if (imageData is Uint8List) {
        // Save the bytes to a file and store the path
        localImagePath = await _saveBytesToFile(imageData);
        imageBytes = imageData;
      }
    }

    // Create a new history item
    final historyItem = ScanHistoryItem.fromRecognitionResults(
      results: results,
      imageUrl: imageUrl,
      imageBytes: imageBytes,
      localImagePath: localImagePath,
    );

    // Get current history
    final history = await getHistory();

    // Add new item at the beginning
    history.insert(0, historyItem);

    // Limit history to 100 items to prevent excessive storage use
    if (history.length > 100) {
      history.removeLast();
    }

    // Update cache
    _cachedHistory = history;

    // Save to shared preferences
    await _saveHistoryToPrefs(history);
  }

  // Get all scan history
  Future<List<ScanHistoryItem>> getHistory() async {
    // Return cached history if available
    if (_cachedHistory != null) {
      return _cachedHistory!;
    }

    // Otherwise load from shared preferences
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList(_scanHistoryKey) ?? [];

    final history = historyJson
        .map((itemJson) => ScanHistoryItem.fromJson(jsonDecode(itemJson)))
        .toList();

    // Cache the result
    _cachedHistory = history;

    return history;
  }

  // Clear all history
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_scanHistoryKey);
    _cachedHistory = [];

    // Also delete all saved images
    if (!kIsWeb) {
      try {
        final directory = await _getImageDirectory();
        if (directory.existsSync()) {
          directory.deleteSync(recursive: true);
          await directory.create(recursive: true);
        }
      } catch (e) {
        debugPrint('Error clearing image directory: $e');
      }
    }
  }

  // Delete a specific history item
  Future<void> deleteHistoryItem(String id) async {
    final history = await getHistory();
    history.removeWhere((item) => item.id == id);

    // Update cache
    _cachedHistory = history;

    // Save to shared preferences
    await _saveHistoryToPrefs(history);
  }

  // Helper method to save history to shared preferences
  Future<void> _saveHistoryToPrefs(List<ScanHistoryItem> history) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson =
        history.map((item) => jsonEncode(item.toJson())).toList();

    await prefs.setStringList(_scanHistoryKey, historyJson);
  }

  // Helper method to save an image file and return its path
  Future<String> _saveImageFile(File file) async {
    if (kIsWeb) {
      // Web platform doesn't support File operations
      return '';
    }

    try {
      final directory = await _getImageDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedFile = await file.copy('${directory.path}/$fileName');
      return savedFile.path;
    } catch (e) {
      debugPrint('Error saving image file: $e');
      return '';
    }
  }

  // Helper method to save bytes to a file and return its path
  Future<String> _saveBytesToFile(Uint8List bytes) async {
    if (kIsWeb) {
      // Web platform doesn't support File operations
      return '';
    }

    try {
      final directory = await _getImageDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(bytes);
      return file.path;
    } catch (e) {
      debugPrint('Error saving image bytes: $e');
      return '';
    }
  }

  // Helper method to get the image directory
  Future<Directory> _getImageDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final directory = Directory('${appDir.path}/$_imageDir');

    if (!directory.existsSync()) {
      await directory.create(recursive: true);
    }

    return directory;
  }

  // Load image for a history item
  Future<Uint8List?> loadImageForHistoryItem(ScanHistoryItem item) async {
    // If we already have the bytes, return them
    if (item.imageBytes != null) {
      return item.imageBytes;
    }

    // If we have a local path, load the file
    if (item.localImagePath != null && item.localImagePath!.isNotEmpty) {
      try {
        final file = File(item.localImagePath!);
        if (await file.exists()) {
          return await file.readAsBytes();
        }
      } catch (e) {
        debugPrint('Error loading image from local path: $e');
      }
    }

    // If we have a URL, we'd need to download it
    // This would require additional network code

    return null;
  }
}

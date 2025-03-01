import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../models/recognition_result.dart';
import '../models/scan_history_item.dart';

class FavoritesService {
  static const String _favoritesKey = 'favorites';
  static const String _favoritesTable = 'favorites';
  static const String _imageCacheKey = 'favorite_images_cache';

  // Supabase client instance
  final SupabaseClient _supabase = Supabase.instance.client;

  // Singleton pattern
  static final FavoritesService _instance = FavoritesService._internal();
  factory FavoritesService() => _instance;
  FavoritesService._internal();

  // Cache for better performance
  List<ScanHistoryItem>? _cachedFavorites;

  // In-memory image cache
  final Map<String, Uint8List> _imageCache = {};

  // Initialize and load image cache
  Future<void> _initImageCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheInfo = prefs.getStringList(_imageCacheKey) ?? [];

      for (final info in cacheInfo) {
        try {
          final parts = info.split('|');
          if (parts.length == 2) {
            final id = parts[0];
            final path = parts[1];

            // Load image from local storage
            if (await File(path).exists()) {
              final bytes = await File(path).readAsBytes();
              _imageCache[id] = bytes;
            }
          }
        } catch (e) {
          debugPrint('Error loading cached image: $e');
        }
      }

      debugPrint('Loaded ${_imageCache.length} images from cache');
    } catch (e) {
      debugPrint('Error initializing image cache: $e');
    }
  }

  // Save image cache info to persistent storage
  Future<void> _saveImageCacheInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheInfo = <String>[];

      for (final entry in _imageCache.entries) {
        try {
          final id = entry.key;
          final bytes = entry.value;

          // Save image to local storage if not already saved
          final directory = await getApplicationDocumentsDirectory();
          final path = '${directory.path}/favorite_images/$id.jpg';

          final imageFile = File(path);
          if (!await imageFile.exists()) {
            await imageFile.create(recursive: true);
            await imageFile.writeAsBytes(bytes);
          }

          cacheInfo.add('$id|$path');
        } catch (e) {
          debugPrint('Error saving cached image: $e');
        }
      }

      await prefs.setStringList(_imageCacheKey, cacheInfo);
    } catch (e) {
      debugPrint('Error saving image cache info: $e');
    }
  }

  /// Get all favorite items
  Future<List<ScanHistoryItem>> getFavorites() async {
    // Initialize image cache if needed
    if (_imageCache.isEmpty) {
      await _initImageCache();
    }

    // Return cached favorites if available
    if (_cachedFavorites != null) {
      return _cachedFavorites!;
    }

    try {
      // First try to get favorites from Supabase if user is authenticated
      if (_supabase.auth.currentUser != null) {
        try {
          final userId = _supabase.auth.currentUser!.id;
          final response = await _supabase
              .from(_favoritesTable)
              .select()
              .eq('user_id', userId)
              .order('created_at', ascending: false);

          if (response != null && response is List && response.isNotEmpty) {
            final favorites = response.map((item) {
              // Convert Supabase response to ScanHistoryItem
              return ScanHistoryItem.fromJson(jsonDecode(item['data']));
            }).toList();

            // Preload images for all favorites
            for (final favorite in favorites) {
              await _preloadImage(favorite);
            }

            // Cache the result
            _cachedFavorites = favorites;

            // Also update local storage for offline access
            _updateLocalStorage(favorites);

            return favorites;
          }
        } catch (e) {
          debugPrint('Error getting favorites from Supabase: $e');
          // Fall back to local storage if Supabase fails
        }
      }

      // Fall back to SharedPreferences if Supabase is not available or fails
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];

      final favorites = favoritesJson
          .map((json) => ScanHistoryItem.fromJson(jsonDecode(json)))
          .toList();

      // Sort by most recent first
      favorites.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // Preload images for all favorites
      for (final favorite in favorites) {
        await _preloadImage(favorite);
      }

      // Cache the result
      _cachedFavorites = favorites;

      return favorites;
    } catch (e) {
      debugPrint('Error getting favorites: $e');
      return [];
    }
  }

  /// Preload image for a favorite item
  Future<void> _preloadImage(ScanHistoryItem item) async {
    try {
      // Skip if image is already in cache
      if (_imageCache.containsKey(item.id)) {
        return;
      }

      Uint8List? imageBytes;

      // Try to load from item's imageBytes first (fastest)
      if (item.imageBytes != null) {
        imageBytes = item.imageBytes;
      }
      // Try to load from local path
      else if (item.localImagePath != null &&
          await File(item.localImagePath!).exists()) {
        imageBytes = await File(item.localImagePath!).readAsBytes();
      }
      // Try to download from URL
      else if (item.imageUrl != null) {
        try {
          final response = await http.get(Uri.parse(item.imageUrl!));
          if (response.statusCode == 200) {
            imageBytes = response.bodyBytes;
          }
        } catch (e) {
          debugPrint('Error downloading image: $e');
        }
      }

      // Cache the image if we got it
      if (imageBytes != null) {
        _imageCache[item.id] = imageBytes;

        // Save to local storage in the background
        _saveImageCacheInfo();
      }
    } catch (e) {
      debugPrint('Error preloading image: $e');
    }
  }

  /// Get image for a favorite item
  Uint8List? getImageForFavorite(String id) {
    return _imageCache[id];
  }

  /// Add a food item to favorites
  Future<bool> addToFavorites(ScanHistoryItem item) async {
    try {
      final favorites = await getFavorites();

      // Check if item already exists in favorites
      if (favorites.any((fav) => fav.id == item.id)) {
        return true; // Already a favorite
      }

      // Cache the image immediately
      await _preloadImage(item);

      // Add to favorites
      favorites.add(item);

      // Update cache
      _cachedFavorites = favorites;

      // Save to SharedPreferences
      final success = await _updateLocalStorage(favorites);

      // Save to Supabase if user is authenticated
      if (_supabase.auth.currentUser != null) {
        try {
          final userId = _supabase.auth.currentUser!.id;

          // Create a record for Supabase
          final favoriteData = {
            'user_id': userId,
            'item_id': item.id,
            'data': jsonEncode(item.toJson()),
            'created_at': DateTime.now().toIso8601String(),
          };

          // Insert into Supabase
          await _supabase.from(_favoritesTable).insert(favoriteData);
          debugPrint('Favorite saved to Supabase: ${item.id}');
        } catch (e) {
          debugPrint('Error saving favorite to Supabase: $e');
          // Continue even if Supabase fails, as we've already saved to local storage
        }
      }

      return success;
    } catch (e) {
      debugPrint('Error adding to favorites: $e');
      return false;
    }
  }

  /// Add recognition results to favorites
  Future<bool> addResultsToFavorites({
    required List<RecognitionResult> results,
    required dynamic imageData,
    bool isFromCamera = false,
  }) async {
    try {
      // Create a ScanHistoryItem from the results
      final item = ScanHistoryItem.fromRecognitionResults(
        results: results,
        imageUrl: imageData is String ? imageData : null,
        imageBytes: imageData is Uint8List ? imageData : null,
        localImagePath: imageData is File ? imageData.path : null,
      );

      return await addToFavorites(item);
    } catch (e) {
      debugPrint('Error adding results to favorites: $e');
      return false;
    }
  }

  /// Remove an item from favorites
  Future<bool> removeFromFavorites(String id) async {
    try {
      final favorites = await getFavorites();

      // Remove the item
      favorites.removeWhere((item) => item.id == id);

      // Remove from image cache
      _imageCache.remove(id);

      // Update cache
      _cachedFavorites = favorites;

      // Save to SharedPreferences
      final success = await _updateLocalStorage(favorites);

      // Remove from Supabase if user is authenticated
      if (_supabase.auth.currentUser != null) {
        try {
          final userId = _supabase.auth.currentUser!.id;

          // Delete from Supabase
          await _supabase
              .from(_favoritesTable)
              .delete()
              .eq('user_id', userId)
              .eq('item_id', id);

          debugPrint('Favorite removed from Supabase: $id');
        } catch (e) {
          debugPrint('Error removing favorite from Supabase: $e');
          // Continue even if Supabase fails, as we've already updated local storage
        }
      }

      return success;
    } catch (e) {
      debugPrint('Error removing from favorites: $e');
      return false;
    }
  }

  /// Check if an item is in favorites
  Future<bool> isFavorite(String id) async {
    final favorites = await getFavorites();
    return favorites.any((item) => item.id == id);
  }

  /// Clear all favorites
  Future<bool> clearFavorites() async {
    try {
      // Clear cache
      _cachedFavorites = [];
      _imageCache.clear();

      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.remove(_favoritesKey);
      await prefs.remove(_imageCacheKey);

      // Clear from Supabase if user is authenticated
      if (_supabase.auth.currentUser != null) {
        try {
          final userId = _supabase.auth.currentUser!.id;

          // Delete all user's favorites from Supabase
          await _supabase.from(_favoritesTable).delete().eq('user_id', userId);

          debugPrint('All favorites cleared from Supabase');
        } catch (e) {
          debugPrint('Error clearing favorites from Supabase: $e');
          // Continue even if Supabase fails, as we've already cleared local storage
        }
      }

      return success;
    } catch (e) {
      debugPrint('Error clearing favorites: $e');
      return false;
    }
  }

  /// Clear the cache to force reload from SharedPreferences
  void clearCache() {
    _cachedFavorites = null;
  }

  /// Helper method to update local storage
  Future<bool> _updateLocalStorage(List<ScanHistoryItem> favorites) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson =
          favorites.map((item) => jsonEncode(item.toJson())).toList();

      return await prefs.setStringList(_favoritesKey, favoritesJson);
    } catch (e) {
      debugPrint('Error updating local storage: $e');
      return false;
    }
  }
}

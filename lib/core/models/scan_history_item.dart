import 'dart:convert';
import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'recognition_result.dart';

class ScanHistoryItem extends Equatable {
  final String id;
  final DateTime timestamp;
  final List<RecognitionResult> results;
  final String? imageUrl;
  final Uint8List? imageBytes;
  final String? localImagePath;

  // Derived properties for convenience
  final String foodName;
  final String category;
  final double calories;

  const ScanHistoryItem({
    required this.id,
    required this.timestamp,
    required this.results,
    this.imageUrl,
    this.imageBytes,
    this.localImagePath,
    required this.foodName,
    required this.category,
    required this.calories,
  });

  // Factory constructor to create from recognition results
  factory ScanHistoryItem.fromRecognitionResults({
    required List<RecognitionResult> results,
    String? imageUrl,
    Uint8List? imageBytes,
    String? localImagePath,
  }) {
    // Generate a unique ID
    final id = const Uuid().v4();

    // Use the first result as the primary food item
    final primaryResult = results.isNotEmpty ? results.first : null;

    return ScanHistoryItem(
      id: id,
      timestamp: DateTime.now(),
      results: results,
      imageUrl: imageUrl,
      imageBytes: imageBytes,
      localImagePath: localImagePath,
      foodName: primaryResult?.label ?? 'Unknown Food',
      category: primaryResult?.category ?? 'Uncategorized',
      calories: primaryResult?.nutritionalInfo?['calories'] ?? 0.0,
    );
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'results': results.map((result) => result.toJson()).toList(),
      'imageUrl': imageUrl,
      'localImagePath': localImagePath,
      'foodName': foodName,
      'category': category,
      'calories': calories,
      // We don't store imageBytes in JSON
    };
  }

  // Create from JSON
  factory ScanHistoryItem.fromJson(Map<String, dynamic> json) {
    return ScanHistoryItem(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      results: (json['results'] as List)
          .map((resultJson) => RecognitionResult.fromJson(resultJson))
          .toList(),
      imageUrl: json['imageUrl'],
      localImagePath: json['localImagePath'],
      foodName: json['foodName'],
      category: json['category'],
      calories: json['calories'],
    );
  }

  // Formatted date for display
  String get displayDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final itemDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (itemDate == today) {
      return 'Today, ${DateFormat.jm().format(timestamp)}';
    } else if (itemDate == yesterday) {
      return 'Yesterday, ${DateFormat.jm().format(timestamp)}';
    } else {
      return DateFormat('MMM d, yyyy').format(timestamp);
    }
  }

  @override
  List<Object?> get props => [
        id,
        timestamp,
        results,
        imageUrl,
        localImagePath,
        foodName,
        category,
        calories,
      ];
}

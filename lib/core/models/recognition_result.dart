class RecognitionResult {
  final String label;
  final double confidence;
  final String category;
  final Map<String, dynamic> nutritionalInfo;
  final double calories;
  final String? description;
  final String? imageUrl;

  const RecognitionResult({
    required this.label,
    required this.confidence,
    this.category = 'Unknown',
    this.nutritionalInfo = const {},
    this.calories = 0,
    this.description,
    this.imageUrl,
  });

  factory RecognitionResult.fromJson(Map<String, dynamic> json) {
    return RecognitionResult(
      label: json['label'] as String,
      confidence: json['confidence'] as double,
      category: json['category'] as String? ?? 'Unknown',
      nutritionalInfo: Map<String, dynamic>.from(json['nutritionalInfo'] ?? {}),
      calories: json['calories'] as double? ?? 0,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'confidence': confidence,
      'category': category,
      'nutritionalInfo': nutritionalInfo,
      'calories': calories,
      'description': description,
      'imageUrl': imageUrl,
    };
  }

  // Get a specific nutritional value with a default if not found
  dynamic getNutritionalValue(String key, {dynamic defaultValue}) {
    return nutritionalInfo[key] ?? defaultValue;
  }

  // Get a specific nutritional value as double with a default if not found
  double getNutritionalValueAsDouble(String key, {double defaultValue = 0.0}) {
    final value = nutritionalInfo[key];
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      // Try to parse the string as a double, removing any non-numeric characters
      final numericString = value.replaceAll(RegExp(r'[^0-9.]'), '');
      return double.tryParse(numericString) ?? defaultValue;
    }
    return defaultValue;
  }

  @override
  String toString() => '$label (${(confidence * 100).toStringAsFixed(1)}%)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecognitionResult &&
        other.label == label &&
        other.confidence == confidence &&
        other.category == category;
  }

  @override
  int get hashCode => label.hashCode ^ confidence.hashCode ^ category.hashCode;
}

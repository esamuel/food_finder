class RecognitionResult {
  final String label;
  final double confidence;
  final String category;
  final Map<String, double> nutritionalInfo;

  const RecognitionResult({
    required this.label,
    required this.confidence,
    this.category = 'Unknown',
    this.nutritionalInfo = const {},
  });

  factory RecognitionResult.fromJson(Map<String, dynamic> json) {
    return RecognitionResult(
      label: json['label'] as String,
      confidence: json['confidence'] as double,
      category: json['category'] as String? ?? 'Unknown',
      nutritionalInfo: Map<String, double>.from(json['nutritionalInfo'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'confidence': confidence,
      'category': category,
      'nutritionalInfo': nutritionalInfo,
    };
  }

  // Get a specific nutritional value with a default if not found
  double getNutritionalValue(String key, {double defaultValue = 0.0}) {
    return nutritionalInfo[key] ?? defaultValue;
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

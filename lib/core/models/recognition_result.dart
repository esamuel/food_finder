import 'package:equatable/equatable.dart';

class RecognitionResult extends Equatable {
  final String label;
  final double confidence;
  
  const RecognitionResult({
    required this.label,
    required this.confidence,
  });
  
  @override
  List<Object> get props => [label, confidence];
  
  factory RecognitionResult.fromJson(Map<String, dynamic> json) {
    return RecognitionResult(
      label: json['label'] as String,
      confidence: json['confidence'] as double,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'confidence': confidence,
    };
  }
  
  @override
  String toString() => '$label (${(confidence * 100).toStringAsFixed(1)}%)';
}
import 'package:flutter/painting.dart';

class RedactBox {
  final Rect rect;
  final String label;
  final double confidence;
  final bool isAutoDetected;
  final bool shouldRedact;
  final String id;

  RedactBox({
    required this.rect,
    required this.label,
    required this.confidence,
    required this.isAutoDetected,
    this.shouldRedact = true,
    String? id,
  }) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString();

  RedactBox copyWith({
    Rect? rect,
    String? label,
    double? confidence,
    bool? isAutoDetected,
    bool? shouldRedact,
    String? id,
  }) {
    return RedactBox(
      rect: rect ?? this.rect,
      label: label ?? this.label,
      confidence: confidence ?? this.confidence,
      isAutoDetected: isAutoDetected ?? this.isAutoDetected,
      shouldRedact: shouldRedact ?? this.shouldRedact,
      id: id ?? this.id,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is RedactBox && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
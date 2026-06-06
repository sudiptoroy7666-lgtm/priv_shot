import 'package:flutter/painting.dart';

class PiiItem {
  final String text;
  final String type;
  final Rect boundingBox;

  const PiiItem({
    required this.text,
    required this.type,
    required this.boundingBox,
  });
}
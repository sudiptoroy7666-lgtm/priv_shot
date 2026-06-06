import 'dart:typed_data';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:priv_shot/models/redact_box.dart';
import 'package:priv_shot/services/bitmap_redactor.dart';

void main() {
  group('BitmapRedactor', () {
    final redactor = BitmapRedactor();

    late Uint8List testImageBytes;

    setUp(() {
      // Create a 100x100 white test image
      final image = img.Image(width: 100, height: 100);
      img.fillRect(image,
          x1: 0, y1: 0, x2: 100, y2: 100,
          color: img.ColorInt8.rgba(255, 255, 255, 255));
      testImageBytes = Uint8List.fromList(img.encodePng(image));
    });

    test('redacts specified region with black', () async {
      final boxes = [
        RedactBox(
          rect: const Rect.fromLTWH(10, 10, 20, 20),
          label: 'Test',
          confidence: 1.0,
          isAutoDetected: true,
        ),
      ];

      final result = await redactor.redact(
        sourceBytes: testImageBytes,
        boxes: boxes,
      );

      final decoded = img.decodeImage(result);
      expect(decoded, isNotNull);

      // Check pixel inside redacted area is black
      final pixel = decoded!.getPixel(15, 15);
      expect(pixel.r.toInt(), 0);
      expect(pixel.g.toInt(), 0);
      expect(pixel.b.toInt(), 0);
    });

    test('preserves pixels outside redacted region', () async {
      final boxes = [
        RedactBox(
          rect: const Rect.fromLTWH(10, 10, 20, 20),
          label: 'Test',
          confidence: 1.0,
          isAutoDetected: true,
        ),
      ];

      final result = await redactor.redact(
        sourceBytes: testImageBytes,
        boxes: boxes,
      );

      final decoded = img.decodeImage(result);
      final pixel = decoded!.getPixel(50, 50);
      expect(pixel.r.toInt(), 255);
      expect(pixel.g.toInt(), 255);
      expect(pixel.b.toInt(), 255);
    });

    test('handles multiple non-overlapping boxes', () async {
      final boxes = [
        RedactBox(
          rect: const Rect.fromLTWH(0, 0, 10, 10),
          label: 'A',
          confidence: 1.0,
          isAutoDetected: true,
        ),
        RedactBox(
          rect: const Rect.fromLTWH(80, 80, 10, 10),
          label: 'B',
          confidence: 1.0,
          isAutoDetected: true,
        ),
      ];

      final result = await redactor.redact(
        sourceBytes: testImageBytes,
        boxes: boxes,
      );

      final decoded = img.decodeImage(result);
      expect(decoded!.getPixel(5, 5).r.toInt(), 0);
      expect(decoded.getPixel(85, 85).r.toInt(), 0);
      expect(decoded.getPixel(50, 50).r.toInt(), 255);
    });

    test('handles empty boxes list', () async {
      final result = await redactor.redact(
        sourceBytes: testImageBytes,
        boxes: [],
      );

      final decoded = img.decodeImage(result);
      final pixel = decoded!.getPixel(50, 50);
      expect(pixel.r.toInt(), 255);
    });

    test('clamps box coordinates to image bounds', () async {
      final boxes = [
        RedactBox(
          rect: const Rect.fromLTWH(-10, -10, 200, 200),
          label: 'Out',
          confidence: 1.0,
          isAutoDetected: true,
        ),
      ];

      final result = await redactor.redact(
        sourceBytes: testImageBytes,
        boxes: boxes,
      );

      final decoded = img.decodeImage(result);
      expect(decoded, isNotNull);
      expect(decoded!.getPixel(0, 0).r.toInt(), 0);
      expect(decoded.getPixel(99, 99).r.toInt(), 0);
    });

    test('skips zero-size boxes', () async {
      final boxes = [
        RedactBox(
          rect: const Rect.fromLTWH(10, 10, 0, 0),
          label: 'Zero',
          confidence: 1.0,
          isAutoDetected: true,
        ),
      ];

      final result = await redactor.redact(
        sourceBytes: testImageBytes,
        boxes: boxes,
      );

      final decoded = img.decodeImage(result);
      expect(decoded!.getPixel(10, 10).r.toInt(), 255);
    });
  });
}
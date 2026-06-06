import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:priv_shot/models/redact_box.dart';

class BitmapRedactor {
  Future<Uint8List> redact({
    required Uint8List sourceBytes,
    required List<RedactBox> boxes,
  }) async {
    // 1. Draw black boxes using dart:ui (Handles EXIF rotation automatically)
    final codec = await ui.instantiateImageCodec(sourceBytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawImage(image, Offset.zero, Paint());

    final paint = Paint()..color = Colors.black;
    for (final box in boxes) {
      canvas.drawRect(box.rect, paint);
    }

    final picture = recorder.endRecording();
    final redactedImage = await picture.toImage(image.width, image.height);
    final byteData = await redactedImage.toByteData(format: ui.ImageByteFormat.png);

    image.dispose();
    redactedImage.dispose();

    if (byteData == null) throw Exception('Failed to encode redacted image.');
    final redactedPngBytes = byteData.buffer.asUint8List();

    // 2. 🕵️ STRIP METADATA: Decode and Re-encode
    // This completely destroys all hidden EXIF, GPS, and device metadata.
    final decodedImage = img.decodeImage(redactedPngBytes);
    if (decodedImage == null) throw Exception('Failed to decode for metadata stripping.');

    // Re-encoding as PNG guarantees a clean file with zero metadata.
    final strippedBytes = Uint8List.fromList(img.encodePng(decodedImage));

    return strippedBytes;
  }
}
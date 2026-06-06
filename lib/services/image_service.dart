import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class ImageService {
  /// Loads image bytes from a file path.
  Future<Uint8List> loadBytesFromFile(String path) async {
    final file = File(path);
    return await file.readAsBytes();
  }

  /// Decodes image bytes into a ui.Image.
  Future<ui.Image> decodeImage(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  /// Saves bytes to a temporary file and returns the path.
  Future<String> saveToTempFile(Uint8List bytes, String prefix) async {
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/${prefix}_${DateTime.now().millisecondsSinceEpoch}.png';
    final file = File(path);
    await file.writeAsBytes(bytes);
    return path;
  }

  /// Resizes image if too large to prevent OOM.
  Future<Uint8List> downsampleIfNeeded(Uint8List bytes, {int maxDim = 2048}) async {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return bytes;

    if (decoded.width <= maxDim && decoded.height <= maxDim) {
      return bytes;
    }

    final ratio = decoded.width > decoded.height
        ? maxDim / decoded.width
        : maxDim / decoded.height;

    final newWidth = (decoded.width * ratio).round();
    final newHeight = (decoded.height * ratio).round();

    final resized = img.copyResize(
      decoded,
      width: newWidth,
      height: newHeight,
      interpolation: img.Interpolation.linear,
    );

    return Uint8List.fromList(img.encodePng(resized));
  }
}
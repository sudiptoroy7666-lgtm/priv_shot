import 'dart:io';
import 'dart:typed_data';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';

class OcrEngine {
  final TextRecognizer _recognizer =
  TextRecognizer(script: TextRecognitionScript.latin);

  /// Processes image bytes and returns recognized text blocks.
  Future<List<TextBlock>> process(Uint8List bytes) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/privshot_ocr_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final tempFile = File(tempPath);

      // 🚨 CRITICAL FIX: flush: true ensures the file is 100% written to disk
      // before ML Kit attempts to read it.
      await tempFile.writeAsBytes(bytes, flush: true);

      final inputImage = InputImage.fromFilePath(tempPath);
      final recognized = await _recognizer.processImage(inputImage);

      // Clean up temp file
      try { await tempFile.delete(); } catch (_) {}

      return recognized.blocks;
    } catch (e) {
      print('OCR processing error: $e');
      return [];
    }
  }

  void dispose() {
    _recognizer.close();
  }
}
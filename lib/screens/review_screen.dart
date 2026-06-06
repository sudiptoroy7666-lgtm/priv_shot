import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:priv_shot/core/theme.dart';
import 'package:priv_shot/domain/pii_matcher.dart';
import 'package:priv_shot/domain/privacy_scorer.dart';
import 'package:priv_shot/domain/preset_manager.dart';
import 'package:priv_shot/models/redact_box.dart';
import 'package:priv_shot/models/review_state.dart';
import 'package:priv_shot/screens/result_screen.dart';
import 'package:priv_shot/services/bitmap_redactor.dart';
import 'package:priv_shot/services/image_service.dart';
import 'package:priv_shot/services/ocr_engine.dart';
import 'package:priv_shot/widgets/detection_chip.dart';
import 'package:priv_shot/widgets/preset_buttons.dart';
import 'package:priv_shot/widgets/privacy_score_card.dart';
import 'package:priv_shot/widgets/redact_canvas.dart';
import 'package:share_plus/share_plus.dart';

class ReviewScreen extends StatefulWidget {
  final Uint8List imageBytes;
  const ReviewScreen({super.key, required this.imageBytes});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final OcrEngine _ocrEngine = OcrEngine();
  final PiiMatcher _piiMatcher = PiiMatcher();
  final PrivacyScorer _scorer = PrivacyScorer();
  final PresetManager _presetManager = PresetManager();
  final ImageService _imageService = ImageService();
  final BitmapRedactor _redactor = BitmapRedactor();

  ReviewState _state = const ReviewState();

  @override
  void initState() {
    super.initState();
    _processImage(widget.imageBytes);
  }

  Future<void> _processImage(Uint8List bytes) async {
    _setState(_state.copyWith(isProcessing: true));
    try {
      final processed = await _imageService.downsampleIfNeeded(bytes);
      final image = await _imageService.decodeImage(processed);
      final blocks = await _ocrEngine.process(processed);

      print('🔍 ML Kit found ${blocks.length} text blocks.');
      final items = _piiMatcher.detectItems(blocks);
      final detectedBoxes = _piiMatcher.toRedactBoxes(items);

      print('🚨 PiiMatcher flagged ${detectedBoxes.length} sensitive items.');
      final score = _scorer.calculate(detectedBoxes);

      _setState(_state.copyWith(
        image: image,
        rawBytes: processed,
        detectedBoxes: detectedBoxes,
        privacyScore: score,
        isProcessing: false,
      ));
    } catch (e) {
      print('❌ ReviewScreen Error: $e');
      _setState(_state.copyWith(error: e.toString(), isProcessing: false));
    }
  }

  void _applyPreset(PresetMode mode) {
    if (mode == _state.activePreset) {
      _setState(_state.copyWith(
        activePreset: PresetMode.none,
        detectedBoxes: _state.detectedBoxes.map((b) => b.copyWith(shouldRedact: true)).toList(),
      ));
      return;
    }
    final filtered = _presetManager.apply(_state.detectedBoxes, mode);
    _setState(_state.copyWith(detectedBoxes: filtered, activePreset: mode));
  }

  void _addUserBox(Rect rect) {
    final newBox = RedactBox(
      rect: rect,
      label: 'User',
      confidence: 1.0,
      isAutoDetected: false,
      shouldRedact: true,
    );
    _setState(_state.copyWith(userBoxes: [..._state.userBoxes, newBox]));
  }

  void _dismissBox(RedactBox box) {
    if (box.isAutoDetected) {
      _setState(_state.copyWith(detectedBoxes: _state.detectedBoxes.where((b) => b.id != box.id).toList()));
    } else {
      _setState(_state.copyWith(userBoxes: _state.userBoxes.where((b) => b.id != box.id).toList()));
    }
  }

  void _toggleBox(RedactBox box) {
    final updated = box.copyWith(shouldRedact: !box.shouldRedact);
    if (box.isAutoDetected) {
      _setState(_state.copyWith(detectedBoxes: _state.detectedBoxes.map((b) => b.id == box.id ? updated : b).toList()));
    } else {
      _setState(_state.copyWith(userBoxes: _state.userBoxes.map((b) => b.id == box.id ? updated : b).toList()));
    }
  }

  Future<void> _exportAndShare() async {
    if (_state.rawBytes == null) return;
    _setState(_state.copyWith(isProcessing: true));
    try {
      final redactedBytes = await _redactor.redact(
        sourceBytes: _state.rawBytes!,
        boxes: _state.boxesToRedact,
      );

      final tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/privshot_clean_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(path);
      await file.writeAsBytes(redactedBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Shared via PrivShot - Metadata Stripped & Safe',
      );
      _setState(_state.copyWith(isProcessing: false));
    } catch (e) {
      _setState(_state.copyWith(error: e.toString(), isProcessing: false));
    }
  }

  void _setState(ReviewState newState) {
    if (mounted) setState(() => _state = newState);
  }

  @override
  void dispose() {
    _ocrEngine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_state.isProcessing) {
      return Scaffold(
        backgroundColor: AppTheme.bgDark,
        appBar: AppBar(title: const Text('Analyzing...')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: AppTheme.primary),
              const SizedBox(height: 16),
              Text('Scanning for sensitive info...', style: TextStyle(color: AppTheme.textSecondary)),
            ],
          ),
        ),
      );
    }

    if (_state.error != null) {
      return Scaffold(
        backgroundColor: AppTheme.bgDark,
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: AppTheme.accent),
                const SizedBox(height: 16),
                Text('Error: ${_state.error}', style: const TextStyle(color: AppTheme.textPrimary)),
                const SizedBox(height: 24),
                ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Go Back')),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text('Review & Redact'),
        actions: [
          IconButton(icon: const Icon(Icons.info_outline), onPressed: () => _showHelpDialog(context)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PrivacyScoreCard(score: _state.privacyScore),
            PresetButtons(activePreset: _state.activePreset, onPresetSelected: _applyPreset),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Text('Interactive Canvas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text('Use the toggle on the canvas to switch between Draw and Zoom modes.', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            ),
            const SizedBox(height: 12),

            if (_state.image != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: 450,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.15), blurRadius: 20, spreadRadius: 2)],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: RedactCanvas(
                    image: _state.image!,
                    boxes: _state.allBoxes,
                    onBoxDrawn: _addUserBox,
                    onBoxDismissed: _dismissBox,
                  ),
                ),
              ),
            const SizedBox(height: 24),

            if (_state.allBoxes.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text('Detected Items (${_state.boxesToRedact.length} to redact)', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: _state.allBoxes
                      .map((box) => DetectionChip(
                    box: box,
                    onToggle: () => _toggleBox(box),
                    onDelete: box.isAutoDetected ? null : () => _dismissBox(box),
                  ))
                      .toList(),
                ),
              ),
            ],

            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton.icon(
                onPressed: _state.boxesToRedact.isEmpty ? null : _exportAndShare,
                icon: const Icon(Icons.shield_outlined),
                label: const Text('Apply Redactions & Share'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: const Text('How to use PrivShot', style: TextStyle(color: AppTheme.textPrimary)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _helpItem('Red boxes = auto-detected PII'),
              _helpItem('Tap the ✕ button to ignore false positives'),
              _helpItem('Use the toggle to switch between Draw and Zoom modes'),
              _helpItem('Drag on the canvas to draw custom blue boxes'),
              _helpItem('Use presets for quick one-tap redaction'),
              _helpItem('Tap "Apply Redactions" to strip metadata and share'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Got it', style: TextStyle(color: AppTheme.primary))),
        ],
      ),
    );
  }

  Widget _helpItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, size: 18, color: AppTheme.success),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(color: AppTheme.textSecondary))),
        ],
      ),
    );
  }
}
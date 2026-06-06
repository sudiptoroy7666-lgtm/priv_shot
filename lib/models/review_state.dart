import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/painting.dart';
import 'package:priv_shot/models/redact_box.dart';
import 'package:priv_shot/models/privacy_score.dart';

enum PresetMode { none, socialMedia, financial, fullPrivacy }

class ReviewState {
  final ui.Image? image;
  final Uint8List? rawBytes;
  final List<RedactBox> detectedBoxes;
  final List<RedactBox> userBoxes;
  final PrivacyScore? privacyScore;
  final PresetMode activePreset;
  final bool isProcessing;
  final String? error;

  const ReviewState({
    this.image,
    this.rawBytes,
    this.detectedBoxes = const [],
    this.userBoxes = const [],
    this.privacyScore,
    this.activePreset = PresetMode.none,
    this.isProcessing = false,
    this.error,
  });

  List<RedactBox> get allBoxes => [...detectedBoxes, ...userBoxes];
  List<RedactBox> get boxesToRedact =>
      allBoxes.where((b) => b.shouldRedact).toList();
  Size? get imageSize =>
      image != null ? Size(image!.width.toDouble(), image!.height.toDouble()) : null;

  ReviewState copyWith({
    ui.Image? image,
    Uint8List? rawBytes,
    List<RedactBox>? detectedBoxes,
    List<RedactBox>? userBoxes,
    PrivacyScore? privacyScore,
    PresetMode? activePreset,
    bool? isProcessing,
    String? error,
  }) {
    return ReviewState(
      image: image ?? this.image,
      rawBytes: rawBytes ?? this.rawBytes,
      detectedBoxes: detectedBoxes ?? this.detectedBoxes,
      userBoxes: userBoxes ?? this.userBoxes,
      privacyScore: privacyScore ?? this.privacyScore,
      activePreset: activePreset ?? this.activePreset,
      isProcessing: isProcessing ?? this.isProcessing,
      error: error,
    );
  }
}
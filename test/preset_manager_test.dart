import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:priv_shot/domain/preset_manager.dart';
import 'package:priv_shot/models/redact_box.dart';
import 'package:priv_shot/models/review_state.dart';

void main() {
  group('PresetManager', () {
    final manager = PresetManager();

    RedactBox _box(String label, {bool shouldRedact = true}) => RedactBox(
      rect: const Rect.fromLTWH(0, 0, 100, 20),
      label: label,
      confidence: 1.0,
      isAutoDetected: true,
      shouldRedact: shouldRedact,
    );

    final testBoxes = [
      _box('Email'),
      _box('Phone'),
      _box('Street Address'),
      _box('Credit Card'),
      _box('Account Number'),
      _box('Verification Code'),
      _box('National ID'),
      _box('IP Address'),
    ];

    test('none mode leaves all unchanged', () {
      final result = manager.apply(testBoxes, PresetMode.none);
      expect(result.length, testBoxes.length);
      expect(result.every((b) => b.shouldRedact), isTrue);
    });

    test('socialMedia hides emails, phones, addresses', () {
      final result = manager.apply(testBoxes, PresetMode.socialMedia);
      final redacted = result.where((b) => b.shouldRedact).toList();
      expect(redacted.any((b) => b.label == 'Email'), isFalse);
      expect(redacted.any((b) => b.label == 'Phone'), isFalse);
      expect(redacted.any((b) => b.label == 'Street Address'), isFalse);
      expect(redacted.any((b) => b.label == 'Credit Card'), isTrue);
    });

    test('financial hides cards, accounts, OTP', () {
      final result = manager.apply(testBoxes, PresetMode.financial);
      final redacted = result.where((b) => b.shouldRedact).toList();
      expect(redacted.any((b) => b.label == 'Credit Card'), isFalse);
      expect(redacted.any((b) => b.label == 'Account Number'), isFalse);
      expect(redacted.any((b) => b.label == 'Verification Code'), isFalse);
      expect(redacted.any((b) => b.label == 'Email'), isTrue);
    });

    test('fullPrivacy hides everything', () {
      final result = manager.apply(testBoxes, PresetMode.fullPrivacy);
      final redacted = result.where((b) => b.shouldRedact).toList();
      expect(redacted.isEmpty, isTrue);
    });

    test('getModeLabel returns correct strings', () {
      expect(manager.getModeLabel(PresetMode.none), 'None');
      expect(manager.getModeLabel(PresetMode.socialMedia), 'Social Media');
      expect(manager.getModeLabel(PresetMode.financial), 'Financial');
      expect(manager.getModeLabel(PresetMode.fullPrivacy), 'Full Privacy');
    });

    test('preset preserves box structure', () {
      final result = manager.apply(testBoxes, PresetMode.socialMedia);
      expect(result.length, testBoxes.length);
      for (int i = 0; i < testBoxes.length; i++) {
        expect(result[i].label, testBoxes[i].label);
        expect(result[i].rect, testBoxes[i].rect);
      }
    });
  });
}
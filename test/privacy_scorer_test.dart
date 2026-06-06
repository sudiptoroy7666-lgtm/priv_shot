import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:priv_shot/domain/privacy_scorer.dart';
import 'package:priv_shot/models/redact_box.dart';

void main() {
  group('PrivacyScorer', () {
    final scorer = PrivacyScorer();

    RedactBox _box(String label) => RedactBox(
      rect: const Rect.fromLTWH(0, 0, 100, 20),
      label: label,
      confidence: 1.0,
      isAutoDetected: true,
    );

    test('empty list returns score 0', () {
      final score = scorer.calculate([]);
      expect(score.score, 0);
      expect(score.status, 'Low Risk');
      expect(score.breakdown.isEmpty, isTrue);
    });

    test('email adds 15 points', () {
      final score = scorer.calculate([_box('Email')]);
      expect(score.score, 2); // 15/10 rounded
    });

    test('phone adds 20 points', () {
      final score = scorer.calculate([_box('Phone')]);
      expect(score.score, 2); // 20/10
    });

    test('credit card adds 35 points', () {
      final score = scorer.calculate([_box('Credit Card')]);
      expect(score.score, 4); // 35/10 rounded
    });

    test('national ID adds 45 points', () {
      final score = scorer.calculate([_box('National ID')]);
      expect(score.score, 5); // 45/10 rounded
    });

    test('multiple items sum correctly', () {
      final score = scorer.calculate([
        _box('Email'),
        _box('Email'),
        _box('Phone'),
      ]);
      // 15+15+20 = 50, /10 = 5
      expect(score.score, 5);
    });

    test('breakdown is accurate', () {
      final score = scorer.calculate([
        _box('Email'),
        _box('Email'),
        _box('Phone'),
      ]);
      expect(score.breakdown['Email'], 2);
      expect(score.breakdown['Phone'], 1);
    });

    test('High Risk for score >= 60', () {
      final boxes = List.generate(5, (_) => _box('Credit Card'));
      final score = scorer.calculate(boxes);
      expect(score.status, 'High Risk');
    });

    test('Medium Risk for score between 25 and 59', () {
      final boxes = List.generate(3, (_) => _box('Credit Card'));
      final score = scorer.calculate(boxes);
      expect(score.status, 'Medium Risk');
    });

    test('Low Risk for score < 25', () {
      final score = scorer.calculate([_box('Email')]);
      expect(score.status, 'Low Risk');
    });

    test('score clamped at 100', () {
      final boxes = List.generate(20, (_) => _box('National ID'));
      final score = scorer.calculate(boxes);
      expect(score.score, 100);
    });

    test('totalItems is correct', () {
      final score = scorer.calculate([
        _box('Email'),
        _box('Phone'),
        _box('Credit Card'),
      ]);
      expect(score.totalItems, 3);
    });
  });
}
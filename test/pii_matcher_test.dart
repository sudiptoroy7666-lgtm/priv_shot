import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:priv_shot/domain/pii_matcher.dart';

void main() {
  group('PiiMatcher', () {
    final matcher = PiiMatcher();

    TextBlock _mockBlock(String text) {
      return TextBlock(
        text: text,
        recognizedLanguages: const [],
        boundingBox: const Rect.fromLTWH(0, 0, 100, 20),
        cornerPoints: const [],
        lines: [],
      );
    }

    // Email tests
    group('Email detection', () {
      test('detects valid email', () {
        final items = matcher.detectItems([_mockBlock('Contact me at john.doe@gmail.com today')]);
        expect(items.any((i) => i.type == 'Email'), isTrue);
      });

      test('detects email with subdomain', () {
        final items = matcher.detectItems([_mockBlock('user@mail.company.co.uk')]);
        expect(items.any((i) => i.type == 'Email'), isTrue);
      });

      test('rejects example.com', () {
        final items = matcher.detectItems([_mockBlock('test@example.com')]);
        expect(items.where((i) => i.type == 'Email').isEmpty, isTrue);
      });

      test('rejects test.com', () {
        final items = matcher.detectItems([_mockBlock('foo@test.com')]);
        expect(items.where((i) => i.type == 'Email').isEmpty, isTrue);
      });

      test('detects multiple emails in one block', () {
        final items = matcher.detectItems([_mockBlock('a@b.com and c@d.org')]);
        expect(items.where((i) => i.type == 'Email').length, 2);
      });
    });

    // Phone tests
    group('Phone detection', () {
      test('detects US phone', () {
        final items = matcher.detectItems([_mockBlock('Call 555-123-4567')]);
        expect(items.any((i) => i.type == 'Phone'), isTrue);
      });

      test('detects international format', () {
        final items = matcher.detectItems([_mockBlock('+1 (555) 123-4567')]);
        expect(items.any((i) => i.type == 'Phone'), isTrue);
      });

      test('rejects all-same-digit', () {
        final items = matcher.detectItems([_mockBlock('111-111-1111')]);
        expect(items.where((i) => i.type == 'Phone').isEmpty, isTrue);
      });

      test('rejects too short numbers', () {
        final items = matcher.detectItems([_mockBlock('123')]);
        expect(items.where((i) => i.type == 'Phone').isEmpty, isTrue);
      });
    });

    // Credit card tests
    group('Credit Card detection', () {
      test('detects valid Luhn card', () {
        final items = matcher.detectItems([_mockBlock('Card: 4111111111111111')]);
        expect(items.any((i) => i.type == 'Credit Card'), isTrue);
      });

      test('detects card with spaces', () {
        final items = matcher.detectItems([_mockBlock('4111 1111 1111 1111')]);
        expect(items.any((i) => i.type == 'Credit Card'), isTrue);
      });

      test('rejects invalid Luhn', () {
        final items = matcher.detectItems([_mockBlock('1234567890123456')]);
        expect(items.where((i) => i.type == 'Credit Card').isEmpty, isTrue);
      });

      test('rejects all-same-digit card', () {
        final items = matcher.detectItems([_mockBlock('1111111111111111')]);
        expect(items.where((i) => i.type == 'Credit Card').isEmpty, isTrue);
      });
    });

    // IP address tests
    group('IP address detection', () {
      test('detects public IP', () {
        final items = matcher.detectItems([_mockBlock('Server at 8.8.8.8')]);
        expect(items.any((i) => i.type == 'IP Address'), isTrue);
      });

      test('rejects private 192.168.x.x', () {
        final items = matcher.detectItems([_mockBlock('192.168.1.1')]);
        expect(items.where((i) => i.type == 'IP Address').isEmpty, isTrue);
      });

      test('rejects 127.0.0.1', () {
        final items = matcher.detectItems([_mockBlock('127.0.0.1')]);
        expect(items.where((i) => i.type == 'IP Address').isEmpty, isTrue);
      });

      test('rejects invalid octets', () {
        final items = matcher.detectItems([_mockBlock('999.999.999.999')]);
        expect(items.where((i) => i.type == 'IP Address').isEmpty, isTrue);
      });
    });

    // Address tests
    group('Street address detection', () {
      test('detects basic address', () {
        final items = matcher.detectItems([_mockBlock('123 Main St')]);
        expect(items.any((i) => i.type == 'Street Address'), isTrue);
      });

      test('detects address with avenue', () {
        final items = matcher.detectItems([_mockBlock('456 Park Avenue')]);
        expect(items.any((i) => i.type == 'Street Address'), isTrue);
      });
    });

    // Account number tests
    group('Account number detection', () {
      test('detects 10-digit account', () {
        final items = matcher.detectItems([_mockBlock('Account: 1234567890')]);
        expect(items.any((i) => i.type == 'Account Number'), isTrue);
      });
    });

    // OTP tests
    group('Verification code detection', () {
      test('detects OTP pattern', () {
        final items = matcher.detectItems([_mockBlock('Your OTP is 123456')]);
        expect(items.any((i) => i.type == 'Verification Code'), isTrue);
      });
    });

    // Edge cases
    group('Edge cases', () {
      test('empty block returns empty list', () {
        final items = matcher.detectItems([_mockBlock('')]);
        expect(items.isEmpty, isTrue);
      });

      test('text with no PII returns empty', () {
        final items = matcher.detectItems([_mockBlock('Hello world, today is sunny')]);
        expect(items.isEmpty, isTrue);
      });

      test('toRedactBoxes converts correctly', () {
        final items = matcher.detectItems([_mockBlock('john@gmail.com')]);
        final boxes = matcher.toRedactBoxes(items);
        expect(boxes.every((b) => b.isAutoDetected), isTrue);
        expect(boxes.every((b) => b.shouldRedact), isTrue);
      });
    });
  });
}
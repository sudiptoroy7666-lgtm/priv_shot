import 'package:flutter/painting.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:priv_shot/core/constants.dart';
import 'package:priv_shot/core/utils.dart';
import 'package:priv_shot/models/redact_box.dart';
import 'package:priv_shot/models/pii_item.dart';

class PiiMatcher {
  // 🚨 1. ULTRA-ROBUST EMAIL (Handles "gmail .com", "To:email", and cut-offs like "gmail.")
  // Allows optional spaces around @ and ., and allows the domain extension to be missing or cut off.
  static final _emailRegex = RegExp(
    r'[A-Za-z0-9._%+\-\[\]\(\)\{\}\|]+\s*@\s*[A-Za-z0-9.\-]+(?:\s*\.\s*[A-Za-z]*)?',
  );

  // 🚨 2. ULTRA-ROBUST DATE & TIME (Handles "Jun 4, 2026, 12:23 PM", newlines, and OCR typos)
  static final _dateTimeCombinedRegex = RegExp(
    r'\b(?:\d{4}[-/\.]\d{1,2}[-/\.]\d{1,2}|\d{1,2}[-/\.]\d{1,2}[-/\.]\d{2,4}|(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\.?\s+\d{1,2}[a-z]*,?\s+\d{2,4}|\d{1,2}[a-z]*\.?\s+(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\.?,?\s+\d{2,4})(?:[\s,\n]+(?:at\s+)?\d{1,2}:\d{2}(?::\d{2})?(?:\s?[APap][Mm])?)?',
    caseSensitive: false,
  );

  // 3. URLs & Links
  static final _urlRegex = RegExp(
    r'\b(?:https?:\/\/|www\.)[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,}(?:\/[^\s]*)?\b|(?:t\.me|wa\.me|bit\.ly|tinyurl\.com)\/[a-zA-Z0-9_\-]+',
    caseSensitive: false,
  );

  // 4. Crypto Wallets
  static final _cryptoRegex = RegExp(
    r'\b(?:0x[a-fA-F0-9]{40}|bc1[a-zA-HJ-NP-Z0-9]{25,87}|[13][a-km-zA-HJ-NP-Z1-9]{25,34}|T[a-zA-HJ-NP-Z0-9]{33})\b',
  );

  // 5. Credit Card
  static final _creditCardRegex = RegExp(
    r'\b(?:\d{4}[\s\-]?){3}\d{4}\b',
  );

  // 6. IBAN
  static final _ibanRegex = RegExp(
    r'\b[A-Z]{2}\d{2}[A-Z0-9]{11,30}\b',
  );

  // 7. Phone
  static final _phoneRegex = RegExp(
    r'(?<!\d)(\+?\d{1,3}[\s\-.]?)?\(?\d{2,4}\)?[\s\-.]?\d{3,4}[\s\-.]?\d{3,4}(?!\d)',
  );

  // 8. IP Address
  static final _ipRegex = RegExp(
    r'\b(?:\d{1,3}\.){3}\d{1,3}\b',
  );

  // 9. MAC Address
  static final _macRegex = RegExp(
    r'\b(?:[0-9A-Fa-f]{2}[:-]){5}(?:[0-9A-Fa-f]{2})\b',
  );

  // 10. Standalone Date (Fallback if not caught by combined)
  static final _dateRegex = RegExp(
    r'\b(?:\d{4}[-/.]\d{1,2}[-/.]\d{1,2}|\d{1,2}[-/.]\d{1,2}[-/.]\d{2,4}|\d{1,2}\.\d{1,2}\.\d{2,4}|(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]* \d{1,2}(?:st|nd|rd|th)?,?\s*\d{2,4}|\d{1,2}(?:st|nd|rd|th)? (?:of\s+)?(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*,?\s*\d{2,4})\b',
    caseSensitive: false,
  );

  // 11. Standalone Time
  static final _timeRegex = RegExp(
    r'\b\d{1,2}:\d{2}(?::\d{2})?(?:\s?[APap][Mm])?(?:\s?[A-Z]{2,4})?\b',
  );

  // 12. Street Address
  static final _addressRegex = RegExp(
    r'\b\d{1,5}\s+[\w\s]{2,}\s+(?:St|Street|Ave|Avenue|Rd|Road|Blvd|Boulevard|Lane|Ln|Dr|Drive|Ct|Court|Way|Pl|Place)\.?\b',
    caseSensitive: false,
  );

  // 13. National ID / Passport
  static final _nationalIdRegex = RegExp(
    r'\b[A-Z]{1,2}\d{6,9}\b',
  );

  // 14. Account Number
  static final _accountNumberRegex = RegExp(
    r'\b\d{9,18}\b',
  );

  // 15. OTP / Verification Code
  static final _otpRegex = RegExp(
    r'\b(?:OTP|code|pin|verify|verification)\D{0,10}\b(\d{4,6})\b|\b(\d{4,6})\b\D{0,10}(?:OTP|code|pin|verify|verification)',
    caseSensitive: false,
  );

  // 16. Usernames / Handles
  static final _handleRegex = RegExp(
    r'(?<!\w)@[a-zA-Z0-9_]{3,15}\b',
  );

  // 17. Flight PNR / Booking Reference
  static final _pnrRegex = RegExp(
    r'\b(?:PNR|Booking|Ticket|Flight|Reservation)\D{0,15}\b([A-Z0-9]{6})\b|\b([A-Z0-9]{6})\b\D{0,15}(?:PNR|Booking|Ticket|Flight|Reservation)',
    caseSensitive: false,
  );

  /// Detects PII items from recognized text blocks.
  List<PiiItem> detectItems(List<TextBlock> blocks) {
    final items = <PiiItem>[];

    for (final block in blocks) {
      final fullText = block.text;
      final box = block.boundingBox;
      if (box == null) continue;

      // 1. Combined Date & Time (Runs first to catch "Jun 4, 2026, 12:23 PM" as one block)
      for (final m in _dateTimeCombinedRegex.allMatches(fullText)) {
        items.add(PiiItem(text: m.group(0)!, type: 'Date & Time', boundingBox: _approximateMatchRect(box, fullText, m.start, m.end)));
      }

      // 2. Ultra-Robust Email
      for (final m in _emailRegex.allMatches(fullText)) {
        final email = m.group(0)!;
        if (_isValidEmail(email)) {
          items.add(PiiItem(text: email, type: 'Email', boundingBox: _approximateMatchRect(box, fullText, m.start, m.end)));
        }
      }

      // 3. URLs
      for (final m in _urlRegex.allMatches(fullText)) {
        items.add(PiiItem(text: m.group(0)!, type: 'URL / Link', boundingBox: _approximateMatchRect(box, fullText, m.start, m.end)));
      }

      // 4. Crypto
      for (final m in _cryptoRegex.allMatches(fullText)) {
        items.add(PiiItem(text: m.group(0)!, type: 'Crypto Wallet', boundingBox: _approximateMatchRect(box, fullText, m.start, m.end)));
      }

      // 5. Credit Card
      for (final m in _creditCardRegex.allMatches(fullText)) {
        final card = m.group(0)!;
        final digits = card.replaceAll(RegExp(r'\D'), '');
        if (digits.length >= 13 && digits.length <= 19 && Utils.isValidLuhn(digits) && !Utils.isAllSameDigit(digits)) {
          items.add(PiiItem(text: card, type: 'Credit Card', boundingBox: _approximateMatchRect(box, fullText, m.start, m.end)));
        }
      }

      // 6. IBAN
      for (final m in _ibanRegex.allMatches(fullText)) {
        items.add(PiiItem(text: m.group(0)!, type: 'IBAN', boundingBox: _approximateMatchRect(box, fullText, m.start, m.end)));
      }

      // 7. Phone
      for (final m in _phoneRegex.allMatches(fullText)) {
        final phone = m.group(0)!;
        final digits = phone.replaceAll(RegExp(r'\D'), '');
        if (digits.length >= 7 && digits.length <= 15 && !Utils.isAllSameDigit(digits)) {
          items.add(PiiItem(text: phone, type: 'Phone', boundingBox: _approximateMatchRect(box, fullText, m.start, m.end)));
        }
      }

      // 8. IP Address
      for (final m in _ipRegex.allMatches(fullText)) {
        final ip = m.group(0)!;
        if (_isValidPublicIp(ip)) {
          items.add(PiiItem(text: ip, type: 'IP Address', boundingBox: _approximateMatchRect(box, fullText, m.start, m.end)));
        }
      }

      // 9. MAC Address
      for (final m in _macRegex.allMatches(fullText)) {
        items.add(PiiItem(text: m.group(0)!, type: 'MAC Address', boundingBox: _approximateMatchRect(box, fullText, m.start, m.end)));
      }

      // 10. Standalone Date (Fallback)
      for (final m in _dateRegex.allMatches(fullText)) {
        items.add(PiiItem(text: m.group(0)!, type: 'Date', boundingBox: _approximateMatchRect(box, fullText, m.start, m.end)));
      }

      // 11. Standalone Time (Fallback)
      for (final m in _timeRegex.allMatches(fullText)) {
        items.add(PiiItem(text: m.group(0)!, type: 'Time', boundingBox: _approximateMatchRect(box, fullText, m.start, m.end)));
      }

      // 12. Street Address
      for (final m in _addressRegex.allMatches(fullText)) {
        items.add(PiiItem(text: m.group(0)!, type: 'Street Address', boundingBox: _approximateMatchRect(box, fullText, m.start, m.end)));
      }

      // 13. National ID / Passport
      for (final m in _nationalIdRegex.allMatches(fullText)) {
        final id = m.group(0)!;
        if (!_isAlreadyCovered(items, id)) {
          items.add(PiiItem(text: id, type: 'National ID', boundingBox: _approximateMatchRect(box, fullText, m.start, m.end)));
        }
      }

      // 14. Account Number
      for (final m in _accountNumberRegex.allMatches(fullText)) {
        final num = m.group(0)!;
        if (!_isAlreadyCovered(items, num)) {
          items.add(PiiItem(text: num, type: 'Account Number', boundingBox: _approximateMatchRect(box, fullText, m.start, m.end)));
        }
      }

      // 15. OTP / Verification Code
      final otpMatch = _otpRegex.firstMatch(fullText);
      if (otpMatch != null) {
        final code = otpMatch.group(1) ?? otpMatch.group(2);
        if (code != null) {
          final start = fullText.indexOf(code, otpMatch.start);
          final end = start + code.length;
          items.add(PiiItem(text: code, type: 'Verification Code', boundingBox: _approximateMatchRect(box, fullText, start, end)));
        }
      }

      // 16. Usernames / Handles
      for (final m in _handleRegex.allMatches(fullText)) {
        items.add(PiiItem(text: m.group(0)!, type: 'Username', boundingBox: _approximateMatchRect(box, fullText, m.start, m.end)));
      }

      // 17. Flight PNR / Booking Reference
      final pnrMatch = _pnrRegex.firstMatch(fullText);
      if (pnrMatch != null) {
        final code = pnrMatch.group(1) ?? pnrMatch.group(2);
        if (code != null) {
          final start = fullText.indexOf(code, pnrMatch.start);
          final end = start + code.length;
          items.add(PiiItem(text: code, type: 'Flight PNR', boundingBox: _approximateMatchRect(box, fullText, start, end)));
        }
      }
    }

    return _deduplicate(items);
  }

  List<RedactBox> toRedactBoxes(List<PiiItem> items) {
    return items.map((item) => RedactBox(
      rect: item.boundingBox, label: item.type, confidence: 1.0, isAutoDetected: true, shouldRedact: true,
    )).toList();
  }

  bool _isValidEmail(String email) {
    // Clean up OCR spaces for domain validation
    final cleanEmail = email.replaceAll(RegExp(r'\s+'), '');
    if (!cleanEmail.contains('@')) return false;

    final domain = cleanEmail.split('@').last.toLowerCase();
    for (final blocked in AppConstants.blockedEmailDomains) {
      if (domain == blocked || domain.endsWith('.$blocked')) return false;
    }
    return true;
  }

  bool _isValidPublicIp(String ip) {
    for (final prefix in AppConstants.privateIpPrefixes) {
      if (ip.startsWith(prefix)) return false;
    }
    final parts = ip.split('.');
    for (final part in parts) {
      final n = int.tryParse(part);
      if (n == null || n < 0 || n > 255) return false;
    }
    return true;
  }

  bool _isAlreadyCovered(List<PiiItem> items, String text) {
    return items.any((i) => i.text.contains(text) || text.contains(i.text));
  }

  Rect _approximateMatchRect(Rect blockRect, String fullText, int start, int end) {
    if (fullText.isEmpty) return blockRect;
    final ratio = (end - start) / fullText.length;
    final startRatio = start / fullText.length;
    return Rect.fromLTWH(
      blockRect.left + blockRect.width * startRatio, blockRect.top, blockRect.width * ratio, blockRect.height,
    );
  }

  /// Sorts by length descending to keep the LONGEST match (e.g. Combined Date/Time)
  /// and discard smaller overlapping matches.
  List<PiiItem> _deduplicate(List<PiiItem> items) {
    items.sort((a, b) => b.text.length.compareTo(a.text.length));

    final result = <PiiItem>[];
    for (final item in items) {
      final overlaps = result.where((r) => _rectsOverlap(r.boundingBox, item.boundingBox));
      if (overlaps.isEmpty) {
        result.add(item);
      }
    }
    return result;
  }

  bool _rectsOverlap(Rect a, Rect b) {
    return a.left < b.right && a.right > b.left && a.top < b.bottom && a.bottom > b.top;
  }
}
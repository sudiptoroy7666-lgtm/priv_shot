import 'package:priv_shot/core/utils.dart';
import 'package:priv_shot/models/privacy_score.dart';
import 'package:priv_shot/models/redact_box.dart';

class PrivacyScorer {
  static const Map<String, int> weights = {
    'Email': 15,
    'Phone': 20,
    'Credit Card': 35,
    'Account Number': 30,
    'Street Address': 25,
    'National ID': 45,
    'Passport': 45,
    'Verification Code': 40,
    'IP Address': 10,
    'Date': 10,
    'Time': 5,
    'Date & Time': 15,      // 🚨 NEW
    'URL / Link': 20,       // 🚨 NEW
    'Crypto Wallet': 40,    // 🚨 NEW
    'IBAN': 35,             // 🚨 NEW
    'MAC Address': 15,      // 🚨 NEW
    'Username': 10,         // 🚨 NEW
    'Flight PNR': 25,       // 🚨 NEW
    'User': 5,
  };

  PrivacyScore calculate(List<RedactBox> boxes) {
    if (boxes.isEmpty) return PrivacyScore.empty();

    int total = 0;
    final breakdown = <String, int>{};

    for (final box in boxes) {
      breakdown[box.label] = (breakdown[box.label] ?? 0) + 1;
      total += weights[box.label] ?? 10;
    }

    final score = Utils.clampInt((total / 10).round(), 0, 100);
    final status = Utils.scoreToStatus(score);

    return PrivacyScore(score: score, status: status, breakdown: breakdown);
  }
}
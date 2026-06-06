import 'dart:math';

class Utils {
  /// Checks Luhn algorithm validity for credit card numbers.
  static bool isValidLuhn(String digits) {
    final clean = digits.replaceAll(RegExp(r'\D'), '');
    if (clean.length < 13 || clean.length > 19) return false;

    int sum = 0;
    bool alternate = false;
    for (int i = clean.length - 1; i >= 0; i--) {
      int n = int.parse(clean[i]);
      if (alternate) {
        n *= 2;
        if (n > 9) n -= 9;
      }
      sum += n;
      alternate = !alternate;
    }
    return sum % 10 == 0;
  }

  /// Rejects numbers with all identical digits (e.g., 111-111-1111)
  static bool isAllSameDigit(String digits) {
    final clean = digits.replaceAll(RegExp(r'\D'), '');
    if (clean.isEmpty) return true;
    final first = clean[0];
    return clean.split('').every((d) => d == first);
  }

  /// Clamps a value between min and max.
  static int clampInt(int value, int min, int max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  /// Formats a privacy score as a readable label.
  static String scoreToStatus(int score) {
    if (score >= 60) return 'High Risk';
    if (score >= 25) return 'Medium Risk';
    return 'Low Risk';
  }

  /// Generates a random ID for temporary items.
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        Random().nextInt(1000).toString();
  }
}
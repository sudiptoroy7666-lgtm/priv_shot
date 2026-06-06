import 'package:priv_shot/models/redact_box.dart';
import 'package:priv_shot/models/review_state.dart';

class PresetManager {
  static const Map<PresetMode, List<String>> rules = {
    PresetMode.socialMedia: [
      'Email', 'Phone', 'Street Address', 'Username', 'URL / Link'
    ],
    PresetMode.financial: [
      'Credit Card', 'Account Number', 'Verification Code', 'IBAN', 'Crypto Wallet'
    ],
    PresetMode.fullPrivacy: [
      'Email', 'Phone', 'Credit Card', 'Account Number', 'Street Address',
      'National ID', 'Passport', 'Verification Code', 'IP Address',
      'Date', 'Time', 'Date & Time', 'URL / Link', 'Crypto Wallet',
      'IBAN', 'MAC Address', 'Username', 'Flight PNR', 'User',
    ],
  };

  List<RedactBox> apply(List<RedactBox> boxes, PresetMode mode) {
    if (mode == PresetMode.none) return boxes;
    final labelsToRedact = rules[mode] ?? [];
    return boxes.map((box) {
      final shouldRedact = labelsToRedact.contains(box.label);
      return box.copyWith(shouldRedact: shouldRedact);
    }).toList();
  }

  String getModeLabel(PresetMode mode) {
    switch (mode) {
      case PresetMode.socialMedia: return 'Social Media';
      case PresetMode.financial: return 'Financial';
      case PresetMode.fullPrivacy: return 'Full Privacy';
      case PresetMode.none: return 'None';
    }
  }
}
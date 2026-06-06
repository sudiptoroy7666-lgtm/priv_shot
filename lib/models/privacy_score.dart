
class PrivacyScore {
  final int score;
  final String status;
  final Map<String, int> breakdown;

  const PrivacyScore({
    required this.score,
    required this.status,
    required this.breakdown,
  });

  factory PrivacyScore.empty() => const PrivacyScore(
    score: 0,
    status: 'Low Risk',
    breakdown: {},
  );

  int get totalItems => breakdown.values.fold(0, (a, b) => a + b);

  @override
  String toString() =>
      'PrivacyScore(score: $score, status: $status, items: $totalItems)';
}
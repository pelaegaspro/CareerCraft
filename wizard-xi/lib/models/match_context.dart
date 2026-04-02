enum PitchType { batting, bowling, balanced }

class MatchContext {
  const MatchContext({
    required this.pitch,
    this.chasingTeam,
    required this.avgScore,
  });

  final PitchType pitch;
  final String? chasingTeam;
  final double avgScore;
}

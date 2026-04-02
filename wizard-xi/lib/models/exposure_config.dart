import 'fantasy_player.dart';

class ExposureConfig {
  const ExposureConfig({
    this.maxExposure = const {},
    this.defaultMaxExposurePercent = 80,
    this.captainLockIds = const {},
    this.captainAvoidIds = const {},
  });

  final Map<String, double> maxExposure;
  final double defaultMaxExposurePercent;
  final Set<String> captainLockIds;
  final Set<String> captainAvoidIds;

  double maxExposureFor(FantasyPlayer player) {
    return maxExposure[player.id] ??
        maxExposure[player.name] ??
        defaultMaxExposurePercent;
  }

  Map<String, dynamic> toMap() => {
        'maxExposure': maxExposure,
        'defaultMaxExposurePercent': defaultMaxExposurePercent,
        'captainLockIds': captainLockIds.toList(),
        'captainAvoidIds': captainAvoidIds.toList(),
      };

  factory ExposureConfig.fromMap(Map<String, dynamic> map) {
    final rawExposure = (map['maxExposure'] as Map<dynamic, dynamic>? ?? const {});

    return ExposureConfig(
      maxExposure: {
        for (final entry in rawExposure.entries)
          entry.key.toString(): _toDouble(entry.value) ?? 80,
      },
      defaultMaxExposurePercent:
          _toDouble(map['defaultMaxExposurePercent']) ?? 80,
      captainLockIds: _toStringSet(map['captainLockIds']),
      captainAvoidIds: _toStringSet(map['captainAvoidIds']),
    );
  }

  factory ExposureConfig.smartDefaults(List<FantasyPlayer> players) {
    final sorted = [...players]
      ..sort((a, b) => b.projectedScore.compareTo(a.projectedScore));

    final maxExposure = <String, double>{};
    for (var index = 0; index < sorted.length; index++) {
      final percentile = sorted.isEmpty ? 0 : index / sorted.length;
      if (percentile < 0.25) {
        maxExposure[sorted[index].id] = 75;
      } else if (percentile < 0.75) {
        maxExposure[sorted[index].id] = 60;
      } else {
        maxExposure[sorted[index].id] = 40;
      }
    }

    return ExposureConfig(
      maxExposure: maxExposure,
      defaultMaxExposurePercent: 60,
      captainLockIds: const {},
      captainAvoidIds: const {},
    );
  }

  factory ExposureConfig.fromPlayers({
    required List<FantasyPlayer> players,
    required double globalExposurePercent,
    Map<String, double> overrides = const {},
    Set<String> captainLockIds = const {},
    Set<String> captainAvoidIds = const {},
  }) {
    final defaults = ExposureConfig.smartDefaults(players);
    final cappedExposure = <String, double>{};

    for (final player in players) {
      final defaultExposure = defaults.maxExposureFor(player);
      final override = overrides[player.id] ?? overrides[player.name];
      final effectiveExposure = ((override ?? defaultExposure)
              .clamp(0.0, globalExposurePercent))
          .toDouble();
      cappedExposure[player.id] = effectiveExposure;
    }

    return ExposureConfig(
      maxExposure: cappedExposure,
      defaultMaxExposurePercent: globalExposurePercent,
      captainLockIds: captainLockIds,
      captainAvoidIds: captainAvoidIds,
    );
  }
}

double? _toDouble(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is double) {
    return value;
  }
  if (value is int) {
    return value.toDouble();
  }
  return double.tryParse(value.toString());
}

Set<String> _toStringSet(dynamic value) {
  if (value == null) return const {};
  if (value is List) {
    return value.map((e) => e.toString()).toSet();
  }
  return const {};
}

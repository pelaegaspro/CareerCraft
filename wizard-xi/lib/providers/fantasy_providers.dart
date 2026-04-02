import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../services/dream11_launcher.dart';
import '../services/team_generator.dart';
import 'app_providers.dart';

final teamGeneratorServiceProvider = Provider<TeamGeneratorService>(
  (ref) => TeamGeneratorService(),
);

final dream11LauncherProvider = Provider<Dream11Launcher>(
  (ref) => Dream11Launcher(),
);

final matchesProvider = FutureProvider<List<FantasyMatch>>((ref) async {
  return ref.watch(fantasyRepositoryProvider).getMatches();
});

final matchPlayersProvider = FutureProvider.family<List<FantasyPlayer>, String>(
  (ref, matchId) async {
    return ref.watch(fantasyRepositoryProvider).getPlayersForMatch(matchId);
  },
);

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_bootstrap.dart';
import '../core/env_config.dart';
import '../services/cric_api_repository.dart';
import '../services/fantasy_repository.dart';
import '../services/sportradar_repository.dart';
import '../services/team_service.dart';

final appBootstrapProvider = Provider<AppBootstrapState>(
  (ref) => throw UnimplementedError('Bootstrap state is injected from main().'),
);

/// Provider for fantasy cricket repository
/// Uses Sportradar for match discovery and CricAPI for players
/// Credentials loaded from EnvConfig (.env file)
final fantasyRepositoryProvider = Provider<FantasyRepository>((ref) {
  final sportradar = SportradarRepository(EnvConfig.premiumFeedApiKey);
  return HybridFantasyRepository(
    matchSource: sportradar,
    playerSource: CricApiRepository(EnvConfig.cricapiApiKey, sportradar),
  );
});

final teamServiceProvider = Provider<TeamService>((ref) => TeamService());

final myTeamsProvider = FutureProvider((ref) {
  return ref.read(teamServiceProvider).getMyTeams();
});

final sportradarRepositoryProvider = Provider<SportradarRepository>((ref) {
  return SportradarRepository(EnvConfig.premiumFeedApiKey);
});

final lineupAvailableProvider = FutureProvider.family<bool, String>((
  ref,
  matchId,
) async {
  final sportradar = ref.read(sportradarRepositoryProvider);
  final xi = await sportradar.getPlayingXI(matchId);
  return xi.isNotEmpty;
});

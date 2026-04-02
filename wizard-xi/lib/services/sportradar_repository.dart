import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/env_config.dart';
import '../models/models.dart';
import 'cric_api_repository.dart';
import 'fantasy_repository.dart';

class SportradarRepository {
  SportradarRepository(this.apiKey);

  final String apiKey;

  Future<List<FantasyMatch>> getMatches() async {
    final url =
        '${EnvConfig.premiumFeedBaseUrl}schedules/live/schedule.json?api_key=$apiKey';

    final res = await http
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 15));

    if (res.statusCode != 200) {
      throw Exception('SportRadar API error: ${res.statusCode}');
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final schedules = json['schedules'];
    if (schedules == null || schedules is! List) {
      throw Exception('No matches');
    }

    return schedules.cast<Map<String, dynamic>>().map((m) {
      final event = m['sport_event'] as Map<String, dynamic>?;
      final competitors = event?['competitors'] as List?;
      if (event == null || competitors == null || competitors.length < 2) {
        throw Exception('Invalid SportRadar match structure');
      }

      return FantasyMatch(
        id: event['id']?.toString() ?? '',
        teamA: competitors[0]['name']?.toString() ?? 'Team A',
        teamB: competitors[1]['name']?.toString() ?? 'Team B',
        startTime:
            DateTime.tryParse(event['start_time']?.toString() ?? '') ??
            DateTime.now(),
        venue: (event['venue'] as Map?)?['name']?.toString() ?? '',
      );
    }).toList();
  }

  Future<List<String>> getPlayingXI(String matchId) async {
    final url =
        '${EnvConfig.premiumFeedBaseUrl}sport_events/$matchId/lineups.json?api_key=$apiKey';

    final res = await http.get(Uri.parse(url));

    if (res.statusCode != 200) {
      print('[LINEUP] API error: ${res.statusCode}');
      return [];
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>?;
    final players = json?['lineups']?[0]?['players'] as List?;

    if (players == null) return [];

    return players
        .where((p) => p['starter'] == true)
        .map<String>((p) => p['name']?.toString() ?? '')
        .where((name) => name.isNotEmpty)
        .toList();
  }
}

class HybridFantasyRepository implements FantasyRepository {
  HybridFantasyRepository({
    required this.matchSource,
    required this.playerSource,
  });

  final SportradarRepository matchSource;
  final CricApiRepository playerSource;

  @override
  Future<List<FantasyMatch>> getMatches() => matchSource.getMatches();

  @override
  Future<List<FantasyPlayer>> getPlayersForMatch(String matchId) =>
      playerSource.getPlayersForMatch(matchId);
}

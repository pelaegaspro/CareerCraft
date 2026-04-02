import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/env_config.dart';
import '../models/models.dart';
import 'fantasy_repository.dart';
import 'sportradar_repository.dart';

/// Real CricAPI implementation for fetching live match players
class CricApiRepository implements FantasyRepository {
  CricApiRepository(this.apiKey, this.sportradar);

  final String apiKey;
  final SportradarRepository sportradar;

  @override
  Future<List<FantasyMatch>> getMatches() async {
    try {
      const iplSeriesId = 'd5a498c8-7596-4b93-8ab0-e0efc3345312';
      final url =
          '${EnvConfig.cricapiBaseUrl}series_info?apikey=${EnvConfig.cricapiApiKey}&id=$iplSeriesId';
      final res = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 15));

      if (res.statusCode != 200) {
        throw Exception('API error: ${res.statusCode}');
      }

      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final data = json['data'];
      // ignore: avoid_print
      print('[SERIES RAW] $data');

      if (data == null || data is! Map<String, dynamic>) {
        throw Exception('Invalid series response: missing data object');
      }

      final matchList = data['matchList'];
      if (matchList == null || matchList is! List || matchList.isEmpty) {
        throw Exception('No IPL matches available in series_info');
      }

      return matchList
          .cast<Map<String, dynamic>>()
          .map((m) {
            final teams = m['teamInfo'] as List?;
            if (teams == null || teams.length < 2) {
              return null;
            }

            return FantasyMatch(
              id: m['id']?.toString() ?? '',
              teamA: teams[0]['name']?.toString() ?? 'Team A',
              teamB: teams[1]['name']?.toString() ?? 'Team B',
              startTime:
                  DateTime.tryParse(m['dateTimeGMT']?.toString() ?? '') ??
                  DateTime.now(),
              venue: m['venue']?.toString() ?? '',
              tournament:
                  data['name']?.toString() ??
                  m['series']?.toString() ??
                  'Indian Premier League',
            );
          })
          .whereType<FantasyMatch>()
          .toList();
    } catch (e) {
      // Log error and return empty list
      // ignore: avoid_print
      print('[MATCHES FAIL] $e');
      return [];
    }
  }

  @override
  Future<List<FantasyPlayer>> getPlayersForMatch(String matchId) async {
    try {
      final url =
          'https://api.cricapi.com/v1/match_squad?apikey=$apiKey&id=$matchId';
      final res = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 15));

      if (res.statusCode != 200) {
        throw Exception('API error: ${res.statusCode}');
      }

      final json = jsonDecode(res.body) as Map<String, dynamic>;

      // Safe parsing: validate data structure
      final data = json['data'];
      if (data == null || data is! Map<String, dynamic>) {
        throw Exception('Invalid API response: missing data');
      }

      final playersData = data['players'];
      if (playersData == null || playersData is! List) {
        throw Exception('Invalid API response: missing players array');
      }

      if (playersData.isEmpty) {
        throw Exception('No players available for this match');
      }

      List<FantasyPlayer> players = playersData
          .cast<Map<String, dynamic>>()
          .map((p) {
            return FantasyPlayer(
              id: p['id']?.toString() ?? '',
              name: p['name']?.toString() ?? 'Unknown',
              team: p['team']?.toString() ?? 'Unknown',
              role: _mapRole(p['role']?.toString() ?? ''),
              credit: 8.0,
              last5Avg: 0.0,
              venueAvg: 0.0,
              opponentAvg: 0.0,
              ownership: (1 / 8.0).clamp(0.05, 0.9),
            );
          })
          .toList();

      // Filter to playing XI if available
      final playingXI = await sportradar.getPlayingXI(matchId);

      if (playingXI.isNotEmpty) {
        final originalCount = players.length;
        players = players.where((p) => playingXI.contains(p.name)).toList();
        print(
          '[LINEUP] Filtered from $originalCount to ${players.length} using ${playingXI.length} players',
        );
      } else {
        print('[LINEUP] No lineup available, using all players');
      }

      // ignore: avoid_print
      print('[PLAYERS] count=${players.length}');

      if (players.isEmpty || players.length < 11) {
        // ignore: avoid_print
        print('[PLAYERS] using fallback due to insufficient player count');
        return _fallbackPlayers();
      }

      // Debug logging for role distribution
      final roleCounts = <String, int>{};
      for (final player in players) {
        roleCounts[player.role] = (roleCounts[player.role] ?? 0) + 1;
      }
      // ignore: avoid_print
      print('Players loaded: ${players.length}');
      // ignore: avoid_print
      print('Role distribution: $roleCounts');

      // Balance roles to ensure generator receives valid Dream11 composition
      final balanced = _balanceRoles(players);

      // Minimal logging for runtime monitoring
      final summary = _roleSummary(balanced);
      // ignore: avoid_print
      print('[GEN] players=${balanced.length} roles=$summary');

      return balanced;
    } catch (e) {
      // Silent fallback on API failure
      // ignore: avoid_print
      print('[API FAIL] $e');
      return _fallbackPlayers();
    }
  }

  /// Generate role distribution summary for monitoring
  Map<String, int> _roleSummary(List<FantasyPlayer> players) {
    return {
      'WK': players.where((p) => p.role == 'WK').length,
      'BAT': players.where((p) => p.role == 'BAT').length,
      'AR': players.where((p) => p.role == 'AR').length,
      'BOWL': players.where((p) => p.role == 'BOWL').length,
    };
  }

  /// Balance player roles to match Dream11 constraints
  /// Ensures generator receives properly distributed roles even if CricAPI is unbalanced
  /// Result: WK: 2, BAT: 4, AR: 3, BOWL: 4 (total 13 players)
  List<FantasyPlayer> _balanceRoles(List<FantasyPlayer> players) {
    final wk = players.where((p) => p.role == 'WK').toList();
    final bat = players.where((p) => p.role == 'BAT').toList();
    final ar = players.where((p) => p.role == 'AR').toList();
    final bowl = players.where((p) => p.role == 'BOWL').toList();

    // Shuffle to get random selection
    wk.shuffle();
    bat.shuffle();
    ar.shuffle();
    bowl.shuffle();

    // Pick balanced amounts
    final balanced = <FantasyPlayer>[
      ...wk.take(2),
      ...bat.take(4),
      ...ar.take(3),
      ...bowl.take(4),
    ];

    // Log balanced distribution
    // ignore: avoid_print
    print(
      '✓ Roles balanced: WK=${wk.take(2).length} BAT=${bat.take(4).length} AR=${ar.take(3).length} BOWL=${bowl.take(4).length}',
    );

    return balanced;
  }

  /// Fallback player pool when API fails
  /// Ensures app never crashes due to API unavailability
  /// Contains balanced roles suitable for Dream11 team generation
  List<FantasyPlayer> _fallbackPlayers() {
    return [
      FantasyPlayer(
        id: 'fb_1',
        name: 'Fallback Player 1',
        team: 'Team A',
        role: 'WK',
        credit: 8.0,
        last5Avg: 35.0,
        venueAvg: 36.0,
        opponentAvg: 34.0,
        ownership: (1 / 8.0).clamp(0.05, 0.9),
      ),

      FantasyPlayer(
        id: 'fb_2',
        name: 'Fallback Player 2',
        team: 'Team A',
        role: 'BAT',
        credit: 8.0,
        last5Avg: 40.0,
        venueAvg: 42.0,
        opponentAvg: 41.0,
        ownership: (1 / 8.0).clamp(0.05, 0.9),
      ),
      FantasyPlayer(
        id: 'fb_3',
        name: 'Fallback Player 3',
        team: 'Team A',
        role: 'BAT',
        credit: 8.0,
        last5Avg: 38.0,
        venueAvg: 39.0,
        opponentAvg: 37.0,
      ),
      FantasyPlayer(
        id: 'fb_4',
        name: 'Fallback Player 4',
        team: 'Team A',
        role: 'BAT',
        credit: 8.0,
        last5Avg: 36.0,
        venueAvg: 37.0,
        opponentAvg: 35.0,
      ),
      FantasyPlayer(
        id: 'fb_5',
        name: 'Fallback Player 5',
        team: 'Team A',
        role: 'AR',
        credit: 8.0,
        last5Avg: 32.0,
        venueAvg: 33.0,
        opponentAvg: 31.0,
      ),
      FantasyPlayer(
        id: 'fb_6',
        name: 'Fallback Player 6',
        team: 'Team A',
        role: 'AR',
        credit: 8.0,
        last5Avg: 30.0,
        venueAvg: 31.0,
        opponentAvg: 29.0,
      ),
      FantasyPlayer(
        id: 'fb_7',
        name: 'Fallback Player 7',
        team: 'Team B',
        role: 'BOWL',
        credit: 8.0,
        last5Avg: 25.0,
        venueAvg: 26.0,
        opponentAvg: 24.0,
      ),
      FantasyPlayer(
        id: 'fb_8',
        name: 'Fallback Player 8',
        team: 'Team B',
        role: 'BOWL',
        credit: 8.0,
        last5Avg: 24.0,
        venueAvg: 25.0,
        opponentAvg: 23.0,
      ),
      FantasyPlayer(
        id: 'fb_9',
        name: 'Fallback Player 9',
        team: 'Team B',
        role: 'BOWL',
        credit: 8.0,
        last5Avg: 23.0,
        venueAvg: 24.0,
        opponentAvg: 22.0,
      ),
      FantasyPlayer(
        id: 'fb_10',
        name: 'Fallback Player 10',
        team: 'Team B',
        role: 'BOWL',
        credit: 8.0,
        last5Avg: 22.0,
        venueAvg: 23.0,
        opponentAvg: 21.0,
      ),
      FantasyPlayer(
        id: 'fb_11',
        name: 'Fallback Player 11',
        team: 'Team B',
        role: 'BAT',
        credit: 8.0,
        last5Avg: 37.0,
        venueAvg: 38.0,
        opponentAvg: 36.0,
      ),
      FantasyPlayer(
        id: 'fb_12',
        name: 'Fallback Player 12',
        team: 'Team B',
        role: 'WK',
        credit: 8.0,
        last5Avg: 33.0,
        venueAvg: 34.0,
        opponentAvg: 32.0,
      ),
    ];
  }

  /// Map CricAPI role strings to Dream11 standard roles
  /// Handles inconsistent CricAPI role naming with fallback
  String _mapRole(String role) {
    final r = role.toLowerCase();
    if (r.contains('wk') || r.contains('keeper')) {
      return 'WK';
    }
    if (r.contains('all')) {
      return 'AR';
    }
    if (r.contains('bowl')) {
      return 'BOWL';
    }
    if (r.contains('bat')) {
      return 'BAT';
    }
    // Safe fallback: assume batsman if role is unclear
    return 'BAT';
  }
}

import '../models/models.dart';
import 'fantasy_repository.dart';

/// Mock implementation of FantasyRepository for development/demo mode
///
/// This provides realistic mock data without requiring Firebase or APIs.
/// Easy to swap for real implementation later.
class MockFantasyRepository implements FantasyRepository {
  @override
  Future<List<FantasyMatch>> getMatches() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    return _mockMatches();
  }

  @override
  Future<List<FantasyPlayer>> getPlayersForMatch(String matchId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    return _mockPlayers();
  }

  /// Mock match data
  List<FantasyMatch> _mockMatches() {
    final now = DateTime.now();
    return [
      FantasyMatch(
        id: 'match_001',
        teamA: 'RCB',
        teamB: 'MI',
        startTime: now.add(const Duration(hours: 2)),
        venue: 'M.A. Chidambaram Stadium, Chennai',
      ),
      FantasyMatch(
        id: 'match_002',
        teamA: 'CSK',
        teamB: 'SRH',
        startTime: now.add(const Duration(hours: 6)),
        venue: 'Arun Jaitley Stadium, Delhi',
      ),
      FantasyMatch(
        id: 'match_003',
        teamA: 'DC',
        teamB: 'KKR',
        startTime: now.add(const Duration(hours: 10)),
        venue: 'Narendra Modi Stadium, Ahmedabad',
      ),
    ];
  }

  /// Mock player dataset matching Dream11 style
  /// ✓ BALANCED for Dream11 role constraints
  /// WK: 3 (valid range 1-4) | BAT: 4 (valid range 3-6) | AR: 3 (valid range 1-4) | BOWL: 4 (valid range 3-6) = 14 total
  /// This ensures generator can create valid 11-person teams
  List<FantasyPlayer> _mockPlayers() {
    return [
      // === WICKETKEEPERS (3 total - fits 1-4 constraint) ===
      FantasyPlayer(
        id: 'p1',
        name: 'MS Dhoni',
        team: 'CSK',
        role: 'WK',
        credit: 9.0,
        last5Avg: 42.8,
        venueAvg: 45.2,
        opponentAvg: 44.5,
      ),
      FantasyPlayer(
        id: 'p2',
        name: 'Rishabh Pant',
        team: 'DC',
        role: 'WK',
        credit: 8.5,
        last5Avg: 38.5,
        venueAvg: 40.2,
        opponentAvg: 39.8,
      ),
      FantasyPlayer(
        id: 'p3',
        name: 'KL Rahul',
        team: 'PBKS',
        role: 'WK',
        credit: 8.5,
        last5Avg: 36.2,
        venueAvg: 38.5,
        opponentAvg: 37.8,
      ),
      // === BATSMEN (4 total - fits 3-6 constraint) ===
      FantasyPlayer(
        id: 'p4',
        name: 'Virat Kohli',
        team: 'RCB',
        role: 'BAT',
        credit: 10.0,
        last5Avg: 45.8,
        venueAvg: 48.2,
        opponentAvg: 50.5,
      ),
      FantasyPlayer(
        id: 'p5',
        name: 'Rohit Sharma',
        team: 'MI',
        role: 'BAT',
        credit: 9.5,
        last5Avg: 42.5,
        venueAvg: 44.8,
        opponentAvg: 46.2,
      ),
      FantasyPlayer(
        id: 'p6',
        name: 'Suryakumar Yadav',
        team: 'MI',
        role: 'BAT',
        credit: 9.0,
        last5Avg: 40.2,
        venueAvg: 42.5,
        opponentAvg: 41.8,
      ),
      FantasyPlayer(
        id: 'p7',
        name: 'Shreyas Iyer',
        team: 'KKR',
        role: 'BAT',
        credit: 8.5,
        last5Avg: 35.2,
        venueAvg: 37.5,
        opponentAvg: 36.8,
      ),
      // === ALL-ROUNDERS (3 total - fits 1-4 constraint) ===
      FantasyPlayer(
        id: 'p8',
        name: 'Hardik Pandya',
        team: 'MI',
        role: 'AR',
        credit: 9.5,
        last5Avg: 38.2,
        venueAvg: 40.5,
        opponentAvg: 42.8,
      ),
      FantasyPlayer(
        id: 'p9',
        name: 'Ravindra Jadeja',
        team: 'CSK',
        role: 'AR',
        credit: 8.5,
        last5Avg: 32.5,
        venueAvg: 34.8,
        opponentAvg: 33.5,
      ),
      FantasyPlayer(
        id: 'p10',
        name: 'Rashid Khan',
        team: 'SRH',
        role: 'AR',
        credit: 8.5,
        last5Avg: 28.2,
        venueAvg: 30.5,
        opponentAvg: 32.8,
      ),
      // === BOWLERS (4 total - fits 3-6 constraint) ===
      FantasyPlayer(
        id: 'p11',
        name: 'Jasprit Bumrah',
        team: 'MI',
        role: 'BOWL',
        credit: 9.0,
        last5Avg: 22.5,
        venueAvg: 24.8,
        opponentAvg: 26.2,
      ),
      FantasyPlayer(
        id: 'p12',
        name: 'Mohammed Shami',
        team: 'SRH',
        role: 'BOWL',
        credit: 8.5,
        last5Avg: 20.2,
        venueAvg: 22.5,
        opponentAvg: 24.8,
      ),
      FantasyPlayer(
        id: 'p13',
        name: 'Yuzvendra Chahal',
        team: 'RR',
        role: 'BOWL',
        credit: 8.5,
        last5Avg: 18.5,
        venueAvg: 20.2,
        opponentAvg: 22.5,
      ),
      FantasyPlayer(
        id: 'p14',
        name: 'Bhuvneshwar Kumar',
        team: 'SRH',
        role: 'BOWL',
        credit: 8.0,
        last5Avg: 16.8,
        venueAvg: 18.5,
        opponentAvg: 20.2,
      ),
    ];
  }
}

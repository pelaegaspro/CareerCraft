// Example service: SportRadar Premium Feed integration
import '../core/env_config.dart';

/// Example of how to use SportRadar Premium Feed configuration in your services
class SportRadarPremiumService {
  final String baseUrl;
  final String apiKey;

  SportRadarPremiumService({required this.baseUrl, required this.apiKey});

  /// Factory constructor that uses environment config
  factory SportRadarPremiumService.fromEnv() {
    return SportRadarPremiumService(
      baseUrl: EnvConfig.premiumFeedBaseUrl,
      apiKey: EnvConfig.premiumFeedApiKey,
    );
  }

  /// Example method to fetch live match data
  Future<Map<String, dynamic>> fetchLiveMatches() async {
    final url = Uri.parse(
      '${baseUrl}matches/live',
    ).replace(queryParameters: {'api_key': apiKey});

    try {
      // TODO: Implement actual HTTP request
      // final response = await http.get(url);
      // return jsonDecode(response.body);
      return {};
    } catch (e) {
      throw Exception('Failed to fetch live matches: $e');
    }
  }

  /// Example method to fetch match statistics
  Future<Map<String, dynamic>> fetchMatchStats(String matchId) async {
    final url = Uri.parse(
      '${baseUrl}matches/$matchId/statistics',
    ).replace(queryParameters: {'api_key': apiKey});

    try {
      // TODO: Implement actual HTTP request
      // final response = await http.get(url);
      // return jsonDecode(response.body);
      return {};
    } catch (e) {
      throw Exception('Failed to fetch match stats: $e');
    }
  }
}

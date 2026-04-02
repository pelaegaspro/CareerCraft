// Example service: CricAPI integration
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/env_config.dart';

/// Example of how to use CricAPI configuration in your services
class CricAPIService {
  final String baseUrl;
  final String apiKey;

  CricAPIService({required this.baseUrl, required this.apiKey});

  /// Factory constructor that uses environment config
  factory CricAPIService.fromEnv() {
    return CricAPIService(
      baseUrl: EnvConfig.cricapiBaseUrl,
      apiKey: EnvConfig.cricapiApiKey,
    );
  }

  /// Example method using the configured API
  Future<Map<String, dynamic>> fetchMatches() async {
    final url = Uri.parse(
      '$baseUrl/matches',
    ).replace(queryParameters: {'apikey': apiKey});

    try {
      // TODO: Implement actual HTTP request
      // final response = await http.get(url);
      // return jsonDecode(response.body);
      return {};
    } catch (e) {
      throw Exception('Failed to fetch matches: $e');
    }
  }
}

/// Riverpod provider for CricAPI service
final cricApiServiceProvider = Provider<CricAPIService>((ref) {
  return CricAPIService.fromEnv();
});

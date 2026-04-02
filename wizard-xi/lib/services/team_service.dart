import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/generated_team.dart';

class TeamService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> saveTeam(GeneratedTeam team) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('Not logged in');
    }

    await _client.from('teams').insert({
      'user_id': user.id,
      'team_data': team.toMap(),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getMyTeams() async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not logged in');

    final res = await _client
        .from('teams')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(res);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';

class MyTeamsScreen extends ConsumerWidget {
  const MyTeamsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamsAsync = ref.watch(myTeamsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Teams')),
      body: teamsAsync.when(
        data: (teams) => ListView.builder(
          itemCount: teams.length,
          itemBuilder: (context, i) {
            final t = teams[i];
            return ListTile(
              title: Text('Team ${i + 1}'),
              subtitle: Text(t['created_at']),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }
}

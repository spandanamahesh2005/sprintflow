import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_state.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaders = ref.watch(appControllerProvider).leaderboard;

    return Scaffold(
      appBar: AppBar(title: const Text('Global Leaderboard')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: leaders.length,
        itemBuilder: (context, index) {
          final leader = leaders[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(child: Text('#${leader['rank']}')),
              title: Text(leader['name'].toString()),
              subtitle: Text(leader['badge'].toString()),
              trailing: Text('XP ${leader['xp']} • Lvl ${leader['level']}'),
            ),
          );
        },
      ),
    );
  }
}

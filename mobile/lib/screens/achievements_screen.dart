import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_state.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final app = ref.watch(appControllerProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Text('Achievements', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        ...app.achievements.map(
          (achievement) => Card(
            child: ListTile(
              leading: Icon(achievement.unlocked ? Icons.lock_open : Icons.lock_outline),
              title: Text(achievement.title),
              subtitle: Text(achievement.description),
              trailing: Text(achievement.unlocked ? 'Unlocked' : 'Locked'),
            ),
          ),
        ),
      ],
    );
  }
}

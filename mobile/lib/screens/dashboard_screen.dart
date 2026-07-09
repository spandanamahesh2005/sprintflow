import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_state.dart';
import 'leaderboard_screen.dart';
import 'project_detail_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final app = ref.watch(appControllerProvider);

    final projects = app.projects;
    final width = MediaQuery.sizeOf(context).width;
    final metricsColumns = width >= 1024 ? 3 : (width >= 700 ? 2 : 1);

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(authControllerProvider).refreshProfile();
        await ref.read(appControllerProvider).bootstrap();
      },
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: width >= 900 ? 24 : 16, vertical: 16),
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Welcome back, ${auth.user?.name ?? 'Recruit'}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const LeaderboardScreen()));
                },
                icon: const Icon(Icons.emoji_events_outlined),
                tooltip: 'Leaderboard',
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: metricsColumns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: width >= 1024 ? 2.6 : (width >= 700 ? 2.2 : 2.6),
            children: <Widget>[
              _MetricCard(label: 'Current Level', value: '${auth.user?.level ?? 1}', sub: '${auth.user?.xp ?? 0} XP'),
              _MetricCard(label: 'Active Projects', value: '${projects.length}', sub: 'Total projects'),
              _MetricCard(label: 'Achievements', value: '${auth.user?.badges.length ?? 0}', sub: 'Badges earned'),
            ],
          ),
          const SizedBox(height: 16),
          Text('Active Projects', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (projects.isEmpty)
            const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('No projects yet. Create one from Projects tab.')))
          else
            ...projects.take(3).map(
              (project) => Card(
                child: ListTile(
                  title: Text(project.name),
                  subtitle: Text('Sprint ${project.currentSprintNumber} • ${project.description.isEmpty ? 'No description' : project.description}'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => ProjectDetailScreen(projectId: project.id)),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value, required this.sub});

  final String label;
  final String value;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 6),
            Text(value, style: Theme.of(context).textTheme.headlineMedium),
            Text(sub, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

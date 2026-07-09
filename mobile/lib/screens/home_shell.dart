import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_state.dart';
import 'achievements_screen.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';
import 'projects_screen.dart';
import 'settings_screen.dart';
import 'team_screen.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  static const List<(IconData, IconData, String)> _destinations = <(IconData, IconData, String)>[
    (Icons.dashboard_outlined, Icons.dashboard, 'Overview'),
    (Icons.view_kanban_outlined, Icons.view_kanban, 'Projects'),
    (Icons.group_outlined, Icons.group, 'Team'),
    (Icons.emoji_events_outlined, Icons.emoji_events, 'Achievements'),
    (Icons.settings_outlined, Icons.settings, 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final width = MediaQuery.sizeOf(context).width;
    final useRail = width >= 900;

    final screens = <Widget>[
      const DashboardScreen(),
      const ProjectsScreen(),
      const TeamScreen(),
      const AchievementsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agile Sprint Master'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Logout',
            onPressed: () async {
              await ref.read(authControllerProvider).logout();
              if (!mounted) {
                return;
              }
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: useRail
          ? Row(
              children: <Widget>[
                NavigationRail(
                  selectedIndex: _index,
                  onDestinationSelected: (value) => setState(() => _index = value),
                  labelType: NavigationRailLabelType.all,
                  destinations: _destinations
                      .map(
                        (d) => NavigationRailDestination(
                          icon: Icon(d.$1),
                          selectedIcon: Icon(d.$2),
                          label: Text(d.$3),
                        ),
                      )
                      .toList(),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: IndexedStack(index: _index, children: screens)),
              ],
            )
          : IndexedStack(index: _index, children: screens),
      bottomNavigationBar: useRail
          ? null
          : NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (value) => setState(() => _index = value),
              destinations: _destinations
                  .map(
                    (d) => NavigationDestination(
                      icon: Icon(d.$1),
                      selectedIcon: Icon(d.$2),
                      label: d.$3,
                    ),
                  )
                  .toList(),
            ),
      floatingActionButton: auth.user == null
          ? null
          : FloatingActionButton.extended(
              onPressed: null,
              label: Text('Lvl ${auth.user!.level} • ${auth.user!.xp} XP'),
              icon: const Icon(Icons.trending_up),
            ),
      floatingActionButtonLocation: useRail
          ? FloatingActionButtonLocation.endFloat
          : FloatingActionButtonLocation.centerFloat,
    );
  }
}

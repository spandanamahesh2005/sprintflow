import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agile_sprint_sim_mobile/models/task_model.dart';
import 'package:agile_sprint_sim_mobile/providers/app_state.dart';
import 'package:agile_sprint_sim_mobile/screens/sprint_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('sprint screen step advances day and updates board', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: _SeededSprintHost(),
        ),
      ),
    );

    expect(find.textContaining('Day 0/5'), findsOneWidget);

    await tester.tap(find.byTooltip('Step'));
    await tester.pump();

    expect(find.textContaining('Day 1/5'), findsOneWidget);
    expect(find.textContaining('Sprint Board'), findsOneWidget);
  });
}

class _SeededSprintHost extends ConsumerStatefulWidget {
  const _SeededSprintHost();

  @override
  ConsumerState<_SeededSprintHost> createState() => _SeededSprintHostState();
}

class _SeededSprintHostState extends ConsumerState<_SeededSprintHost> {
  @override
  void initState() {
    super.initState();
    final app = ref.read(appControllerProvider);
    app.backlogByProject['project-1'] = <TaskModel>[
      const TaskModel(
        id: 't1',
        title: 'Story A',
        description: '',
        type: TaskType.feature,
        storyPoints: 3,
        status: TaskStatus.todo,
        projectId: 'project-1',
      ),
      const TaskModel(
        id: 't2',
        title: 'Story B',
        description: '',
        type: TaskType.bug,
        storyPoints: 2,
        status: TaskStatus.todo,
        projectId: 'project-1',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return const SprintScreen(
      projectId: 'project-1',
      sprintId: 's1',
      sprintName: 'Sprint 1',
      durationDays: 5,
    );
  }
}

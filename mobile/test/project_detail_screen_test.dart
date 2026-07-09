import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agile_sprint_sim_mobile/models/project_model.dart';
import 'package:agile_sprint_sim_mobile/models/task_model.dart';
import 'package:agile_sprint_sim_mobile/providers/app_state.dart';
import 'package:agile_sprint_sim_mobile/screens/project_detail_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('project detail shows backlog items and sprint CTA', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: _SeededProjectHost()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining('Product Backlog'), findsOneWidget);
    expect(find.textContaining('Implement login'), findsOneWidget);
    expect(find.textContaining('Plan & Start Sprint'), findsOneWidget);
  });
}

class _SeededProjectHost extends ConsumerStatefulWidget {
  const _SeededProjectHost();

  @override
  ConsumerState<_SeededProjectHost> createState() => _SeededProjectHostState();
}

class _SeededProjectHostState extends ConsumerState<_SeededProjectHost> {
  @override
  void initState() {
    super.initState();
    final app = ref.read(appControllerProvider);
    app.projects = const <ProjectModel>[
      ProjectModel(
        id: 'project-1',
        name: 'Mobile Agile',
        description: 'Build mobile parity',
        ownerId: 'u1',
        currentSprintNumber: 1,
        members: <ProjectMember>[],
      ),
    ];

    app.backlogByProject['project-1'] = const <TaskModel>[
      TaskModel(
        id: 'task-1',
        title: 'Implement login',
        description: '',
        type: TaskType.feature,
        storyPoints: 3,
        status: TaskStatus.todo,
        projectId: 'project-1',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return const ProjectDetailScreen(projectId: 'project-1');
  }
}

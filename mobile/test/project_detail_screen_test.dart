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
    SharedPreferences.setMockInitialValues(<String, Object>{
      'cache_tasks_project-1': '[{"id":"task-1","title":"Implement login","description":"","type":"FEATURE","storyPoints":3,"status":"TODO","projectId":"project-1"}]',
      'cache_projects': '[{"id":"project-1","name":"Mobile Agile","description":"Build mobile parity","ownerId":"u1","currentSprintNumber":1,"members":[],"createdBy":{"id":"u1","name":"Test User","email":"test@user.com"},"status":"ACTIVE","deadline":"2026-12-31T00:00:00.000"}]',
    });

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: _SeededProjectHost()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining('Product Backlog'), findsOneWidget);
    expect(find.textContaining('Implement login'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();

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
    app.projects = <ProjectModel>[
      ProjectModel(
        id: 'project-1',
        name: 'Mobile Agile',
        description: 'Build mobile parity',
        ownerId: 'u1',
        currentSprintNumber: 1,
        members: const <ProjectMember>[],
        createdBy: const ProjectCreator(id: 'u1', name: 'Test User', email: 'test@user.com'),
        status: 'ACTIVE',
        deadline: DateTime(2026, 12, 31),
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

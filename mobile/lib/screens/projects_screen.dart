import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_state.dart';
import 'project_detail_screen.dart';

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final app = ref.watch(appControllerProvider);
    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 1100 ? 3 : (width >= 700 ? 2 : 1);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.read(appControllerProvider).loadProjects(),
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: width >= 900 ? 24 : 16, vertical: 16),
          children: <Widget>[
            Text('Your Projects', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            if (app.projects.isEmpty)
              const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('No projects found. Tap + to create one.'))),
            if (app.projects.isNotEmpty)
              GridView.builder(
                itemCount: app.projects.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: width >= 700 ? 1.8 : 2.3,
                ),
                itemBuilder: (context, index) {
                  final project = app.projects[index];
                  return Card(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(builder: (_) => ProjectDetailScreen(projectId: project.id)),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(project.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 6),
                            Expanded(
                              child: Text(
                                project.description.isEmpty ? 'No description' : project.description,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('Sprint ${project.currentSprintNumber}'),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateProjectDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New Project'),
      ),
    );
  }

  Future<void> _showCreateProjectDialog(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    final formOk = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Project'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Project Name')),
            const SizedBox(height: 8),
            TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Description')),
          ],
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Create')),
        ],
      ),
    );

    if (formOk != true || nameController.text.trim().isEmpty) {
      return;
    }

    await ref.read(appControllerProvider).createProject(nameController.text.trim(), descriptionController.text.trim());
  }
}

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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    project.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _buildStatusBadge(context, project.status),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Host: ${project.createdBy.name}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.outline,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Expanded(
                              child: Text(
                                project.description.isEmpty ? 'No description' : project.description,
                                maxLines: 2,
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

  Widget _buildStatusBadge(BuildContext context, String status) {
    Color backgroundColor;
    Color textColor;
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        backgroundColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        break;
      case 'ENDED':
        backgroundColor = Colors.blue.shade50;
        textColor = Colors.blue.shade700;
        break;
      case 'ENDED_LATE':
        backgroundColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        break;
      default:
        backgroundColor = Colors.grey.shade50;
        textColor = Colors.grey.shade700;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _showCreateProjectDialog(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime? selectedDeadline;
    bool showValidationError = false;

    final formOk = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Create Project'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Project Name')),
                  const SizedBox(height: 8),
                  TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Description')),
                  const SizedBox(height: 16),
                  Text('Deadline (Required)', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 1)),
                        firstDate: DateTime.now().add(const Duration(days: 1)),
                        lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                      );
                      if (picked != null) {
                        setState(() {
                          selectedDeadline = picked;
                          showValidationError = false;
                        });
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            selectedDeadline == null
                                ? 'Choose Deadline'
                                : '${selectedDeadline!.year}-${selectedDeadline!.month.toString().padLeft(2, '0')}-${selectedDeadline!.day.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              color: selectedDeadline == null && showValidationError ? Colors.red : null,
                              fontWeight: selectedDeadline == null && showValidationError ? FontWeight.bold : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (showValidationError && selectedDeadline == null) ...[
                    const SizedBox(height: 4),
                    const Text(
                      'Please select a deadline date.',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ],
                ],
              ),
              actions: <Widget>[
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                FilledButton(
                  onPressed: () {
                    if (selectedDeadline == null) {
                      setState(() {
                        showValidationError = true;
                      });
                      return;
                    }
                    Navigator.pop(context, true);
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );

    if (formOk != true || nameController.text.trim().isEmpty || selectedDeadline == null) {
      return;
    }

    await ref.read(appControllerProvider).createProject(
          nameController.text.trim(),
          descriptionController.text.trim(),
          selectedDeadline!,
        );
  }
}

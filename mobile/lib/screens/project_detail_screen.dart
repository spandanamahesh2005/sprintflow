import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/task_model.dart';
import '../providers/app_state.dart';
import 'sprint_screen.dart';

class ProjectDetailScreen extends ConsumerStatefulWidget {
  const ProjectDetailScreen({super.key, required this.projectId});

  final String projectId;

  @override
  ConsumerState<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends ConsumerState<ProjectDetailScreen> {
  final _titleController = TextEditingController();
  final _storyPointsController = TextEditingController(text: '3');
  TaskType _type = TaskType.feature;
  bool _actionLoading = false;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() async {
      await ref.read(appControllerProvider).loadBacklog(widget.projectId);
      await ref.read(appControllerProvider).loadSprints(widget.projectId);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _storyPointsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = ref.watch(appControllerProvider);
    final project = app.projects.firstWhereOrNull((p) => p.id == widget.projectId);
    final tasks = app.backlogOf(widget.projectId);
    final sprints = app.sprintsOf(widget.projectId);
    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 1100 ? 2 : 1;

    return Scaffold(
      appBar: AppBar(title: Text(project?.name ?? 'Project')),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: width >= 900 ? 24 : 16, vertical: 16),
        children: <Widget>[
          if (project != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Project Info', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.person, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('Host: ${project.createdBy.name} (${project.createdBy.email})'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('Deadline: ${_formatDate(project.deadline)}'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.info_outline, size: 16),
                        const SizedBox(width: 8),
                        const Text('Status: '),
                        _buildStatusBadge(context, project.status),
                      ],
                    ),
                    if (ref.watch(authControllerProvider).user?.id == project.createdBy.id && project.status == 'ACTIVE') ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if (_actionLoading)
                            const CircularProgressIndicator()
                          else ...[
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _endProject(context, project.id),
                                icon: const Icon(Icons.stop),
                                label: const Text('End Project'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Theme.of(context).colorScheme.error,
                                  side: BorderSide(color: Theme.of(context).colorScheme.error),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: () => _extendDeadline(context, project.id, project.deadline),
                                icon: const Icon(Icons.edit_calendar),
                                label: const Text('Extend Deadline'),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text('Product Backlog', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: <Widget>[
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Add a new user story'),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: <Widget>[
                      SizedBox(
                        width: width >= 700 ? 180 : width - 72,
                        child: TextField(
                          controller: _storyPointsController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Story points'),
                        ),
                      ),
                      SizedBox(
                        width: width >= 700 ? 220 : width - 72,
                        child: DropdownButtonFormField<TaskType>(
                          value: _type,
                          items: const <DropdownMenuItem<TaskType>>[
                            DropdownMenuItem(value: TaskType.feature, child: Text('Feature')),
                            DropdownMenuItem(value: TaskType.bug, child: Text('Bug')),
                            DropdownMenuItem(value: TaskType.chore, child: Text('Chore')),
                          ],
                          onChanged: (value) => setState(() => _type = value ?? TaskType.feature),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () async {
                        final title = _titleController.text.trim();
                        if (title.isEmpty) {
                          return;
                        }
                        final points = int.tryParse(_storyPointsController.text.trim()) ?? 0;
                        await ref.read(appControllerProvider).addTask(
                              projectId: widget.projectId,
                              title: title,
                              storyPoints: points,
                              type: _type,
                            );
                        _titleController.clear();
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Story'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (tasks.isEmpty)
            const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('Backlog is empty. Add stories above.')))
          else
            GridView.builder(
              itemCount: tasks.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: width >= 1100 ? 2.5 : 3.4,
              ),
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    leading: Icon(task.type == TaskType.bug ? Icons.bug_report : Icons.circle_outlined),
                    title: Text(task.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text('${task.storyPoints} pts • ${task.status.name.toUpperCase()}'),
                    trailing: Text('#${task.id.length > 4 ? task.id.substring(task.id.length - 4) : task.id}'),
                  ),
                );
              },
            ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: tasks.isEmpty
                ? null
                : () async {
                    final sprint = await _openSprintPlanDialog(context);
                    if (sprint == null || !mounted) {
                      return;
                    }
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => SprintScreen(
                          projectId: widget.projectId,
                          sprintId: sprint.id,
                          sprintName: sprint.name,
                          durationDays: sprint.durationDays,
                        ),
                      ),
                    );
                  },
            icon: const Icon(Icons.play_arrow),
            label: Text(sprints.isEmpty ? 'Plan & Start Sprint' : 'Start Next Sprint'),
          ),
        ],
      ),
    );
  }

  Future<dynamic> _openSprintPlanDialog(BuildContext context) async {
    final nameController = TextEditingController(text: 'Sprint ${DateTime.now().millisecondsSinceEpoch % 100}');
    final goalController = TextEditingController(text: 'Deliver highest-priority backlog stories');
    final durationController = TextEditingController(text: '10');

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sprint Setup / Configuration'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Sprint name')),
            const SizedBox(height: 8),
            TextField(controller: goalController, decoration: const InputDecoration(labelText: 'Goal')),
            const SizedBox(height: 8),
            TextField(controller: durationController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Duration days')),
          ],
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Start')),
        ],
      ),
    );

    if (ok != true) {
      return null;
    }

    final duration = int.tryParse(durationController.text.trim()) ?? 10;

    return ref.read(appControllerProvider).createSprint(
          projectId: widget.projectId,
          name: nameController.text.trim(),
          goal: goalController.text.trim(),
          durationDays: duration,
        );
  }

  String _formatDate(DateTime date) {
    final year = date.year;
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$year-$month-$day $hour:$minute';
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

  Future<void> _endProject(BuildContext context, String projectId) async {
    setState(() => _actionLoading = true);
    try {
      await ref.read(appControllerProvider).endProject(projectId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Project ended successfully.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to end project: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _actionLoading = false);
      }
    }
  }

  Future<void> _extendDeadline(BuildContext context, String projectId, DateTime currentDeadline) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: currentDeadline.isAfter(DateTime.now()) ? currentDeadline : DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (pickedDate == null || !mounted) {
      return;
    }

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(currentDeadline),
    );

    if (pickedTime == null || !mounted) {
      return;
    }

    final combinedDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() => _actionLoading = true);
    try {
      await ref.read(appControllerProvider).extendDeadline(projectId, combinedDateTime);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Project deadline extended successfully.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to extend deadline: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _actionLoading = false);
      }
    }
  }
}

extension _FirstWhereOrNull<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (final element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}

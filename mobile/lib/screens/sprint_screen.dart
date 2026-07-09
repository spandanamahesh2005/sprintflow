import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/task_model.dart';
import '../providers/app_state.dart';
import '../widgets/burndown_chart.dart';

class SprintScreen extends StatefulWidget {
  const SprintScreen({
    super.key,
    required this.projectId,
    required this.sprintId,
    required this.sprintName,
    required this.durationDays,
  });

  final String projectId;
  final String sprintId;
  final String sprintName;
  final int durationDays;

  @override
  State<SprintScreen> createState() => _SprintScreenState();
}

class _SprintScreenState extends State<SprintScreen> {
  late SimulationController _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (mounted && !_initialized) {
      _init();
    }
  }

  bool _initialized = false;

  void _init() {
    final app = ProviderScope.containerOf(context).read(appControllerProvider);
    final tasks = app.backlogOf(widget.projectId);
    _controller = SimulationController(sourceTasks: tasks, durationDays: widget.durationDays);
    _initialized = true;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final state = _controller.state;
        final tasks = _controller.tasks;
        final width = MediaQuery.sizeOf(context).width;
        final boardColumns = width >= 1100 ? 2 : 1;
        final todo = tasks.where((t) => t.status == TaskStatus.todo).toList();
        final inProgress = tasks.where((t) => t.status == TaskStatus.inProgress).toList();
        final review = tasks.where((t) => t.status == TaskStatus.review).toList();
        final done = tasks.where((t) => t.status == TaskStatus.done).toList();

        final remaining = <int>[state.remainingPoints, ...state.history.map((e) => e.remainingPoints)];

        return Scaffold(
          appBar: AppBar(title: Text(widget.sprintName)),
          body: ListView(
            padding: EdgeInsets.symmetric(horizontal: width >= 900 ? 24 : 16, vertical: 16),
            children: <Widget>[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      SizedBox(
                        width: width >= 700 ? 340 : width - 72,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Day ${state.day}/${state.durationDays}', style: Theme.of(context).textTheme.titleMedium),
                            Text('Velocity: ${state.velocity} pts/day'),
                            Text('Completed: ${state.completedPoints} • Remaining: ${state.remainingPoints}'),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: width >= 700 ? 220 : width - 72,
                        child: Row(
                          children: <Widget>[
                            IconButton(
                              onPressed: state.completed ? null : () => setState(_controller.step),
                              icon: const Icon(Icons.skip_next),
                              tooltip: 'Step',
                            ),
                            IconButton(
                              onPressed: state.completed
                                  ? null
                                  : () => setState(() {
                                        if (_controller.isPlaying) {
                                          _controller.pause();
                                        } else {
                                          _controller.play();
                                        }
                                      }),
                              icon: Icon(_controller.isPlaying ? Icons.pause : Icons.play_arrow),
                              tooltip: _controller.isPlaying ? 'Pause' : 'Play',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Burndown Tracking', style: Theme.of(context).textTheme.titleMedium),
                      BurndownChart(points: remaining),
                    ],
                  ),
                ),
              ),
              if (state.lastEvent != null) ...<Widget>[
                const SizedBox(height: 8),
                Card(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  child: ListTile(
                    leading: const Icon(Icons.warning_amber_outlined),
                    title: Text(state.lastEvent!.title),
                    subtitle: Text(state.lastEvent!.description),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text('Sprint Board', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              GridView.count(
                crossAxisCount: boardColumns,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: width >= 1100 ? 1.8 : 2.2,
                children: <Widget>[
                  _StatusSection(title: 'TODO', tasks: todo),
                  _StatusSection(title: 'IN PROGRESS', tasks: inProgress),
                  _StatusSection(title: 'REVIEW', tasks: review),
                  _StatusSection(title: 'DONE', tasks: done),
                ],
              ),
              if (state.completed)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('End-of-sprint summary', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text('Days used: ${state.day}/${state.durationDays}'),
                        Text('Velocity (final): ${state.velocity}'),
                        Text('Completed points: ${state.completedPoints}'),
                        Text('Remaining points: ${state.remainingPoints}'),
                        Text('Event count: ${state.history.where((h) => h.event != null).length}'),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _StatusSection extends StatelessWidget {
  const _StatusSection({required this.title, required this.tasks});

  final String title;
  final List<TaskModel> tasks;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title: Text('$title (${tasks.length})'),
        children: tasks
            .map(
              (task) => ListTile(
                title: Text(task.title),
                subtitle: Text('${task.storyPoints} pts • ${task.type.name.toUpperCase()}'),
              ),
            )
            .toList(),
      ),
    );
  }
}

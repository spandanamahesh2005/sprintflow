import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:agile_sprint_sim_mobile/models/task_model.dart';
import 'package:agile_sprint_sim_mobile/providers/simulation_engine.dart';

void main() {
  test('simulation engine applies event velocity delta deterministically', () {
    final engine = SimulationEngine(random: _QueueRandom(<int>[10, 0]));

    final initial = SimulationState.initial(durationDays: 10, totalStoryPoints: 5);
    final tasks = <TaskModel>[
      const TaskModel(
        id: 't1',
        title: 'Story 1',
        description: '',
        type: TaskType.feature,
        storyPoints: 5,
        status: TaskStatus.todo,
        projectId: 'p1',
      ),
    ];

    final (state, _) = engine.stepDay(initial, tasks);

    expect(state.day, 1);
    expect(state.lastEvent, isNotNull);
    expect(state.velocity, 4); // Base 6 + (-2 outage)
    expect(state.history.length, 1);
  });

  test('simulation completes by duration even with remaining points', () {
    final engine = SimulationEngine(random: _QueueRandom(<int>[99, 99]));

    final initial = SimulationState.initial(durationDays: 2, totalStoryPoints: 20);
    final tasks = <TaskModel>[
      const TaskModel(
        id: 't1',
        title: 'Big story',
        description: '',
        type: TaskType.feature,
        storyPoints: 20,
        status: TaskStatus.todo,
        projectId: 'p1',
      ),
    ];

    final (state1, tasks1) = engine.stepDay(initial, tasks);
    final (state2, _) = engine.stepDay(state1, tasks1);

    expect(state2.day, 2);
    expect(state2.completed, isTrue);
    expect(state2.remainingPoints, greaterThan(0));
  });
}

class _QueueRandom implements Random {
  _QueueRandom(this._values);

  final List<int> _values;
  int _index = 0;

  @override
  bool nextBool() => nextInt(2) == 1;

  @override
  double nextDouble() => nextInt(1000) / 1000.0;

  @override
  int nextInt(int max) {
    if (_values.isEmpty) {
      return 0;
    }

    final value = _values[_index % _values.length];
    _index += 1;
    return value % max;
  }
}

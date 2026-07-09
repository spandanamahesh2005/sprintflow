import 'dart:math';

import '../models/simulation_model.dart';
import '../models/task_model.dart';

class SimulationState {
  const SimulationState({
    required this.day,
    required this.durationDays,
    required this.velocity,
    required this.completedPoints,
    required this.remainingPoints,
    required this.history,
    this.lastEvent,
    this.completed = false,
  });

  final int day;
  final int durationDays;
  final int velocity;
  final int completedPoints;
  final int remainingPoints;
  final List<DayResult> history;
  final SimulationEvent? lastEvent;
  final bool completed;

  SimulationState copyWith({
    int? day,
    int? durationDays,
    int? velocity,
    int? completedPoints,
    int? remainingPoints,
    List<DayResult>? history,
    SimulationEvent? lastEvent,
    bool? completed,
  }) {
    return SimulationState(
      day: day ?? this.day,
      durationDays: durationDays ?? this.durationDays,
      velocity: velocity ?? this.velocity,
      completedPoints: completedPoints ?? this.completedPoints,
      remainingPoints: remainingPoints ?? this.remainingPoints,
      history: history ?? this.history,
      lastEvent: lastEvent,
      completed: completed ?? this.completed,
    );
  }

  factory SimulationState.initial({
    required int durationDays,
    required int totalStoryPoints,
  }) {
    return SimulationState(
      day: 0,
      durationDays: durationDays,
      velocity: 6,
      completedPoints: 0,
      remainingPoints: totalStoryPoints,
      history: const <DayResult>[],
    );
  }
}

class SimulationEngine {
  SimulationEngine({Random? random}) : _random = random ?? Random();

  final Random _random;

  static const List<SimulationEvent> _eventPool = <SimulationEvent>[
    SimulationEvent(
      title: 'Unexpected Outage',
      description: 'Main database latency blocked integration tests.',
      velocityDelta: -2,
      xpDelta: 8,
    ),
    SimulationEvent(
      title: 'Refinement Win',
      description: 'Clarified stories reduced rework significantly.',
      velocityDelta: 2,
      xpDelta: 10,
    ),
    SimulationEvent(
      title: 'Dependency Delay',
      description: 'External API change caused task churn.',
      velocityDelta: -1,
      xpDelta: 5,
    ),
  ];

  // Equivalent to the web sprint board intent: advance one virtual day with
  // optional random event impact and move tasks toward DONE based on velocity.
  (SimulationState, List<TaskModel>) stepDay(
    SimulationState current,
    List<TaskModel> tasks,
  ) {
    if (current.completed) {
      return (current, tasks);
    }

    final nextDay = current.day + 1;
    final event = _rollEvent();
    final effectiveVelocity = max(1, current.velocity + (event?.velocityDelta ?? 0));

    var budget = effectiveVelocity;
    var completedToday = 0;

    final nextTasks = tasks.map((task) {
      if (budget <= 0 || task.status == TaskStatus.done) {
        return task;
      }

      if (task.status == TaskStatus.review) {
        budget -= max(1, task.storyPoints ~/ 2);
        completedToday += task.storyPoints;
        return task.copyWith(status: TaskStatus.done);
      }

      if (task.status == TaskStatus.inProgress) {
        budget -= max(1, task.storyPoints ~/ 3);
        return task.copyWith(status: TaskStatus.review);
      }

      if (task.status == TaskStatus.todo) {
        budget -= 1;
        return task.copyWith(status: TaskStatus.inProgress);
      }

      return task;
    }).toList();

    final completedPoints = current.completedPoints + completedToday;
    final totalPoints = _sumPoints(tasks);
    final remainingPoints = max(0, totalPoints - completedPoints);

    final dayResult = DayResult(
      day: nextDay,
      completedPoints: completedPoints,
      remainingPoints: remainingPoints,
      velocity: effectiveVelocity,
      event: event,
    );

    final isDone = nextDay >= current.durationDays || remainingPoints == 0;

    return (
      current.copyWith(
        day: nextDay,
        velocity: effectiveVelocity,
        completedPoints: completedPoints,
        remainingPoints: remainingPoints,
        history: <DayResult>[...current.history, dayResult],
        lastEvent: event,
        completed: isDone,
      ),
      nextTasks,
    );
  }

  int _sumPoints(List<TaskModel> tasks) {
    return tasks.fold<int>(0, (sum, task) => sum + task.storyPoints);
  }

  SimulationEvent? _rollEvent() {
    final chance = _random.nextInt(100);
    if (chance > 35) {
      return null;
    }
    return _eventPool[_random.nextInt(_eventPool.length)];
  }
}

import 'sprint_model.dart';

class SimulationEvent {
  const SimulationEvent({
    required this.title,
    required this.description,
    required this.velocityDelta,
    required this.xpDelta,
  });

  final String title;
  final String description;
  final int velocityDelta;
  final int xpDelta;

  EventLogItem toEventLog(int day) {
    final impact =
        'velocity ${velocityDelta >= 0 ? '+' : ''}$velocityDelta, xp ${xpDelta >= 0 ? '+' : ''}$xpDelta';
    return EventLogItem(day: day, description: '$title: $description', impact: impact);
  }
}

class DayResult {
  const DayResult({
    required this.day,
    required this.completedPoints,
    required this.remainingPoints,
    required this.velocity,
    this.event,
  });

  final int day;
  final int completedPoints;
  final int remainingPoints;
  final int velocity;
  final SimulationEvent? event;
}

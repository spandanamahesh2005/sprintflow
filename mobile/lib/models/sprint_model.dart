enum SprintStatus { planning, active, completed }

SprintStatus sprintStatusFromString(String value) {
  switch (value.toUpperCase()) {
    case 'ACTIVE':
      return SprintStatus.active;
    case 'COMPLETED':
      return SprintStatus.completed;
    case 'PLANNING':
    default:
      return SprintStatus.planning;
  }
}

String sprintStatusToString(SprintStatus status) {
  switch (status) {
    case SprintStatus.planning:
      return 'PLANNING';
    case SprintStatus.active:
      return 'ACTIVE';
    case SprintStatus.completed:
      return 'COMPLETED';
  }
}

class EventLogItem {
  const EventLogItem({
    required this.day,
    required this.description,
    required this.impact,
  });

  final int day;
  final String description;
  final String impact;

  factory EventLogItem.fromJson(Map<String, dynamic> json) {
    return EventLogItem(
      day: (json['day'] ?? 0) as int,
      description: (json['description'] ?? '').toString(),
      impact: (json['impact'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'day': day, 'description': description, 'impact': impact};
  }
}

class SprintModel {
  const SprintModel({
    required this.id,
    required this.name,
    required this.goal,
    required this.projectId,
    required this.status,
    required this.durationDays,
    required this.currentDay,
    required this.eventLog,
    this.startDate,
    this.endDate,
  });

  final String id;
  final String name;
  final String goal;
  final String projectId;
  final SprintStatus status;
  final DateTime? startDate;
  final DateTime? endDate;
  final int durationDays;
  final int currentDay;
  final List<EventLogItem> eventLog;

  SprintModel copyWith({
    String? id,
    String? name,
    String? goal,
    String? projectId,
    SprintStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    int? durationDays,
    int? currentDay,
    List<EventLogItem>? eventLog,
  }) {
    return SprintModel(
      id: id ?? this.id,
      name: name ?? this.name,
      goal: goal ?? this.goal,
      projectId: projectId ?? this.projectId,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      durationDays: durationDays ?? this.durationDays,
      currentDay: currentDay ?? this.currentDay,
      eventLog: eventLog ?? this.eventLog,
    );
  }

  factory SprintModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value, int fallback) {
      if (value is int) {
        return value;
      }
      if (value is num) {
        return value.toInt();
      }
      return int.tryParse(value?.toString() ?? '') ?? fallback;
    }

    DateTime? parseDate(dynamic value) {
      if (value == null) {
        return null;
      }
      return DateTime.tryParse(value.toString());
    }

    return SprintModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      goal: (json['goal'] ?? '').toString(),
      projectId: (json['projectId'] ?? '').toString(),
      status: sprintStatusFromString((json['status'] ?? 'PLANNING').toString()),
      startDate: parseDate(json['startDate']),
      endDate: parseDate(json['endDate']),
      durationDays: parseInt(json['durationDays'], 10),
      currentDay: parseInt(json['currentDay'], 0),
      eventLog: ((json['eventLog'] ?? const <dynamic>[]) as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map(EventLogItem.fromJson)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'goal': goal,
      'projectId': projectId,
      'status': sprintStatusToString(status),
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'durationDays': durationDays,
      'currentDay': currentDay,
      'eventLog': eventLog.map((e) => e.toJson()).toList(),
    };
  }
}

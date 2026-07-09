enum TaskType { feature, bug, chore }

enum TaskStatus { todo, inProgress, review, done }

TaskType taskTypeFromString(String value) {
  switch (value.toUpperCase()) {
    case 'BUG':
      return TaskType.bug;
    case 'CHORE':
      return TaskType.chore;
    case 'FEATURE':
    default:
      return TaskType.feature;
  }
}

String taskTypeToString(TaskType type) {
  switch (type) {
    case TaskType.feature:
      return 'FEATURE';
    case TaskType.bug:
      return 'BUG';
    case TaskType.chore:
      return 'CHORE';
  }
}

TaskStatus taskStatusFromString(String value) {
  switch (value.toUpperCase()) {
    case 'IN_PROGRESS':
      return TaskStatus.inProgress;
    case 'REVIEW':
      return TaskStatus.review;
    case 'DONE':
      return TaskStatus.done;
    case 'TODO':
    default:
      return TaskStatus.todo;
  }
}

String taskStatusToString(TaskStatus status) {
  switch (status) {
    case TaskStatus.todo:
      return 'TODO';
    case TaskStatus.inProgress:
      return 'IN_PROGRESS';
    case TaskStatus.review:
      return 'REVIEW';
    case TaskStatus.done:
      return 'DONE';
  }
}

class TaskModel {
  const TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.storyPoints,
    required this.status,
    required this.projectId,
    this.sprintId,
    this.assigneeId,
  });

  final String id;
  final String title;
  final String description;
  final TaskType type;
  final int storyPoints;
  final TaskStatus status;
  final String projectId;
  final String? sprintId;
  final String? assigneeId;

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    TaskType? type,
    int? storyPoints,
    TaskStatus? status,
    String? projectId,
    String? sprintId,
    String? assigneeId,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      storyPoints: storyPoints ?? this.storyPoints,
      status: status ?? this.status,
      projectId: projectId ?? this.projectId,
      sprintId: sprintId ?? this.sprintId,
      assigneeId: assigneeId ?? this.assigneeId,
    );
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value, int fallback) {
      if (value is int) {
        return value;
      }
      if (value is num) {
        return value.toInt();
      }
      return int.tryParse(value?.toString() ?? '') ?? fallback;
    }

    final sprintNode = json['sprintId'];
    final assigneeNode = json['assigneeId'];

    return TaskModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      type: taskTypeFromString((json['type'] ?? 'FEATURE').toString()),
      storyPoints: parseInt(json['storyPoints'], 0),
      status: taskStatusFromString((json['status'] ?? 'TODO').toString()),
      projectId: (json['projectId'] ?? '').toString(),
      sprintId: sprintNode == null ? null : sprintNode.toString(),
      assigneeId: assigneeNode == null ? null : assigneeNode.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': taskTypeToString(type),
      'storyPoints': storyPoints,
      'status': taskStatusToString(status),
      'projectId': projectId,
      'sprintId': sprintId,
      'assigneeId': assigneeId,
    };
  }
}

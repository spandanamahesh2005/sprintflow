enum ProjectRole { po, sm, dev }

ProjectRole projectRoleFromString(String value) {
  switch (value.toUpperCase()) {
    case 'PO':
      return ProjectRole.po;
    case 'SM':
      return ProjectRole.sm;
    case 'DEV':
    default:
      return ProjectRole.dev;
  }
}

String projectRoleToString(ProjectRole role) {
  switch (role) {
    case ProjectRole.po:
      return 'PO';
    case ProjectRole.sm:
      return 'SM';
    case ProjectRole.dev:
      return 'DEV';
  }
}

class ProjectMember {
  const ProjectMember({required this.userId, required this.role});

  final String userId;
  final ProjectRole role;

  factory ProjectMember.fromJson(Map<String, dynamic> json) {
    final userNode = json['userId'];
    final resolvedUserId = userNode is Map<String, dynamic>
        ? (userNode['_id'] ?? userNode['id'] ?? '').toString()
        : (userNode ?? '').toString();

    return ProjectMember(
      userId: resolvedUserId,
      role: projectRoleFromString((json['role'] ?? 'DEV').toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {'userId': userId, 'role': projectRoleToString(role)};
  }
}

class ProjectCreator {
  const ProjectCreator({
    required this.id,
    required this.name,
    required this.email,
  });

  final String id;
  final String name;
  final String email;

  factory ProjectCreator.fromJson(Map<String, dynamic> json) {
    return ProjectCreator(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}

class ProjectModel {
  const ProjectModel({
    required this.id,
    required this.name,
    required this.description,
    required this.ownerId,
    required this.currentSprintNumber,
    required this.members,
    required this.createdBy,
    required this.status,
    required this.deadline,
  });

  final String id;
  final String name;
  final String description;
  final String ownerId;
  final int currentSprintNumber;
  final List<ProjectMember> members;
  final ProjectCreator createdBy;
  final String status;
  final DateTime deadline;

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value, int fallback) {
      if (value is int) {
        return value;
      }
      if (value is num) {
        return value.toInt();
      }
      return int.tryParse(value?.toString() ?? '') ?? fallback;
    }

    final createdByJson = json['createdBy'];
    final parsedCreatedBy = createdByJson is Map
        ? ProjectCreator.fromJson(Map<String, dynamic>.from(createdByJson))
        : const ProjectCreator(id: '', name: '', email: '');

    final parsedDeadline = json['deadline'] != null
        ? DateTime.tryParse(json['deadline'].toString()) ?? DateTime.now()
        : DateTime.now();

    return ProjectModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      ownerId: (json['ownerId'] ?? '').toString(),
      currentSprintNumber: parseInt(json['currentSprintNumber'], 0),
      members: ((json['members'] ?? const <dynamic>[]) as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map(ProjectMember.fromJson)
          .toList(),
      createdBy: parsedCreatedBy,
      status: (json['status'] ?? 'ACTIVE').toString(),
      deadline: parsedDeadline,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ownerId': ownerId,
      'currentSprintNumber': currentSprintNumber,
      'members': members.map((m) => m.toJson()).toList(),
      'createdBy': createdBy.toJson(),
      'status': status,
      'deadline': deadline.toIso8601String(),
    };
  }
}

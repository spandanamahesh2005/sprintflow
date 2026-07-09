enum UserRole { guest, student, coach, admin }

UserRole userRoleFromString(String value) {
  switch (value.toUpperCase()) {
    case 'GUEST':
      return UserRole.guest;
    case 'COACH':
      return UserRole.coach;
    case 'ADMIN':
      return UserRole.admin;
    case 'STUDENT':
    default:
      return UserRole.student;
  }
}

String userRoleToString(UserRole role) {
  switch (role) {
    case UserRole.guest:
      return 'GUEST';
    case UserRole.coach:
      return 'COACH';
    case UserRole.admin:
      return 'ADMIN';
    case UserRole.student:
      return 'STUDENT';
  }
}

class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.xp,
    required this.level,
    required this.badges,
  });

  final String id;
  final String name;
  final String email;
  final UserRole role;
  final int xp;
  final int level;
  final List<String> badges;

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    int? xp,
    int? level,
    List<String>? badges,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      badges: badges ?? this.badges,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value, int fallback) {
      if (value is int) {
        return value;
      }
      if (value is num) {
        return value.toInt();
      }
      return int.tryParse(value?.toString() ?? '') ?? fallback;
    }

    return UserModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      role: userRoleFromString((json['role'] ?? 'STUDENT').toString()),
      xp: parseInt(json['xp'], 0),
      level: parseInt(json['level'], 1),
      badges: ((json['badges'] ?? const <dynamic>[]) as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': userRoleToString(role),
      'xp': xp,
      'level': level,
      'badges': badges,
    };
  }
}

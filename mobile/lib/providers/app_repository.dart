import 'dart:convert';

import 'package:dio/dio.dart';

import '../models/project_model.dart';
import '../models/sprint_model.dart';
import '../models/task_model.dart';
import '../models/user_model.dart';
import '../utils/app_constants.dart';
import 'api_client.dart';
import 'local_store.dart';

class AuthResult {
  const AuthResult({required this.user, required this.token});

  final UserModel user;
  final String token;
}

class AppRepository {
  AppRepository({required ApiClient apiClient, required LocalStore localStore})
      : _apiClient = apiClient,
        _localStore = localStore;

  final ApiClient _apiClient;
  final LocalStore _localStore;

  Future<AuthResult> login({required String email, required String password}) async {
    final response = await _apiClient.dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: <String, dynamic>{'email': email, 'password': password},
    );

    final body = response.data ?? <String, dynamic>{};
    final token = (body['access_token'] ?? '').toString();
    final user = UserModel.fromJson((body['user'] ?? <String, dynamic>{}) as Map<String, dynamic>);

    await saveSession(token: token, user: user);
    return AuthResult(user: user, token: token);
  }

  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.dio.post<Map<String, dynamic>>(
      '/auth/register',
      data: <String, dynamic>{'name': name, 'email': email, 'password': password},
    );

    final body = response.data ?? <String, dynamic>{};
    final token = (body['access_token'] ?? '').toString();
    final user = UserModel.fromJson((body['user'] ?? <String, dynamic>{}) as Map<String, dynamic>);

    await saveSession(token: token, user: user);
    return AuthResult(user: user, token: token);
  }

  Future<void> saveSession({required String token, required UserModel user}) async {
    await _localStore.writeString(AppConstants.tokenKey, token);
    await _localStore.writeJson(AppConstants.userKey, user.toJson());
    _apiClient.setToken(token);
  }

  Future<(String?, UserModel?)> restoreSession() async {
    final token = await _localStore.readString(AppConstants.tokenKey);
    final rawUser = await _localStore.readJson(AppConstants.userKey);
    if (token == null || rawUser == null) {
      return (null, null);
    }

    _apiClient.setToken(token);
    return (token, UserModel.fromJson((rawUser as Map).cast<String, dynamic>()));
  }

  Future<void> clearSession() async {
    await _localStore.remove(AppConstants.tokenKey);
    await _localStore.remove(AppConstants.userKey);
    _apiClient.setToken(null);
  }

  Future<UserModel> fetchProfile({required UserModel fallback}) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>('/users/profile');
      final user = UserModel.fromJson(response.data ?? <String, dynamic>{});
      await _localStore.writeJson(AppConstants.userKey, user.toJson());
      return user;
    } on DioException {
      return fallback;
    }
  }

  Future<UserModel> updateProfile({
    required String name,
    String? currentPassword,
    String? newPassword,
  }) async {
    final response = await _apiClient.dio.put<Map<String, dynamic>>(
      '/users/profile',
      data: <String, dynamic>{
        'name': name,
        if (currentPassword != null && currentPassword.isNotEmpty)
          'currentPassword': currentPassword,
        if (newPassword != null && newPassword.isNotEmpty) 'newPassword': newPassword,
      },
    );

    final user = UserModel.fromJson(response.data ?? <String, dynamic>{});
    await _localStore.writeJson(AppConstants.userKey, user.toJson());
    return user;
  }

  Future<List<ProjectModel>> fetchProjects() async {
    try {
      final response = await _apiClient.dio.get<List<dynamic>>('/projects');
      final projects = (response.data ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(ProjectModel.fromJson)
          .toList();
      await _localStore.writeJson(
        AppConstants.projectsCacheKey,
        projects.map((p) => p.toJson()).toList(),
      );
      return projects;
    } on DioException {
      return _readProjectsCache();
    }
  }

  Future<ProjectModel?> fetchProjectById(String projectId) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>('/projects/$projectId');
      return ProjectModel.fromJson(response.data ?? <String, dynamic>{});
    } on DioException {
      final projects = await _readProjectsCache();
      for (final project in projects) {
        if (project.id == projectId) {
          return project;
        }
      }
      return null;
    }
  }

  Future<ProjectModel> createProject({required String name, required String description}) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/projects',
        data: <String, dynamic>{'name': name, 'description': description},
      );
      final project = ProjectModel.fromJson(response.data ?? <String, dynamic>{});
      final cache = await _readProjectsCache();
      await _localStore.writeJson(
        AppConstants.projectsCacheKey,
        <Map<String, dynamic>>[project.toJson(), ...cache.map((p) => p.toJson())],
      );
      return project;
    } on DioException {
      final fakeProject = ProjectModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        description: description,
        ownerId: 'local',
        currentSprintNumber: 0,
        members: const <ProjectMember>[],
        createdBy: const ProjectCreator(id: 'local', name: 'Local Host', email: 'local@host.com'),
        status: 'ACTIVE',
        deadline: DateTime.now().add(const Duration(days: 30)),
      );
      final cache = await _readProjectsCache();
      await _localStore.writeJson(
        AppConstants.projectsCacheKey,
        <Map<String, dynamic>>[fakeProject.toJson(), ...cache.map((p) => p.toJson())],
      );
      return fakeProject;
    }
  }

  Future<ProjectModel> endProject(String projectId) async {
    final response = await _apiClient.endProject(projectId);
    final project = ProjectModel.fromJson(response.data ?? <String, dynamic>{});
    try {
      final cache = await _readProjectsCache();
      final index = cache.indexWhere((p) => p.id == projectId);
      if (index != -1) {
        cache[index] = project;
        await _localStore.writeJson(
          AppConstants.projectsCacheKey,
          cache.map((p) => p.toJson()).toList(),
        );
      }
    } catch (_) {}
    return project;
  }

  Future<ProjectModel> extendDeadline(String projectId, DateTime newDeadline) async {
    final response = await _apiClient.extendDeadline(projectId, newDeadline);
    final project = ProjectModel.fromJson(response.data ?? <String, dynamic>{});
    try {
      final cache = await _readProjectsCache();
      final index = cache.indexWhere((p) => p.id == projectId);
      if (index != -1) {
        cache[index] = project;
        await _localStore.writeJson(
          AppConstants.projectsCacheKey,
          cache.map((p) => p.toJson()).toList(),
        );
      }
    } catch (_) {}
    return project;
  }

  Future<List<TaskModel>> fetchBacklog(String projectId) async {
    try {
      final response = await _apiClient.dio.get<List<dynamic>>('/tasks/backlog', queryParameters: <String, dynamic>{'projectId': projectId});
      final tasks = (response.data ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(TaskModel.fromJson)
          .toList();
      await _writeTaskCache(projectId, tasks);
      return tasks;
    } on DioException {
      return _readTaskCache(projectId);
    }
  }

  Future<TaskModel> createTask({
    required String projectId,
    required String title,
    required int storyPoints,
    required TaskType type,
  }) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/tasks',
        data: <String, dynamic>{
          'title': title,
          'projectId': projectId,
          'storyPoints': storyPoints,
          'type': taskTypeToString(type),
        },
      );
      final task = TaskModel.fromJson(response.data ?? <String, dynamic>{});
      final tasks = await _readTaskCache(projectId);
      await _writeTaskCache(projectId, <TaskModel>[task, ...tasks]);
      return task;
    } on DioException {
      final localTask = TaskModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        description: '',
        type: type,
        storyPoints: storyPoints,
        status: TaskStatus.todo,
        projectId: projectId,
      );
      final tasks = await _readTaskCache(projectId);
      await _writeTaskCache(projectId, <TaskModel>[localTask, ...tasks]);
      return localTask;
    }
  }

  Future<TaskModel> updateTask(TaskModel task) async {
    try {
      final response = await _apiClient.dio.put<Map<String, dynamic>>('/tasks/${task.id}', data: task.toJson());
      final updated = TaskModel.fromJson(response.data ?? <String, dynamic>{});
      await _replaceTaskInCache(updated);
      return updated;
    } on DioException {
      await _replaceTaskInCache(task);
      return task;
    }
  }

  Future<List<UserModel>> fetchUsers() async {
    try {
      final response = await _apiClient.dio.get<List<dynamic>>('/users');
      final users = (response.data ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(UserModel.fromJson)
          .toList();
      await _localStore.writeJson(AppConstants.usersCacheKey, users.map((u) => u.toJson()).toList());
      return users;
    } on DioException {
      final data = await _localStore.readJson(AppConstants.usersCacheKey);
      return _jsonList(data).map(UserModel.fromJson).toList();
    }
  }

  Future<UserModel> createUser({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final response = await _apiClient.dio.post<Map<String, dynamic>>(
      '/users',
      data: <String, dynamic>{'name': name, 'email': email, 'password': password, 'role': role},
    );
    final user = UserModel.fromJson(response.data ?? <String, dynamic>{});
    final cache = await fetchUsers();
    await _localStore.writeJson(
      AppConstants.usersCacheKey,
      <Map<String, dynamic>>[user.toJson(), ...cache.map((e) => e.toJson())],
    );
    return user;
  }

  Future<List<SprintModel>> fetchSprints(String projectId) async {
    try {
      final response = await _apiClient.dio.get<List<dynamic>>('/sprints', queryParameters: <String, dynamic>{'projectId': projectId});
      final sprints = (response.data ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(SprintModel.fromJson)
          .toList();
      await _writeSprintsCache(projectId, sprints);
      return sprints;
    } on DioException {
      return _readSprintsCache(projectId);
    }
  }

  Future<SprintModel> createSprint({
    required String projectId,
    required String name,
    required String goal,
    int durationDays = 10,
  }) async {
    final now = DateTime.now();

    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/sprints',
        data: <String, dynamic>{
          'projectId': projectId,
          'name': name,
          'goal': goal,
          'durationDays': durationDays,
          'status': 'ACTIVE',
          'startDate': now.toIso8601String(),
        },
      );
      final sprint = SprintModel.fromJson(response.data ?? <String, dynamic>{});
      final cache = await _readSprintsCache(projectId);
      await _writeSprintsCache(projectId, <SprintModel>[sprint, ...cache]);
      return sprint;
    } on DioException {
      final localSprint = SprintModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        goal: goal,
        projectId: projectId,
        status: SprintStatus.active,
        durationDays: durationDays,
        currentDay: 0,
        eventLog: const <EventLogItem>[],
        startDate: now,
      );
      final cache = await _readSprintsCache(projectId);
      await _writeSprintsCache(projectId, <SprintModel>[localSprint, ...cache]);
      return localSprint;
    }
  }

  Future<void> setThemeMode(String mode) async {
    await _localStore.writeString(AppConstants.themeModeKey, mode);
  }

  Future<String> getThemeMode() async {
    return (await _localStore.readString(AppConstants.themeModeKey)) ?? 'system';
  }
  
  Future<void> setApiBaseUrl(String baseUrl) async {
    final normalized = _normalizeBaseUrl(baseUrl);
    await _localStore.writeString(AppConstants.apiBaseUrlKey, normalized);
    _apiClient.setBaseUrl(normalized);
  }
  
  Future<String> getApiBaseUrl() async {
    final saved = await _localStore.readString(AppConstants.apiBaseUrlKey);
    final baseUrl = _normalizeBaseUrl(
      (saved == null || saved.trim().isEmpty)
          ? AppConstants.defaultBackendBaseUrl
          : saved,
    );
    _apiClient.setBaseUrl(baseUrl);
    return baseUrl;
  }

  Future<bool> hasConfiguredBackendUrl() async {
    final saved = await _localStore.readString(AppConstants.apiBaseUrlKey);
    return saved != null && saved.trim().isNotEmpty;
  }

  Future<void> setTutorialSeen(bool seen) async {
    await _localStore.writeBool(AppConstants.tutorialSeenKey, seen);
  }

  Future<bool> isTutorialSeen() {
    return _localStore.readBool(AppConstants.tutorialSeenKey, defaultValue: false);
  }

  Future<List<ProjectModel>> _readProjectsCache() async {
    final data = await _localStore.readJson(AppConstants.projectsCacheKey);
    return _jsonList(data).map(ProjectModel.fromJson).toList();
  }

  Future<void> _writeTaskCache(String projectId, List<TaskModel> tasks) async {
    final key = '${AppConstants.tasksCacheKey}_$projectId';
    await _localStore.writeJson(key, tasks.map((e) => e.toJson()).toList());
  }

  Future<List<TaskModel>> _readTaskCache(String projectId) async {
    final key = '${AppConstants.tasksCacheKey}_$projectId';
    final data = await _localStore.readJson(key);
    return _jsonList(data).map(TaskModel.fromJson).toList();
  }
  
  String _normalizeBaseUrl(String raw) {
    final trimmed = raw.trim();
    if (trimmed.endsWith('/')) {
      return trimmed.substring(0, trimmed.length - 1);
    }
    return trimmed;
  }

  Future<void> _replaceTaskInCache(TaskModel updated) async {
    final tasks = await _readTaskCache(updated.projectId);
    final next = tasks.map((task) => task.id == updated.id ? updated : task).toList();
    await _writeTaskCache(updated.projectId, next);
  }

  Future<void> _writeSprintsCache(String projectId, List<SprintModel> sprints) async {
    final key = '${AppConstants.sprintsCacheKey}_$projectId';
    await _localStore.writeJson(key, sprints.map((e) => e.toJson()).toList());
  }

  Future<List<SprintModel>> _readSprintsCache(String projectId) async {
    final key = '${AppConstants.sprintsCacheKey}_$projectId';
    final data = await _localStore.readJson(key);
    return _jsonList(data).map(SprintModel.fromJson).toList();
  }

  List<Map<String, dynamic>> _jsonList(dynamic raw) {
    if (raw is! List) {
      return const <Map<String, dynamic>>[];
    }
    return raw.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList();
  }
}

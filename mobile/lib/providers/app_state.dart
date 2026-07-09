import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/achievement_model.dart';
import '../models/project_model.dart';
import '../models/simulation_model.dart';
import '../models/sprint_model.dart';
import '../models/task_model.dart';
import '../models/user_model.dart';
import 'api_client.dart';
import 'app_repository.dart';
import 'local_store.dart';
import 'simulation_engine.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());
final localStoreProvider = Provider<LocalStore>((ref) => LocalStore());

final repositoryProvider = Provider<AppRepository>(
  (ref) => AppRepository(
    apiClient: ref.read(apiClientProvider),
    localStore: ref.read(localStoreProvider),
  ),
);

final authControllerProvider = ChangeNotifierProvider<AuthController>(
  (ref) => AuthController(repository: ref.read(repositoryProvider)),
);

final appControllerProvider = ChangeNotifierProvider<AppController>(
  (ref) => AppController(repository: ref.read(repositoryProvider)),
);

final settingsControllerProvider = ChangeNotifierProvider<SettingsController>(
  (ref) => SettingsController(repository: ref.read(repositoryProvider)),
);

final tutorialControllerProvider = ChangeNotifierProvider<TutorialController>(
  (ref) => TutorialController(repository: ref.read(repositoryProvider)),
);

class AuthController extends ChangeNotifier {
  AuthController({required AppRepository repository}) : _repository = repository;

  final AppRepository _repository;

  UserModel? user;
  String? token;
  bool loading = false;
  String? error;

  bool get isAuthenticated => token != null && user != null;

  String _friendlyAuthError(Object e, {required String fallback}) {
    if (e is DioException) {
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        final msg = responseData['message'];
        if (msg is String && msg.trim().isNotEmpty) {
          return msg.trim();
        }
        if (msg is List && msg.isNotEmpty) {
          return msg.first.toString();
        }
      }

      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        return 'Cannot reach backend. Check Backend Connection URL and ensure backend is running.';
      }

      return e.message ?? fallback;
    }

    return fallback;
  }

  Future<void> restoreSession() async {
    loading = true;
    notifyListeners();
    final result = await _repository.restoreSession();
    token = result.$1;
    user = result.$2;
    loading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final result = await _repository.login(email: email, password: password);
      user = result.user;
      token = result.token;
      return true;
    } catch (e) {
      error = _friendlyAuthError(
        e,
        fallback: 'Login failed. Check credentials and backend availability.',
      );
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String name, String email, String password) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final result = await _repository.register(name: name, email: email, password: password);
      user = result.user;
      token = result.token;
      return true;
    } catch (e) {
      error = _friendlyAuthError(e, fallback: 'Registration failed.');
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> refreshProfile() async {
    final current = user;
    if (current == null) {
      return;
    }
    user = await _repository.fetchProfile(fallback: current);
    notifyListeners();
  }

  Future<bool> updateProfile({
    required String name,
    String? currentPassword,
    String? newPassword,
  }) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      user = await _repository.updateProfile(
        name: name,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return true;
    } catch (e) {
      error = 'Failed to update profile.';
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _repository.clearSession();
    token = null;
    user = null;
    notifyListeners();
  }
}

class AppController extends ChangeNotifier {
  AppController({required AppRepository repository}) : _repository = repository;

  final AppRepository _repository;

  bool loading = false;
  String? error;

  List<ProjectModel> projects = <ProjectModel>[];
  final Map<String, List<TaskModel>> backlogByProject = <String, List<TaskModel>>{};
  final Map<String, List<SprintModel>> sprintsByProject = <String, List<SprintModel>>{};
  List<UserModel> team = <UserModel>[];

  final List<AchievementModel> achievements = const <AchievementModel>[
    AchievementModel(id: 1, title: 'Sprinting Start', description: 'Complete your first sprint', unlocked: true),
    AchievementModel(id: 2, title: 'Backlog Master', description: 'Create 10 user stories', unlocked: true),
    AchievementModel(id: 3, title: 'Velocity King', description: 'Increase velocity by 20%', unlocked: false),
    AchievementModel(id: 4, title: 'Grandmaster', description: 'Reach Level 20', unlocked: false),
  ];

  List<Map<String, dynamic>> get leaderboard => const <Map<String, dynamic>>[
        {'rank': 1, 'name': 'Agile Master X', 'xp': 15400, 'level': 24, 'badge': 'Grandmaster'},
        {'rank': 2, 'name': 'ScrumWizard', 'xp': 14200, 'level': 22, 'badge': 'Master'},
        {'rank': 3, 'name': 'SprointBooster', 'xp': 12800, 'level': 19, 'badge': 'Expert'},
        {'rank': 4, 'name': 'BacklogHero', 'xp': 9500, 'level': 15, 'badge': 'Practitioner'},
        {'rank': 5, 'name': 'DailyStandup', 'xp': 8200, 'level': 12, 'badge': 'Practitioner'},
      ];

  Future<void> bootstrap() async {
    await Future.wait(<Future<void>>[
      loadProjects(),
      loadTeam(),
    ]);
  }

  Future<void> loadProjects() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      projects = await _repository.fetchProjects();
    } catch (e) {
      error = 'Failed to load projects.';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> createProject(String name, String description) async {
    final project = await _repository.createProject(name: name, description: description);
    projects = <ProjectModel>[project, ...projects];
    notifyListeners();
  }

  Future<void> loadBacklog(String projectId) async {
    final tasks = await _repository.fetchBacklog(projectId);
    backlogByProject[projectId] = tasks;
    notifyListeners();
  }

  List<TaskModel> backlogOf(String projectId) {
    return backlogByProject[projectId] ?? const <TaskModel>[];
  }

  Future<void> addTask({
    required String projectId,
    required String title,
    required int storyPoints,
    required TaskType type,
  }) async {
    final task = await _repository.createTask(
      projectId: projectId,
      title: title,
      storyPoints: storyPoints,
      type: type,
    );

    final existing = backlogByProject[projectId] ?? const <TaskModel>[];
    backlogByProject[projectId] = <TaskModel>[task, ...existing];
    notifyListeners();
  }

  Future<void> upsertTask(TaskModel task) async {
    final updated = await _repository.updateTask(task);
    final tasks = backlogByProject[task.projectId] ?? const <TaskModel>[];
    backlogByProject[task.projectId] = tasks.map((e) => e.id == updated.id ? updated : e).toList();
    notifyListeners();
  }

  Future<void> loadTeam() async {
    try {
      team = await _repository.fetchUsers();
      notifyListeners();
    } catch (_) {
      // Keep last cached team.
    }
  }

  Future<void> addTeamMember({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final user = await _repository.createUser(name: name, email: email, password: password, role: role);
    team = <UserModel>[user, ...team];
    notifyListeners();
  }

  Future<void> loadSprints(String projectId) async {
    final sprints = await _repository.fetchSprints(projectId);
    sprintsByProject[projectId] = sprints;
    notifyListeners();
  }

  List<SprintModel> sprintsOf(String projectId) {
    return sprintsByProject[projectId] ?? const <SprintModel>[];
  }

  Future<SprintModel> createSprint({
    required String projectId,
    required String name,
    required String goal,
    int durationDays = 10,
  }) async {
    final sprint = await _repository.createSprint(
      projectId: projectId,
      name: name,
      goal: goal,
      durationDays: durationDays,
    );
    final existing = sprintsByProject[projectId] ?? const <SprintModel>[];
    sprintsByProject[projectId] = <SprintModel>[sprint, ...existing];
    notifyListeners();
    return sprint;
  }
}

class SettingsController extends ChangeNotifier {
  SettingsController({required AppRepository repository}) : _repository = repository;

  final AppRepository _repository;

  ThemeMode themeMode = ThemeMode.system;
  String apiBaseUrl = '';
  bool savingApiBaseUrl = false;
  bool backendConfigured = false;

  Future<void> loadPreferences() async {
    final mode = await _repository.getThemeMode();
    final baseUrl = await _repository.getApiBaseUrl();
    themeMode = _parseTheme(mode);
    apiBaseUrl = baseUrl;
    backendConfigured = await _repository.hasConfiguredBackendUrl();
    notifyListeners();
  }

  Future<void> loadTheme() async {
    final mode = await _repository.getThemeMode();
    themeMode = _parseTheme(mode);
    notifyListeners();
  }

  Future<void> setTheme(ThemeMode mode) async {
    themeMode = mode;
    notifyListeners();

    final raw = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await _repository.setThemeMode(raw);
  }

  Future<bool> saveApiBaseUrl(String rawBaseUrl) async {
    final normalized = rawBaseUrl.trim();
    if (normalized.isEmpty) {
      return false;
    }

    final parsed = Uri.tryParse(normalized);
    final valid = parsed != null && parsed.hasScheme && parsed.host.isNotEmpty;
    if (!valid) {
      return false;
    }

    savingApiBaseUrl = true;
    notifyListeners();

    await _repository.setApiBaseUrl(normalized);
    apiBaseUrl = normalized.endsWith('/')
        ? normalized.substring(0, normalized.length - 1)
        : normalized;
    backendConfigured = true;

    savingApiBaseUrl = false;
    notifyListeners();
    return true;
  }

  Future<void> markBackendConfigured() async {
    backendConfigured = true;
    notifyListeners();
  }

  ThemeMode _parseTheme(String raw) {
    switch (raw) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}

class TutorialController extends ChangeNotifier {
  TutorialController({required AppRepository repository}) : _repository = repository;

  final AppRepository _repository;

  bool seen = false;
  bool loading = false;

  Future<void> load() async {
    loading = true;
    notifyListeners();
    seen = await _repository.isTutorialSeen();
    loading = false;
    notifyListeners();
  }

  Future<void> markSeen() async {
    seen = true;
    notifyListeners();
    await _repository.setTutorialSeen(true);
  }
}

class SimulationController extends ChangeNotifier {
  SimulationController({
    required List<TaskModel> sourceTasks,
    required int durationDays,
    SimulationEngine? engine,
  })  : _engine = engine ?? SimulationEngine(),
        _tasks = sourceTasks,
        _state = SimulationState.initial(
          durationDays: durationDays,
          totalStoryPoints: sourceTasks.fold<int>(0, (sum, task) => sum + task.storyPoints),
        );

  final SimulationEngine _engine;

  SimulationState _state;
  List<TaskModel> _tasks;
  Timer? _timer;

  SimulationState get state => _state;
  List<TaskModel> get tasks => _tasks;
  bool get isPlaying => _timer?.isActive ?? false;

  void step() {
    final result = _engine.stepDay(_state, _tasks);
    _state = result.$1;
    _tasks = result.$2;
    notifyListeners();

    if (_state.completed) {
      pause();
    }
  }

  void play() {
    if (isPlaying) {
      return;
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      step();
    });
    notifyListeners();
  }

  void pause() {
    _timer?.cancel();
    _timer = null;
    notifyListeners();
  }

  void reset(List<TaskModel> nextTasks, {int durationDays = 10}) {
    pause();
    _tasks = nextTasks;
    _state = SimulationState.initial(
      durationDays: durationDays,
      totalStoryPoints: nextTasks.fold<int>(0, (sum, task) => sum + task.storyPoints),
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

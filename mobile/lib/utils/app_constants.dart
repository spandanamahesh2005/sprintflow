class AppConstants {
  static const String defaultBackendBaseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:3001');

  static const String tokenKey = 'token';
  static const String userKey = 'user';
  static const String themeModeKey = 'theme_mode';
  static const String tutorialSeenKey = 'tutorial_seen';
  static const String apiBaseUrlKey = 'api_base_url';

  static const String projectsCacheKey = 'cache_projects';
  static const String tasksCacheKey = 'cache_tasks';
  static const String usersCacheKey = 'cache_users';
  static const String sprintsCacheKey = 'cache_sprints';
}

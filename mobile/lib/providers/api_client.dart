import 'package:dio/dio.dart';

import '../utils/app_constants.dart';

class ApiClient {
  ApiClient({String? initialBaseUrl})
      : _dio = Dio(
          BaseOptions(baseUrl: _normalizeBaseUrl(initialBaseUrl ?? AppConstants.defaultBackendBaseUrl)),
        );

  final Dio _dio;

  Dio get dio => _dio;
  String get baseUrl => _dio.options.baseUrl;

  void setBaseUrl(String baseUrl) {
    _dio.options.baseUrl = _normalizeBaseUrl(baseUrl);
  }

  void setToken(String? token) {
    if (token == null || token.isEmpty) {
      _dio.options.headers.remove('Authorization');
      return;
    }
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  static String _normalizeBaseUrl(String raw) {
    final trimmed = raw.trim();
    if (trimmed.endsWith('/')) {
      return trimmed.substring(0, trimmed.length - 1);
    }
    return trimmed;
  }

  Future<Response<Map<String, dynamic>>> endProject(String projectId) {
    return _dio.patch<Map<String, dynamic>>('/projects/$projectId/end');
  }

  Future<Response<Map<String, dynamic>>> extendDeadline(String projectId, DateTime newDeadline) {
    return _dio.patch<Map<String, dynamic>>(
      '/projects/$projectId/deadline',
      data: <String, dynamic>{'newDeadline': newDeadline.toIso8601String()},
    );
  }
}

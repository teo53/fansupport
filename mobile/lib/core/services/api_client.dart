import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import 'logger_service.dart';
import 'secure_storage_service.dart';

/// HTTP 메서드
enum HttpMethod { get, post, put, patch, delete }

/// API 응답
class ApiResponse<T> {
  final int statusCode;
  final T? data;
  final String? errorMessage;
  final Map<String, String>? headers;

  ApiResponse({
    required this.statusCode,
    this.data,
    this.errorMessage,
    this.headers,
  });

  bool get isSuccess => statusCode >= 200 && statusCode < 300;
  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isServerError => statusCode >= 500;
}

/// API 예외
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  ApiException(this.message, {this.statusCode, this.originalError});

  @override
  String toString() => 'ApiException: $message (status: $statusCode)';
}

/// API 클라이언트
/// 프로덕션에서는 dio 패키지 사용 권장
/// 현재는 데모용으로 Mock 응답 제공
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final SecureStorageService _storage = SecureStorageService();

  // 요청 타임아웃
  Duration timeout = const Duration(seconds: 30);

  // 재시도 설정
  int maxRetries = 3;
  Duration retryDelay = const Duration(seconds: 1);

  /// 기본 헤더 생성
  Future<Map<String, String>> _getHeaders() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-App-Version': AppConfig.appVersion,
      'X-Platform': defaultTargetPlatform.name,
    };

    final token = await _storage.getAccessToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  /// API 요청 실행
  Future<ApiResponse<T>> request<T>({
    required String endpoint,
    required HttpMethod method,
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    Map<String, String>? additionalHeaders,
    T Function(dynamic json)? parser,
  }) async {
    final url = '${AppConfig.apiBaseUrl}$endpoint';

    logger.d('ApiClient', '${method.name.toUpperCase()} $url');

    // 데모 모드에서는 Mock 응답 반환
    if (AppConfig.isDemoMode) {
      return _getMockResponse<T>(endpoint, method, body, parser);
    }

    // TODO: 프로덕션에서 실제 HTTP 요청 구현
    // dio 패키지 사용 권장
    throw ApiException('Production API not implemented');
  }

  /// GET 요청
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? queryParams,
    T Function(dynamic json)? parser,
  }) {
    return request<T>(
      endpoint: endpoint,
      method: HttpMethod.get,
      queryParams: queryParams,
      parser: parser,
    );
  }

  /// POST 요청
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic json)? parser,
  }) {
    return request<T>(
      endpoint: endpoint,
      method: HttpMethod.post,
      body: body,
      parser: parser,
    );
  }

  /// PUT 요청
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic json)? parser,
  }) {
    return request<T>(
      endpoint: endpoint,
      method: HttpMethod.put,
      body: body,
      parser: parser,
    );
  }

  /// DELETE 요청
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    T Function(dynamic json)? parser,
  }) {
    return request<T>(
      endpoint: endpoint,
      method: HttpMethod.delete,
      parser: parser,
    );
  }

  /// Mock 응답 생성 (데모용)
  Future<ApiResponse<T>> _getMockResponse<T>(
    String endpoint,
    HttpMethod method,
    Map<String, dynamic>? body,
    T Function(dynamic json)? parser,
  ) async {
    // 네트워크 지연 시뮬레이션
    await Future.delayed(const Duration(milliseconds: 300));

    logger.d('ApiClient', '[MOCK] Returning mock response for $endpoint');

    // 성공 응답 반환
    return ApiResponse<T>(
      statusCode: 200,
      data: null,
      headers: {'X-Mock': 'true'},
    );
  }

  /// 토큰 갱신
  Future<bool> refreshToken() async {
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null) return false;

    try {
      // TODO: 실제 토큰 갱신 API 호출
      logger.i('ApiClient', 'Token refreshed successfully');
      return true;
    } catch (e) {
      logger.e('ApiClient', 'Token refresh failed', error: e);
      return false;
    }
  }

  /// 로그아웃 (토큰 삭제)
  Future<void> logout() async {
    await _storage.clearAuthData();
    logger.i('ApiClient', 'Logged out, tokens cleared');
  }
}

/// 전역 API 클라이언트 인스턴스
final apiClient = ApiClient();

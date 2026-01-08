import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'logger.dart';

/// App-specific exception types
enum AppErrorType {
  network,
  unauthorized,
  notFound,
  validation,
  server,
  unknown,
  insufficientBalance,
  timeout,
}

/// Unified app exception with localization support
class AppException implements Exception {
  final AppErrorType type;
  final String message;
  final String? localizedKey;
  final dynamic originalError;

  const AppException({
    required this.type,
    required this.message,
    this.localizedKey,
    this.originalError,
  });

  @override
  String toString() => 'AppException(type: $type, message: $message)';
}

/// Global error handler for the application
class ErrorHandler {
  /// Convert any error to AppException
  static AppException toAppException(Object error, [StackTrace? stackTrace]) {
    if (error is AppException) return error;
    if (error is DioException) return _handleDioError(error);
    if (error is AuthException) return _handleAuthError(error);
    if (error is PostgrestException) return _handlePostgrestError(error);
    if (error is SocketException) {
      return AppException(
        type: AppErrorType.network,
        message: '인터넷 연결을 확인해주세요.',
        localizedKey: 'errorNetwork',
        originalError: error,
      );
    }

    return AppException(
      type: AppErrorType.unknown,
      message: error.toString(),
      localizedKey: 'errorGeneric',
      originalError: error,
    );
  }

  static AppException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return AppException(
          type: AppErrorType.timeout,
          message: '연결 시간이 초과되었습니다. 다시 시도해주세요.',
          localizedKey: 'errorNetwork',
          originalError: error,
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 401) {
          return AppException(
            type: AppErrorType.unauthorized,
            message: '인증이 만료되었습니다. 다시 로그인해주세요.',
            localizedKey: 'errorUnauthorized',
            originalError: error,
          );
        } else if (statusCode == 404) {
          return AppException(
            type: AppErrorType.notFound,
            message: '요청한 리소스를 찾을 수 없습니다.',
            localizedKey: 'errorNotFound',
            originalError: error,
          );
        } else if (statusCode != null && statusCode >= 500) {
          return AppException(
            type: AppErrorType.server,
            message: '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.',
            localizedKey: 'errorServerError',
            originalError: error,
          );
        }
        return AppException(
          type: AppErrorType.unknown,
          message: '네트워크 오류가 발생했습니다.',
          localizedKey: 'errorGeneric',
          originalError: error,
        );

      case DioExceptionType.connectionError:
        return AppException(
          type: AppErrorType.network,
          message: '인터넷 연결을 확인해주세요.',
          localizedKey: 'errorNetwork',
          originalError: error,
        );

      default:
        return AppException(
          type: AppErrorType.unknown,
          message: '알 수 없는 오류가 발생했습니다.',
          localizedKey: 'errorGeneric',
          originalError: error,
        );
    }
  }

  static AppException _handleAuthError(AuthException error) {
    return AppException(
      type: AppErrorType.unauthorized,
      message: error.message,
      localizedKey: 'errorUnauthorized',
      originalError: error,
    );
  }

  static AppException _handlePostgrestError(PostgrestException error) {
    return AppException(
      type: AppErrorType.server,
      message: error.message,
      localizedKey: 'errorServerError',
      originalError: error,
    );
  }

  /// Handle and display error to user
  static void handle(
    BuildContext context,
    Object error, {
    StackTrace? stackTrace,
    String? tag,
  }) {
    final appError = toAppException(error, stackTrace);

    // Log error
    AppLogger.error(
      appError.message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );

    // Show user-friendly message
    _showErrorSnackBar(context, appError.message);
  }

  /// Get user-friendly error message (legacy method for compatibility)
  static String _getErrorMessage(Object error) {
    return toAppException(error).message;
  }

  /// Show error snackbar
  static void _showErrorSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: '확인',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Show success message
  static void showSuccess(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show info message
  static void showInfo(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF3B82F6),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show warning message
  static void showWarning(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber_outlined, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFF59E0B),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

/// Extension on AsyncValue for consistent error handling with guard pattern
extension AsyncValueGuardExtension<T> on AsyncValue<T> {
  /// Execute async operation with automatic error handling
  /// Returns AsyncValue.data on success, AsyncValue.error on failure
  ///
  /// Example:
  /// ```dart
  /// final result = await AsyncValueGuardExtension.guard(() async {
  ///   return await repository.fetchData();
  /// });
  /// ```
  static Future<AsyncValue<T>> guard<T>(
    Future<T> Function() future,
  ) async {
    try {
      final result = await future();
      return AsyncValue.data(result);
    } catch (e, st) {
      final appError = ErrorHandler.toAppException(e, st);
      return AsyncValue.error(appError, st);
    }
  }
}

/// Mixin for StateNotifiers to use guard pattern with AsyncValue state
///
/// Example:
/// ```dart
/// class UserNotifier extends StateNotifier<AsyncValue<User>>
///     with AsyncGuardMixin<User> {
///
///   Future<void> fetchUser(String id) async {
///     await guardedOperation(() => repository.getUser(id));
///   }
/// }
/// ```
mixin AsyncGuardMixin<T> on StateNotifier<AsyncValue<T>> {
  /// Execute operation with loading state and error handling
  Future<void> guardedOperation(Future<T> Function() operation) async {
    state = const AsyncValue.loading();
    try {
      final result = await operation();
      state = AsyncValue.data(result);
    } catch (e, st) {
      final appError = ErrorHandler.toAppException(e, st);
      state = AsyncValue.error(appError, st);
    }
  }

  /// Execute operation without changing state to loading first
  Future<void> silentGuardedOperation(Future<T> Function() operation) async {
    try {
      final result = await operation();
      state = AsyncValue.data(result);
    } catch (e, st) {
      final appError = ErrorHandler.toAppException(e, st);
      state = AsyncValue.error(appError, st);
    }
  }

  /// Execute operation and return whether it was successful
  Future<bool> tryOperation(Future<T> Function() operation) async {
    try {
      final result = await operation();
      state = AsyncValue.data(result);
      return true;
    } catch (e, st) {
      final appError = ErrorHandler.toAppException(e, st);
      state = AsyncValue.error(appError, st);
      return false;
    }
  }
}

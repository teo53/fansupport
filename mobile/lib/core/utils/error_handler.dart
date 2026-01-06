import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'logger.dart';

/// Global error handler for the application
class ErrorHandler {
  /// Handle and display error to user
  static void handle(
    BuildContext context,
    Object error, {
    StackTrace? stackTrace,
    String? tag,
  }) {
    final errorMessage = _getErrorMessage(error);

    // Log error
    AppLogger.error(
      errorMessage,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );

    // Show user-friendly message
    _showErrorSnackBar(context, errorMessage);
  }

  /// Get user-friendly error message
  static String _getErrorMessage(Object error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return '연결 시간이 초과되었습니다. 다시 시도해주세요.';

        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          if (statusCode == 401) {
            return '인증이 만료되었습니다. 다시 로그인해주세요.';
          } else if (statusCode == 403) {
            return '접근 권한이 없습니다.';
          } else if (statusCode == 404) {
            return '요청한 리소스를 찾을 수 없습니다.';
          } else if (statusCode == 500) {
            return '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
          }
          return '네트워크 오류가 발생했습니다. (${statusCode ?? 'Unknown'})';

        case DioExceptionType.cancel:
          return '요청이 취소되었습니다.';

        case DioExceptionType.connectionError:
          return '인터넷 연결을 확인해주세요.';

        case DioExceptionType.badCertificate:
          return '보안 인증서 오류가 발생했습니다.';

        case DioExceptionType.unknown:
        default:
          return '알 수 없는 오류가 발생했습니다.';
      }
    }

    // Generic error
    return error.toString();
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

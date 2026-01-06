import 'package:flutter/foundation.dart';

/// Application logger utility
///
/// Provides structured logging with different levels:
/// - debug: Development information
/// - info: General information
/// - warning: Warning messages
/// - error: Error messages with stack trace
class AppLogger {
  static const String _prefix = '[PIPO]';

  /// Log debug message (only in debug mode)
  static void debug(String message, [String? tag]) {
    if (kDebugMode) {
      final tagStr = tag != null ? '[$tag]' : '';
      debugPrint('$_prefix [DEBUG] $tagStr $message');
    }
  }

  /// Log info message
  static void info(String message, [String? tag]) {
    final tagStr = tag != null ? '[$tag]' : '';
    debugPrint('$_prefix [INFO] $tagStr $message');
  }

  /// Log warning message
  static void warning(String message, [String? tag]) {
    final tagStr = tag != null ? '[$tag]' : '';
    debugPrint('$_prefix [WARNING] $tagStr $message');
  }

  /// Log error message with optional stack trace
  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final tagStr = tag != null ? '[$tag]' : '';
    debugPrint('$_prefix [ERROR] $tagStr $message');

    if (error != null) {
      debugPrint('Error details: $error');
    }

    if (stackTrace != null) {
      debugPrint('Stack trace:\n$stackTrace');
    }
  }

  /// Log network request
  static void network(String method, String url, {int? statusCode}) {
    final status = statusCode != null ? ' - $statusCode' : '';
    debug('$method $url$status', 'NETWORK');
  }

  /// Log analytics event
  static void analytics(String eventName, Map<String, dynamic>? params) {
    debug('Event: $eventName ${params ?? ''}', 'ANALYTICS');
  }
}

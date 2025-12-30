import 'package:flutter/foundation.dart';

/// 로그 레벨
enum LogLevel {
  verbose,
  debug,
  info,
  warning,
  error,
  fatal,
}

/// 로그 엔트리
class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final String tag;
  final String message;
  final dynamic error;
  final StackTrace? stackTrace;

  LogEntry({
    required this.timestamp,
    required this.level,
    required this.tag,
    required this.message,
    this.error,
    this.stackTrace,
  });

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write('[${timestamp.toIso8601String()}] ');
    buffer.write('[${level.name.toUpperCase()}] ');
    buffer.write('[$tag] ');
    buffer.write(message);
    if (error != null) {
      buffer.write('\nError: $error');
    }
    if (stackTrace != null) {
      buffer.write('\nStackTrace: $stackTrace');
    }
    return buffer.toString();
  }
}

/// 로거 서비스
/// 앱 전체에서 일관된 로깅 제공
class LoggerService {
  static final LoggerService _instance = LoggerService._internal();
  factory LoggerService() => _instance;
  LoggerService._internal();

  // 로그 저장 (최근 1000개)
  final List<LogEntry> _logs = [];
  static const int _maxLogs = 1000;

  // 현재 로그 레벨 (이 레벨 이상만 출력)
  LogLevel _minLevel = kDebugMode ? LogLevel.verbose : LogLevel.info;

  /// 로그 레벨 설정
  void setMinLevel(LogLevel level) {
    _minLevel = level;
  }

  /// 로그 기록
  void log(
    LogLevel level,
    String tag,
    String message, {
    dynamic error,
    StackTrace? stackTrace,
  }) {
    if (level.index < _minLevel.index) return;

    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      tag: tag,
      message: message,
      error: error,
      stackTrace: stackTrace,
    );

    _logs.add(entry);
    if (_logs.length > _maxLogs) {
      _logs.removeAt(0);
    }

    // 콘솔 출력
    _printLog(entry);
  }

  void _printLog(LogEntry entry) {
    final emoji = switch (entry.level) {
      LogLevel.verbose => '📝',
      LogLevel.debug => '🔍',
      LogLevel.info => 'ℹ️',
      LogLevel.warning => '⚠️',
      LogLevel.error => '❌',
      LogLevel.fatal => '💀',
    };

    debugPrint('$emoji ${entry.toString()}');
  }

  // ============ 편의 메서드 ============

  void v(String tag, String message) => log(LogLevel.verbose, tag, message);
  void d(String tag, String message) => log(LogLevel.debug, tag, message);
  void i(String tag, String message) => log(LogLevel.info, tag, message);
  void w(String tag, String message) => log(LogLevel.warning, tag, message);

  void e(String tag, String message, {dynamic error, StackTrace? stackTrace}) {
    log(LogLevel.error, tag, message, error: error, stackTrace: stackTrace);
  }

  void f(String tag, String message, {dynamic error, StackTrace? stackTrace}) {
    log(LogLevel.fatal, tag, message, error: error, stackTrace: stackTrace);
  }

  /// 모든 로그 조회
  List<LogEntry> getAllLogs() => List.unmodifiable(_logs);

  /// 레벨별 로그 조회
  List<LogEntry> getLogsByLevel(LogLevel level) {
    return _logs.where((log) => log.level == level).toList();
  }

  /// 태그별 로그 조회
  List<LogEntry> getLogsByTag(String tag) {
    return _logs.where((log) => log.tag == tag).toList();
  }

  /// 로그 초기화
  void clear() {
    _logs.clear();
  }

  /// 에러 로그만 추출 (크래시 리포트용)
  String getErrorReport() {
    final errors = _logs.where((log) =>
      log.level == LogLevel.error || log.level == LogLevel.fatal
    ).toList();

    if (errors.isEmpty) return 'No errors recorded';

    return errors.map((e) => e.toString()).join('\n\n');
  }
}

/// 전역 로거 인스턴스
final logger = LoggerService();

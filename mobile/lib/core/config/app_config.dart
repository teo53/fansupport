import 'package:flutter/foundation.dart';

/// 앱 환경
enum AppEnvironment {
  development,
  staging,
  production,
}

/// 앱 설정
/// 환경별 설정 관리
class AppConfig {
  static AppEnvironment _environment = AppEnvironment.development;
  static bool _isDemoMode = true; // 데모 모드 플래그

  /// 현재 환경 조회
  static AppEnvironment get environment => _environment;

  /// 데모 모드 여부
  static bool get isDemoMode => _isDemoMode;

  /// 환경 설정
  static void setEnvironment(AppEnvironment env) {
    _environment = env;
    debugPrint('[AppConfig] Environment set to: ${env.name}');
  }

  /// 데모 모드 설정
  static void setDemoMode(bool enabled) {
    _isDemoMode = enabled;
    debugPrint('[AppConfig] Demo mode: $enabled');
  }

  /// 앱 버전
  static const String appVersion = '1.0.0';
  static const int buildNumber = 1;

  /// API 기본 URL
  static String get apiBaseUrl {
    return switch (_environment) {
      AppEnvironment.development => 'https://dev-api.fansupport.app',
      AppEnvironment.staging => 'https://staging-api.fansupport.app',
      AppEnvironment.production => 'https://api.fansupport.app',
    };
  }

  /// WebSocket URL
  static String get wsBaseUrl {
    return switch (_environment) {
      AppEnvironment.development => 'wss://dev-api.fansupport.app/ws',
      AppEnvironment.staging => 'wss://staging-api.fansupport.app/ws',
      AppEnvironment.production => 'wss://api.fansupport.app/ws',
    };
  }

  /// 이미지 CDN URL
  static String get cdnBaseUrl {
    return switch (_environment) {
      AppEnvironment.development => 'https://dev-cdn.fansupport.app',
      AppEnvironment.staging => 'https://staging-cdn.fansupport.app',
      AppEnvironment.production => 'https://cdn.fansupport.app',
    };
  }

  /// 디버그 모드 여부
  static bool get isDebug => kDebugMode;

  /// 프로덕션 여부
  static bool get isProduction => _environment == AppEnvironment.production;

  /// 로깅 활성화 여부
  static bool get enableLogging => !isProduction || kDebugMode;

  /// Analytics 활성화 여부
  static bool get enableAnalytics => isProduction;

  /// Crashlytics 활성화 여부
  static bool get enableCrashlytics => isProduction;

  // ============ 기능 플래그 ============

  /// 푸시 알림 활성화
  static bool get enablePushNotifications => true;

  /// 생체 인증 활성화
  static bool get enableBiometricAuth => true;

  /// 다크 모드 지원
  static bool get enableDarkMode => true;

  /// 오프라인 모드 지원
  static bool get enableOfflineMode => false; // TODO: 구현 후 활성화

  /// 실험 기능 활성화
  static bool get enableExperimentalFeatures => !isProduction;

  // ============ 제한값 ============

  /// 최대 이미지 업로드 크기 (MB)
  static const int maxImageUploadSizeMb = 10;

  /// 최대 비디오 업로드 크기 (MB)
  static const int maxVideoUploadSizeMb = 100;

  /// 게시물 최대 글자 수
  static const int maxPostLength = 2000;

  /// 댓글 최대 글자 수
  static const int maxCommentLength = 500;

  /// 페이지당 아이템 수
  static const int pageSize = 20;

  /// 캐시 유효 시간 (분)
  static const int cacheExpirationMinutes = 30;

  // ============ 외부 서비스 ============

  /// 결제 테스트 모드
  static bool get isPaymentTestMode => !isProduction;

  /// 소셜 로그인 설정
  static const Map<String, bool> socialLoginEnabled = {
    'google': true,
    'apple': true,
    'kakao': true,
    'twitter': true,
  };

  /// 설정 요약 출력
  static void printConfig() {
    debugPrint('╔══════════════════════════════════════╗');
    debugPrint('║         FanSupport App Config        ║');
    debugPrint('╠══════════════════════════════════════╣');
    debugPrint('║ Environment: ${_environment.name.padRight(22)}║');
    debugPrint('║ Demo Mode: ${_isDemoMode.toString().padRight(24)}║');
    debugPrint('║ Version: $appVersion (Build $buildNumber)'.padRight(39) + '║');
    debugPrint('║ Debug: ${isDebug.toString().padRight(27)}║');
    debugPrint('╚══════════════════════════════════════╝');
  }
}

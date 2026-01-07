import 'environment.dart';

/// Supabase Configuration
///
/// 환경별 Supabase 설정을 관리합니다.
/// EnvironmentConfig를 통해 dev/staging/production 환경을 자동으로 구분합니다.
///
/// 사용법:
/// 1. https://app.supabase.com 에서 프로젝트 생성
/// 2. Project Settings > API > URL과 anon key 복사
/// 3. scripts/run_dev.sh, run_staging.sh, run_prod.sh 파일에서 값 업데이트
///
/// 실행:
/// - Dev: ./scripts/run_dev.sh
/// - Staging: ./scripts/run_staging.sh
/// - Production: ./scripts/run_prod.sh

class SupabaseConfig {
  SupabaseConfig._();

  // Environment-aware Supabase URL
  static String get url => EnvironmentConfig.supabaseUrl;

  // Environment-aware Supabase Anonymous Key
  static String get anonKey => EnvironmentConfig.supabaseAnonKey;

  // Realtime 설정
  static Map<String, String> get realtimeConfig {
    return {
      'log_level': EnvironmentConfig.enableLogging ? 'info' : 'error',
    };
  }

  // Connection timeout
  static Duration get timeout => EnvironmentConfig.apiTimeout;

  // Max retry attempts
  static int get maxRetries => EnvironmentConfig.maxRetries;

  // Print configuration (dev only)
  static void printConfig() {
    if (!EnvironmentConfig.enableLogging) return;

    print('📡 Supabase Configuration:');
    print('   URL: $url');
    print('   Timeout: ${timeout.inSeconds}s');
    print('   Max Retries: $maxRetries');
  }
}

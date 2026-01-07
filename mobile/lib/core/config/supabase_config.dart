/// Supabase Configuration
///
/// Supabase 프로젝트 설정
/// 1. https://app.supabase.com 에서 프로젝트 생성
/// 2. Project Settings > API > URL과 anon key 복사
/// 3. 아래 값 업데이트

class SupabaseConfig {
  // Supabase Project URL
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://your-project-id.supabase.co',
  );

  // Supabase Anonymous Key
  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'your-anon-key-here',
  );

  // Realtime 설정
  static const realtimeConfig = {
    'log_level': 'info',
  };
}

import 'package:flutter/material.dart';

/// 지원 언어
enum AppLocale {
  ko('ko', '한국어'),
  ja('ja', '日本語'),
  en('en', 'English');

  final String code;
  final String nativeName;

  const AppLocale(this.code, this.nativeName);

  Locale get locale => Locale(code);

  static AppLocale fromCode(String code) {
    return AppLocale.values.firstWhere(
      (l) => l.code == code,
      orElse: () => AppLocale.ko,
    );
  }
}

/// 앱 문자열 리소스
/// 다국어 지원을 위한 문자열 관리
class AppStrings {
  final AppLocale locale;

  AppStrings(this.locale);

  // ============ 공통 ============
  String get appName => _get({
    AppLocale.ko: 'FanSupport',
    AppLocale.ja: 'FanSupport',
    AppLocale.en: 'FanSupport',
  });

  String get ok => _get({
    AppLocale.ko: '확인',
    AppLocale.ja: 'OK',
    AppLocale.en: 'OK',
  });

  String get cancel => _get({
    AppLocale.ko: '취소',
    AppLocale.ja: 'キャンセル',
    AppLocale.en: 'Cancel',
  });

  String get save => _get({
    AppLocale.ko: '저장',
    AppLocale.ja: '保存',
    AppLocale.en: 'Save',
  });

  String get delete => _get({
    AppLocale.ko: '삭제',
    AppLocale.ja: '削除',
    AppLocale.en: 'Delete',
  });

  String get edit => _get({
    AppLocale.ko: '수정',
    AppLocale.ja: '編集',
    AppLocale.en: 'Edit',
  });

  String get close => _get({
    AppLocale.ko: '닫기',
    AppLocale.ja: '閉じる',
    AppLocale.en: 'Close',
  });

  String get retry => _get({
    AppLocale.ko: '다시 시도',
    AppLocale.ja: 'リトライ',
    AppLocale.en: 'Retry',
  });

  String get loading => _get({
    AppLocale.ko: '로딩 중...',
    AppLocale.ja: '読み込み中...',
    AppLocale.en: 'Loading...',
  });

  // ============ 네비게이션 ============
  String get home => _get({
    AppLocale.ko: '홈',
    AppLocale.ja: 'ホーム',
    AppLocale.en: 'Home',
  });

  String get search => _get({
    AppLocale.ko: '검색',
    AppLocale.ja: '検索',
    AppLocale.en: 'Search',
  });

  String get calendar => _get({
    AppLocale.ko: '캘린더',
    AppLocale.ja: 'カレンダー',
    AppLocale.en: 'Calendar',
  });

  String get profile => _get({
    AppLocale.ko: '프로필',
    AppLocale.ja: 'プロフィール',
    AppLocale.en: 'Profile',
  });

  String get settings => _get({
    AppLocale.ko: '설정',
    AppLocale.ja: '設定',
    AppLocale.en: 'Settings',
  });

  // ============ 인증 ============
  String get login => _get({
    AppLocale.ko: '로그인',
    AppLocale.ja: 'ログイン',
    AppLocale.en: 'Login',
  });

  String get logout => _get({
    AppLocale.ko: '로그아웃',
    AppLocale.ja: 'ログアウト',
    AppLocale.en: 'Logout',
  });

  String get register => _get({
    AppLocale.ko: '회원가입',
    AppLocale.ja: '新規登録',
    AppLocale.en: 'Sign Up',
  });

  String get email => _get({
    AppLocale.ko: '이메일',
    AppLocale.ja: 'メール',
    AppLocale.en: 'Email',
  });

  String get password => _get({
    AppLocale.ko: '비밀번호',
    AppLocale.ja: 'パスワード',
    AppLocale.en: 'Password',
  });

  String get demoLogin => _get({
    AppLocale.ko: '데모 로그인',
    AppLocale.ja: 'デモログイン',
    AppLocale.en: 'Demo Login',
  });

  // ============ 피드 ============
  String get recommend => _get({
    AppLocale.ko: '추천',
    AppLocale.ja: 'おすすめ',
    AppLocale.en: 'For You',
  });

  String get following => _get({
    AppLocale.ko: '팔로잉',
    AppLocale.ja: 'フォロー中',
    AppLocale.en: 'Following',
  });

  String get popular => _get({
    AppLocale.ko: '인기',
    AppLocale.ja: '人気',
    AppLocale.en: 'Popular',
  });

  String get like => _get({
    AppLocale.ko: '좋아요',
    AppLocale.ja: 'いいね',
    AppLocale.en: 'Like',
  });

  String get comment => _get({
    AppLocale.ko: '댓글',
    AppLocale.ja: 'コメント',
    AppLocale.en: 'Comment',
  });

  String get share => _get({
    AppLocale.ko: '공유',
    AppLocale.ja: 'シェア',
    AppLocale.en: 'Share',
  });

  String get bookmark => _get({
    AppLocale.ko: '북마크',
    AppLocale.ja: 'ブックマーク',
    AppLocale.en: 'Bookmark',
  });

  // ============ 아이돌 ============
  String get idol => _get({
    AppLocale.ko: '아이돌',
    AppLocale.ja: 'アイドル',
    AppLocale.en: 'Idol',
  });

  String get follow => _get({
    AppLocale.ko: '팔로우',
    AppLocale.ja: 'フォロー',
    AppLocale.en: 'Follow',
  });

  String get unfollow => _get({
    AppLocale.ko: '언팔로우',
    AppLocale.ja: 'フォロー解除',
    AppLocale.en: 'Unfollow',
  });

  String get subscribe => _get({
    AppLocale.ko: '구독',
    AppLocale.ja: '購読',
    AppLocale.en: 'Subscribe',
  });

  String get support => _get({
    AppLocale.ko: '후원',
    AppLocale.ja: '応援',
    AppLocale.en: 'Support',
  });

  // ============ 카테고리 ============
  String get undergroundIdol => _get({
    AppLocale.ko: '지하돌',
    AppLocale.ja: '地下アイドル',
    AppLocale.en: 'Underground Idol',
  });

  String get maidCafe => _get({
    AppLocale.ko: '메이드카페',
    AppLocale.ja: 'メイドカフェ',
    AppLocale.en: 'Maid Cafe',
  });

  String get cosplayer => _get({
    AppLocale.ko: '코스플레이어',
    AppLocale.ja: 'コスプレイヤー',
    AppLocale.en: 'Cosplayer',
  });

  String get vtuber => _get({
    AppLocale.ko: '버튜버',
    AppLocale.ja: 'VTuber',
    AppLocale.en: 'VTuber',
  });

  // ============ 에러 ============
  String get errorGeneric => _get({
    AppLocale.ko: '오류가 발생했습니다',
    AppLocale.ja: 'エラーが発生しました',
    AppLocale.en: 'An error occurred',
  });

  String get errorNetwork => _get({
    AppLocale.ko: '네트워크 연결을 확인해주세요',
    AppLocale.ja: 'ネットワーク接続を確認してください',
    AppLocale.en: 'Please check your network connection',
  });

  String get errorServer => _get({
    AppLocale.ko: '서버에 문제가 발생했습니다',
    AppLocale.ja: 'サーバーに問題が発生しました',
    AppLocale.en: 'Server error occurred',
  });

  // ============ 준비 중 ============
  String get featureInProgress => _get({
    AppLocale.ko: '준비 중입니다',
    AppLocale.ja: '準備中です',
    AppLocale.en: 'Coming soon',
  });

  // ============ 유틸리티 메서드 ============
  String _get(Map<AppLocale, String> values) {
    return values[locale] ?? values[AppLocale.ko] ?? '';
  }

  /// 포맷 문자열 (인자 대입)
  String format(String template, List<dynamic> args) {
    String result = template;
    for (int i = 0; i < args.length; i++) {
      result = result.replaceAll('{$i}', args[i].toString());
    }
    return result;
  }
}

/// 현재 활성 로케일 (전역)
AppLocale _currentLocale = AppLocale.ko;

AppLocale get currentLocale => _currentLocale;

void setLocale(AppLocale locale) {
  _currentLocale = locale;
}

/// 문자열 리소스 접근
AppStrings get strings => AppStrings(_currentLocale);

/// BuildContext 확장 - 문자열 접근
extension LocalizationContext on BuildContext {
  AppStrings get strings => AppStrings(_currentLocale);
}

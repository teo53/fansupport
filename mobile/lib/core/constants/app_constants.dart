class AppConstants {
  static const String appName = '아이돌 서포트';
  static const String appNameEn = 'Idol Support';

  // API
  static const String baseUrl = 'https://api.idol-support.com';
  static const String devBaseUrl = 'http://localhost:3000';

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';

  // Timeouts
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;

  // Pagination
  static const int defaultPageSize = 20;

  // Support
  static const int minSupportAmount = 100;
  static const int maxSupportAmount = 10000000;

  // Subscription
  static const int minSubscriptionPrice = 1000;
}

/// 데모 계정 정보
class DemoCredentials {
  DemoCredentials._();

  static const String email = 'demo@fansupport.com';
  static const String testEmail = 'demo@test.com';
  static const String password = 'password';
  static const String userId = 'demo_user_1';
  static const String nickname = '열혈팬';
  static const String bio = '아이돌을 사랑하는 팬입니다 💕';
}

/// UI 관련 상수
class UIConstants {
  UIConstants._();

  // 애니메이션 지속시간
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // 스낵바 지속시간
  static const Duration snackBarShort = Duration(seconds: 2);
  static const Duration snackBarNormal = Duration(seconds: 4);

  // 디바운스 시간
  static const Duration debounceDelay = Duration(milliseconds: 300);
  static const Duration searchDebounce = Duration(milliseconds: 500);

  // Mock 딜레이
  static const Duration mockDelay = Duration(milliseconds: 300);
  static const Duration shortMockDelay = Duration(milliseconds: 200);

  // 입력 제한
  static const int maxNicknameLength = 20;
  static const int minNicknameLength = 2;
  static const int maxBioLength = 200;
  static const int maxCommentLength = 500;
}

/// 아바타 이미지 URL 생성
class AvatarUrls {
  AvatarUrls._();

  static const String _baseUrl = 'https://api.dicebear.com/7.x/adventurer-neutral/svg';

  /// seed 기반 아바타 URL 생성
  static String generate(String seed) => '$_baseUrl?seed=$seed';

  /// 기본 아바타
  static const String defaultAvatar = '$_baseUrl?seed=default';

  /// 익명 아바타
  static const String anonymous = '$_baseUrl?seed=anonymous';
}

/// 라우트 경로
class RoutePaths {
  RoutePaths._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String search = '/search';
  static const String profile = '/profile';
  static const String settings = '/settings';

  // 동적 라우트
  static String idol(String id) => '/idols/$id';
  static String post(String id) => '/posts/$id';
  static String campaign(String id) => '/campaigns/$id';
}

/// 에러 메시지
class ErrorMessages {
  ErrorMessages._();

  static const String generic = '오류가 발생했습니다';
  static const String network = '네트워크 연결을 확인해주세요';
  static const String server = '서버에 문제가 발생했습니다';
  static const String timeout = '요청 시간이 초과되었습니다';
  static const String unauthorized = '로그인이 필요합니다';
  static const String invalidCredentials = '이메일 또는 비밀번호가 올바르지 않습니다';
  static const String sessionExpired = '세션이 만료되었습니다. 다시 로그인해주세요';
}

class ApiEndpoints {
  // Auth
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String refresh = '/api/auth/refresh';
  static const String logout = '/api/auth/logout';
  static const String googleAuth = '/api/auth/google';

  // Users
  static const String me = '/api/users/me';
  static const String users = '/api/users';
  static const String idols = '/api/users/idols';
  static const String idolRanking = '/api/users/idols/ranking';

  // Wallet
  static const String wallet = '/api/wallet';
  static const String walletBalance = '/api/wallet/balance';
  static const String transactions = '/api/wallet/transactions';

  // Support
  static const String support = '/api/support';
  static const String supportSent = '/api/support/sent';
  static const String supportReceived = '/api/support/received';

  // Subscription
  static const String subscriptions = '/api/subscriptions';
  static const String subscriptionTiers = '/api/subscriptions/tiers';
  static const String mySubscriptions = '/api/subscriptions/my-subscriptions';

  // Campaign
  static const String campaigns = '/api/campaigns';
  static const String myCampaigns = '/api/campaigns/my-campaigns';
  static const String myContributions = '/api/campaigns/my-contributions';

  // Booking
  static const String bookings = '/api/bookings';
  static const String upcomingBookings = '/api/bookings/upcoming';
  static const String availableSlots = '/api/bookings/available-slots';

  // Community
  static const String posts = '/api/community/posts';
  static const String feed = '/api/community/feed';

  // Payment
  static const String createPaymentIntent = '/api/payments/create-intent';
  static const String verifyIAP = '/api/payments/verify-iap';
  static const String paymentHistory = '/api/payments';
}

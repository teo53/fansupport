class AppConstants {
  static const String appName = '아이돌 서포트';
  static const String appNameEn = 'Idol Support';

  // API
  static const String baseUrl = 'https://api.idol-support.com';
  static const String devBaseUrl = 'http://localhost:3000';

  // Use dev URL for development, production URL for release
  static const String apiBaseUrl = devBaseUrl; // Change to baseUrl for production

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

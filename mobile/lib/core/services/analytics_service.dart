import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import 'logger_service.dart';

/// 분석 이벤트 타입
enum AnalyticsEventType {
  // 화면 조회
  screenView,

  // 사용자 액션
  buttonClick,
  tabChange,
  scroll,

  // 콘텐츠 상호작용
  like,
  comment,
  share,
  bookmark,
  follow,

  // 구매/결제
  viewProduct,
  addToCart,
  purchase,
  subscribe,
  donate,

  // 검색
  search,

  // 에러
  error,

  // 커스텀
  custom,
}

/// 분석 이벤트
class AnalyticsEvent {
  final AnalyticsEventType type;
  final String name;
  final Map<String, dynamic>? parameters;
  final DateTime timestamp;

  AnalyticsEvent({
    required this.type,
    required this.name,
    this.parameters,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'name': name,
      'parameters': parameters,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// 분석 서비스
/// Firebase Analytics, Amplitude 등 연동 기반
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  // 분석 활성화 여부
  bool get isEnabled => AppConfig.enableAnalytics;

  // 사용자 ID
  String? _userId;

  // 사용자 속성
  final Map<String, String> _userProperties = {};

  /// 초기화
  Future<void> initialize() async {
    if (!isEnabled) {
      debugPrint('[AnalyticsService] Disabled in current environment');
      return;
    }

    // TODO: Firebase Analytics 초기화
    debugPrint('[AnalyticsService] Initialized');
  }

  /// 사용자 ID 설정
  void setUserId(String? userId) {
    _userId = userId;
    // TODO: Firebase/Amplitude에 사용자 ID 설정
    logger.d('Analytics', 'User ID set: ${userId != null ? "***" : "null"}');
  }

  /// 사용자 속성 설정
  void setUserProperty(String name, String value) {
    _userProperties[name] = value;
    // TODO: Firebase/Amplitude에 사용자 속성 설정
    logger.d('Analytics', 'User property set: $name');
  }

  /// 이벤트 로깅
  void logEvent(AnalyticsEvent event) {
    if (!isEnabled) return;

    // TODO: Firebase/Amplitude에 이벤트 전송
    logger.d('Analytics', 'Event: ${event.name} (${event.type.name})');

    if (kDebugMode) {
      debugPrint('[AnalyticsService] ${event.toMap()}');
    }
  }

  // ============ 편의 메서드 ============

  /// 화면 조회
  void logScreenView(String screenName, {String? screenClass}) {
    logEvent(AnalyticsEvent(
      type: AnalyticsEventType.screenView,
      name: 'screen_view',
      parameters: {
        'screen_name': screenName,
        if (screenClass != null) 'screen_class': screenClass,
      },
    ));
  }

  /// 버튼 클릭
  void logButtonClick(String buttonName, {Map<String, dynamic>? extra}) {
    logEvent(AnalyticsEvent(
      type: AnalyticsEventType.buttonClick,
      name: 'button_click',
      parameters: {
        'button_name': buttonName,
        ...?extra,
      },
    ));
  }

  /// 좋아요
  void logLike(String contentId, String contentType) {
    logEvent(AnalyticsEvent(
      type: AnalyticsEventType.like,
      name: 'like',
      parameters: {
        'content_id': contentId,
        'content_type': contentType,
      },
    ));
  }

  /// 팔로우
  void logFollow(String targetId, String targetType) {
    logEvent(AnalyticsEvent(
      type: AnalyticsEventType.follow,
      name: 'follow',
      parameters: {
        'target_id': targetId,
        'target_type': targetType,
      },
    ));
  }

  /// 검색
  void logSearch(String query, {int? resultCount}) {
    logEvent(AnalyticsEvent(
      type: AnalyticsEventType.search,
      name: 'search',
      parameters: {
        'query': query,
        if (resultCount != null) 'result_count': resultCount,
      },
    ));
  }

  /// 상품 조회
  void logViewProduct(String productId, String productName, {int? price}) {
    logEvent(AnalyticsEvent(
      type: AnalyticsEventType.viewProduct,
      name: 'view_product',
      parameters: {
        'product_id': productId,
        'product_name': productName,
        if (price != null) 'price': price,
      },
    ));
  }

  /// 구매
  void logPurchase({
    required String transactionId,
    required int amount,
    required String currency,
    String? productType,
  }) {
    logEvent(AnalyticsEvent(
      type: AnalyticsEventType.purchase,
      name: 'purchase',
      parameters: {
        'transaction_id': transactionId,
        'amount': amount,
        'currency': currency,
        if (productType != null) 'product_type': productType,
      },
    ));
  }

  /// 구독
  void logSubscribe(String idolId, String tierName, int price) {
    logEvent(AnalyticsEvent(
      type: AnalyticsEventType.subscribe,
      name: 'subscribe',
      parameters: {
        'idol_id': idolId,
        'tier_name': tierName,
        'price': price,
      },
    ));
  }

  /// 후원
  void logDonate(String idolId, int amount) {
    logEvent(AnalyticsEvent(
      type: AnalyticsEventType.donate,
      name: 'donate',
      parameters: {
        'idol_id': idolId,
        'amount': amount,
      },
    ));
  }

  /// 에러
  void logError(String errorType, String message, {dynamic error}) {
    logEvent(AnalyticsEvent(
      type: AnalyticsEventType.error,
      name: 'error',
      parameters: {
        'error_type': errorType,
        'message': message,
        if (error != null) 'error_detail': error.toString(),
      },
    ));
  }

  /// 커스텀 이벤트
  void logCustomEvent(String eventName, {Map<String, dynamic>? parameters}) {
    logEvent(AnalyticsEvent(
      type: AnalyticsEventType.custom,
      name: eventName,
      parameters: parameters,
    ));
  }
}

/// 전역 인스턴스
final analytics = AnalyticsService();

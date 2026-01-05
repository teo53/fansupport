/// 🎖️ 서포터 (후원자) 모델
/// 후원 + 펀딩 참여 통합 랭킹
class SupporterModel {
  final String id;
  final String userId;
  final String nickname;
  final String? profileImage;
  final bool isVerified;

  // 후원 내역
  final int totalSupport; // 총 후원 금액 (일회성 후원)
  final int totalFunding; // 총 펀딩 참여 금액
  final int totalAmount; // 총 금액 (후원 + 펀딩)

  // 통계
  final int supportCount; // 후원 횟수
  final int fundingCount; // 펀딩 참여 횟수
  final DateTime firstSupportDate; // 첫 후원 날짜
  final DateTime lastSupportDate; // 마지막 후원 날짜

  // 구독 정보
  final bool isSubscriber; // 현재 구독 중
  final String? subscriptionTier; // 구독 티어 (라이트/프리미엄/VIP)
  final DateTime? subscriptionStartDate; // 구독 시작일

  // 뱃지
  final List<String> badges; // 획득한 뱃지 목록

  const SupporterModel({
    required this.id,
    required this.userId,
    required this.nickname,
    this.profileImage,
    this.isVerified = false,
    required this.totalSupport,
    required this.totalFunding,
    required this.totalAmount,
    this.supportCount = 0,
    this.fundingCount = 0,
    required this.firstSupportDate,
    required this.lastSupportDate,
    this.isSubscriber = false,
    this.subscriptionTier,
    this.subscriptionStartDate,
    this.badges = const [],
  });

  /// 랭킹 (1위, 2위, 3위)
  SupporterTier get tier {
    // 실제로는 전체 서포터 중 순위를 계산해야 하지만
    // 여기서는 금액 기준으로 티어 계산
    if (totalAmount >= 1000000) return SupporterTier.diamond; // 100만원+
    if (totalAmount >= 500000) return SupporterTier.platinum; // 50만원+
    if (totalAmount >= 100000) return SupporterTier.gold; // 10만원+
    return SupporterTier.silver;
  }

  /// 지속 기간 (일)
  int get supportDuration {
    return lastSupportDate.difference(firstSupportDate).inDays + 1;
  }

  /// 베스트 서포터 여부 (TOP 3)
  bool get isBestSupporter {
    return totalAmount >= 100000; // 10만원 이상
  }
}

/// 서포터 티어
enum SupporterTier {
  diamond, // 다이아몬드 (100만원+)
  platinum, // 플래티넘 (50만원+)
  gold, // 골드 (10만원+)
  silver, // 실버
}

extension SupporterTierExtension on SupporterTier {
  String get displayName {
    switch (this) {
      case SupporterTier.diamond:
        return '다이아몬드';
      case SupporterTier.platinum:
        return '플래티넘';
      case SupporterTier.gold:
        return '골드';
      case SupporterTier.silver:
        return '실버';
    }
  }

  String get icon {
    switch (this) {
      case SupporterTier.diamond:
        return '💎';
      case SupporterTier.platinum:
        return '🌟';
      case SupporterTier.gold:
        return '👑';
      case SupporterTier.silver:
        return '🥈';
    }
  }

  String get color {
    switch (this) {
      case SupporterTier.diamond:
        return '#00E5FF'; // Cyan
      case SupporterTier.platinum:
        return '#E0E0E0'; // Platinum
      case SupporterTier.gold:
        return '#FFD700'; // Gold
      case SupporterTier.silver:
        return '#C0C0C0'; // Silver
    }
  }
}

/// 서포터 배지
class SupporterBadge {
  final String id;
  final String name;
  final String description;
  final String icon;

  const SupporterBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
  });
}

/// 기본 서포터 배지 목록
class SupporterBadges {
  static const firstSupporter = SupporterBadge(
    id: 'first_supporter',
    name: '얼리 서포터',
    description: '첫 100명의 후원자',
    icon: '🎖️',
  );

  static const loyalSupporter = SupporterBadge(
    id: 'loyal_supporter',
    name: '로열 팬',
    description: '1년 이상 지속 후원',
    icon: '💝',
  );

  static const vipSupporter = SupporterBadge(
    id: 'vip_supporter',
    name: 'VIP 서포터',
    description: '총 100만원 이상 후원',
    icon: '👑',
  );

  static const subscriberSupporter = SupporterBadge(
    id: 'subscriber_supporter',
    name: '구독자',
    description: '현재 구독 중',
    icon: '⭐',
  );
}

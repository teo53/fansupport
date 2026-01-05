/// 📊 크리에이터 활동 통계 모델
/// 컨텐츠 생산을 독려하기 위한 활동 지표
class ActivityStats {
  // 컨텐츠 생산 지표
  final int totalPosts; // 총 게시글 수
  final int postsThisWeek; // 이번 주 게시글 수
  final int postsThisMonth; // 이번 달 게시글 수

  final int totalBubbleMessages; // 총 버블 메시지 수
  final int bubbleMessagesThisWeek; // 이번 주 버블 메시지

  final int totalEvents; // 총 이벤트 수
  final int upcomingEvents; // 예정된 이벤트 수

  // 활동 일수
  final int totalActiveDays; // 총 활동 일수
  final int consecutiveActiveDays; // 연속 활동 일수
  final DateTime lastActiveDate; // 마지막 활동 날짜

  // 팬 소통 지표
  final int totalComments; // 총 댓글 수
  final int commentsThisWeek; // 이번 주 댓글 수
  final double fanResponseRate; // 팬 응답률 (0.0 ~ 1.0)

  // 라이브/실시간 활동
  final int totalLiveHours; // 총 라이브 시간 (시간)
  final int liveHoursThisWeek; // 이번 주 라이브 시간

  // 업적/배지
  final List<String> badges; // 획득한 배지 ID 목록

  // 활동 점수 (종합)
  final int activityScore; // 활동 점수 (계산된 값)

  const ActivityStats({
    this.totalPosts = 0,
    this.postsThisWeek = 0,
    this.postsThisMonth = 0,
    this.totalBubbleMessages = 0,
    this.bubbleMessagesThisWeek = 0,
    this.totalEvents = 0,
    this.upcomingEvents = 0,
    this.totalActiveDays = 0,
    this.consecutiveActiveDays = 0,
    required this.lastActiveDate,
    this.totalComments = 0,
    this.commentsThisWeek = 0,
    this.fanResponseRate = 0.0,
    this.totalLiveHours = 0,
    this.liveHoursThisWeek = 0,
    this.badges = const [],
    this.activityScore = 0,
  });

  /// 활동 점수 자동 계산
  /// - 게시글: 10점/개
  /// - 버블 메시지: 5점/개
  /// - 이벤트: 50점/개
  /// - 연속 활동일: 2점/일
  /// - 댓글: 3점/개
  /// - 라이브: 10점/시간
  factory ActivityStats.withCalculatedScore({
    int totalPosts = 0,
    int postsThisWeek = 0,
    int postsThisMonth = 0,
    int totalBubbleMessages = 0,
    int bubbleMessagesThisWeek = 0,
    int totalEvents = 0,
    int upcomingEvents = 0,
    int totalActiveDays = 0,
    int consecutiveActiveDays = 0,
    required DateTime lastActiveDate,
    int totalComments = 0,
    int commentsThisWeek = 0,
    double fanResponseRate = 0.0,
    int totalLiveHours = 0,
    int liveHoursThisWeek = 0,
    List<String> badges = const [],
  }) {
    final score = (postsThisWeek * 10) +
        (bubbleMessagesThisWeek * 5) +
        (upcomingEvents * 50) +
        (consecutiveActiveDays * 2) +
        (commentsThisWeek * 3) +
        (liveHoursThisWeek * 10);

    return ActivityStats(
      totalPosts: totalPosts,
      postsThisWeek: postsThisWeek,
      postsThisMonth: postsThisMonth,
      totalBubbleMessages: totalBubbleMessages,
      bubbleMessagesThisWeek: bubbleMessagesThisWeek,
      totalEvents: totalEvents,
      upcomingEvents: upcomingEvents,
      totalActiveDays: totalActiveDays,
      consecutiveActiveDays: consecutiveActiveDays,
      lastActiveDate: lastActiveDate,
      totalComments: totalComments,
      commentsThisWeek: commentsThisWeek,
      fanResponseRate: fanResponseRate,
      totalLiveHours: totalLiveHours,
      liveHoursThisWeek: liveHoursThisWeek,
      badges: badges,
      activityScore: score,
    );
  }

  /// 활동 레벨 (점수 기반)
  ActivityLevel get level {
    if (activityScore >= 500) return ActivityLevel.legendary;
    if (activityScore >= 300) return ActivityLevel.master;
    if (activityScore >= 150) return ActivityLevel.expert;
    if (activityScore >= 50) return ActivityLevel.active;
    return ActivityLevel.beginner;
  }

  /// 이번 주 활동 중인지 여부
  bool get isActiveThisWeek {
    return postsThisWeek > 0 ||
        bubbleMessagesThisWeek > 0 ||
        commentsThisWeek > 0 ||
        liveHoursThisWeek > 0;
  }

  /// 연속 활동 스트릭 유지 중
  bool get hasActiveStreak {
    final now = DateTime.now();
    final difference = now.difference(lastActiveDate).inDays;
    return difference <= 1; // 1일 이내 활동
  }
}

/// 활동 레벨
enum ActivityLevel {
  beginner, // 초보 (0~49)
  active, // 활발 (50~149)
  expert, // 전문가 (150~299)
  master, // 마스터 (300~499)
  legendary, // 전설 (500+)
}

extension ActivityLevelExtension on ActivityLevel {
  String get displayName {
    switch (this) {
      case ActivityLevel.beginner:
        return '신인 크리에이터';
      case ActivityLevel.active:
        return '활발한 크리에이터';
      case ActivityLevel.expert:
        return '전문 크리에이터';
      case ActivityLevel.master:
        return '마스터 크리에이터';
      case ActivityLevel.legendary:
        return '전설의 크리에이터';
    }
  }

  String get icon {
    switch (this) {
      case ActivityLevel.beginner:
        return '🌱';
      case ActivityLevel.active:
        return '⭐';
      case ActivityLevel.expert:
        return '💎';
      case ActivityLevel.master:
        return '👑';
      case ActivityLevel.legendary:
        return '🏆';
    }
  }

  String get color {
    switch (this) {
      case ActivityLevel.beginner:
        return '#9E9E9E'; // Gray
      case ActivityLevel.active:
        return '#4CAF50'; // Green
      case ActivityLevel.expert:
        return '#2196F3'; // Blue
      case ActivityLevel.master:
        return '#9C27B0'; // Purple
      case ActivityLevel.legendary:
        return '#FF9800'; // Gold
    }
  }
}

/// 배지 타입
class Badge {
  final String id;
  final String name;
  final String description;
  final String icon;
  final BadgeCategory category;

  const Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
  });
}

enum BadgeCategory {
  consistency, // 꾸준함
  engagement, // 소통
  content, // 컨텐츠 생산
  event, // 이벤트
  special, // 특별
}

/// 기본 배지 목록
class Badges {
  static const week1Streak = Badge(
    id: 'streak_7',
    name: '7일 연속 활동',
    description: '7일 연속으로 활동했어요!',
    icon: '🔥',
    category: BadgeCategory.consistency,
  );

  static const week4Streak = Badge(
    id: 'streak_30',
    name: '30일 연속 활동',
    description: '한 달 내내 활동했어요!',
    icon: '💪',
    category: BadgeCategory.consistency,
  );

  static const posts50 = Badge(
    id: 'posts_50',
    name: '게시글 50개',
    description: '총 50개의 게시글을 작성했어요',
    icon: '📝',
    category: BadgeCategory.content,
  );

  static const posts100 = Badge(
    id: 'posts_100',
    name: '게시글 100개',
    description: '총 100개의 게시글을 작성했어요',
    icon: '📚',
    category: BadgeCategory.content,
  );

  static const earlyBird = Badge(
    id: 'early_bird',
    name: '얼리버드',
    description: '플랫폼 초기 가입자입니다',
    icon: '🐦',
    category: BadgeCategory.special,
  );

  static const eventKing = Badge(
    id: 'event_10',
    name: '이벤트 마스터',
    description: '10개 이상의 이벤트를 개최했어요',
    icon: '🎉',
    category: BadgeCategory.event,
  );

  static const fanFavorite = Badge(
    id: 'fan_favorite',
    name: '팬들의 사랑',
    description: '팬 응답률 90% 이상',
    icon: '💕',
    category: BadgeCategory.engagement,
  );
}

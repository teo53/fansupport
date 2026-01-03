/// CRM 분석 모델
/// 소속사 및 아이돌을 위한 실시간 매출/구독 분석

enum TransactionType {
  subscription,
  gift,
  dateTicket,
  campaign,
  advertisement,
  bubble,
}

enum TimeRange {
  today,
  week,
  month,
  quarter,
  year,
  all,
}

/// 시간대별 매출 데이터
class HourlyRevenue {
  final int hour; // 0-23
  final int revenue;
  final int transactionCount;
  final int subscriptionCount;

  HourlyRevenue({
    required this.hour,
    required this.revenue,
    required this.transactionCount,
    required this.subscriptionCount,
  });
}

/// 일별 매출 데이터
class DailyRevenue {
  final DateTime date;
  final int revenue;
  final int subscriptionRevenue;
  final int giftRevenue;
  final int dateTicketRevenue;
  final int campaignRevenue;
  final int advertisementRevenue;
  final int bubbleRevenue;
  final int newSubscribers;
  final int churnedSubscribers;
  final int transactionCount;

  DailyRevenue({
    required this.date,
    required this.revenue,
    this.subscriptionRevenue = 0,
    this.giftRevenue = 0,
    this.dateTicketRevenue = 0,
    this.campaignRevenue = 0,
    this.advertisementRevenue = 0,
    this.bubbleRevenue = 0,
    this.newSubscribers = 0,
    this.churnedSubscribers = 0,
    this.transactionCount = 0,
  });

  int get netSubscriberChange => newSubscribers - churnedSubscribers;
}

/// 아이돌별 매출 요약
class IdolRevenueSummary {
  final String idolId;
  final String idolName;
  final String idolProfileImage;
  final String? groupName;
  final int totalRevenue;
  final int monthlyRevenue;
  final int weeklyRevenue;
  final int todayRevenue;
  final int subscriberCount;
  final int newSubscribersToday;
  final int giftCount;
  final int bubbleMessageCount;
  final double revenueGrowthRate; // 전월 대비 %
  final double subscriberGrowthRate;
  final List<HourlyRevenue>? hourlyData;
  final List<DailyRevenue>? dailyData;
  final int peakHour; // 가장 매출이 높은 시간대
  final String peakDay; // 가장 매출이 높은 요일

  IdolRevenueSummary({
    required this.idolId,
    required this.idolName,
    required this.idolProfileImage,
    this.groupName,
    required this.totalRevenue,
    required this.monthlyRevenue,
    required this.weeklyRevenue,
    required this.todayRevenue,
    required this.subscriberCount,
    this.newSubscribersToday = 0,
    this.giftCount = 0,
    this.bubbleMessageCount = 0,
    this.revenueGrowthRate = 0.0,
    this.subscriberGrowthRate = 0.0,
    this.hourlyData,
    this.dailyData,
    this.peakHour = 21,
    this.peakDay = '토요일',
  });
}

/// 소속사 전체 매출 요약
class AgencyRevenueSummary {
  final String agencyId;
  final String agencyName;
  final int totalRevenue;
  final int monthlyRevenue;
  final int weeklyRevenue;
  final int todayRevenue;
  final int totalSubscribers;
  final int totalIdols;
  final int activeIdols;
  final double revenueGrowthRate;
  final double subscriberGrowthRate;
  final List<IdolRevenueSummary> idolSummaries;
  final List<DailyRevenue> recentDailyRevenue;
  final int peakHour;
  final String peakDay;

  // 카테고리별 매출 비율
  final double subscriptionRevenueRatio;
  final double giftRevenueRatio;
  final double dateTicketRevenueRatio;
  final double campaignRevenueRatio;
  final double advertisementRevenueRatio;

  AgencyRevenueSummary({
    required this.agencyId,
    required this.agencyName,
    required this.totalRevenue,
    required this.monthlyRevenue,
    required this.weeklyRevenue,
    required this.todayRevenue,
    required this.totalSubscribers,
    required this.totalIdols,
    required this.activeIdols,
    this.revenueGrowthRate = 0.0,
    this.subscriberGrowthRate = 0.0,
    this.idolSummaries = const [],
    this.recentDailyRevenue = const [],
    this.peakHour = 21,
    this.peakDay = '토요일',
    this.subscriptionRevenueRatio = 0.0,
    this.giftRevenueRatio = 0.0,
    this.dateTicketRevenueRatio = 0.0,
    this.campaignRevenueRatio = 0.0,
    this.advertisementRevenueRatio = 0.0,
  });
}

/// 실시간 매출 알림
class RevenueNotification {
  final String id;
  final String idolId;
  final String idolName;
  final TransactionType type;
  final int amount;
  final String? fanName;
  final String? message;
  final DateTime createdAt;

  RevenueNotification({
    required this.id,
    required this.idolId,
    required this.idolName,
    required this.type,
    required this.amount,
    this.fanName,
    this.message,
    required this.createdAt,
  });

  String get typeLabel {
    switch (type) {
      case TransactionType.subscription:
        return '구독';
      case TransactionType.gift:
        return '선물';
      case TransactionType.dateTicket:
        return '데이트권';
      case TransactionType.campaign:
        return '캠페인';
      case TransactionType.advertisement:
        return '광고';
      case TransactionType.bubble:
        return '버블';
    }
  }

  String get typeEmoji {
    switch (type) {
      case TransactionType.subscription:
        return '💎';
      case TransactionType.gift:
        return '🎁';
      case TransactionType.dateTicket:
        return '🎫';
      case TransactionType.campaign:
        return '🎯';
      case TransactionType.advertisement:
        return '📢';
      case TransactionType.bubble:
        return '💬';
    }
  }
}

/// 아이돌 게시물 통계
class PostEngagement {
  final String postId;
  final int viewCount;
  final int likeCount;
  final int commentCount;
  final int bookmarkCount;
  final int shareCount;
  final DateTime createdAt;
  final List<HourlyEngagement>? hourlyEngagement;

  PostEngagement({
    required this.postId,
    required this.viewCount,
    required this.likeCount,
    required this.commentCount,
    required this.bookmarkCount,
    required this.shareCount,
    required this.createdAt,
    this.hourlyEngagement,
  });

  double get engagementRate {
    if (viewCount == 0) return 0;
    return (likeCount + commentCount + bookmarkCount + shareCount) / viewCount * 100;
  }
}

class HourlyEngagement {
  final int hour;
  final int views;
  final int likes;
  final int comments;

  HourlyEngagement({
    required this.hour,
    required this.views,
    required this.likes,
    required this.comments,
  });
}

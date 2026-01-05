/// 📊 크리에이터 메트릭스
/// 아이돌 계정의 활동 통계 및 정산 관리
library;

import 'package:flutter/material.dart';

/// 크리에이터 메트릭스
class CreatorMetrics {
  /// 정산 관련
  final int unansweredChekiCount; // 미답글 정산 개수
  final int urgentChekiCount; // 긴급 정산 (12시간 이상)
  final int overdueChekiCount; // 지연 정산 (24시간 이상)
  final int totalChekiCount; // 총 정산 개수
  final int thisMonthChekiCount; // 이번 달 정산
  final int hiddenChekiCount; // 히든정산 개수

  /// 게시글 통계
  final int totalPosts; // 총 게시글
  final int thisMonthPosts; // 이번 달 게시글
  final int generalPosts; // 일반 게시글
  final int mealDatePosts; // 메시 게시글
  final int birthdayTimePosts; // --시 게시글

  /// Bubble 메시지
  final int thisWeekBubbleMessages; // 이번 주 메시지
  final int thisMonthBubbleMessages; // 이번 달 메시지
  final int totalBubbleMessages; // 총 메시지

  /// 구독 관련
  final int totalSubscribers; // 총 구독자
  final int standardSubscribers; // 일반 구독자
  final int premiumSubscribers; // 프리미엄 구독자
  final int thisMonthNewSubscribers; // 이번 달 신규 구독자

  /// 답글률
  final double chekiResponseRate; // 정산 답글률 (0.0 ~ 1.0)
  final double averageResponseTime; // 평균 답글 시간 (시간 단위)

  /// 참여도
  final int totalLikes; // 총 좋아요
  final int totalComments; // 총 댓글
  final int totalViews; // 총 조회수

  const CreatorMetrics({
    this.unansweredChekiCount = 0,
    this.urgentChekiCount = 0,
    this.overdueChekiCount = 0,
    this.totalChekiCount = 0,
    this.thisMonthChekiCount = 0,
    this.hiddenChekiCount = 0,
    this.totalPosts = 0,
    this.thisMonthPosts = 0,
    this.generalPosts = 0,
    this.mealDatePosts = 0,
    this.birthdayTimePosts = 0,
    this.thisWeekBubbleMessages = 0,
    this.thisMonthBubbleMessages = 0,
    this.totalBubbleMessages = 0,
    this.totalSubscribers = 0,
    this.standardSubscribers = 0,
    this.premiumSubscribers = 0,
    this.thisMonthNewSubscribers = 0,
    this.chekiResponseRate = 0.0,
    this.averageResponseTime = 0.0,
    this.totalLikes = 0,
    this.totalComments = 0,
    this.totalViews = 0,
  });

  factory CreatorMetrics.fromJson(Map<String, dynamic> json) {
    return CreatorMetrics(
      unansweredChekiCount: json['unansweredChekiCount'] as int? ?? 0,
      urgentChekiCount: json['urgentChekiCount'] as int? ?? 0,
      overdueChekiCount: json['overdueChekiCount'] as int? ?? 0,
      totalChekiCount: json['totalChekiCount'] as int? ?? 0,
      thisMonthChekiCount: json['thisMonthChekiCount'] as int? ?? 0,
      hiddenChekiCount: json['hiddenChekiCount'] as int? ?? 0,
      totalPosts: json['totalPosts'] as int? ?? 0,
      thisMonthPosts: json['thisMonthPosts'] as int? ?? 0,
      generalPosts: json['generalPosts'] as int? ?? 0,
      mealDatePosts: json['mealDatePosts'] as int? ?? 0,
      birthdayTimePosts: json['birthdayTimePosts'] as int? ?? 0,
      thisWeekBubbleMessages: json['thisWeekBubbleMessages'] as int? ?? 0,
      thisMonthBubbleMessages: json['thisMonthBubbleMessages'] as int? ?? 0,
      totalBubbleMessages: json['totalBubbleMessages'] as int? ?? 0,
      totalSubscribers: json['totalSubscribers'] as int? ?? 0,
      standardSubscribers: json['standardSubscribers'] as int? ?? 0,
      premiumSubscribers: json['premiumSubscribers'] as int? ?? 0,
      thisMonthNewSubscribers: json['thisMonthNewSubscribers'] as int? ?? 0,
      chekiResponseRate: (json['chekiResponseRate'] as num?)?.toDouble() ?? 0.0,
      averageResponseTime: (json['averageResponseTime'] as num?)?.toDouble() ?? 0.0,
      totalLikes: json['totalLikes'] as int? ?? 0,
      totalComments: json['totalComments'] as int? ?? 0,
      totalViews: json['totalViews'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'unansweredChekiCount': unansweredChekiCount,
      'urgentChekiCount': urgentChekiCount,
      'overdueChekiCount': overdueChekiCount,
      'totalChekiCount': totalChekiCount,
      'thisMonthChekiCount': thisMonthChekiCount,
      'hiddenChekiCount': hiddenChekiCount,
      'totalPosts': totalPosts,
      'thisMonthPosts': thisMonthPosts,
      'generalPosts': generalPosts,
      'mealDatePosts': mealDatePosts,
      'birthdayTimePosts': birthdayTimePosts,
      'thisWeekBubbleMessages': thisWeekBubbleMessages,
      'thisMonthBubbleMessages': thisMonthBubbleMessages,
      'totalBubbleMessages': totalBubbleMessages,
      'totalSubscribers': totalSubscribers,
      'standardSubscribers': standardSubscribers,
      'premiumSubscribers': premiumSubscribers,
      'thisMonthNewSubscribers': thisMonthNewSubscribers,
      'chekiResponseRate': chekiResponseRate,
      'averageResponseTime': averageResponseTime,
      'totalLikes': totalLikes,
      'totalComments': totalComments,
      'totalViews': totalViews,
    };
  }

  /// 정산 관리가 필요한지 (미답글 정산이 있거나 긴급/지연 정산이 있음)
  bool get needsAttention => unansweredChekiCount > 0 || urgentChekiCount > 0;

  /// 정산 관리 상태
  ChekiManagementStatus get chekiStatus {
    if (overdueChekiCount > 0) return ChekiManagementStatus.critical;
    if (urgentChekiCount > 0) return ChekiManagementStatus.warning;
    if (unansweredChekiCount > 0) return ChekiManagementStatus.needsAction;
    return ChekiManagementStatus.good;
  }

  /// 정산 답글률 등급
  ResponseRateGrade get responseGrade {
    if (chekiResponseRate >= 0.95) return ResponseRateGrade.excellent;
    if (chekiResponseRate >= 0.90) return ResponseRateGrade.good;
    if (chekiResponseRate >= 0.80) return ResponseRateGrade.fair;
    return ResponseRateGrade.poor;
  }

  /// 프리미엄 구독자 비율
  double get premiumSubscriberRate {
    if (totalSubscribers == 0) return 0.0;
    return premiumSubscribers / totalSubscribers;
  }

  CreatorMetrics copyWith({
    int? unansweredChekiCount,
    int? urgentChekiCount,
    int? overdueChekiCount,
    int? totalChekiCount,
    int? thisMonthChekiCount,
    int? hiddenChekiCount,
    int? totalPosts,
    int? thisMonthPosts,
    int? generalPosts,
    int? mealDatePosts,
    int? birthdayTimePosts,
    int? thisWeekBubbleMessages,
    int? thisMonthBubbleMessages,
    int? totalBubbleMessages,
    int? totalSubscribers,
    int? standardSubscribers,
    int? premiumSubscribers,
    int? thisMonthNewSubscribers,
    double? chekiResponseRate,
    double? averageResponseTime,
    int? totalLikes,
    int? totalComments,
    int? totalViews,
  }) {
    return CreatorMetrics(
      unansweredChekiCount: unansweredChekiCount ?? this.unansweredChekiCount,
      urgentChekiCount: urgentChekiCount ?? this.urgentChekiCount,
      overdueChekiCount: overdueChekiCount ?? this.overdueChekiCount,
      totalChekiCount: totalChekiCount ?? this.totalChekiCount,
      thisMonthChekiCount: thisMonthChekiCount ?? this.thisMonthChekiCount,
      hiddenChekiCount: hiddenChekiCount ?? this.hiddenChekiCount,
      totalPosts: totalPosts ?? this.totalPosts,
      thisMonthPosts: thisMonthPosts ?? this.thisMonthPosts,
      generalPosts: generalPosts ?? this.generalPosts,
      mealDatePosts: mealDatePosts ?? this.mealDatePosts,
      birthdayTimePosts: birthdayTimePosts ?? this.birthdayTimePosts,
      thisWeekBubbleMessages: thisWeekBubbleMessages ?? this.thisWeekBubbleMessages,
      thisMonthBubbleMessages: thisMonthBubbleMessages ?? this.thisMonthBubbleMessages,
      totalBubbleMessages: totalBubbleMessages ?? this.totalBubbleMessages,
      totalSubscribers: totalSubscribers ?? this.totalSubscribers,
      standardSubscribers: standardSubscribers ?? this.standardSubscribers,
      premiumSubscribers: premiumSubscribers ?? this.premiumSubscribers,
      thisMonthNewSubscribers: thisMonthNewSubscribers ?? this.thisMonthNewSubscribers,
      chekiResponseRate: chekiResponseRate ?? this.chekiResponseRate,
      averageResponseTime: averageResponseTime ?? this.averageResponseTime,
      totalLikes: totalLikes ?? this.totalLikes,
      totalComments: totalComments ?? this.totalComments,
      totalViews: totalViews ?? this.totalViews,
    );
  }
}

/// 정산 관리 상태
enum ChekiManagementStatus {
  /// 완벽 (미답글 정산 없음)
  good,

  /// 주의 필요 (미답글 정산 있지만 12시간 이내)
  needsAction,

  /// 경고 (12시간 이상 지난 정산 있음)
  warning,

  /// 긴급 (24시간 이상 지난 정산 있음)
  critical,
}

extension ChekiManagementStatusExtension on ChekiManagementStatus {
  Color get color {
    switch (this) {
      case ChekiManagementStatus.good:
        return Colors.green;
      case ChekiManagementStatus.needsAction:
        return Colors.blue;
      case ChekiManagementStatus.warning:
        return Colors.orange;
      case ChekiManagementStatus.critical:
        return Colors.red;
    }
  }

  String get message {
    switch (this) {
      case ChekiManagementStatus.good:
        return '모든 정산에 답글을 달았어요! 👍';
      case ChekiManagementStatus.needsAction:
        return '답글 달지 않은 정산이 있어요';
      case ChekiManagementStatus.warning:
        return '⚠️ 12시간 이상 지난 정산이 있어요';
      case ChekiManagementStatus.critical:
        return '🚨 24시간 이상 지난 정산이 있어요!';
    }
  }
}

/// 답글률 등급
enum ResponseRateGrade {
  excellent, // 95% 이상
  good, // 90% 이상
  fair, // 80% 이상
  poor, // 80% 미만
}

extension ResponseRateGradeExtension on ResponseRateGrade {
  String get displayName {
    switch (this) {
      case ResponseRateGrade.excellent:
        return '최고';
      case ResponseRateGrade.good:
        return '좋음';
      case ResponseRateGrade.fair:
        return '보통';
      case ResponseRateGrade.poor:
        return '개선 필요';
    }
  }

  Color get color {
    switch (this) {
      case ResponseRateGrade.excellent:
        return Colors.green;
      case ResponseRateGrade.good:
        return Colors.blue;
      case ResponseRateGrade.fair:
        return Colors.orange;
      case ResponseRateGrade.poor:
        return Colors.red;
    }
  }
}

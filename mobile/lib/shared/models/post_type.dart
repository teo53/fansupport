/// 🎭 지하돌 문화 게시글 타입 시스템
///
/// 정산, 메시, --시 등 지하돌 문화의 핵심 게시글 타입 정의
library;

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// 게시글 타입
enum PostType {
  /// 일반 게시글
  general,

  /// 정산 (精算) - 공연 후 체키(2샷) 인증
  /// 가장 중요한 타입. 아이돌의 답글이 필수
  cheki,

  /// 히든정산 - 구독자 전용 비공개 정산
  /// 프리미엄 구독자만 볼 수 있음
  hiddenCheki,

  /// 메시 (飯) - 식사 체키
  /// 아이돌과 밥 먹을 때 찍은 사진
  mealDate,

  /// --시 - 생일 시간 맞춤 글
  /// 예: 나연이 9시 (나연 생일 9월 22일 → 9:22)
  birthdayTime,

  /// 공지사항
  announcement,
}

/// PostType 확장 메서드
extension PostTypeExtension on PostType {
  /// 타입명 (한글)
  String get displayName {
    switch (this) {
      case PostType.general:
        return '일반';
      case PostType.cheki:
        return '정산';
      case PostType.hiddenCheki:
        return '히든정산';
      case PostType.mealDate:
        return '메시';
      case PostType.birthdayTime:
        return '--시';
      case PostType.announcement:
        return '공지';
    }
  }

  /// 타입 설명
  String get description {
    switch (this) {
      case PostType.general:
        return '일반 게시글';
      case PostType.cheki:
        return '공연 후 체키 인증';
      case PostType.hiddenCheki:
        return '구독자 전용 정산';
      case PostType.mealDate:
        return '식사 체키';
      case PostType.birthdayTime:
        return '생일 시간 맞춤 글';
      case PostType.announcement:
        return '공지사항';
    }
  }

  /// 아이콘
  IconData get icon {
    switch (this) {
      case PostType.general:
        return Icons.article_outlined;
      case PostType.cheki:
        return Icons.camera_alt_outlined;
      case PostType.hiddenCheki:
        return Icons.lock_outline;
      case PostType.mealDate:
        return Icons.restaurant_outlined;
      case PostType.birthdayTime:
        return Icons.cake_outlined;
      case PostType.announcement:
        return Icons.campaign_outlined;
    }
  }

  /// 색상
  Color get color {
    switch (this) {
      case PostType.general:
        return AppColors.textSecondary;
      case PostType.cheki:
        return AppColors.primary; // Coral Pink
      case PostType.hiddenCheki:
        return AppColors.neonPurple; // Purple
      case PostType.mealDate:
        return AppColors.warning; // Orange
      case PostType.birthdayTime:
        return AppColors.info; // Blue
      case PostType.announcement:
        return AppColors.error; // Red
    }
  }

  /// 배경색 (softer)
  Color get backgroundColor {
    return color.withValues(alpha: 0.1);
  }

  /// 답글이 중요한 타입인지 (정산 계열)
  bool get requiresCreatorReply {
    return this == PostType.cheki || this == PostType.hiddenCheki;
  }

  /// 구독자 전용 타입인지
  bool get isSubscriberOnly {
    return this == PostType.hiddenCheki;
  }

  /// 프리미엄 전용 타입인지
  bool get isPremiumOnly {
    return this == PostType.hiddenCheki;
  }
}

/// PostType 유틸리티
class PostTypeUtils {
  /// 정산 관련 타입들
  static const List<PostType> chekiTypes = [
    PostType.cheki,
    PostType.hiddenCheki,
  ];

  /// 답글이 필요한 타입들
  static const List<PostType> replyRequiredTypes = [
    PostType.cheki,
    PostType.hiddenCheki,
    PostType.mealDate,
  ];

  /// 구독자만 볼 수 있는 타입들
  static const List<PostType> subscriberOnlyTypes = [
    PostType.hiddenCheki,
  ];

  /// 문자열을 PostType으로 변환
  static PostType? fromString(String? value) {
    if (value == null) return null;

    switch (value.toLowerCase()) {
      case 'general':
        return PostType.general;
      case 'cheki':
      case '정산':
        return PostType.cheki;
      case 'hiddencheki':
      case 'hidden_cheki':
      case '히든정산':
        return PostType.hiddenCheki;
      case 'mealdate':
      case 'meal_date':
      case '메시':
        return PostType.mealDate;
      case 'birthdaytime':
      case 'birthday_time':
      case '--시':
        return PostType.birthdayTime;
      case 'announcement':
      case '공지':
        return PostType.announcement;
      default:
        return null;
    }
  }

  /// PostType을 JSON 문자열로 변환
  static String toJson(PostType type) {
    return type.name;
  }
}

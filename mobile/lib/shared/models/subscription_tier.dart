/// 💎 구독 티어 시스템
/// 일반 구독 (3,900원/월)
library;

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// 구독 티어
enum SubscriptionTier {
  /// 미구독
  none,

  /// 일반 구독 - 3,900원/월
  /// Bubble 메시지 수신 + 히든정산 작성 가능
  standard,
}

extension SubscriptionTierExtension on SubscriptionTier {
  /// 티어명
  String get displayName {
    switch (this) {
      case SubscriptionTier.none:
        return '미구독';
      case SubscriptionTier.standard:
        return '일반 구독';
    }
  }

  /// 짧은 이름
  String get shortName {
    switch (this) {
      case SubscriptionTier.none:
        return '-';
      case SubscriptionTier.standard:
        return '일반';
    }
  }

  /// 가격 (월)
  int get price {
    switch (this) {
      case SubscriptionTier.none:
        return 0;
      case SubscriptionTier.standard:
        return 3900;
    }
  }

  /// 가격 포맷 (예: "3,900원/월")
  String get priceFormatted {
    if (this == SubscriptionTier.none) return '-';
    final formatted = price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
    return '₩$formatted/월';
  }

  /// 설명
  String get description {
    switch (this) {
      case SubscriptionTier.none:
        return '구독하지 않은 상태';
      case SubscriptionTier.standard:
        return '아이돌의 Bubble 메시지를 받고 히든정산을 작성할 수 있어요';
    }
  }

  /// 아이콘
  IconData get icon {
    switch (this) {
      case SubscriptionTier.none:
        return Icons.person_outline;
      case SubscriptionTier.standard:
        return Icons.favorite;
    }
  }

  /// 색상
  Color get color {
    switch (this) {
      case SubscriptionTier.none:
        return AppColors.textTertiary;
      case SubscriptionTier.standard:
        return AppColors.primary;
    }
  }

  /// 배지 색상
  Color get badgeColor {
    switch (this) {
      case SubscriptionTier.none:
        return Colors.grey;
      case SubscriptionTier.standard:
        return AppColors.primary;
    }
  }

  /// 혜택 목록
  List<SubscriptionBenefit> get benefits {
    switch (this) {
      case SubscriptionTier.none:
        return [];
      case SubscriptionTier.standard:
        return [
          SubscriptionBenefit(
            icon: Icons.mail_outline,
            title: 'Bubble 메시지',
            description: '아이돌이 보내는 메시지를 받을 수 있어요',
          ),
          SubscriptionBenefit(
            icon: Icons.lock_outline,
            title: '히든정산 작성',
            description: '나와 아이돌만 볼 수 있는 1:1 정산을 올릴 수 있어요',
          ),
          SubscriptionBenefit(
            icon: Icons.article_outlined,
            title: '정산 게시글',
            description: '정산 게시글을 자유롭게 작성할 수 있어요',
          ),
          SubscriptionBenefit(
            icon: Icons.comment_outlined,
            title: '댓글 작성',
            description: '게시글에 댓글을 작성할 수 있어요',
          ),
        ];
    }
  }

  /// Bubble 메시지 수신 가능 여부
  bool get canReceiveBubble => this != SubscriptionTier.none;

  /// 히든정산 작성 가능 여부 (일반 구독자 가능)
  bool get canCreateHiddenCheki => this == SubscriptionTier.standard;

  /// 정산 작성 가능 여부
  bool get canCreatePost => this == SubscriptionTier.standard;
}

/// 구독 혜택
class SubscriptionBenefit {
  final IconData icon;
  final String title;
  final String description;

  const SubscriptionBenefit({
    required this.icon,
    required this.title,
    required this.description,
  });
}

/// 구독 티어 유틸리티
class SubscriptionTierUtils {
  /// 문자열을 SubscriptionTier로 변환
  static SubscriptionTier? fromString(String? value) {
    if (value == null) return null;

    switch (value.toLowerCase()) {
      case 'none':
      case '미구독':
        return SubscriptionTier.none;
      case 'standard':
      case '일반':
        return SubscriptionTier.standard;
      default:
        return null;
    }
  }

  /// SubscriptionTier를 JSON 문자열로 변환
  static String toJson(SubscriptionTier tier) {
    return tier.name;
  }

  /// 가격으로 티어 찾기
  static SubscriptionTier? fromPrice(int price) {
    switch (price) {
      case 0:
        return SubscriptionTier.none;
      case 3900:
        return SubscriptionTier.standard;
      default:
        return null;
    }
  }

  /// 모든 구독 가능 티어 (none 제외)
  static List<SubscriptionTier> get availableTiers => [
        SubscriptionTier.standard,
      ];
}

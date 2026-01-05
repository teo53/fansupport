/// 💎 구독 티어 시스템
/// 일반 (3,900원) / 프리미엄 (9,900원)
library;

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// 구독 티어
enum SubscriptionTier {
  /// 미구독
  none,

  /// 일반 구독 - 3,900원/월
  /// Bubble 메시지 수신
  standard,

  /// 프리미엄 구독 - 9,900원/월
  /// 히든정산 + Bubble 메시지 + 우선 답글 + 생일 축전
  premium,
}

extension SubscriptionTierExtension on SubscriptionTier {
  /// 티어명
  String get displayName {
    switch (this) {
      case SubscriptionTier.none:
        return '미구독';
      case SubscriptionTier.standard:
        return '일반 구독';
      case SubscriptionTier.premium:
        return '프리미엄 구독';
    }
  }

  /// 짧은 이름
  String get shortName {
    switch (this) {
      case SubscriptionTier.none:
        return '-';
      case SubscriptionTier.standard:
        return '일반';
      case SubscriptionTier.premium:
        return '프리미엄';
    }
  }

  /// 가격 (월)
  int get price {
    switch (this) {
      case SubscriptionTier.none:
        return 0;
      case SubscriptionTier.standard:
        return 3900;
      case SubscriptionTier.premium:
        return 9900;
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
        return '아이돌의 Bubble 메시지를 받을 수 있어요';
      case SubscriptionTier.premium:
        return '히든정산, 우선 답글, 생일 축전 등 모든 혜택';
    }
  }

  /// 아이콘
  IconData get icon {
    switch (this) {
      case SubscriptionTier.none:
        return Icons.person_outline;
      case SubscriptionTier.standard:
        return Icons.favorite_outline;
      case SubscriptionTier.premium:
        return Icons.star;
    }
  }

  /// 색상
  Color get color {
    switch (this) {
      case SubscriptionTier.none:
        return AppColors.textTertiary;
      case SubscriptionTier.standard:
        return AppColors.primary;
      case SubscriptionTier.premium:
        return AppColors.gold;
    }
  }

  /// 배지 색상
  Color get badgeColor {
    switch (this) {
      case SubscriptionTier.none:
        return Colors.grey;
      case SubscriptionTier.standard:
        return AppColors.primary;
      case SubscriptionTier.premium:
        return AppColors.gold;
    }
  }

  /// 그라데이션 (프리미엄용)
  LinearGradient? get gradient {
    switch (this) {
      case SubscriptionTier.premium:
        return LinearGradient(
          colors: [
            AppColors.gold,
            Color(0xFFFFE57F),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return null;
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
        ];
      case SubscriptionTier.premium:
        return [
          SubscriptionBenefit(
            icon: Icons.mail_outline,
            title: 'Bubble 메시지',
            description: '아이돌이 보내는 메시지를 받을 수 있어요',
          ),
          SubscriptionBenefit(
            icon: Icons.lock_outline,
            title: '히든정산',
            description: '구독자만 볼 수 있는 특별한 정산을 받아요',
            isPremiumOnly: true,
          ),
          SubscriptionBenefit(
            icon: Icons.priority_high,
            title: '우선 답글',
            description: '아이돌이 우선적으로 답글을 달아줘요',
            isPremiumOnly: true,
          ),
          SubscriptionBenefit(
            icon: Icons.cake_outlined,
            title: '생일 축전',
            description: '생일에 특별한 메시지를 받아요',
            isPremiumOnly: true,
          ),
          SubscriptionBenefit(
            icon: Icons.discount_outlined,
            title: '이벤트 할인',
            description: '공연 및 이벤트 티켓 10% 할인',
            isPremiumOnly: true,
          ),
        ];
    }
  }

  /// Bubble 메시지 수신 가능 여부
  bool get canReceiveBubble => this != SubscriptionTier.none;

  /// 히든정산 접근 가능 여부
  bool get canAccessHiddenCheki => this == SubscriptionTier.premium;

  /// 우선 답글 대상 여부
  bool get hasPriorityReply => this == SubscriptionTier.premium;

  /// 프리미엄 혜택 접근 가능 여부
  bool get isPremium => this == SubscriptionTier.premium;
}

/// 구독 혜택
class SubscriptionBenefit {
  final IconData icon;
  final String title;
  final String description;
  final bool isPremiumOnly;

  const SubscriptionBenefit({
    required this.icon,
    required this.title,
    required this.description,
    this.isPremiumOnly = false,
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
      case 'premium':
      case '프리미엄':
        return SubscriptionTier.premium;
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
      case 9900:
        return SubscriptionTier.premium;
      default:
        return null;
    }
  }

  /// 모든 구독 가능 티어 (none 제외)
  static List<SubscriptionTier> get availableTiers => [
        SubscriptionTier.standard,
        SubscriptionTier.premium,
      ];

  /// 티어 업그레이드 가능 여부
  static bool canUpgrade(SubscriptionTier from, SubscriptionTier to) {
    if (from == to) return false;
    if (to == SubscriptionTier.none) return false;

    final fromIndex = SubscriptionTier.values.indexOf(from);
    final toIndex = SubscriptionTier.values.indexOf(to);

    return toIndex > fromIndex;
  }

  /// 티어 다운그레이드 가능 여부
  static bool canDowngrade(SubscriptionTier from, SubscriptionTier to) {
    if (from == to) return false;
    if (from == SubscriptionTier.none) return false;

    final fromIndex = SubscriptionTier.values.indexOf(from);
    final toIndex = SubscriptionTier.values.indexOf(to);

    return toIndex < fromIndex;
  }

  /// 가격 차이 계산
  static int priceDifference(SubscriptionTier from, SubscriptionTier to) {
    return to.price - from.price;
  }
}

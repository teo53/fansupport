import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/supporter_model.dart';
import '../../../shared/widgets/idol_avatar.dart';

/// 🏆 후원자 랭킹 섹션 (치지직 스타일)
class SupporterRankingSection extends StatelessWidget {
  final List<SupporterModel> supporters;
  final VoidCallback? onViewAll;

  const SupporterRankingSection({
    super.key,
    required this.supporters,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    '🏆',
                    style: TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '후원 랭킹',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              if (onViewAll != null)
                TextButton(
                  onPressed: onViewAll,
                  child: Text(
                    '전체보기',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '후원 + 펀딩 참여 금액 기준',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),

          // 랭킹 리스트
          ...List.generate(
            supporters.length > 10 ? 10 : supporters.length,
            (index) => _buildRankingItem(
              context,
              supporters[index],
              index + 1,
            ),
          ),
        ],
      ),
    );
  }

  /// 랭킹 아이템
  Widget _buildRankingItem(
    BuildContext context,
    SupporterModel supporter,
    int rank,
  ) {
    final isTop3 = rank <= 3;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isTop3 ? _getTop3BackgroundColor(rank) : AppColors.backgroundAlt,
        borderRadius: BorderRadius.circular(16),
        border: isTop3
            ? Border.all(color: _getTop3BorderColor(rank), width: 2)
            : null,
        boxShadow: isTop3
            ? [
                BoxShadow(
                  color: _getTop3BorderColor(rank).withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          // 순위 아이콘
          SizedBox(
            width: 40,
            child: _buildRankBadge(rank),
          ),

          const SizedBox(width: 12),

          // 프로필 이미지
          _buildProfileImage(supporter),

          const SizedBox(width: 12),

          // 닉네임 & 뱃지
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        supporter.nickname,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isTop3 ? FontWeight.w700 : FontWeight.w600,
                          letterSpacing: -0.3,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (supporter.isVerified) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.verified,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    // 구독 중 뱃지
                    if (supporter.isSubscriber)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              '⭐',
                              style: TextStyle(fontSize: 10),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              supporter.subscriptionTier ?? '구독',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // 티어 뱃지
                    if (supporter.tier != SupporterTier.silver) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Color(
                            int.parse(
                              supporter.tier.color.replaceFirst('#', '0xFF'),
                            ),
                          ).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${supporter.tier.icon} ${supporter.tier.displayName}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(
                              int.parse(
                                supporter.tier.color.replaceFirst('#', '0xFF'),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // 금액
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${_formatAmount(supporter.totalAmount)}원',
                style: TextStyle(
                  fontSize: isTop3 ? 16 : 15,
                  fontWeight: FontWeight.w800,
                  color: isTop3 ? _getTop3BorderColor(rank) : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${supporter.supportCount + supporter.fundingCount}회',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 순위 뱃지
  Widget _buildRankBadge(int rank) {
    if (rank <= 3) {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _getTop3GradientColors(rank),
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: _getTop3BorderColor(rank).withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            _getTop3Icon(rank),
            style: const TextStyle(fontSize: 20),
          ),
        ),
      );
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.backgroundAlt,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$rank',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  /// 프로필 이미지
  Widget _buildProfileImage(SupporterModel supporter) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border, width: 2),
      ),
      child: ClipOval(
        child: supporter.profileImage != null
            ? Image.network(
                supporter.profileImage!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildDefaultAvatar(supporter.nickname),
              )
            : _buildDefaultAvatar(supporter.nickname),
      ),
    );
  }

  /// 기본 아바타
  Widget _buildDefaultAvatar(String nickname) {
    return Container(
      color: AppColors.primary.withOpacity(0.1),
      child: Center(
        child: Text(
          nickname.isNotEmpty ? nickname[0].toUpperCase() : '?',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  /// TOP 3 아이콘
  String _getTop3Icon(int rank) {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '';
    }
  }

  /// TOP 3 배경색
  Color _getTop3BackgroundColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFF8E1); // Gold tint
      case 2:
        return const Color(0xFFF5F5F5); // Silver tint
      case 3:
        return const Color(0xFFFFECB3); // Bronze tint
      default:
        return Colors.white;
    }
  }

  /// TOP 3 테두리 색
  Color _getTop3BorderColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return AppColors.border;
    }
  }

  /// TOP 3 그라데이션 색상
  List<Color> _getTop3GradientColors(int rank) {
    switch (rank) {
      case 1:
        return [const Color(0xFFFFD700), const Color(0xFFFFA500)];
      case 2:
        return [const Color(0xFFC0C0C0), const Color(0xFF808080)];
      case 3:
        return [const Color(0xFFCD7F32), const Color(0xFF8B4513)];
      default:
        return [AppColors.primary, AppColors.primaryLight];
    }
  }

  /// 금액 포맷
  String _formatAmount(int amount) {
    if (amount >= 10000) {
      return NumberFormat('#,###').format((amount / 10000).floor()) + '만';
    }
    return NumberFormat('#,###').format(amount);
  }
}

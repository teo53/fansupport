import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/design_system.dart';

/// Fan Letter Widget
///
/// Emotional connection widget for sending support messages to creators
class FanLetterCard extends StatelessWidget {
  final VoidCallback onTap;

  const FanLetterCard({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(PipoSpacing.xl),
        margin: PipoSpacing.screenPadding,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              PipoColors.primary.withOpacity(0.1),
              PipoColors.secondary.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(PipoRadius.xl),
          border: Border.all(
            color: PipoColors.primary.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(PipoSpacing.md),
              decoration: BoxDecoration(
                color: PipoColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(PipoRadius.md),
              ),
              child: Icon(
                Icons.mail_outline,
                color: PipoColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: PipoSpacing.lg),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '응원 메시지 보내기',
                    style: PipoTypography.titleMedium.copyWith(
                      color: PipoColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '크리에이터에게 따뜻한 마음을 전하세요',
                    style: PipoTypography.bodySmall.copyWith(
                      color: PipoColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Arrow
            Icon(
              Icons.arrow_forward_ios,
              color: PipoColors.primary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

/// Support Impact Card
///
/// Shows the impact of user's support on creators
class SupportImpactCard extends StatelessWidget {
  final int totalSupported;
  final int creatorsHelped;
  final String topCategory;

  const SupportImpactCard({
    super.key,
    required this.totalSupported,
    required this.creatorsHelped,
    required this.topCategory,
  });

  String _formatAmount(int amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: PipoSpacing.screenPadding,
      padding: const EdgeInsets.all(PipoSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            PipoColors.primary,
            PipoColors.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(PipoRadius.xl),
        boxShadow: PipoShadows.primaryGlow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.favorite,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: PipoSpacing.sm),
              Text(
                '나의 서포트 임팩트',
                style: PipoTypography.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: PipoSpacing.lg),
          // Stats Grid
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.monetization_on_outlined,
                  value: '₩${_formatAmount(totalSupported)}',
                  label: '총 후원',
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.people_outline,
                  value: '$creatorsHelped명',
                  label: '후원 크리에이터',
                ),
              ),
            ],
          ),
          const SizedBox(height: PipoSpacing.md),
          Divider(color: Colors.white.withOpacity(0.3)),
          const SizedBox(height: PipoSpacing.md),
          Row(
            children: [
              Icon(
                Icons.emoji_events_outlined,
                color: Colors.white.withOpacity(0.9),
                size: 16,
              ),
              const SizedBox(width: PipoSpacing.sm),
              Text(
                '가장 많이 후원한 카테고리: ',
                style: PipoTypography.caption.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              Text(
                topCategory,
                style: PipoTypography.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: PipoTypography.titleLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          style: PipoTypography.caption.copyWith(
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }
}

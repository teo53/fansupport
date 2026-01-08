import 'package:flutter/material.dart';
import '../../../core/theme/design_system.dart';

/// Badge showing remaining slots for a creator
class SlotBadge extends StatelessWidget {
  final int remainingSlots;
  final int? totalSlots;
  final SlotBadgeSize size;
  final bool showIcon;

  const SlotBadge({
    super.key,
    required this.remainingSlots,
    this.totalSlots,
    this.size = SlotBadgeSize.medium,
    this.showIcon = true,
  });

  bool get isLow => remainingSlots <= 2;
  bool get isSoldOut => remainingSlots <= 0;

  Color get backgroundColor {
    if (isSoldOut) return PipoColors.error.withOpacity(0.1);
    if (isLow) return PipoColors.warning.withOpacity(0.1);
    return PipoColors.success.withOpacity(0.1);
  }

  Color get borderColor {
    if (isSoldOut) return PipoColors.error;
    if (isLow) return PipoColors.warning;
    return PipoColors.success;
  }

  Color get textColor {
    if (isSoldOut) return PipoColors.error;
    if (isLow) return PipoColors.warning;
    return PipoColors.success;
  }

  IconData get icon {
    if (isSoldOut) return Icons.block_rounded;
    if (isLow) return Icons.local_fire_department_rounded;
    return Icons.check_circle_outline_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final double iconSize;
    final EdgeInsets padding;
    final TextStyle textStyle;

    switch (size) {
      case SlotBadgeSize.small:
        iconSize = 12;
        padding = const EdgeInsets.symmetric(
          horizontal: PipoSpacing.xs,
          vertical: 2,
        );
        textStyle = PipoTypography.labelSmall;
        break;
      case SlotBadgeSize.medium:
        iconSize = 14;
        padding = const EdgeInsets.symmetric(
          horizontal: PipoSpacing.sm,
          vertical: PipoSpacing.xs,
        );
        textStyle = PipoTypography.labelMedium;
        break;
      case SlotBadgeSize.large:
        iconSize = 16;
        padding = const EdgeInsets.symmetric(
          horizontal: PipoSpacing.md,
          vertical: PipoSpacing.sm,
        );
        textStyle = PipoTypography.bodyMedium;
        break;
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(PipoRadius.sm),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(icon, size: iconSize, color: textColor),
            const SizedBox(width: PipoSpacing.xs),
          ],
          Text(
            _buildLabel(),
            style: textStyle.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _buildLabel() {
    if (isSoldOut) {
      return '마감';
    }
    if (totalSlots != null) {
      return '$remainingSlots/$totalSlots 슬롯';
    }
    return '$remainingSlots슬롯 남음';
  }
}

enum SlotBadgeSize { small, medium, large }

/// Inline slot indicator for compact displays
class SlotIndicator extends StatelessWidget {
  final int remainingSlots;
  final int totalSlots;

  const SlotIndicator({
    super.key,
    required this.remainingSlots,
    required this.totalSlots,
  });

  @override
  Widget build(BuildContext context) {
    final filledSlots = totalSlots - remainingSlots;
    final isSoldOut = remainingSlots <= 0;
    final isLow = remainingSlots <= 2;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalSlots, (index) {
        final isFilled = index < filledSlots;
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(right: 2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled
                ? PipoColors.textTertiary
                : (isSoldOut
                    ? PipoColors.error
                    : (isLow ? PipoColors.warning : PipoColors.success)),
            border: isFilled
                ? null
                : Border.all(
                    color: isSoldOut
                        ? PipoColors.error
                        : (isLow ? PipoColors.warning : PipoColors.success),
                    width: 1.5,
                  ),
          ),
        );
      }),
    );
  }
}

/// Large slot card for request composer
class SlotCard extends StatelessWidget {
  final int remainingSlots;
  final int totalSlots;
  final DateTime? resetTime;
  final VoidCallback? onInfoTap;

  const SlotCard({
    super.key,
    required this.remainingSlots,
    required this.totalSlots,
    this.resetTime,
    this.onInfoTap,
  });

  bool get isSoldOut => remainingSlots <= 0;
  bool get isLow => remainingSlots <= 2;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PipoSpacing.md),
      decoration: BoxDecoration(
        gradient: isSoldOut
            ? LinearGradient(
                colors: [
                  PipoColors.error.withOpacity(0.1),
                  PipoColors.error.withOpacity(0.05),
                ],
              )
            : (isLow
                ? LinearGradient(
                    colors: [
                      PipoColors.warning.withOpacity(0.1),
                      PipoColors.warning.withOpacity(0.05),
                    ],
                  )
                : null),
        color: isSoldOut || isLow ? null : PipoColors.surfaceVariant,
        borderRadius: BorderRadius.circular(PipoRadius.md),
        border: Border.all(
          color: isSoldOut
              ? PipoColors.error.withOpacity(0.3)
              : (isLow
                  ? PipoColors.warning.withOpacity(0.3)
                  : PipoColors.border),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isSoldOut
                    ? Icons.event_busy_rounded
                    : Icons.calendar_today_rounded,
                size: 20,
                color: isSoldOut
                    ? PipoColors.error
                    : (isLow ? PipoColors.warning : PipoColors.textSecondary),
              ),
              const SizedBox(width: PipoSpacing.sm),
              Text(
                '오늘의 슬롯',
                style: PipoTypography.titleSmall.copyWith(
                  color: PipoColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (onInfoTap != null)
                GestureDetector(
                  onTap: onInfoTap,
                  child: Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: PipoColors.textTertiary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: PipoSpacing.md),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: remainingSlots / totalSlots,
              backgroundColor: PipoColors.border,
              valueColor: AlwaysStoppedAnimation(
                isSoldOut
                    ? PipoColors.error
                    : (isLow ? PipoColors.warning : PipoColors.success),
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: PipoSpacing.sm),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isSoldOut ? '오늘 마감됨' : '$remainingSlots개 남음',
                style: PipoTypography.bodyMedium.copyWith(
                  color: isSoldOut
                      ? PipoColors.error
                      : (isLow ? PipoColors.warning : PipoColors.textPrimary),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '총 $totalSlots슬롯',
                style: PipoTypography.labelSmall.copyWith(
                  color: PipoColors.textTertiary,
                ),
              ),
            ],
          ),

          if (resetTime != null && isSoldOut) ...[
            const SizedBox(height: PipoSpacing.sm),
            Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 14,
                  color: PipoColors.textTertiary,
                ),
                const SizedBox(width: PipoSpacing.xs),
                Text(
                  '내일 ${_formatTime(resetTime!)}에 리셋',
                  style: PipoTypography.labelSmall.copyWith(
                    color: PipoColors.textTertiary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute;
    final period = hour >= 12 ? '오후' : '오전';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$period $displayHour:${minute.toString().padLeft(2, '0')}';
  }
}

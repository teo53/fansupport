import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/design_system.dart';

/// Countdown widget showing time remaining until SLA deadline
class SLACountdown extends StatefulWidget {
  final DateTime deadline;
  final VoidCallback? onExpired;
  final SLACountdownStyle style;

  const SLACountdown({
    super.key,
    required this.deadline,
    this.onExpired,
    this.style = SLACountdownStyle.card,
  });

  @override
  State<SLACountdown> createState() => _SLACountdownState();
}

class _SLACountdownState extends State<SLACountdown> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateRemaining();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateRemaining() {
    final now = DateTime.now();
    final remaining = widget.deadline.difference(now);

    if (remaining.isNegative && _remaining.inSeconds >= 0) {
      widget.onExpired?.call();
    }

    setState(() {
      _remaining = remaining.isNegative ? Duration.zero : remaining;
    });
  }

  bool get isUrgent => _remaining.inHours < 4;
  bool get isExpired => _remaining.inSeconds <= 0;

  @override
  Widget build(BuildContext context) {
    switch (widget.style) {
      case SLACountdownStyle.card:
        return _buildCardStyle();
      case SLACountdownStyle.inline:
        return _buildInlineStyle();
      case SLACountdownStyle.badge:
        return _buildBadgeStyle();
      case SLACountdownStyle.minimal:
        return _buildMinimalStyle();
    }
  }

  Widget _buildCardStyle() {
    return Container(
      padding: const EdgeInsets.all(PipoSpacing.md),
      decoration: BoxDecoration(
        gradient: isExpired
            ? LinearGradient(
                colors: [
                  PipoColors.error.withOpacity(0.1),
                  PipoColors.error.withOpacity(0.05),
                ],
              )
            : (isUrgent
                ? LinearGradient(
                    colors: [
                      PipoColors.warning.withOpacity(0.1),
                      PipoColors.warning.withOpacity(0.05),
                    ],
                  )
                : null),
        color: isExpired || isUrgent ? null : PipoColors.surfaceVariant,
        borderRadius: BorderRadius.circular(PipoRadius.md),
        border: Border.all(
          color: isExpired
              ? PipoColors.error.withOpacity(0.3)
              : (isUrgent
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
                isExpired
                    ? Icons.timer_off_rounded
                    : Icons.hourglass_bottom_rounded,
                size: 20,
                color: isExpired
                    ? PipoColors.error
                    : (isUrgent ? PipoColors.warning : PipoColors.textSecondary),
              ),
              const SizedBox(width: PipoSpacing.sm),
              Text(
                isExpired ? 'SLA 만료됨' : 'SLA 마감까지',
                style: PipoTypography.titleSmall.copyWith(
                  color: PipoColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (isUrgent && !isExpired)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: PipoSpacing.xs,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: PipoColors.warning,
                    borderRadius: BorderRadius.circular(PipoRadius.xs),
                  ),
                  child: Text(
                    '긴급',
                    style: PipoTypography.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: PipoSpacing.md),

          // Time display
          if (isExpired)
            Text(
              '만료됨',
              style: PipoTypography.heading1.copyWith(
                color: PipoColors.error,
                fontWeight: FontWeight.bold,
              ),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTimeUnit(_remaining.inDays, '일'),
                _buildSeparator(),
                _buildTimeUnit(_remaining.inHours % 24, '시간'),
                _buildSeparator(),
                _buildTimeUnit(_remaining.inMinutes % 60, '분'),
                _buildSeparator(),
                _buildTimeUnit(_remaining.inSeconds % 60, '초'),
              ],
            ),

          const SizedBox(height: PipoSpacing.sm),
          Text(
            '마감: ${_formatDeadline(widget.deadline)}',
            style: PipoTypography.labelSmall.copyWith(
              color: PipoColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeUnit(int value, String label) {
    return Column(
      children: [
        Text(
          value.toString().padLeft(2, '0'),
          style: PipoTypography.heading1.copyWith(
            color: isUrgent ? PipoColors.warning : PipoColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        Text(
          label,
          style: PipoTypography.labelSmall.copyWith(
            color: PipoColors.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildSeparator() {
    return Text(
      ':',
      style: PipoTypography.heading2.copyWith(
        color: PipoColors.textTertiary,
      ),
    );
  }

  Widget _buildInlineStyle() {
    final text = isExpired
        ? '만료됨'
        : _formatDuration(_remaining);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isExpired ? Icons.timer_off_rounded : Icons.schedule_rounded,
          size: 16,
          color: isExpired
              ? PipoColors.error
              : (isUrgent ? PipoColors.warning : PipoColors.textSecondary),
        ),
        const SizedBox(width: PipoSpacing.xs),
        Text(
          text,
          style: PipoTypography.bodyMedium.copyWith(
            color: isExpired
                ? PipoColors.error
                : (isUrgent ? PipoColors.warning : PipoColors.textPrimary),
            fontWeight: isUrgent ? FontWeight.w600 : FontWeight.normal,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeStyle() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PipoSpacing.sm,
        vertical: PipoSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isExpired
            ? PipoColors.error.withOpacity(0.1)
            : (isUrgent
                ? PipoColors.warning.withOpacity(0.1)
                : PipoColors.surfaceVariant),
        borderRadius: BorderRadius.circular(PipoRadius.sm),
        border: Border.all(
          color: isExpired
              ? PipoColors.error
              : (isUrgent ? PipoColors.warning : PipoColors.border),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.schedule_rounded,
            size: 12,
            color: isExpired
                ? PipoColors.error
                : (isUrgent ? PipoColors.warning : PipoColors.textSecondary),
          ),
          const SizedBox(width: PipoSpacing.xs),
          Text(
            isExpired ? '만료' : _formatDurationShort(_remaining),
            style: PipoTypography.labelSmall.copyWith(
              color: isExpired
                  ? PipoColors.error
                  : (isUrgent ? PipoColors.warning : PipoColors.textPrimary),
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalStyle() {
    return Text(
      isExpired ? '만료됨' : _formatDuration(_remaining),
      style: PipoTypography.labelMedium.copyWith(
        color: isExpired
            ? PipoColors.error
            : (isUrgent ? PipoColors.warning : PipoColors.textSecondary),
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}일 ${duration.inHours % 24}시간';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}시간 ${duration.inMinutes % 60}분';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}분 ${duration.inSeconds % 60}초';
    }
    return '${duration.inSeconds}초';
  }

  String _formatDurationShort(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}일';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}시간';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}분';
    }
    return '${duration.inSeconds}초';
  }

  String _formatDeadline(DateTime deadline) {
    return '${deadline.month}/${deadline.day} ${deadline.hour}:${deadline.minute.toString().padLeft(2, '0')}';
  }
}

enum SLACountdownStyle { card, inline, badge, minimal }

/// SLA selector widget for request composer
class SLASelector extends StatelessWidget {
  final List<SLAOption> options;
  final String? selectedId;
  final ValueChanged<String> onSelected;

  const SLASelector({
    super.key,
    required this.options,
    this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '응답 시간 선택',
          style: PipoTypography.titleSmall.copyWith(
            color: PipoColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: PipoSpacing.sm),
        ...options.map((option) => _buildOption(option)),
      ],
    );
  }

  Widget _buildOption(SLAOption option) {
    final isSelected = option.id == selectedId;

    return GestureDetector(
      onTap: () => onSelected(option.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: PipoSpacing.sm),
        padding: const EdgeInsets.all(PipoSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? PipoColors.primary.withOpacity(0.05)
              : PipoColors.surfaceVariant,
          borderRadius: BorderRadius.circular(PipoRadius.md),
          border: Border.all(
            color: isSelected ? PipoColors.primary : PipoColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Radio indicator
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? PipoColors.primary : PipoColors.textTertiary,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: PipoColors.primary,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: PipoSpacing.md),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.name,
                    style: PipoTypography.titleSmall.copyWith(
                      color: PipoColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${option.hours}시간 내 응답',
                    style: PipoTypography.labelSmall.copyWith(
                      color: PipoColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),

            // Price multiplier
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '×${option.multiplier.toStringAsFixed(1)}',
                  style: PipoTypography.titleSmall.copyWith(
                    color: isSelected ? PipoColors.primary : PipoColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (option.isPopular)
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: PipoSpacing.xs,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: PipoColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(PipoRadius.xs),
                    ),
                    child: Text(
                      '인기',
                      style: PipoTypography.labelSmall.copyWith(
                        color: PipoColors.success,
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SLAOption {
  final String id;
  final String name;
  final int hours;
  final double multiplier;
  final bool isPopular;

  const SLAOption({
    required this.id,
    required this.name,
    required this.hours,
    required this.multiplier,
    this.isPopular = false,
  });
}

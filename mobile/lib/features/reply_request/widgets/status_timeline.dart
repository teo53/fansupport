import 'package:flutter/material.dart';
import '../../../core/theme/design_system.dart';
import '../models/reply_request_model.dart';

/// Timeline widget showing request status progression
class StatusTimeline extends StatelessWidget {
  final ReplyRequestStatus currentStatus;
  final DateTime? createdAt;
  final DateTime? queuedAt;
  final DateTime? startedAt;
  final DateTime? deliveredAt;
  final DateTime? expiredAt;
  final DateTime? refundedAt;
  final bool isCompact;

  const StatusTimeline({
    super.key,
    required this.currentStatus,
    this.createdAt,
    this.queuedAt,
    this.startedAt,
    this.deliveredAt,
    this.expiredAt,
    this.refundedAt,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final steps = _buildSteps();

    if (isCompact) {
      return _buildCompactTimeline(steps);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < steps.length; i++) ...[
          _buildTimelineStep(steps[i], isLast: i == steps.length - 1),
        ],
      ],
    );
  }

  List<_TimelineStep> _buildSteps() {
    final isRefunded = currentStatus == ReplyRequestStatus.refunded;
    final isExpired = currentStatus == ReplyRequestStatus.expired;
    final isRejected = currentStatus == ReplyRequestStatus.rejected;
    final isDelivered = currentStatus == ReplyRequestStatus.delivered;

    final steps = <_TimelineStep>[];

    // Step 1: Created/Pending Payment
    steps.add(_TimelineStep(
      status: ReplyRequestStatus.pendingPayment,
      label: '요청 생성',
      timestamp: createdAt,
      isCompleted: _isStatusPast(ReplyRequestStatus.pendingPayment),
      isCurrent: currentStatus == ReplyRequestStatus.pendingPayment,
    ));

    // Step 2: Queued
    steps.add(_TimelineStep(
      status: ReplyRequestStatus.queued,
      label: '결제 완료 / 대기중',
      timestamp: queuedAt,
      isCompleted: _isStatusPast(ReplyRequestStatus.queued),
      isCurrent: currentStatus == ReplyRequestStatus.queued,
    ));

    // Step 3: In Progress
    steps.add(_TimelineStep(
      status: ReplyRequestStatus.inProgress,
      label: '작업중',
      timestamp: startedAt,
      isCompleted: _isStatusPast(ReplyRequestStatus.inProgress),
      isCurrent: currentStatus == ReplyRequestStatus.inProgress,
    ));

    // Step 4: Final state (varies based on outcome)
    if (isDelivered) {
      steps.add(_TimelineStep(
        status: ReplyRequestStatus.delivered,
        label: '전달 완료',
        timestamp: deliveredAt,
        isCompleted: true,
        isCurrent: true,
        isSuccess: true,
      ));
    } else if (isExpired || isRefunded) {
      steps.add(_TimelineStep(
        status: isRefunded ? ReplyRequestStatus.refunded : ReplyRequestStatus.expired,
        label: isRefunded ? '환불 완료' : 'SLA 만료',
        timestamp: isRefunded ? refundedAt : expiredAt,
        isCompleted: true,
        isCurrent: true,
        isError: true,
      ));
    } else if (isRejected) {
      steps.add(_TimelineStep(
        status: ReplyRequestStatus.rejected,
        label: '거절됨',
        timestamp: null,
        isCompleted: true,
        isCurrent: true,
        isError: true,
      ));
    } else {
      // Still in progress - show expected delivery
      steps.add(_TimelineStep(
        status: ReplyRequestStatus.delivered,
        label: '전달 예정',
        timestamp: null,
        isCompleted: false,
        isCurrent: false,
      ));
    }

    return steps;
  }

  bool _isStatusPast(ReplyRequestStatus status) {
    final statusOrder = [
      ReplyRequestStatus.pendingPayment,
      ReplyRequestStatus.queued,
      ReplyRequestStatus.inProgress,
      ReplyRequestStatus.delivered,
    ];

    final currentIndex = statusOrder.indexOf(currentStatus);
    final checkIndex = statusOrder.indexOf(status);

    if (currentIndex == -1) {
      // Current status is a terminal state (expired, refunded, rejected)
      // Consider all statuses before it as past
      return status != ReplyRequestStatus.delivered;
    }

    return checkIndex < currentIndex;
  }

  Widget _buildTimelineStep(_TimelineStep step, {required bool isLast}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              _buildIndicator(step),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: step.isCompleted
                        ? (step.isError ? PipoColors.error : PipoColors.primary)
                        : PipoColors.border,
                  ),
                ),
            ],
          ),
          const SizedBox(width: PipoSpacing.md),

          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : PipoSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.label,
                    style: PipoTypography.titleSmall.copyWith(
                      color: step.isCurrent
                          ? (step.isError
                              ? PipoColors.error
                              : (step.isSuccess
                                  ? PipoColors.success
                                  : PipoColors.primary))
                          : (step.isCompleted
                              ? PipoColors.textPrimary
                              : PipoColors.textTertiary),
                      fontWeight:
                          step.isCurrent ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  if (step.timestamp != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      _formatTimestamp(step.timestamp!),
                      style: PipoTypography.labelSmall.copyWith(
                        color: PipoColors.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(_TimelineStep step) {
    final color = step.isError
        ? PipoColors.error
        : (step.isSuccess ? PipoColors.success : PipoColors.primary);

    if (step.isCurrent) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
        ),
        child: Center(
          child: step.isError
              ? Icon(Icons.close_rounded, size: 14, color: color)
              : (step.isSuccess
                  ? Icon(Icons.check_rounded, size: 14, color: color)
                  : Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    )),
        ),
      );
    }

    if (step.isCompleted) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(Icons.check_rounded, size: 14, color: Colors.white),
        ),
      );
    }

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: PipoColors.surface,
        shape: BoxShape.circle,
        border: Border.all(color: PipoColors.border, width: 2),
      ),
    );
  }

  Widget _buildCompactTimeline(List<_TimelineStep> steps) {
    return Row(
      children: [
        for (int i = 0; i < steps.length; i++) ...[
          _buildCompactIndicator(steps[i]),
          if (i < steps.length - 1)
            Expanded(
              child: Container(
                height: 2,
                color: steps[i].isCompleted
                    ? (steps[i].isError ? PipoColors.error : PipoColors.primary)
                    : PipoColors.border,
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildCompactIndicator(_TimelineStep step) {
    final color = step.isError
        ? PipoColors.error
        : (step.isSuccess ? PipoColors.success : PipoColors.primary);

    if (step.isCurrent) {
      return Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
        ),
        child: Center(
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    }

    if (step.isCompleted) {
      return Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(Icons.check_rounded, size: 10, color: Colors.white),
        ),
      );
    }

    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: PipoColors.surface,
        shape: BoxShape.circle,
        border: Border.all(color: PipoColors.border, width: 2),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) {
      return '방금 전';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}분 전';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}시간 전';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}일 전';
    } else {
      return '${timestamp.month}/${timestamp.day} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}

class _TimelineStep {
  final ReplyRequestStatus status;
  final String label;
  final DateTime? timestamp;
  final bool isCompleted;
  final bool isCurrent;
  final bool isError;
  final bool isSuccess;

  _TimelineStep({
    required this.status,
    required this.label,
    this.timestamp,
    required this.isCompleted,
    required this.isCurrent,
    this.isError = false,
    this.isSuccess = false,
  });
}

/// Simple status badge for list items
class StatusBadge extends StatelessWidget {
  final ReplyRequestStatus status;
  final bool showIcon;

  const StatusBadge({
    super.key,
    required this.status,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PipoSpacing.sm,
        vertical: PipoSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(PipoRadius.sm),
        border: Border.all(color: status.color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(status.icon, size: 12, color: status.color),
            const SizedBox(width: PipoSpacing.xs),
          ],
          Text(
            status.displayName,
            style: PipoTypography.labelSmall.copyWith(
              color: status.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

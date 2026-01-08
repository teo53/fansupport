import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/design_system.dart';
import '../../../shared/widgets/glass_card.dart';

/// Reply Request Detail Screen - Shows request details, status timeline, and delivery
class ReplyRequestDetailScreen extends ConsumerWidget {
  final String requestId;

  const ReplyRequestDetailScreen({
    super.key,
    required this.requestId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Fetch request from provider
    final request = _getMockRequest();

    return Scaffold(
      backgroundColor: PipoColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          color: PipoColors.textPrimary,
          onPressed: () => context.pop(),
        ),
        title: Text(
          '요청 상세',
          style: PipoTypography.titleLarge.copyWith(
            color: PipoColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            color: PipoColors.textSecondary,
            onPressed: () => _showOptionsMenu(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(PipoSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Creator info
            _buildCreatorCard(context, request),
            const SizedBox(height: PipoSpacing.lg),

            // Status timeline
            _buildStatusTimeline(request),
            const SizedBox(height: PipoSpacing.lg),

            // SLA countdown (if pending)
            if (['QUEUED', 'IN_PROGRESS'].contains(request['status']))
              _buildSlaCountdown(request),

            // Request content
            _buildRequestContent(request),
            const SizedBox(height: PipoSpacing.lg),

            // Delivery content (if delivered)
            if (request['status'] == 'DELIVERED' && request['delivery'] != null)
              _buildDeliveryContent(context, request),

            // Refund info (if refunded)
            if (['REFUNDED', 'EXPIRED', 'REJECTED'].contains(request['status']))
              _buildRefundInfo(request),

            // Price info
            _buildPriceInfo(request),
            const SizedBox(height: PipoSpacing.lg),

            // Actions
            _buildActions(context, request),
          ],
        ),
      ),
    );
  }

  Widget _buildCreatorCard(BuildContext context, Map<String, dynamic> request) {
    return GlassCard(
      onTap: () => context.push('/idols/${request['creatorId']}'),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: PipoColors.surfaceVariant,
            child: const Icon(Icons.person, color: PipoColors.textTertiary),
          ),
          const SizedBox(width: PipoSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request['creatorName'] ?? '',
                  style: PipoTypography.titleMedium.copyWith(
                    color: PipoColors.textPrimary,
                  ),
                ),
                Text(
                  request['productName'] ?? '',
                  style: PipoTypography.bodySmall.copyWith(
                    color: PipoColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: PipoColors.textTertiary,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTimeline(Map<String, dynamic> request) {
    final status = request['status'] as String;
    final steps = [
      {'key': 'created', 'label': '요청됨', 'time': request['createdAt']},
      {'key': 'queued', 'label': '대기중', 'time': request['queuedAt']},
      {'key': 'in_progress', 'label': '작업중', 'time': request['startedAt']},
      {'key': 'delivered', 'label': '완료', 'time': request['deliveredAt']},
    ];

    int currentStep;
    switch (status) {
      case 'QUEUED':
        currentStep = 1;
        break;
      case 'IN_PROGRESS':
        currentStep = 2;
        break;
      case 'DELIVERED':
        currentStep = 3;
        break;
      case 'EXPIRED':
      case 'REFUNDED':
      case 'REJECTED':
        currentStep = -1; // Show error state
        break;
      default:
        currentStep = 0;
    }

    if (currentStep < 0) {
      return _buildErrorStatus(status, request);
    }

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '진행 상태',
            style: PipoTypography.titleSmall.copyWith(
              color: PipoColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: PipoSpacing.md),
          ...steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isCompleted = index <= currentStep;
            final isCurrent = index == currentStep;
            final isLast = index == steps.length - 1;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted
                            ? (isCurrent ? PipoColors.primary : PipoColors.success)
                            : PipoColors.surfaceVariant,
                        border: Border.all(
                          color: isCompleted
                              ? (isCurrent ? PipoColors.primary : PipoColors.success)
                              : PipoColors.border,
                          width: 2,
                        ),
                      ),
                      child: isCompleted
                          ? Icon(
                              isCurrent ? Icons.hourglass_bottom_rounded : Icons.check_rounded,
                              size: 14,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 32,
                        color: index < currentStep
                            ? PipoColors.success
                            : PipoColors.border,
                      ),
                  ],
                ),
                const SizedBox(width: PipoSpacing.md),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : PipoSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step['label'] as String,
                          style: PipoTypography.titleSmall.copyWith(
                            color: isCompleted
                                ? PipoColors.textPrimary
                                : PipoColors.textTertiary,
                          ),
                        ),
                        if (step['time'] != null)
                          Text(
                            step['time'] as String,
                            style: PipoTypography.labelSmall.copyWith(
                              color: PipoColors.textTertiary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildErrorStatus(String status, Map<String, dynamic> request) {
    final statusInfo = _getErrorStatusInfo(status);

    return GlassCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: statusInfo['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(PipoRadius.md),
            ),
            child: Icon(
              statusInfo['icon'],
              color: statusInfo['color'],
            ),
          ),
          const SizedBox(width: PipoSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusInfo['title'],
                  style: PipoTypography.titleMedium.copyWith(
                    color: statusInfo['color'],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  statusInfo['description'],
                  style: PipoTypography.bodySmall.copyWith(
                    color: PipoColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlaCountdown(Map<String, dynamic> request) {
    return Container(
      margin: const EdgeInsets.only(bottom: PipoSpacing.lg),
      padding: const EdgeInsets.all(PipoSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            PipoColors.warning.withOpacity(0.1),
            PipoColors.warning.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(PipoRadius.lg),
        border: Border.all(color: PipoColors.warning.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.timer_outlined,
            color: PipoColors.warning,
          ),
          const SizedBox(width: PipoSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SLA 마감까지',
                  style: PipoTypography.labelMedium.copyWith(
                    color: PipoColors.textSecondary,
                  ),
                ),
                Text(
                  request['deadline'] ?? '23시간 45분',
                  style: PipoTypography.titleLarge.copyWith(
                    color: PipoColors.warning,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${request['slaName'] ?? 'Standard'}',
            style: PipoTypography.labelMedium.copyWith(
              color: PipoColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestContent(Map<String, dynamic> request) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '요청 내용',
                style: PipoTypography.titleSmall.copyWith(
                  color: PipoColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (request['isAnonymous'] == true)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: PipoSpacing.sm,
                    vertical: PipoSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: PipoColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(PipoRadius.sm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.visibility_off_rounded,
                        size: 14,
                        color: PipoColors.textTertiary,
                      ),
                      const SizedBox(width: PipoSpacing.xs),
                      Text(
                        '익명',
                        style: PipoTypography.labelSmall.copyWith(
                          color: PipoColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: PipoSpacing.md),
          Text(
            request['message'] ?? '',
            style: PipoTypography.bodyMedium.copyWith(
              color: PipoColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryContent(BuildContext context, Map<String, dynamic> request) {
    final delivery = request['delivery'] as Map<String, dynamic>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.mark_email_read_rounded,
                    color: PipoColors.success,
                  ),
                  const SizedBox(width: PipoSpacing.sm),
                  Text(
                    '리프 도착!',
                    style: PipoTypography.titleMedium.copyWith(
                      color: PipoColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: PipoSpacing.md),

              // Text content
              if (delivery['textContent'] != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(PipoSpacing.md),
                  decoration: BoxDecoration(
                    color: PipoColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(PipoRadius.md),
                  ),
                  child: Text(
                    delivery['textContent'],
                    style: PipoTypography.bodyMedium.copyWith(
                      color: PipoColors.textPrimary,
                    ),
                  ),
                ),
              ],

              // Media content placeholder
              if (delivery['voiceUrl'] != null) ...[
                const SizedBox(height: PipoSpacing.md),
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: PipoColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(PipoRadius.md),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          // TODO: Play voice
                        },
                        icon: const Icon(Icons.play_circle_filled_rounded),
                        color: PipoColors.primary,
                        iconSize: 40,
                      ),
                      Text(
                        '${delivery['duration'] ?? 0}초',
                        style: PipoTypography.labelMedium.copyWith(
                          color: PipoColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              if (delivery['creatorNote'] != null) ...[
                const SizedBox(height: PipoSpacing.md),
                Text(
                  '크리에이터 메모: ${delivery['creatorNote']}',
                  style: PipoTypography.bodySmall.copyWith(
                    color: PipoColors.textTertiary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: PipoSpacing.lg),

        // Feedback section
        if (delivery['fanRating'] == null)
          _buildFeedbackPrompt(context)
        else
          _buildFeedbackSummary(delivery),
      ],
    );
  }

  Widget _buildFeedbackPrompt(BuildContext context) {
    return GlassCard(
      child: Column(
        children: [
          Text(
            '리프는 어떠셨나요?',
            style: PipoTypography.titleSmall.copyWith(
              color: PipoColors.textPrimary,
            ),
          ),
          const SizedBox(height: PipoSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                onPressed: () {
                  // TODO: Submit rating
                },
                icon: Icon(
                  Icons.star_border_rounded,
                  color: PipoColors.warning,
                  size: 32,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackSummary(Map<String, dynamic> delivery) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '내 평가',
                style: PipoTypography.titleSmall.copyWith(
                  color: PipoColors.textPrimary,
                ),
              ),
              const Spacer(),
              ...List.generate(5, (index) {
                return Icon(
                  index < (delivery['fanRating'] ?? 0)
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  color: PipoColors.warning,
                  size: 20,
                );
              }),
            ],
          ),
          if (delivery['fanFeedback'] != null) ...[
            const SizedBox(height: PipoSpacing.sm),
            Text(
              delivery['fanFeedback'],
              style: PipoTypography.bodySmall.copyWith(
                color: PipoColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRefundInfo(Map<String, dynamic> request) {
    return Container(
      margin: const EdgeInsets.only(bottom: PipoSpacing.lg),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.replay_rounded,
                  color: PipoColors.info,
                ),
                const SizedBox(width: PipoSpacing.sm),
                Text(
                  '환불 완료',
                  style: PipoTypography.titleMedium.copyWith(
                    color: PipoColors.info,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: PipoSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '환불 금액',
                  style: PipoTypography.bodyMedium.copyWith(
                    color: PipoColors.textSecondary,
                  ),
                ),
                Text(
                  '${request['totalPrice']}원',
                  style: PipoTypography.titleMedium.copyWith(
                    color: PipoColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (request['refundReason'] != null) ...[
              const SizedBox(height: PipoSpacing.sm),
              Text(
                '사유: ${request['refundReason']}',
                style: PipoTypography.bodySmall.copyWith(
                  color: PipoColors.textTertiary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPriceInfo(Map<String, dynamic> request) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '결제 정보',
            style: PipoTypography.titleSmall.copyWith(
              color: PipoColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: PipoSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '상품',
                style: PipoTypography.bodyMedium.copyWith(
                  color: PipoColors.textSecondary,
                ),
              ),
              Text(
                request['productName'] ?? '',
                style: PipoTypography.bodyMedium.copyWith(
                  color: PipoColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: PipoSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SLA',
                style: PipoTypography.bodyMedium.copyWith(
                  color: PipoColors.textSecondary,
                ),
              ),
              Text(
                request['slaName'] ?? '',
                style: PipoTypography.bodyMedium.copyWith(
                  color: PipoColors.textPrimary,
                ),
              ),
            ],
          ),
          const Divider(height: PipoSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '총 결제금액',
                style: PipoTypography.titleSmall.copyWith(
                  color: PipoColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${request['totalPrice']}원',
                style: PipoTypography.titleMedium.copyWith(
                  color: PipoColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, Map<String, dynamic> request) {
    final status = request['status'];

    return Column(
      children: [
        if (status == 'DELIVERED')
          ElevatedButton.icon(
            onPressed: () => context.push('/create?creatorId=${request['creatorId']}'),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('같은 크리에이터에게 다시 요청'),
            style: ElevatedButton.styleFrom(
              backgroundColor: PipoColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: PipoSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(PipoRadius.lg),
              ),
              minimumSize: const Size(double.infinity, 56),
            ),
          ),
      ],
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: PipoColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(PipoRadius.xl)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.flag_rounded),
              title: const Text('신고하기'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Show report dialog
              },
            ),
            ListTile(
              leading: const Icon(Icons.block_rounded),
              title: const Text('차단하기'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Block creator
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline_rounded),
              title: const Text('문의하기'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Open support
              },
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getErrorStatusInfo(String status) {
    switch (status) {
      case 'EXPIRED':
        return {
          'icon': Icons.timer_off_rounded,
          'color': PipoColors.error,
          'title': 'SLA 만료',
          'description': '크리에이터가 시간 내 답변하지 못해 자동 환불되었습니다.',
        };
      case 'REJECTED':
        return {
          'icon': Icons.cancel_rounded,
          'color': PipoColors.error,
          'title': '요청 거절',
          'description': '크리에이터가 요청을 거절하여 환불되었습니다.',
        };
      case 'REFUNDED':
      default:
        return {
          'icon': Icons.replay_rounded,
          'color': PipoColors.info,
          'title': '환불됨',
          'description': '요청이 환불 처리되었습니다.',
        };
    }
  }

  Map<String, dynamic> _getMockRequest() {
    return {
      'id': requestId,
      'creatorId': '1',
      'creatorName': 'Sakura',
      'productName': '텍스트 메시지',
      'slaName': 'Standard (48시간)',
      'status': 'DELIVERED',
      'message': '안녕하세요! 저는 오랫동안 팬이었어요. 응원 메시지 부탁드려요!',
      'isAnonymous': false,
      'totalPrice': '5,000',
      'deadline': '23시간 45분',
      'createdAt': '2024.01.15 14:30',
      'queuedAt': '2024.01.15 14:30',
      'startedAt': '2024.01.15 18:00',
      'deliveredAt': '2024.01.16 10:00',
      'delivery': {
        'textContent': '안녕하세요! 항상 응원해주셔서 정말 감사합니다! 덕분에 힘이 나요. 앞으로도 좋은 모습 보여드릴게요. 사랑해요! 💕',
        'creatorNote': null,
        'fanRating': null,
        'fanFeedback': null,
      },
    };
  }
}

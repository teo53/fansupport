import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/design_system.dart';
import '../../../shared/widgets/glass_card.dart';

/// Creator Queue Screen - Creator's work queue for managing reply requests
class CreatorQueueScreen extends ConsumerStatefulWidget {
  const CreatorQueueScreen({super.key});

  @override
  ConsumerState<CreatorQueueScreen> createState() => _CreatorQueueScreenState();
}

class _CreatorQueueScreenState extends ConsumerState<CreatorQueueScreen> {
  @override
  Widget build(BuildContext context) {
    // TODO: Fetch queue data from provider
    final queueStats = _getMockQueueStats();
    final requests = _getMockQueueRequests();

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
          '작업 큐',
          style: PipoTypography.titleLarge.copyWith(
            color: PipoColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            color: PipoColors.textSecondary,
            onPressed: () => _showQueueSettings(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatsHeader(queueStats),
          Expanded(
            child: requests.isEmpty
                ? _buildEmptyState()
                : _buildQueueList(requests),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsHeader(Map<String, dynamic> stats) {
    return Container(
      margin: const EdgeInsets.all(PipoSpacing.md),
      padding: const EdgeInsets.all(PipoSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            PipoColors.primary.withOpacity(0.1),
            PipoColors.primaryLight.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(PipoRadius.lg),
        border: Border.all(color: PipoColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          _buildStatItem(
            icon: Icons.inbox_rounded,
            value: '${stats['queueCount']}',
            label: '대기중',
            color: PipoColors.primary,
          ),
          _buildStatDivider(),
          _buildStatItem(
            icon: Icons.check_circle_rounded,
            value: '${stats['todayDelivered']}',
            label: '오늘 완료',
            color: PipoColors.success,
          ),
          _buildStatDivider(),
          _buildStatItem(
            icon: Icons.event_available_rounded,
            value: '${stats['remainingSlots']}/${stats['dailySlotLimit']}',
            label: '남은 슬롯',
            color: stats['remainingSlots'] > 0 ? PipoColors.success : PipoColors.error,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: PipoSpacing.xs),
          Text(
            value,
            style: PipoTypography.titleLarge.copyWith(
              color: PipoColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: PipoTypography.labelSmall.copyWith(
              color: PipoColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 40,
      color: PipoColors.border,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_rounded,
            size: 64,
            color: PipoColors.textTertiary,
          ),
          const SizedBox(height: PipoSpacing.md),
          Text(
            '대기 중인 요청이 없습니다',
            style: PipoTypography.titleMedium.copyWith(
              color: PipoColors.textSecondary,
            ),
          ),
          const SizedBox(height: PipoSpacing.sm),
          Text(
            '잠시 쉬어가세요!',
            style: PipoTypography.bodyMedium.copyWith(
              color: PipoColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueueList(List<Map<String, dynamic>> requests) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: PipoSpacing.md),
      itemCount: requests.length,
      itemBuilder: (context, index) => _buildQueueCard(requests[index]),
    );
  }

  Widget _buildQueueCard(Map<String, dynamic> request) {
    final isUrgent = request['isUrgent'] == true;
    final status = request['status'] as String;

    return GlassCard(
      margin: const EdgeInsets.only(bottom: PipoSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with urgency indicator
          Row(
            children: [
              if (isUrgent)
                Container(
                  margin: const EdgeInsets.only(right: PipoSpacing.sm),
                  padding: const EdgeInsets.symmetric(
                    horizontal: PipoSpacing.sm,
                    vertical: PipoSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: PipoColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(PipoRadius.sm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 14,
                        color: PipoColors.error,
                      ),
                      const SizedBox(width: PipoSpacing.xs),
                      Text(
                        '긴급',
                        style: PipoTypography.labelSmall.copyWith(
                          color: PipoColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: PipoSpacing.sm,
                  vertical: PipoSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: PipoColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(PipoRadius.sm),
                ),
                child: Text(
                  request['productName'] ?? '',
                  style: PipoTypography.labelSmall.copyWith(
                    color: PipoColors.textSecondary,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: PipoSpacing.sm,
                  vertical: PipoSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(PipoRadius.sm),
                ),
                child: Text(
                  _getStatusText(status),
                  style: PipoTypography.labelSmall.copyWith(
                    color: _getStatusColor(status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: PipoSpacing.md),

          // Fan info (if not anonymous)
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: PipoColors.surfaceVariant,
                child: request['isAnonymous'] == true
                    ? const Icon(Icons.visibility_off, size: 16, color: PipoColors.textTertiary)
                    : const Icon(Icons.person, size: 20, color: PipoColors.textTertiary),
              ),
              const SizedBox(width: PipoSpacing.sm),
              Text(
                request['isAnonymous'] == true ? '익명' : (request['fanName'] ?? 'Fan'),
                style: PipoTypography.titleSmall.copyWith(
                  color: PipoColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: PipoSpacing.md),

          // Request message
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(PipoSpacing.md),
            decoration: BoxDecoration(
              color: PipoColors.surfaceVariant,
              borderRadius: BorderRadius.circular(PipoRadius.md),
            ),
            child: Text(
              request['message'] ?? '',
              style: PipoTypography.bodyMedium.copyWith(
                color: PipoColors.textPrimary,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: PipoSpacing.md),

          // Deadline and price
          Row(
            children: [
              Icon(
                Icons.timer_outlined,
                size: 16,
                color: isUrgent ? PipoColors.error : PipoColors.warning,
              ),
              const SizedBox(width: PipoSpacing.xs),
              Text(
                request['deadline'] ?? '',
                style: PipoTypography.labelMedium.copyWith(
                  color: isUrgent ? PipoColors.error : PipoColors.warning,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${request['price']}원',
                style: PipoTypography.titleSmall.copyWith(
                  color: PipoColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: PipoSpacing.md),

          // Action buttons
          Row(
            children: [
              if (status == 'QUEUED')
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _startRequest(request['id']),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: PipoColors.primary,
                      side: BorderSide(color: PipoColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(PipoRadius.md),
                      ),
                    ),
                    child: const Text('작업 시작'),
                  ),
                ),
              if (status == 'IN_PROGRESS') ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showRejectDialog(context, request['id']),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: PipoColors.error,
                      side: BorderSide(color: PipoColors.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(PipoRadius.md),
                      ),
                    ),
                    child: const Text('거절'),
                  ),
                ),
                const SizedBox(width: PipoSpacing.md),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () => _showDeliverDialog(context, request),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PipoColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(PipoRadius.md),
                      ),
                    ),
                    child: const Text('답장 보내기'),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'QUEUED':
        return PipoColors.info;
      case 'IN_PROGRESS':
        return PipoColors.warning;
      default:
        return PipoColors.textSecondary;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'QUEUED':
        return '대기중';
      case 'IN_PROGRESS':
        return '작업중';
      default:
        return status;
    }
  }

  void _startRequest(String requestId) {
    // TODO: Call API to start request
    setState(() {});
  }

  void _showRejectDialog(BuildContext context, String requestId) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('요청 거절'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('거절 사유를 입력해주세요. 팬에게 전액 환불됩니다.'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: '거절 사유',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Call reject API
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('거절하기'),
          ),
        ],
      ),
    );
  }

  void _showDeliverDialog(BuildContext context, Map<String, dynamic> request) {
    final contentController = TextEditingController();
    final contentType = request['contentType'] ?? 'TEXT';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: PipoColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(PipoRadius.xl)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: PipoSpacing.md,
          right: PipoSpacing.md,
          top: PipoSpacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '답장 작성',
                  style: PipoTypography.titleLarge.copyWith(
                    color: PipoColors.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: PipoSpacing.md),

            // Quick templates
            Text(
              '빠른 답장 템플릿',
              style: PipoTypography.labelMedium.copyWith(
                color: PipoColors.textSecondary,
              ),
            ),
            const SizedBox(height: PipoSpacing.sm),
            Wrap(
              spacing: PipoSpacing.sm,
              children: [
                _buildTemplateChip('감사합니다!', contentController),
                _buildTemplateChip('응원해주세요!', contentController),
                _buildTemplateChip('사랑해요~', contentController),
              ],
            ),
            const SizedBox(height: PipoSpacing.md),

            // Content input
            if (contentType == 'TEXT')
              TextField(
                controller: contentController,
                maxLines: 4,
                maxLength: 500,
                decoration: InputDecoration(
                  hintText: '답장을 입력하세요...',
                  filled: true,
                  fillColor: PipoColors.surfaceVariant,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(PipoRadius.md),
                    borderSide: BorderSide.none,
                  ),
                ),
              )
            else
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: PipoColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(PipoRadius.md),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        contentType == 'VOICE'
                            ? Icons.mic_rounded
                            : contentType == 'VIDEO'
                                ? Icons.videocam_rounded
                                : Icons.camera_alt_rounded,
                        size: 32,
                        color: PipoColors.primary,
                      ),
                      const SizedBox(height: PipoSpacing.sm),
                      Text(
                        contentType == 'VOICE'
                            ? '음성 녹음하기'
                            : contentType == 'VIDEO'
                                ? '영상 촬영하기'
                                : '사진 촬영하기',
                        style: PipoTypography.labelMedium.copyWith(
                          color: PipoColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: PipoSpacing.lg),

            // Submit button
            SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Submit delivery
                    Navigator.pop(context);
                    _showDeliverySuccess(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PipoColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: PipoSpacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(PipoRadius.lg),
                    ),
                  ),
                  child: const Text('답장 보내기'),
                ),
              ),
            ),
            const SizedBox(height: PipoSpacing.md),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateChip(String text, TextEditingController controller) {
    return ActionChip(
      label: Text(text),
      onPressed: () {
        controller.text += text;
      },
      backgroundColor: PipoColors.surfaceVariant,
      labelStyle: PipoTypography.labelMedium.copyWith(
        color: PipoColors.textSecondary,
      ),
    );
  }

  void _showDeliverySuccess(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 8),
            const Text('답장이 성공적으로 전송되었습니다!'),
          ],
        ),
        backgroundColor: PipoColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PipoRadius.md),
        ),
      ),
    );
  }

  void _showQueueSettings(BuildContext context) {
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
              leading: const Icon(Icons.tune_rounded),
              title: const Text('슬롯 설정'),
              subtitle: const Text('일일 최대 접수량 조절'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Open slot settings
              },
            ),
            ListTile(
              leading: const Icon(Icons.schedule_rounded),
              title: const Text('SLA 설정'),
              subtitle: const Text('응답 시간 옵션 관리'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Open SLA settings
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_money_rounded),
              title: const Text('가격 설정'),
              subtitle: const Text('상품별 가격 조절'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Open price settings
              },
            ),
            ListTile(
              leading: Icon(Icons.pause_circle_rounded, color: PipoColors.warning),
              title: const Text('접수 일시중지'),
              subtitle: const Text('새 요청 접수를 중지합니다'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Pause queue
              },
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getMockQueueStats() {
    return {
      'queueCount': 3,
      'todayDelivered': 5,
      'totalDelivered': 127,
      'dailySlotLimit': 10,
      'remainingSlots': 5,
    };
  }

  List<Map<String, dynamic>> _getMockQueueRequests() {
    return [
      {
        'id': '1',
        'fanName': 'Fan123',
        'isAnonymous': false,
        'productName': '텍스트 메시지',
        'contentType': 'TEXT',
        'message': '생일 축하 메시지 부탁드립니다! 항상 응원하고 있어요!',
        'status': 'IN_PROGRESS',
        'deadline': '2시간 30분',
        'price': '5,000',
        'isUrgent': true,
      },
      {
        'id': '2',
        'fanName': null,
        'isAnonymous': true,
        'productName': '보이스 메시지',
        'contentType': 'VOICE',
        'message': '응원 한마디 부탁드려요~',
        'status': 'QUEUED',
        'deadline': '23시간 45분',
        'price': '10,000',
        'isUrgent': false,
      },
      {
        'id': '3',
        'fanName': 'SuperFan',
        'isAnonymous': false,
        'productName': '셀카 사진',
        'contentType': 'PHOTO',
        'message': '팬미팅 기념으로 셀카 한장 부탁드려요!',
        'status': 'QUEUED',
        'deadline': '47시간 12분',
        'price': '8,000',
        'isUrgent': false,
      },
    ];
  }
}

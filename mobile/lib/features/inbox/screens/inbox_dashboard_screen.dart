import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/design_system.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../reply_request/providers/reply_request_provider.dart';
import '../../reply_request/models/reply_request_model.dart';
import '../../reply_request/widgets/status_timeline.dart';
import '../../reply_request/widgets/sla_countdown.dart';

/// Inbox Dashboard - Shows fan's reply requests organized by status
class InboxDashboardScreen extends ConsumerStatefulWidget {
  const InboxDashboardScreen({super.key});

  @override
  ConsumerState<InboxDashboardScreen> createState() => _InboxDashboardScreenState();
}

class _InboxDashboardScreenState extends ConsumerState<InboxDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PipoColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildRequestList('all'),
                  _buildRequestList('queued'),
                  _buildRequestList('delivered'),
                  _buildRequestList('refunded'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(PipoSpacing.md),
      child: Row(
        children: [
          Text(
            '받은함',
            style: PipoTypography.heading1.copyWith(
              color: PipoColors.textPrimary,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              // TODO: Show filter/sort options
            },
            icon: const Icon(Icons.filter_list_rounded),
            color: PipoColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: PipoSpacing.md),
      decoration: BoxDecoration(
        color: PipoColors.surfaceVariant,
        borderRadius: BorderRadius.circular(PipoRadius.lg),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: PipoColors.primary,
          borderRadius: BorderRadius.circular(PipoRadius.md),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: PipoColors.textSecondary,
        labelStyle: PipoTypography.labelMedium.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: PipoTypography.labelMedium,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: '전체'),
          Tab(text: '진행중'),
          Tab(text: '완료'),
          Tab(text: '환불'),
        ],
      ),
    );
  }

  Widget _buildRequestList(String filter) {
    // Get the appropriate status filter
    final statusFilter = _getStatusFilter(filter);
    final inboxFilter = InboxFilter(status: statusFilter);

    // Watch the provider
    final requestsAsync = ref.watch(inboxRequestsProvider(inboxFilter));

    return requestsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error.toString()),
      data: (response) {
        if (response.data.isEmpty) {
          return _buildEmptyState(filter);
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(inboxRequestsProvider(inboxFilter));
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(PipoSpacing.md),
            itemCount: response.data.length,
            itemBuilder: (context, index) {
              return _buildRequestCardFromModel(response.data[index]);
            },
          ),
        );
      },
    );
  }

  ReplyRequestStatus? _getStatusFilter(String filter) {
    switch (filter) {
      case 'queued':
        return ReplyRequestStatus.queued;
      case 'delivered':
        return ReplyRequestStatus.delivered;
      case 'refunded':
        return ReplyRequestStatus.refunded;
      default:
        return null; // All requests
    }
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: PipoColors.error,
          ),
          const SizedBox(height: PipoSpacing.md),
          Text(
            '데이터를 불러오지 못했습니다',
            style: PipoTypography.bodyLarge.copyWith(
              color: PipoColors.textSecondary,
            ),
          ),
          const SizedBox(height: PipoSpacing.sm),
          Text(
            error,
            style: PipoTypography.bodySmall.copyWith(
              color: PipoColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Legacy method for mock data fallback
  Widget _buildRequestListMock(String filter) {
    final mockRequests = _getMockRequests(filter);

    if (mockRequests.isEmpty) {
      return _buildEmptyState(filter);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(PipoSpacing.md),
      itemCount: mockRequests.length,
      itemBuilder: (context, index) {
        return _buildRequestCard(mockRequests[index]);
      },
    );
  }

  Widget _buildRequestCardFromModel(ReplyRequest request) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: PipoSpacing.md),
      onTap: () {
        context.push('/reply-requests/${request.id}');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: request.creator?.profileImageUrl != null
                    ? NetworkImage(request.creator!.profileImageUrl!)
                    : null,
                backgroundColor: PipoColors.surfaceVariant,
                child: request.creator?.profileImageUrl == null
                    ? const Icon(Icons.person, color: PipoColors.textTertiary)
                    : null,
              ),
              const SizedBox(width: PipoSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.creator?.displayName ?? 'Creator',
                      style: PipoTypography.titleMedium.copyWith(
                        color: PipoColors.textPrimary,
                      ),
                    ),
                    Text(
                      request.product?.name ?? 'Product',
                      style: PipoTypography.bodySmall.copyWith(
                        color: PipoColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(status: request.status),
            ],
          ),
          const SizedBox(height: PipoSpacing.md),
          Text(
            request.requestMessage,
            style: PipoTypography.bodyMedium.copyWith(
              color: PipoColors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: PipoSpacing.md),
          Row(
            children: [
              if (request.deadlineAt != null &&
                  (request.status == ReplyRequestStatus.queued ||
                      request.status == ReplyRequestStatus.inProgress)) ...[
                SLACountdown(
                  deadline: request.deadlineAt!,
                  style: SLACountdownStyle.badge,
                ),
                const Spacer(),
              ],
              Text(
                '${_formatPrice(request.totalPrice)}원',
                style: PipoTypography.titleSmall.copyWith(
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

  String _formatPrice(double price) {
    if (price >= 1000) {
      return price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
    }
    return price.toStringAsFixed(0);
  }

  Widget _buildEmptyState(String filter) {
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
            filter == 'all' ? '아직 요청이 없습니다' : '해당 상태의 요청이 없습니다',
            style: PipoTypography.bodyLarge.copyWith(
              color: PipoColors.textSecondary,
            ),
          ),
          const SizedBox(height: PipoSpacing.sm),
          Text(
            '크리에이터에게 리프를 요청해보세요!',
            style: PipoTypography.bodyMedium.copyWith(
              color: PipoColors.textTertiary,
            ),
          ),
          const SizedBox(height: PipoSpacing.lg),
          ElevatedButton.icon(
            onPressed: () => context.go('/explore'),
            icon: const Icon(Icons.explore_rounded),
            label: const Text('크리에이터 탐색'),
            style: ElevatedButton.styleFrom(
              backgroundColor: PipoColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: PipoSpacing.lg,
                vertical: PipoSpacing.md,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(PipoRadius.lg),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {
    final status = request['status'] as String;
    final statusColor = _getStatusColor(status);
    final statusText = _getStatusText(status);

    return GlassCard(
      margin: const EdgeInsets.only(bottom: PipoSpacing.md),
      onTap: () {
        context.push('/reply-requests/${request['id']}');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: request['creatorImage'] != null
                    ? NetworkImage(request['creatorImage'])
                    : null,
                backgroundColor: PipoColors.surfaceVariant,
                child: request['creatorImage'] == null
                    ? const Icon(Icons.person, color: PipoColors.textTertiary)
                    : null,
              ),
              const SizedBox(width: PipoSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request['creatorName'] ?? 'Creator',
                      style: PipoTypography.titleMedium.copyWith(
                        color: PipoColors.textPrimary,
                      ),
                    ),
                    Text(
                      request['productName'] ?? 'Product',
                      style: PipoTypography.bodySmall.copyWith(
                        color: PipoColors.textSecondary,
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
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(PipoRadius.sm),
                ),
                child: Text(
                  statusText,
                  style: PipoTypography.labelSmall.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
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
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: PipoSpacing.md),
          Row(
            children: [
              if (status == 'QUEUED' || status == 'IN_PROGRESS') ...[
                Icon(
                  Icons.timer_outlined,
                  size: 16,
                  color: PipoColors.warning,
                ),
                const SizedBox(width: PipoSpacing.xs),
                Text(
                  request['deadline'] ?? '',
                  style: PipoTypography.labelSmall.copyWith(
                    color: PipoColors.warning,
                  ),
                ),
                const Spacer(),
              ],
              Text(
                '${request['price']}원',
                style: PipoTypography.titleSmall.copyWith(
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'QUEUED':
        return PipoColors.info;
      case 'IN_PROGRESS':
        return PipoColors.warning;
      case 'DELIVERED':
        return PipoColors.success;
      case 'EXPIRED':
      case 'REFUNDED':
      case 'REJECTED':
        return PipoColors.error;
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
      case 'DELIVERED':
        return '완료';
      case 'EXPIRED':
        return '만료';
      case 'REFUNDED':
        return '환불됨';
      case 'REJECTED':
        return '거절됨';
      default:
        return status;
    }
  }

  List<Map<String, dynamic>> _getMockRequests(String filter) {
    final allRequests = [
      {
        'id': '1',
        'creatorName': 'Sakura',
        'creatorImage': null,
        'productName': '텍스트 메시지',
        'message': '안녕하세요! 저는 오랫동안 팬이었어요. 응원 메시지 부탁드려요!',
        'status': 'QUEUED',
        'deadline': '23시간 남음',
        'price': '5,000',
      },
      {
        'id': '2',
        'creatorName': 'Yuki',
        'creatorImage': null,
        'productName': '보이스 메시지',
        'message': '생일 축하 메시지 녹음 부탁드립니다!',
        'status': 'IN_PROGRESS',
        'deadline': '12시간 남음',
        'price': '15,000',
      },
      {
        'id': '3',
        'creatorName': 'Mina',
        'creatorImage': null,
        'productName': '셀카 사진',
        'message': '팬미팅 기념 셀카 부탁드려요!',
        'status': 'DELIVERED',
        'price': '10,000',
      },
    ];

    if (filter == 'all') return allRequests;
    if (filter == 'queued') {
      return allRequests
          .where((r) => r['status'] == 'QUEUED' || r['status'] == 'IN_PROGRESS')
          .toList();
    }
    if (filter == 'delivered') {
      return allRequests.where((r) => r['status'] == 'DELIVERED').toList();
    }
    if (filter == 'refunded') {
      return allRequests
          .where((r) =>
              r['status'] == 'REFUNDED' ||
              r['status'] == 'EXPIRED' ||
              r['status'] == 'REJECTED')
          .toList();
    }
    return allRequests;
  }
}

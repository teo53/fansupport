import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/mock/mock_data.dart';

class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() =>
      _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<NotificationItem> _notifications = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadNotifications();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadNotifications() {
    final idols = MockData.idolModels;
    setState(() {
      _notifications.addAll([
        NotificationItem(
          id: '1',
          type: NotificationType.live,
          title: '${idols[0].stageName}님이 라이브를 시작했어요!',
          subtitle: '지금 바로 참여해보세요',
          imageUrl: idols[0].profileImage,
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
          isRead: false,
          actionRoute: '/live/${idols[0].id}',
        ),
        NotificationItem(
          id: '2',
          type: NotificationType.support,
          title: '후원 감사 메시지가 도착했어요',
          subtitle: '${idols[1].stageName}님이 감사 인사를 보냈어요 💕',
          imageUrl: idols[1].profileImage,
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          isRead: false,
          actionRoute: '/chat/${idols[1].id}',
        ),
        NotificationItem(
          id: '3',
          type: NotificationType.campaign,
          title: '펀딩 목표 달성!',
          subtitle: '생일 서포트 캠페인이 100% 달성되었어요 🎉',
          imageUrl: idols[2].profileImage,
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
          isRead: true,
          actionRoute: '/campaigns/1',
        ),
        NotificationItem(
          id: '4',
          type: NotificationType.community,
          title: '${idols[0].stageName}님이 새 글을 올렸어요',
          subtitle: '오늘의 일상 공유 📸',
          imageUrl: idols[0].profileImage,
          timestamp: DateTime.now().subtract(const Duration(hours: 5)),
          isRead: true,
          actionRoute: '/community',
        ),
        NotificationItem(
          id: '5',
          type: NotificationType.system,
          title: '포토카드 이벤트 안내',
          subtitle: '한정판 포토카드가 출시되었어요!',
          imageUrl: null,
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          isRead: true,
          actionRoute: '/photocards',
        ),
        NotificationItem(
          id: '6',
          type: NotificationType.live,
          title: '${idols[3].stageName}님의 라이브가 종료되었어요',
          subtitle: '다시보기로 시청해보세요',
          imageUrl: idols[3].profileImage,
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          isRead: true,
          actionRoute: '/idols/${idols[3].id}',
        ),
      ]);
    });
  }

  List<NotificationItem> _getFilteredNotifications(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return _notifications;
      case 1:
        return _notifications
            .where((n) =>
                n.type == NotificationType.live ||
                n.type == NotificationType.community)
            .toList();
      case 2:
        return _notifications
            .where((n) =>
                n.type == NotificationType.support ||
                n.type == NotificationType.campaign)
            .toList();
      default:
        return _notifications;
    }
  }

  void _markAsRead(String id) {
    setState(() {
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
      }
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var i = 0; i < _notifications.length; i++) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    });
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: PipoColors.background,
      appBar: AppBar(
        backgroundColor: PipoColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: PipoColors.textPrimary,
          onPressed: () => context.pop(),
        ),
        title: Text(
          '알림',
          style: PipoTypography.titleLarge.copyWith(
            color: PipoColors.textPrimary,
          ),
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                '모두 읽음',
                style: PipoTypography.labelMedium.copyWith(
                  color: PipoColors.primary,
                ),
              ),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: PipoColors.primary,
          unselectedLabelColor: PipoColors.textTertiary,
          indicatorColor: PipoColors.primary,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: [
            Tab(text: '전체'),
            Tab(text: '활동'),
            Tab(text: '서포트'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotificationList(0),
          _buildNotificationList(1),
          _buildNotificationList(2),
        ],
      ),
    );
  }

  Widget _buildNotificationList(int tabIndex) {
    final notifications = _getFilteredNotifications(tabIndex);

    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 64,
              color: PipoColors.textDisabled,
            ),
            const SizedBox(height: PipoSpacing.lg),
            Text(
              '알림이 없어요',
              style: PipoTypography.bodyLarge.copyWith(
                color: PipoColors.textTertiary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: PipoSpacing.md),
      itemCount: notifications.length,
      separatorBuilder: (_, __) => const SizedBox(height: 1),
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _NotificationTile(
          notification: notification,
          onTap: () {
            _markAsRead(notification.id);
            if (notification.actionRoute != null) {
              context.push(notification.actionRoute!);
            }
          },
          onDismiss: () {
            setState(() {
              _notifications.removeWhere((n) => n.id == notification.id);
            });
          },
        );
      },
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationItem notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: PipoSpacing.xl),
        color: Colors.red,
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: PipoSpacing.xl,
            vertical: PipoSpacing.lg,
          ),
          decoration: BoxDecoration(
            color: notification.isRead
                ? PipoColors.background
                : PipoColors.primarySoft.withOpacity(0.3),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatar(),
              const SizedBox(width: PipoSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildTypeChip(),
                        const SizedBox(width: PipoSpacing.sm),
                        Text(
                          _formatTimestamp(notification.timestamp),
                          style: PipoTypography.bodySmall.copyWith(
                            color: PipoColors.textDisabled,
                          ),
                        ),
                        if (!notification.isRead) ...[
                          const Spacer(),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: PipoColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: PipoSpacing.xs),
                    Text(
                      notification.title,
                      style: PipoTypography.labelMedium.copyWith(
                        color: PipoColors.textPrimary,
                        fontWeight:
                            notification.isRead ? FontWeight.w500 : FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      notification.subtitle,
                      style: PipoTypography.bodySmall.copyWith(
                        color: PipoColors.textTertiary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    if (notification.imageUrl != null) {
      return CircleAvatar(
        radius: 24,
        backgroundImage: CachedNetworkImageProvider(notification.imageUrl!),
      );
    }

    return CircleAvatar(
      radius: 24,
      backgroundColor: _getTypeColor().withOpacity(0.1),
      child: Icon(
        _getTypeIcon(),
        color: _getTypeColor(),
        size: 24,
      ),
    );
  }

  Widget _buildTypeChip() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PipoSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: _getTypeColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(PipoRadius.xs),
      ),
      child: Text(
        _getTypeLabel(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: _getTypeColor(),
        ),
      ),
    );
  }

  IconData _getTypeIcon() {
    switch (notification.type) {
      case NotificationType.live:
        return Icons.play_circle_filled;
      case NotificationType.support:
        return Icons.favorite;
      case NotificationType.campaign:
        return Icons.campaign;
      case NotificationType.community:
        return Icons.article;
      case NotificationType.system:
        return Icons.info;
    }
  }

  Color _getTypeColor() {
    switch (notification.type) {
      case NotificationType.live:
        return Colors.red;
      case NotificationType.support:
        return PipoColors.primary;
      case NotificationType.campaign:
        return Colors.orange;
      case NotificationType.community:
        return Colors.blue;
      case NotificationType.system:
        return Colors.grey;
    }
  }

  String _getTypeLabel() {
    switch (notification.type) {
      case NotificationType.live:
        return 'LIVE';
      case NotificationType.support:
        return '서포트';
      case NotificationType.campaign:
        return '펀딩';
      case NotificationType.community:
        return '커뮤니티';
      case NotificationType.system:
        return '시스템';
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}분 전';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}시간 전';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}일 전';
    } else {
      return '${timestamp.month}/${timestamp.day}';
    }
  }
}

enum NotificationType { live, support, campaign, community, system }

class NotificationItem {
  final String id;
  final NotificationType type;
  final String title;
  final String subtitle;
  final String? imageUrl;
  final DateTime timestamp;
  final bool isRead;
  final String? actionRoute;

  NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    required this.timestamp,
    required this.isRead,
    this.actionRoute,
  });

  NotificationItem copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? subtitle,
    String? imageUrl,
    DateTime? timestamp,
    bool? isRead,
    String? actionRoute,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      imageUrl: imageUrl ?? this.imageUrl,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      actionRoute: actionRoute ?? this.actionRoute,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';

enum NotificationType {
  like,
  comment,
  follow,
  support,
  campaign,
  event,
  system,
}

class NotificationItem {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final String? profileImage;
  final String? actionUrl;
  final DateTime createdAt;
  final bool isRead;

  NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.profileImage,
    this.actionUrl,
    required this.createdAt,
    this.isRead = false,
  });
}

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: '1',
      type: NotificationType.like,
      title: '하늘별',
      message: '님이 회원님의 게시물을 좋아합니다.',
      profileImage: 'https://i.pravatar.cc/100?img=5',
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      isRead: false,
    ),
    NotificationItem(
      id: '2',
      type: NotificationType.comment,
      title: '미유',
      message: '님이 댓글을 남겼습니다: "응원 감사합니다~ 💕"',
      profileImage: 'https://i.pravatar.cc/100?img=9',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      isRead: false,
    ),
    NotificationItem(
      id: '3',
      type: NotificationType.follow,
      title: '루나',
      message: '님이 회원님을 팔로우하기 시작했습니다.',
      profileImage: 'https://i.pravatar.cc/100?img=10',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      isRead: true,
    ),
    NotificationItem(
      id: '4',
      type: NotificationType.support,
      title: '후원 완료',
      message: '하늘별님에게 10,000원 후원이 완료되었습니다.',
      profileImage: 'https://i.pravatar.cc/100?img=5',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      isRead: true,
    ),
    NotificationItem(
      id: '5',
      type: NotificationType.campaign,
      title: '펀딩 달성',
      message: '"하늘별 첫 단독 콘서트" 펀딩이 100% 달성되었습니다! 🎉',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
    NotificationItem(
      id: '6',
      type: NotificationType.event,
      title: '공연 알림',
      message: '내일 14:00 "서울 라이브아이돌" 공연이 예정되어 있습니다.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
    NotificationItem(
      id: '7',
      type: NotificationType.system,
      title: '시스템 공지',
      message: '앱이 새로운 버전으로 업데이트되었습니다. 새로운 기능을 확인해보세요!',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<NotificationItem> _getFilteredNotifications(int tabIndex) {
    switch (tabIndex) {
      case 1: // 활동
        return _notifications.where((n) =>
          n.type == NotificationType.like ||
          n.type == NotificationType.comment ||
          n.type == NotificationType.follow
        ).toList();
      case 2: // 공지
        return _notifications.where((n) =>
          n.type == NotificationType.campaign ||
          n.type == NotificationType.event ||
          n.type == NotificationType.system
        ).toList();
      default: // 전체
        return _notifications;
    }
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('알림', style: TextStyle(fontSize: Responsive.sp(18))),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                '모두 읽음',
                style: TextStyle(
                  fontSize: Responsive.sp(14),
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: TextStyle(
            fontSize: Responsive.sp(14),
            fontWeight: FontWeight.w600,
          ),
          tabs: [
            Tab(text: '전체 ($_unreadCount)'),
            const Tab(text: '활동'),
            const Tab(text: '공지'),
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
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: Responsive.hp(1)),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return _buildNotificationTile(notifications[index]);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: Responsive.sp(64),
            color: AppColors.textHint,
          ),
          SizedBox(height: Responsive.hp(2)),
          Text(
            '알림이 없습니다',
            style: TextStyle(
              fontSize: Responsive.sp(16),
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: Responsive.hp(1)),
          Text(
            '새로운 알림이 오면 여기에 표시됩니다',
            style: TextStyle(
              fontSize: Responsive.sp(13),
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTile(NotificationItem notification) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: Responsive.wp(5)),
        color: AppColors.error,
        child: Icon(
          Icons.delete_outline,
          color: Colors.white,
          size: Responsive.sp(24),
        ),
      ),
      onDismissed: (_) {
        setState(() {
          _notifications.removeWhere((n) => n.id == notification.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('알림이 삭제되었습니다'),
            action: SnackBarAction(
              label: '실행 취소',
              onPressed: () {
                // 복원 로직
              },
            ),
          ),
        );
      },
      child: InkWell(
        onTap: () => _handleNotificationTap(notification),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.wp(4),
            vertical: Responsive.hp(1.5),
          ),
          decoration: BoxDecoration(
            color: notification.isRead
                ? Colors.transparent
                : AppColors.primary.withValues(alpha: 0.05),
            border: Border(
              bottom: BorderSide(color: AppColors.border, width: 0.5),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon or Profile
              _buildNotificationIcon(notification),
              SizedBox(width: Responsive.wp(3)),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: Responsive.sp(14),
                          color: AppColors.textPrimary,
                          height: 1.4,
                        ),
                        children: [
                          TextSpan(
                            text: notification.title,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          TextSpan(text: notification.message),
                        ],
                      ),
                    ),
                    SizedBox(height: Responsive.hp(0.5)),
                    Text(
                      _formatTime(notification.createdAt),
                      style: TextStyle(
                        fontSize: Responsive.sp(12),
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ),

              // Unread indicator
              if (!notification.isRead)
                Container(
                  width: 8,
                  height: 8,
                  margin: EdgeInsets.only(left: Responsive.wp(2)),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(NotificationItem notification) {
    if (notification.profileImage != null) {
      return Stack(
        children: [
          CircleAvatar(
            radius: Responsive.wp(6),
            backgroundImage: CachedNetworkImageProvider(notification.profileImage!),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: Responsive.wp(5),
              height: Responsive.wp(5),
              decoration: BoxDecoration(
                color: _getTypeColor(notification.type),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Icon(
                _getTypeIcon(notification.type),
                size: Responsive.sp(10),
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
    }

    return Container(
      width: Responsive.wp(12),
      height: Responsive.wp(12),
      decoration: BoxDecoration(
        color: _getTypeColor(notification.type).withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(
        _getTypeIcon(notification.type),
        color: _getTypeColor(notification.type),
        size: Responsive.sp(22),
      ),
    );
  }

  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.like:
        return Icons.favorite_rounded;
      case NotificationType.comment:
        return Icons.chat_bubble_rounded;
      case NotificationType.follow:
        return Icons.person_add_rounded;
      case NotificationType.support:
        return Icons.volunteer_activism_rounded;
      case NotificationType.campaign:
        return Icons.rocket_launch_rounded;
      case NotificationType.event:
        return Icons.event_rounded;
      case NotificationType.system:
        return Icons.info_rounded;
    }
  }

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.like:
        return AppColors.error;
      case NotificationType.comment:
        return AppColors.info;
      case NotificationType.follow:
        return AppColors.secondary;
      case NotificationType.support:
        return AppColors.success;
      case NotificationType.campaign:
        return AppColors.primary;
      case NotificationType.event:
        return AppColors.warning;
      case NotificationType.system:
        return AppColors.textSecondary;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) {
      return '방금 전';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}분 전';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}시간 전';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}일 전';
    } else {
      return '${dateTime.month}월 ${dateTime.day}일';
    }
  }

  void _handleNotificationTap(NotificationItem notification) {
    // Mark as read
    setState(() {
      final index = _notifications.indexWhere((n) => n.id == notification.id);
      if (index != -1) {
        _notifications[index] = NotificationItem(
          id: notification.id,
          type: notification.type,
          title: notification.title,
          message: notification.message,
          profileImage: notification.profileImage,
          actionUrl: notification.actionUrl,
          createdAt: notification.createdAt,
          isRead: true,
        );
      }
    });

    // Navigate based on type
    switch (notification.type) {
      case NotificationType.follow:
      case NotificationType.like:
      case NotificationType.comment:
        // Navigate to profile or post
        break;
      case NotificationType.support:
        context.push('/wallet');
        break;
      case NotificationType.campaign:
        context.push('/campaigns');
        break;
      case NotificationType.event:
        context.push('/calendar');
        break;
      case NotificationType.system:
        // Show system notification detail
        break;
    }
  }

  void _markAllAsRead() {
    setState(() {
      for (int i = 0; i < _notifications.length; i++) {
        if (!_notifications[i].isRead) {
          _notifications[i] = NotificationItem(
            id: _notifications[i].id,
            type: _notifications[i].type,
            title: _notifications[i].title,
            message: _notifications[i].message,
            profileImage: _notifications[i].profileImage,
            actionUrl: _notifications[i].actionUrl,
            createdAt: _notifications[i].createdAt,
            isRead: true,
          );
        }
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('모든 알림을 읽음 처리했습니다')),
    );
  }
}

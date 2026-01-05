/// 🔔 알림 센터
/// 모든 알림 목록 표시
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/format_utils.dart';
import '../../../shared/models/notification_model.dart';

class NotificationCenterScreen extends ConsumerStatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  ConsumerState<NotificationCenterScreen> createState() =>
      _NotificationCenterScreenState();
}

class _NotificationCenterScreenState
    extends ConsumerState<NotificationCenterScreen> {
  bool _showUnreadOnly = false;

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    // TODO: Replace with actual provider
    final notifications = _getMockNotifications();

    final filteredNotifications = _showUnreadOnly
        ? notifications.where((n) => !n.isRead).toList()
        : notifications;

    final unreadCount = notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const Text(
              '알림',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                fontFamily: 'Pretendard',
              ),
            ),
            if (unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$unreadCount',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontFamily: 'Pretendard',
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'mark_all_read') {
                _markAllAsRead();
              } else if (value == 'clear_all') {
                _clearAll();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'mark_all_read',
                child: Text('모두 읽음 표시'),
              ),
              const PopupMenuItem(
                value: 'clear_all',
                child: Text('모두 삭제'),
              ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppColors.divider,
            height: 1,
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter toggle
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.wp(4),
              vertical: 12,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: AppColors.divider, width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _showUnreadOnly = !_showUnreadOnly),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: _showUnreadOnly
                            ? AppColors.error.withValues(alpha: 0.1)
                            : AppColors.backgroundAlt,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _showUnreadOnly
                              ? AppColors.error
                              : AppColors.border,
                          width: _showUnreadOnly ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _showUnreadOnly
                                ? Icons.check_box_rounded
                                : Icons.check_box_outline_blank_rounded,
                            color: _showUnreadOnly
                                ? AppColors.error
                                : AppColors.textTertiary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '읽지 않은 알림만 보기',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: _showUnreadOnly
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: _showUnreadOnly
                                  ? AppColors.error
                                  : AppColors.textSecondary,
                              fontFamily: 'Pretendard',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Notification list
          Expanded(
            child: filteredNotifications.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: () async {
                      // TODO: Refresh notifications from API
                      await Future.delayed(const Duration(seconds: 1));
                    },
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      itemCount: filteredNotifications.length,
                      itemBuilder: (context, index) {
                        final notification = filteredNotifications[index];
                        return _buildNotificationCard(notification);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.backgroundAlt,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_off_outlined,
              size: 64,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _showUnreadOnly ? '읽지 않은 알림이 없습니다' : '알림이 없습니다',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Pretendard',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _showUnreadOnly
                ? '모든 알림을 확인했습니다'
                : '새로운 알림이 도착하면 여기에 표시됩니다',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontFamily: 'Pretendard',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(AppNotification notification) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: AppColors.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
          size: 28,
        ),
      ),
      onDismissed: (direction) {
        _deleteNotification(notification.id);
      },
      child: GestureDetector(
        onTap: () => _handleNotificationTap(notification),
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: Responsive.wp(4),
            vertical: 4,
          ),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notification.isRead
                ? Colors.white
                : AppColors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: notification.isRead
                  ? AppColors.border
                  : AppColors.primary.withValues(alpha: 0.2),
              width: notification.isRead ? 1 : 1.5,
            ),
            boxShadow: notification.isRead
                ? AppColors.softShadow()
                : AppColors.glowShadow(
                    AppColors.primary.withValues(alpha: 0.1),
                  ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon/Image
              if (notification.imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: notification.imageUrl!,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      notification.type.iconEmoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),

              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: notification.isRead
                                  ? FontWeight.w600
                                  : FontWeight.w700,
                              fontFamily: 'Pretendard',
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: AppColors.textSecondary,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            notification.type.displayName,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                              fontFamily: 'Pretendard',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          FormatUtils.formatRelativeTime(notification.createdAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textTertiary,
                            fontFamily: 'Pretendard',
                          ),
                        ),
                      ],
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

  void _handleNotificationTap(AppNotification notification) {
    // Mark as read
    if (!notification.isRead) {
      _markAsRead(notification.id);
    }

    // Navigate to target
    // TODO: Implement navigation based on targetType and targetId
    print('Navigate to: ${notification.targetType} / ${notification.targetId}');
  }

  void _markAsRead(String notificationId) {
    // TODO: Update via provider/API
    setState(() {});
  }

  void _markAllAsRead() {
    // TODO: Update all via provider/API
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('모든 알림을 읽음 처리했습니다'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _deleteNotification(String notificationId) {
    // TODO: Delete via provider/API
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('알림이 삭제되었습니다'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _clearAll() {
    // TODO: Clear all via provider/API
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('모든 알림이 삭제되었습니다'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  // Mock data - TODO: Replace with actual provider
  List<AppNotification> _getMockNotifications() {
    return [
      AppNotification(
        id: '1',
        type: NotificationType.idolReply,
        title: '아이유님이 회원님의 정산에 답글을 달았습니다',
        body: '오늘 와주셔서 정말 감사해요! 즐거운 시간이었어요 💕',
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        isRead: false,
        targetType: 'post',
        targetId: 'post_123',
      ),
      AppNotification(
        id: '2',
        type: NotificationType.newBubble,
        title: '새로운 Bubble 메시지가 도착했습니다',
        body: '안녕하세요! 오늘 날씨가 정말 좋네요 ☀️',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        isRead: false,
        imageUrl: 'https://i.pravatar.cc/150?img=5',
        targetType: 'bubble',
      ),
      AppNotification(
        id: '3',
        type: NotificationType.eventNotice,
        title: '다음 주 공연 일정이 확정되었습니다',
        body: '12월 15일 오후 7시, 홍대 라이브홀에서 만나요!',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        isRead: false,
        targetType: 'event',
        targetId: 'event_456',
      ),
      AppNotification(
        id: '4',
        type: NotificationType.newPost,
        title: '르세라핌님이 새 게시글을 올렸습니다',
        body: '오늘 콘서트 준비하는 모습 공유해요!',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        isRead: true,
        imageUrl: 'https://picsum.photos/400/300?random=1',
        targetType: 'post',
        targetId: 'post_789',
      ),
      AppNotification(
        id: '5',
        type: NotificationType.likePost,
        title: '김민지님 외 12명이 회원님의 게시글을 좋아합니다',
        body: '오늘 공연 너무 재밌었어요! 다음에도 꼭 올게요 💕',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
        targetType: 'post',
        targetId: 'post_321',
      ),
      AppNotification(
        id: '6',
        type: NotificationType.eventReminder,
        title: '내일 오후 7시 공연이 예정되어 있습니다',
        body: '홍대 라이브홀 · 잊지 말고 참석해주세요!',
        createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 12)),
        isRead: true,
        targetType: 'event',
        targetId: 'event_654',
      ),
    ];
  }
}

/// 🔔 알림 모델
/// 앱 내 알림 시스템
library;

enum NotificationType {
  newPost,           // 구독한 아이돌의 새 게시글
  idolReply,         // 내 정산에 아이돌이 답글
  newBubble,         // 새 Bubble 메시지
  eventReminder,     // 공연/이벤트 알림
  eventNotice,       // 공연 공지사항
  likePost,          // 게시글 좋아요
  commentPost,       // 게시글 댓글
  funding,           // 펀딩 관련
  subscription,      // 구독 관련
}

extension NotificationTypeExtension on NotificationType {
  String get displayName {
    switch (this) {
      case NotificationType.newPost:
        return '새 게시글';
      case NotificationType.idolReply:
        return '아이돌 답글';
      case NotificationType.newBubble:
        return '새 Bubble';
      case NotificationType.eventReminder:
        return '이벤트 알림';
      case NotificationType.eventNotice:
        return '공연 공지';
      case NotificationType.likePost:
        return '좋아요';
      case NotificationType.commentPost:
        return '댓글';
      case NotificationType.funding:
        return '펀딩';
      case NotificationType.subscription:
        return '구독';
    }
  }

  String get iconEmoji {
    switch (this) {
      case NotificationType.newPost:
        return '📝';
      case NotificationType.idolReply:
        return '💬';
      case NotificationType.newBubble:
        return '💌';
      case NotificationType.eventReminder:
        return '📅';
      case NotificationType.eventNotice:
        return '📢';
      case NotificationType.likePost:
        return '❤️';
      case NotificationType.commentPost:
        return '💭';
      case NotificationType.funding:
        return '💰';
      case NotificationType.subscription:
        return '⭐';
    }
  }
}

class AppNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;
  final String? imageUrl;
  final String? targetId; // Post ID, Event ID, etc.
  final String? targetType; // 'post', 'event', 'bubble', etc.
  final Map<String, dynamic>? metadata;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
    this.imageUrl,
    this.targetId,
    this.targetType,
    this.metadata,
  });

  AppNotification copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? body,
    DateTime? createdAt,
    bool? isRead,
    String? imageUrl,
    String? targetId,
    String? targetType,
    Map<String, dynamic>? metadata,
  }) {
    return AppNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      imageUrl: imageUrl ?? this.imageUrl,
      targetId: targetId ?? this.targetId,
      targetType: targetType ?? this.targetType,
      metadata: metadata ?? this.metadata,
    );
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == 'NotificationType.${json['type']}',
        orElse: () => NotificationType.newPost,
      ),
      title: json['title'] as String,
      body: json['body'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: json['isRead'] as bool? ?? false,
      imageUrl: json['imageUrl'] as String?,
      targetId: json['targetId'] as String?,
      targetType: json['targetType'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'title': title,
      'body': body,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'imageUrl': imageUrl,
      'targetId': targetId,
      'targetType': targetType,
      'metadata': metadata,
    };
  }
}

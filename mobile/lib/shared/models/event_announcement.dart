/// 📢 공연/이벤트 공지사항
/// 겐바(공연장) 공지 시스템
library;

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// 공지사항 타입
enum AnnouncementType {
  /// 일반 공지
  general,

  /// 긴급 공지
  urgent,

  /// 변경사항 (시간/장소 변경 등)
  change,

  /// 취소
  cancellation,

  /// 추가 정보
  additional,
}

extension AnnouncementTypeExtension on AnnouncementType {
  String get displayName {
    switch (this) {
      case AnnouncementType.general:
        return '공지';
      case AnnouncementType.urgent:
        return '긴급';
      case AnnouncementType.change:
        return '변경';
      case AnnouncementType.cancellation:
        return '취소';
      case AnnouncementType.additional:
        return '추가정보';
    }
  }

  IconData get icon {
    switch (this) {
      case AnnouncementType.general:
        return Icons.info_outline;
      case AnnouncementType.urgent:
        return Icons.warning_amber_rounded;
      case AnnouncementType.change:
        return Icons.edit_outlined;
      case AnnouncementType.cancellation:
        return Icons.cancel_outlined;
      case AnnouncementType.additional:
        return Icons.add_circle_outline;
    }
  }

  Color get color {
    switch (this) {
      case AnnouncementType.general:
        return AppColors.info;
      case AnnouncementType.urgent:
        return AppColors.error;
      case AnnouncementType.change:
        return AppColors.warning;
      case AnnouncementType.cancellation:
        return AppColors.error;
      case AnnouncementType.additional:
        return AppColors.primary;
    }
  }

  Color get backgroundColor {
    return color.withValues(alpha: 0.1);
  }
}

/// 이벤트 공지사항
class EventAnnouncement {
  final String id;
  final String eventId; // 연결된 이벤트 ID
  final String title;
  final String content;
  final AnnouncementType type;
  final DateTime createdAt;
  final bool isRead; // 사용자가 읽었는지 여부

  /// 공지 작성자 정보 (소속사/아이돌)
  final String authorId;
  final String authorName;
  final bool isAgency; // true: 소속사, false: 아이돌

  const EventAnnouncement({
    required this.id,
    required this.eventId,
    required this.title,
    required this.content,
    this.type = AnnouncementType.general,
    required this.createdAt,
    this.isRead = false,
    required this.authorId,
    required this.authorName,
    this.isAgency = false,
  });

  factory EventAnnouncement.fromJson(Map<String, dynamic> json) {
    return EventAnnouncement(
      id: json['id'] as String,
      eventId: json['eventId'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      type: _parseType(json['type'] as String?),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: json['isRead'] as bool? ?? false,
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
      isAgency: json['isAgency'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'title': title,
      'content': content,
      'type': type.name,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'authorId': authorId,
      'authorName': authorName,
      'isAgency': isAgency,
    };
  }

  EventAnnouncement copyWith({
    String? id,
    String? eventId,
    String? title,
    String? content,
    AnnouncementType? type,
    DateTime? createdAt,
    bool? isRead,
    String? authorId,
    String? authorName,
    bool? isAgency,
  }) {
    return EventAnnouncement(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      isAgency: isAgency ?? this.isAgency,
    );
  }

  /// 긴급 공지인지
  bool get isUrgent =>
      type == AnnouncementType.urgent || type == AnnouncementType.cancellation;

  /// 새 공지인지 (24시간 이내)
  bool get isNew {
    final diff = DateTime.now().difference(createdAt);
    return diff.inHours < 24;
  }

  static AnnouncementType _parseType(String? value) {
    if (value == null) return AnnouncementType.general;

    switch (value.toLowerCase()) {
      case 'general':
      case '일반':
        return AnnouncementType.general;
      case 'urgent':
      case '긴급':
        return AnnouncementType.urgent;
      case 'change':
      case '변경':
        return AnnouncementType.change;
      case 'cancellation':
      case '취소':
        return AnnouncementType.cancellation;
      case 'additional':
      case '추가정보':
        return AnnouncementType.additional;
      default:
        return AnnouncementType.general;
    }
  }
}

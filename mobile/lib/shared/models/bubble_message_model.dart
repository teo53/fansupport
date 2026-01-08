import 'package:equatable/equatable.dart';

/// 버블 메시지 타입
enum BubbleMessageType {
  text('텍스트', 'TEXT'),
  image('이미지', 'IMAGE'),
  voice('음성', 'VOICE'),
  video('영상', 'VIDEO');

  final String displayName;
  final String code;
  const BubbleMessageType(this.displayName, this.code);

  static BubbleMessageType fromCode(String code) {
    return BubbleMessageType.values.firstWhere(
      (e) => e.code == code,
      orElse: () => BubbleMessageType.text,
    );
  }
}

/// 버블 메시지 모델 (아이돌이 팬들에게 보내는 메시지)
class BubbleMessageModel extends Equatable {
  final String id;
  final String idolId;
  final String idolName;
  final String idolProfileImage;
  final BubbleMessageType type;
  final String content;
  final String? mediaUrl;
  final String? thumbnailUrl;
  final int? duration; // 음성/영상 길이 (초)
  final bool isSubscriberOnly; // 구독자 전용 여부
  final int viewCount;
  final int likeCount;
  final bool isLiked;
  final bool isRead;
  final DateTime createdAt;

  const BubbleMessageModel({
    required this.id,
    required this.idolId,
    required this.idolName,
    required this.idolProfileImage,
    required this.type,
    required this.content,
    this.mediaUrl,
    this.thumbnailUrl,
    this.duration,
    this.isSubscriberOnly = false,
    this.viewCount = 0,
    this.likeCount = 0,
    this.isLiked = false,
    this.isRead = false,
    required this.createdAt,
  });

  factory BubbleMessageModel.fromJson(Map<String, dynamic> json) {
    return BubbleMessageModel(
      id: json['id'] as String,
      idolId: json['idolId'] as String,
      idolName: json['idolName'] as String,
      idolProfileImage: json['idolProfileImage'] as String? ?? '',
      type: BubbleMessageType.fromCode(json['type'] as String? ?? 'TEXT'),
      content: json['content'] as String,
      mediaUrl: json['mediaUrl'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      duration: json['duration'] as int?,
      isSubscriberOnly: json['isSubscriberOnly'] as bool? ?? false,
      viewCount: json['viewCount'] as int? ?? 0,
      likeCount: json['likeCount'] as int? ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idolId': idolId,
      'idolName': idolName,
      'idolProfileImage': idolProfileImage,
      'type': type.code,
      'content': content,
      'mediaUrl': mediaUrl,
      'thumbnailUrl': thumbnailUrl,
      'duration': duration,
      'isSubscriberOnly': isSubscriberOnly,
      'viewCount': viewCount,
      'likeCount': likeCount,
      'isLiked': isLiked,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  BubbleMessageModel copyWith({
    String? id,
    String? idolId,
    String? idolName,
    String? idolProfileImage,
    BubbleMessageType? type,
    String? content,
    String? mediaUrl,
    String? thumbnailUrl,
    int? duration,
    bool? isSubscriberOnly,
    int? viewCount,
    int? likeCount,
    bool? isLiked,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return BubbleMessageModel(
      id: id ?? this.id,
      idolId: idolId ?? this.idolId,
      idolName: idolName ?? this.idolName,
      idolProfileImage: idolProfileImage ?? this.idolProfileImage,
      type: type ?? this.type,
      content: content ?? this.content,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      duration: duration ?? this.duration,
      isSubscriberOnly: isSubscriberOnly ?? this.isSubscriberOnly,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, idolId, type, content, createdAt];
}

/// 버블 구독 정보
class BubbleSubscription extends Equatable {
  final String id;
  final String userId;
  final String idolId;
  final String idolName;
  final String idolProfileImage;
  final int price;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final bool autoRenew;
  final int unreadCount;

  const BubbleSubscription({
    required this.id,
    required this.userId,
    required this.idolId,
    required this.idolName,
    required this.idolProfileImage,
    required this.price,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    this.autoRenew = true,
    this.unreadCount = 0,
  });

  bool get isExpired => DateTime.now().isAfter(endDate);
  int get daysLeft => endDate.difference(DateTime.now()).inDays;

  factory BubbleSubscription.fromJson(Map<String, dynamic> json) {
    return BubbleSubscription(
      id: json['id'] as String,
      userId: json['userId'] as String,
      idolId: json['idolId'] as String,
      idolName: json['idolName'] as String,
      idolProfileImage: json['idolProfileImage'] as String? ?? '',
      price: json['price'] as int,
      startDate: DateTime.tryParse(json['startDate'] as String? ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['endDate'] as String? ?? '') ?? DateTime.now().add(const Duration(days: 30)),
      isActive: json['isActive'] as bool? ?? true,
      autoRenew: json['autoRenew'] as bool? ?? true,
      unreadCount: json['unreadCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'idolId': idolId,
      'idolName': idolName,
      'idolProfileImage': idolProfileImage,
      'price': price,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive,
      'autoRenew': autoRenew,
      'unreadCount': unreadCount,
    };
  }

  @override
  List<Object?> get props => [id, userId, idolId, isActive];
}

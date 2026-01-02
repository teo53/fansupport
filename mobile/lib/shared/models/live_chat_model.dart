/// 버블 스타일 라이브 채팅 모델
/// 레퍼런스: 디어유 버블 앱
///
/// 핵심 로직:
/// - 팬은 자신의 메시지와 아이돌 메시지만 볼 수 있음 (1:1 느낌)
/// - 아이돌이 특정 팬의 메시지를 태그/답장할 때만 해당 팬의 메시지가 다른 팬들에게 보임
/// - 아이돌은 모든 팬들의 메시지를 볼 수 있음

enum LiveChatMessageType {
  text,
  image,
  voice,
  sticker,
  gift,
}

enum SenderType {
  idol,
  fan,
  system,
}

class LiveChatMessage {
  final String id;
  final String roomId;
  final String senderId;
  final String senderName;
  final String? senderProfileImage;
  final SenderType senderType;
  final LiveChatMessageType messageType;
  final String content;
  final String? mediaUrl;
  final int? duration; // for voice
  final DateTime createdAt;
  final bool isRead;

  // 버블 스타일 핵심: 아이돌이 태그한 메시지인지 여부
  final bool isTaggedByIdol;
  final String? taggedMessageId; // 아이돌이 답장한 원본 메시지 ID
  final String? taggedFanName; // 태그된 팬 이름
  final String? taggedContent; // 태그된 원본 내용

  // 선물 관련
  final String? giftType;
  final int? giftAmount;

  LiveChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderName,
    this.senderProfileImage,
    required this.senderType,
    required this.messageType,
    required this.content,
    this.mediaUrl,
    this.duration,
    required this.createdAt,
    this.isRead = false,
    this.isTaggedByIdol = false,
    this.taggedMessageId,
    this.taggedFanName,
    this.taggedContent,
    this.giftType,
    this.giftAmount,
  });

  /// 팬이 볼 수 있는 메시지인지 확인
  /// - 아이돌 메시지: 항상 보임
  /// - 내 메시지: 항상 보임
  /// - 다른 팬 메시지: 아이돌이 태그한 경우에만 보임
  bool isVisibleToFan(String myUserId) {
    if (senderType == SenderType.idol) return true;
    if (senderType == SenderType.system) return true;
    if (senderId == myUserId) return true;
    if (isTaggedByIdol) return true;
    return false;
  }

  LiveChatMessage copyWith({
    String? id,
    String? roomId,
    String? senderId,
    String? senderName,
    String? senderProfileImage,
    SenderType? senderType,
    LiveChatMessageType? messageType,
    String? content,
    String? mediaUrl,
    int? duration,
    DateTime? createdAt,
    bool? isRead,
    bool? isTaggedByIdol,
    String? taggedMessageId,
    String? taggedFanName,
    String? taggedContent,
    String? giftType,
    int? giftAmount,
  }) {
    return LiveChatMessage(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderProfileImage: senderProfileImage ?? this.senderProfileImage,
      senderType: senderType ?? this.senderType,
      messageType: messageType ?? this.messageType,
      content: content ?? this.content,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      duration: duration ?? this.duration,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      isTaggedByIdol: isTaggedByIdol ?? this.isTaggedByIdol,
      taggedMessageId: taggedMessageId ?? this.taggedMessageId,
      taggedFanName: taggedFanName ?? this.taggedFanName,
      taggedContent: taggedContent ?? this.taggedContent,
      giftType: giftType ?? this.giftType,
      giftAmount: giftAmount ?? this.giftAmount,
    );
  }
}

/// 버블 라이브 채팅방
class BubbleLiveRoom {
  final String id;
  final String idolId;
  final String idolName;
  final String idolProfileImage;
  final bool isLive;
  final DateTime? liveStartedAt;
  final int viewerCount;
  final int totalMessages;
  final int totalGifts;
  final int totalGiftAmount;
  final List<LiveChatMessage> recentMessages;

  BubbleLiveRoom({
    required this.id,
    required this.idolId,
    required this.idolName,
    required this.idolProfileImage,
    this.isLive = false,
    this.liveStartedAt,
    this.viewerCount = 0,
    this.totalMessages = 0,
    this.totalGifts = 0,
    this.totalGiftAmount = 0,
    this.recentMessages = const [],
  });

  String get liveDuration {
    if (liveStartedAt == null) return '00:00';
    final duration = DateTime.now().difference(liveStartedAt!);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

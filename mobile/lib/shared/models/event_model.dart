import 'idol_model.dart';

/// 🗓️ 이벤트/일정 모델
/// 아이돌 관련 이벤트 (오프라인 모임, 생일, 공연 등)
class EventModel {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final DateTime? endDate; // 여러 날짜에 걸친 이벤트용
  final EventType type;
  final String idolId;
  final IdolCategory category; // 아이돌 카테고리
  final String? location;
  final int? price;
  final int? maxParticipants;
  final int currentParticipants;
  final String? imageUrl;
  final bool isOnline;
  final String? meetingLink;

  const EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.endDate,
    required this.type,
    required this.idolId,
    required this.category,
    this.location,
    this.price,
    this.maxParticipants,
    this.currentParticipants = 0,
    this.imageUrl,
    this.isOnline = false,
    this.meetingLink,
  });

  bool get isSoldOut =>
      maxParticipants != null && currentParticipants >= maxParticipants!;

  bool get isAvailable => !isSoldOut && date.isAfter(DateTime.now());

  int? get availableSlots =>
      maxParticipants != null ? maxParticipants! - currentParticipants : null;
}

/// 이벤트 타입
enum EventType {
  offlineMeeting, // 오프라인 팬미팅
  birthday, // 생일
  performance, // 공연/무대
  cafeEvent, // 카페 이벤트
  cosplayEvent, // 코스프레 이벤트
  fanmeeting, // 소규모 팬미팅
  photocard, // 포토카드 교환회
  other, // 기타
}

extension EventTypeExtension on EventType {
  String get displayName {
    switch (this) {
      case EventType.offlineMeeting:
        return '오프라인 모임';
      case EventType.birthday:
        return '생일 축하';
      case EventType.performance:
        return '공연';
      case EventType.cafeEvent:
        return '카페 이벤트';
      case EventType.cosplayEvent:
        return '코스프레 이벤트';
      case EventType.fanmeeting:
        return '팬미팅';
      case EventType.photocard:
        return '포토카드 교환회';
      case EventType.other:
        return '기타';
    }
  }

  String get icon {
    switch (this) {
      case EventType.offlineMeeting:
        return '👥';
      case EventType.birthday:
        return '🎂';
      case EventType.performance:
        return '🎤';
      case EventType.cafeEvent:
        return '☕';
      case EventType.cosplayEvent:
        return '🎭';
      case EventType.fanmeeting:
        return '💕';
      case EventType.photocard:
        return '📸';
      case EventType.other:
        return '📌';
    }
  }
}

import 'package:flutter/foundation.dart';

/// 이벤트 카테고리
enum EventCategory {
  concert('CONCERT', '콘서트', '🎤'),
  fanmeeting('FANMEETING', '팬미팅', '💕'),
  broadcast('BROADCAST', '방송', '📺'),
  release('RELEASE', '발매', '💿'),
  birthday('BIRTHDAY', '생일', '🎂'),
  anniversary('ANNIVERSARY', '기념일', '🎊'),
  cafeevent('CAFE_EVENT', '카페 이벤트', '☕'),
  exhibition('EXHIBITION', '전시회', '🖼️'),
  other('OTHER', '기타', '📌');

  final String code;
  final String displayName;
  final String emoji;

  const EventCategory(this.code, this.displayName, this.emoji);

  static EventCategory fromCode(String? code) {
    return EventCategory.values.firstWhere(
      (e) => e.code == code,
      orElse: () => EventCategory.other,
    );
  }
}

/// 이벤트 엔티티
@immutable
class EventEntity {
  final String id;
  final String title;
  final String? description;
  final EventCategory category;
  final DateTime date;
  final DateTime? endDate;
  final String? time;
  final String? location;
  final String? locationDetail;
  final String? idolId;
  final String? idolName;
  final String? imageUrl;
  final String? ticketUrl;
  final int? price;
  final bool isAllDay;
  final bool hasReminder;
  final DateTime createdAt;

  const EventEntity({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    required this.date,
    this.endDate,
    this.time,
    this.location,
    this.locationDetail,
    this.idolId,
    this.idolName,
    this.imageUrl,
    this.ticketUrl,
    this.price,
    this.isAllDay = false,
    this.hasReminder = false,
    required this.createdAt,
  });

  /// 여러 날에 걸친 이벤트인지
  bool get isMultiDay => endDate != null && !_isSameDay(date, endDate!);

  /// 오늘 이벤트인지
  bool get isToday => _isSameDay(date, DateTime.now());

  /// 다가오는 이벤트인지 (오늘 포함)
  bool get isUpcoming {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDay = DateTime(date.year, date.month, date.day);
    return !eventDay.isBefore(today);
  }

  /// 지난 이벤트인지
  bool get isPast => !isUpcoming;

  /// D-Day 계산
  int get dDay {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDay = DateTime(date.year, date.month, date.day);
    return eventDay.difference(today).inDays;
  }

  /// D-Day 표시 문자열
  String get dDayString {
    if (dDay == 0) return 'D-DAY';
    if (dDay > 0) return 'D-$dDay';
    return 'D+${-dDay}';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  EventEntity copyWith({
    String? id,
    String? title,
    String? description,
    EventCategory? category,
    DateTime? date,
    DateTime? endDate,
    String? time,
    String? location,
    String? locationDetail,
    String? idolId,
    String? idolName,
    String? imageUrl,
    String? ticketUrl,
    int? price,
    bool? isAllDay,
    bool? hasReminder,
    DateTime? createdAt,
  }) {
    return EventEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      date: date ?? this.date,
      endDate: endDate ?? this.endDate,
      time: time ?? this.time,
      location: location ?? this.location,
      locationDetail: locationDetail ?? this.locationDetail,
      idolId: idolId ?? this.idolId,
      idolName: idolName ?? this.idolName,
      imageUrl: imageUrl ?? this.imageUrl,
      ticketUrl: ticketUrl ?? this.ticketUrl,
      price: price ?? this.price,
      isAllDay: isAllDay ?? this.isAllDay,
      hasReminder: hasReminder ?? this.hasReminder,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'EventEntity(id: $id, title: $title, date: $date)';
}

/// 날짜별 이벤트 그룹
@immutable
class DayEvents {
  final DateTime date;
  final List<EventEntity> events;

  const DayEvents({
    required this.date,
    required this.events,
  });

  bool get isEmpty => events.isEmpty;
  bool get isNotEmpty => events.isNotEmpty;
  int get count => events.length;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DayEvents &&
          runtimeType == other.runtimeType &&
          date == other.date;

  @override
  int get hashCode => date.hashCode;
}

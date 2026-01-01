import '../../core/errors/result.dart';
import '../entities/event_entity.dart';

/// 이벤트 Repository 인터페이스
abstract class EventRepository {
  /// 이벤트 목록 조회 (날짜 범위)
  Future<Result<List<EventEntity>>> getEvents({
    required DateTime startDate,
    required DateTime endDate,
    EventCategory? category,
    String? idolId,
  });

  /// 특정 날짜의 이벤트 조회
  Future<Result<List<EventEntity>>> getEventsByDate(DateTime date);

  /// 이벤트 상세 조회
  Future<Result<EventEntity>> getEventById(String id);

  /// 다가오는 이벤트 조회
  Future<Result<List<EventEntity>>> getUpcomingEvents({
    int limit = 10,
    EventCategory? category,
  });

  /// 오늘의 이벤트 조회
  Future<Result<List<EventEntity>>> getTodayEvents();

  /// 월별 이벤트 조회 (캘린더용)
  Future<Result<Map<DateTime, List<EventEntity>>>> getMonthlyEvents({
    required int year,
    required int month,
    EventCategory? category,
  });

  /// 리마인더 설정
  Future<Result<EventEntity>> setReminder(String eventId);

  /// 리마인더 해제
  Future<Result<EventEntity>> removeReminder(String eventId);

  /// 리마인더 설정된 이벤트 조회
  Future<Result<List<EventEntity>>> getReminderEvents();

  /// 이벤트 검색
  Future<Result<List<EventEntity>>> searchEvents(String query);
}

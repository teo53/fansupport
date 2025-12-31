import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/result.dart';
import '../../domain/entities/event_entity.dart';
import '../../domain/repositories/event_repository.dart';
import '../datasources/local_datasource.dart';

/// EventRepository 구현체
class EventRepositoryImpl implements EventRepository {
  final LocalDataSource _dataSource;

  EventRepositoryImpl(this._dataSource);

  @override
  Future<Result<List<EventEntity>>> getEvents({
    required DateTime startDate,
    required DateTime endDate,
    EventCategory? category,
    String? idolId,
  }) async {
    try {
      var events = await _dataSource.getEvents(
        startDate: startDate,
        endDate: endDate,
      );

      if (category != null) {
        events = events.where((e) => e.category == category).toList();
      }

      if (idolId != null) {
        events = events.where((e) => e.idolId == idolId).toList();
      }

      return Success(events);
    } catch (e) {
      return Fail(_mapException(e));
    }
  }

  @override
  Future<Result<List<EventEntity>>> getEventsByDate(DateTime date) async {
    try {
      final events = await _dataSource.getEventsByDate(date);
      return Success(events);
    } catch (e) {
      return Fail(_mapException(e));
    }
  }

  @override
  Future<Result<EventEntity>> getEventById(String id) async {
    try {
      final now = DateTime.now();
      final events = await _dataSource.getEvents(
        startDate: now.subtract(const Duration(days: 365)),
        endDate: now.add(const Duration(days: 365)),
      );

      final event = events.firstWhere(
        (e) => e.id == id,
        orElse: () => throw NetworkException.notFound(resource: 'Event'),
      );

      return Success(event);
    } catch (e) {
      return Fail(_mapException(e, '이벤트를 찾을 수 없습니다'));
    }
  }

  @override
  Future<Result<List<EventEntity>>> getUpcomingEvents({
    int limit = 10,
    EventCategory? category,
  }) async {
    try {
      final now = DateTime.now();
      var events = await _dataSource.getEvents(
        startDate: now,
        endDate: now.add(const Duration(days: 30)),
      );

      if (category != null) {
        events = events.where((e) => e.category == category).toList();
      }

      events.sort((a, b) => a.date.compareTo(b.date));

      return Success(events.take(limit).toList());
    } catch (e) {
      return Fail(_mapException(e));
    }
  }

  @override
  Future<Result<List<EventEntity>>> getTodayEvents() async {
    try {
      final events = await _dataSource.getEventsByDate(DateTime.now());
      return Success(events);
    } catch (e) {
      return Fail(_mapException(e));
    }
  }

  @override
  Future<Result<Map<DateTime, List<EventEntity>>>> getMonthlyEvents({
    required int year,
    required int month,
    EventCategory? category,
  }) async {
    try {
      var eventsMap = await _dataSource.getMonthlyEvents(
        year: year,
        month: month,
      );

      if (category != null) {
        eventsMap = eventsMap.map((date, events) => MapEntry(
          date,
          events.where((e) => e.category == category).toList(),
        ));
        eventsMap.removeWhere((_, events) => events.isEmpty);
      }

      return Success(eventsMap);
    } catch (e) {
      return Fail(_mapException(e));
    }
  }

  @override
  Future<Result<EventEntity>> setReminder(String eventId) async {
    try {
      final result = await getEventById(eventId);
      await Future.delayed(UIConstants.shortMockDelay);
      return result.map((event) => event.copyWith(hasReminder: true));
    } catch (e) {
      return Fail(_mapException(e, '리마인더 설정에 실패했습니다'));
    }
  }

  @override
  Future<Result<EventEntity>> removeReminder(String eventId) async {
    try {
      final result = await getEventById(eventId);
      await Future.delayed(UIConstants.shortMockDelay);
      return result.map((event) => event.copyWith(hasReminder: false));
    } catch (e) {
      return Fail(_mapException(e, '리마인더 해제에 실패했습니다'));
    }
  }

  @override
  Future<Result<List<EventEntity>>> getReminderEvents() async {
    try {
      final now = DateTime.now();
      final events = await _dataSource.getEvents(
        startDate: now,
        endDate: now.add(const Duration(days: 365)),
      );

      final reminderEvents = events.where((e) => e.hasReminder).toList();
      return Success(reminderEvents);
    } catch (e) {
      return Fail(_mapException(e));
    }
  }

  @override
  Future<Result<List<EventEntity>>> searchEvents(String query) async {
    try {
      final now = DateTime.now();
      final events = await _dataSource.getEvents(
        startDate: now.subtract(const Duration(days: 30)),
        endDate: now.add(const Duration(days: 365)),
      );

      final filtered = events.where(
        (e) => e.title.toLowerCase().contains(query.toLowerCase()) ||
            (e.idolName?.toLowerCase().contains(query.toLowerCase()) ?? false),
      ).toList();

      return Success(filtered);
    } catch (e) {
      return Fail(_mapException(e));
    }
  }

  /// 예외를 Failure로 변환
  Failure _mapException(dynamic e, [String? fallbackMessage]) {
    if (e is NetworkException) {
      return ServerFailure(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      );
    } else if (e is AuthException) {
      return AuthFailure(message: e.message, code: e.code);
    } else if (e is AppException) {
      return ServerFailure(message: e.message, code: e.code);
    }
    return ServerFailure(message: fallbackMessage ?? ErrorMessages.generic);
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/event_entity.dart';
import '../../domain/repositories/event_repository.dart';
import 'base_state.dart';
import 'di_providers.dart';

/// 캘린더 상태
class CalendarState {
  final int year;
  final int month;
  final DateTime? selectedDate;
  final Map<DateTime, List<EventEntity>> events;
  final bool isLoading;
  final String? error;

  const CalendarState({
    required this.year,
    required this.month,
    this.selectedDate,
    this.events = const {},
    this.isLoading = false,
    this.error,
  });

  List<EventEntity> get selectedDateEvents {
    if (selectedDate == null) return [];
    final key = DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day);
    return events[key] ?? [];
  }

  bool hasEvents(DateTime date) {
    final key = DateTime(date.year, date.month, date.day);
    return events[key]?.isNotEmpty ?? false;
  }

  List<EventEntity> getEventsForDay(DateTime date) {
    final key = DateTime(date.year, date.month, date.day);
    return events[key] ?? [];
  }

  CalendarState copyWith({
    int? year,
    int? month,
    DateTime? selectedDate,
    Map<DateTime, List<EventEntity>>? events,
    bool? isLoading,
    String? error,
  }) {
    return CalendarState(
      year: year ?? this.year,
      month: month ?? this.month,
      selectedDate: selectedDate ?? this.selectedDate,
      events: events ?? this.events,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// 캘린더 상태 관리 Notifier
class CalendarNotifier extends StateNotifier<CalendarState> {
  final EventRepository _repository;

  CalendarNotifier(this._repository)
      : super(CalendarState(
          year: DateTime.now().year,
          month: DateTime.now().month,
          selectedDate: DateTime.now(),
        )) {
    loadEvents();
  }

  Future<void> loadEvents() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.getMonthlyEvents(
      year: state.year,
      month: state.month,
    );

    result.fold(
      onSuccess: (events) {
        state = state.copyWith(
          events: events,
          isLoading: false,
        );
      },
      onFailure: (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
    );
  }

  void selectDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  void changeMonth(int year, int month) {
    state = state.copyWith(
      year: year,
      month: month,
    );
    loadEvents();
  }

  void nextMonth() {
    var newMonth = state.month + 1;
    var newYear = state.year;
    if (newMonth > 12) {
      newMonth = 1;
      newYear++;
    }
    changeMonth(newYear, newMonth);
  }

  void previousMonth() {
    var newMonth = state.month - 1;
    var newYear = state.year;
    if (newMonth < 1) {
      newMonth = 12;
      newYear--;
    }
    changeMonth(newYear, newMonth);
  }

  void goToToday() {
    final now = DateTime.now();
    state = state.copyWith(selectedDate: now);
    if (state.year != now.year || state.month != now.month) {
      changeMonth(now.year, now.month);
    }
  }
}

/// 캘린더 Provider
final calendarProvider =
    StateNotifierProvider<CalendarNotifier, CalendarState>((ref) {
  return CalendarNotifier(ref.read(eventRepositoryProvider));
});

/// 오늘의 이벤트 Provider
final todayEventsProvider = FutureProvider<List<EventEntity>>((ref) async {
  final result = await ref.read(eventRepositoryProvider).getTodayEvents();
  return result.data ?? [];
});

/// 다가오는 이벤트 Provider
final upcomingEventsProvider = FutureProvider<List<EventEntity>>((ref) async {
  final result = await ref.read(eventRepositoryProvider).getUpcomingEvents();
  return result.data ?? [];
});

/// 이벤트 상세 Provider
final eventDetailProvider =
    FutureProvider.family<EventEntity?, String>((ref, eventId) async {
  final result = await ref.read(eventRepositoryProvider).getEventById(eventId);
  return result.data;
});

/// 특정 날짜 이벤트 Provider
final dateEventsProvider =
    FutureProvider.family<List<EventEntity>, DateTime>((ref, date) async {
  final result = await ref.read(eventRepositoryProvider).getEventsByDate(date);
  return result.data ?? [];
});

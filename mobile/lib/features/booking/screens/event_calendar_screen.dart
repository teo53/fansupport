import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/mock/mock_data.dart';
import '../../../shared/models/idol_model.dart';
import '../../../shared/models/event_model.dart';
import 'package:intl/intl.dart';

/// 🗓️ 이벤트 캘린더 화면 - 카테고리 필터 지원
class EventCalendarScreen extends ConsumerStatefulWidget {
  const EventCalendarScreen({super.key});

  @override
  ConsumerState<EventCalendarScreen> createState() => _EventCalendarScreenState();
}

class _EventCalendarScreenState extends ConsumerState<EventCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // 선택된 카테고리 (다중 선택 가능)
  final Set<IdolCategory> _selectedCategories = {
    IdolCategory.undergroundIdol,
  };

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  /// 선택된 날짜의 이벤트 목록
  List<EventModel> get _selectedDayEvents {
    if (_selectedDay == null) return [];
    return MockData.getEventsForDateAndCategory(_selectedDay!, _selectedCategories);
  }

  /// 이벤트가 있는 날짜인지 확인
  bool _hasEvents(DateTime day) {
    final events = MockData.getEventsForDateAndCategory(day, _selectedCategories);
    return events.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          '일정 캘린더',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 카테고리 필터 버튼
          _buildCategoryFilter(),

          const SizedBox(height: 8),

          // 캘린더
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildCalendar(),
                  const SizedBox(height: 16),

                  // 선택된 날짜의 이벤트 목록
                  if (_selectedDay != null) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle(),
                          const SizedBox(height: 12),
                          _selectedDayEvents.isEmpty
                              ? _buildEmptyState()
                              : Column(
                                  children: _selectedDayEvents
                                      .map((event) => _buildEventCard(event))
                                      .toList(),
                                ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 카테고리 필터 버튼
  Widget _buildCategoryFilter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _buildFilterChip(
            label: '지하돌',
            icon: Icons.mic_rounded,
            category: IdolCategory.undergroundIdol,
            color: AppColors.undergroundCategory,
          ),
          _buildFilterChip(
            label: '메이드 카페',
            icon: Icons.local_cafe_rounded,
            category: IdolCategory.maidCafe,
            color: AppColors.maidCategory,
          ),
          _buildFilterChip(
            label: '코스프레이어',
            icon: Icons.photo_camera_rounded,
            category: IdolCategory.cosplayer,
            color: AppColors.cosplayCategory,
          ),
        ],
      ),
    );
  }

  /// 필터 칩 (다중 선택 가능)
  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required IdolCategory category,
    required Color color,
  }) {
    final isSelected = _selectedCategories.contains(category);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            if (isSelected) {
              // 최소 1개는 선택되어 있어야 함
              if (_selectedCategories.length > 1) {
                _selectedCategories.remove(category);
              }
            } else {
              _selectedCategories.add(category);
            }
          });
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? color : AppColors.border,
              width: 2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : color,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 캘린더 위젯
  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime(2026, 1, 1),
        lastDay: DateTime(2027, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        calendarFormat: CalendarFormat.month,
        startingDayOfWeek: StartingDayOfWeek.monday,
        locale: 'ko_KR',

        // 이벤트 로더 - 마커 표시용
        eventLoader: (day) {
          return MockData.getEventsForDateAndCategory(day, _selectedCategories);
        },

        // 헤더 스타일
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
          leftChevronIcon: Icon(Icons.chevron_left, size: 28),
          rightChevronIcon: Icon(Icons.chevron_right, size: 28),
        ),

        // 캘린더 스타일
        calendarStyle: CalendarStyle(
          // 선택된 날짜
          selectedDecoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          selectedTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),

          // 오늘 날짜
          todayDecoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          todayTextStyle: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),

          // 기본 날짜
          defaultTextStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),

          // 주말
          weekendTextStyle: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.error,
          ),

          // 다른 달의 날짜
          outsideTextStyle: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.textHint,
          ),

          // 마커 스타일
          markerDecoration: BoxDecoration(
            color: AppColors.accent,
            shape: BoxShape.circle,
          ),
          markerSize: 6,
          markersMaxCount: 1,
          markersAlignment: Alignment.bottomCenter,
          markerMargin: const EdgeInsets.only(top: 2),
        ),

        // 요일 스타일
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
          weekendStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.error,
          ),
        ),

        // 날짜 선택 이벤트
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },

        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
      ),
    );
  }

  /// 섹션 제목
  Widget _buildSectionTitle() {
    final dateFormat = DateFormat('M월 d일 (E)', 'ko_KR');
    return Row(
      children: [
        Text(
          dateFormat.format(_selectedDay!),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${_selectedDayEvents.length}개',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  /// 빈 상태
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.event_busy_rounded,
            size: 64,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 16),
          Text(
            '일정이 없습니다',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '이 날짜에는 예정된 이벤트가 없어요',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }

  /// 이벤트 카드
  Widget _buildEventCard(EventModel event) {
    final idol = MockData.idolModels.firstWhere((i) => i.id == event.idolId);
    final timeFormat = DateFormat('HH:mm');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showEventDetail(event, idol),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 이벤트 타입 아이콘
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _getCategoryColor(event.category).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    event.type.icon,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // 이벤트 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 카테고리 뱃지
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(event.category),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _getCategoryText(event.category),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0),

                    // 제목
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 8.0),

                    // 아이돌 이름
                    Row(
                      children: [
                        Icon(Icons.person_rounded, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          idol.stageName,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),

                    // 시간 & 장소
                    Row(
                      children: [
                        Icon(Icons.schedule_rounded, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          timeFormat.format(event.date),
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (event.location != null) ...[
                          const SizedBox(width: 12),
                          Icon(Icons.location_on_rounded, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              event.location!,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),

                    // 참가 정보
                    if (event.maxParticipants != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: event.currentParticipants / event.maxParticipants!,
                              backgroundColor: AppColors.border,
                              valueColor: AlwaysStoppedAnimation(
                                event.isSoldOut ? AppColors.error : AppColors.success,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            event.isSoldOut
                                ? '매진'
                                : '${event.availableSlots}석 남음',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: event.isSoldOut ? AppColors.error : AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // 가격
              if (event.price != null && event.price! > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${NumberFormat('#,###').format(event.price)}원',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 이벤트 상세 다이얼로그
  void _showEventDetail(EventModel event, IdolModel idol) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(event.category).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        event.type.icon,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          idol.stageName,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 설명
              Text(
                event.description,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),

              // 정보
              _buildDetailRow(Icons.calendar_today_rounded, '날짜', DateFormat('yyyy년 M월 d일 (E) HH:mm', 'ko_KR').format(event.date)),
              if (event.location != null)
                _buildDetailRow(Icons.location_on_rounded, '장소', event.location!),
              if (event.price != null)
                _buildDetailRow(Icons.payments_rounded, '가격', event.price == 0 ? '무료' : '${NumberFormat('#,###').format(event.price)}원'),
              if (event.maxParticipants != null)
                _buildDetailRow(Icons.people_rounded, '정원', '${event.currentParticipants}/${event.maxParticipants}명'),

              const SizedBox(height: 20),

              // 버튼
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '닫기',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: event.isAvailable
                          ? () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('예약 기능은 준비 중입니다'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        event.isSoldOut ? '매진' : '예약하기',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(IdolCategory category) {
    switch (category) {
      case IdolCategory.undergroundIdol:
        return AppColors.undergroundCategory;
      case IdolCategory.maidCafe:
        return AppColors.maidCategory;
      case IdolCategory.cosplayer:
        return AppColors.cosplayCategory;
      default:
        return AppColors.primary;
    }
  }

  String _getCategoryText(IdolCategory category) {
    switch (category) {
      case IdolCategory.undergroundIdol:
        return '지하돌';
      case IdolCategory.maidCafe:
        return '메이드 카페';
      case IdolCategory.cosplayer:
        return '코스프레이어';
      default:
        return '기타';
    }
  }
}

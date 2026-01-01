import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/mock/mock_data.dart';

/// 스케줄 화면 - 초기 유저 유입을 위한 핵심 "훅" 기능
/// 아이돌 스케줄을 캘린더 형태로 보여주어 유틸리티 가치 제공
class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen>
    with SingleTickerProviderStateMixin {
  late DateTime _selectedDate;
  late DateTime _focusedMonth;
  late PageController _pageController;
  late AnimationController _fadeController;

  // 선택된 아이돌 필터 (null = 전체)
  String? _selectedIdolId;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _focusedMonth = DateTime.now();
    _pageController = PageController(initialPage: 500);
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildIdolFilter(),
            _buildCalendar(),
            Expanded(
              child: _buildScheduleList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        DS.screenPadding,
        DS.space4,
        DS.screenPadding,
        DS.space3,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '스케줄',
                style: DS.heading2,
              ),
              const SizedBox(height: 4),
              Text(
                '좋아하는 아이돌의 일정을 확인하세요',
                style: DS.textSm(color: AppColors.textSecondary),
              ),
            ],
          ),
          Row(
            children: [
              _buildHeaderButton(
                icon: Icons.notifications_none_rounded,
                badge: 2,
                onTap: () {
                  // TODO: 스케줄 알림 설정
                },
              ),
              const SizedBox(width: DS.space2),
              _buildHeaderButton(
                icon: Icons.today_rounded,
                onTap: () {
                  setState(() {
                    _selectedDate = DateTime.now();
                    _focusedMonth = DateTime.now();
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    int? badge,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: DS.borderRadiusMd,
          boxShadow: AppColors.cardShadow(opacity: 0.06),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, size: 22, color: AppColors.textPrimary),
            if (badge != null)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$badge',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdolFilter() {
    final idols = MockData.idols.take(6).toList();

    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: DS.space3),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: DS.screenPadding),
        itemCount: idols.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            final isSelected = _selectedIdolId == null;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedIdolId = null);
              },
              child: Container(
                margin: const EdgeInsets.only(right: DS.space2),
                padding: const EdgeInsets.symmetric(
                  horizontal: DS.space4,
                  vertical: DS.space2,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: DS.borderRadiusSm,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Center(
                  child: Text(
                    '전체',
                    style: DS.textSm(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      weight: DS.weightSemibold,
                    ),
                  ),
                ),
              ),
            );
          }

          final idol = idols[index - 1];
          final isSelected = _selectedIdolId == idol['id'];

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedIdolId = idol['id']);
            },
            child: Container(
              margin: const EdgeInsets.only(right: DS.space2),
              padding: const EdgeInsets.symmetric(
                horizontal: DS.space3,
                vertical: DS.space2,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : Colors.white,
                borderRadius: DS.borderRadiusSm,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: AppColors.primarySoft,
                    backgroundImage: idol['profileImage'] != null
                        ? NetworkImage(idol['profileImage'])
                        : null,
                    child: idol['profileImage'] == null
                        ? const Icon(Icons.person, size: 14, color: AppColors.primary)
                        : null,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    idol['stageName'] ?? '',
                    style: DS.textSm(
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      weight: isSelected ? DS.weightSemibold : DS.weightMedium,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: DS.screenPadding),
      padding: const EdgeInsets.all(DS.space4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: DS.borderRadiusLg,
        boxShadow: AppColors.cardShadow(opacity: 0.06),
      ),
      child: Column(
        children: [
          _buildMonthSelector(),
          const SizedBox(height: DS.space4),
          _buildWeekdayHeader(),
          const SizedBox(height: DS.space2),
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            HapticFeedback.selectionClick();
            setState(() {
              _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
            });
          },
          icon: const Icon(Icons.chevron_left_rounded),
          color: AppColors.textSecondary,
        ),
        Text(
          '${_focusedMonth.year}년 ${_focusedMonth.month}월',
          style: DS.textLg(weight: DS.weightBold),
        ),
        IconButton(
          onPressed: () {
            HapticFeedback.selectionClick();
            setState(() {
              _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
            });
          },
          icon: const Icon(Icons.chevron_right_rounded),
          color: AppColors.textSecondary,
        ),
      ],
    );
  }

  Widget _buildWeekdayHeader() {
    const weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    return Row(
      children: weekdays.asMap().entries.map((entry) {
        final index = entry.key;
        final day = entry.value;
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: DS.textXs(
                color: index == 0
                    ? AppColors.error
                    : (index == 6 ? AppColors.primary : AppColors.textSecondary),
                weight: DS.weightMedium,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final startOffset = firstDayOfMonth.weekday % 7;
    final totalDays = lastDayOfMonth.day;
    final totalCells = ((startOffset + totalDays) / 7).ceil() * 7;

    // 스케줄 있는 날짜들 (Mock)
    final scheduleDates = _getScheduleDates();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemCount: totalCells,
      itemBuilder: (context, index) {
        final dayNumber = index - startOffset + 1;

        if (dayNumber < 1 || dayNumber > totalDays) {
          return const SizedBox();
        }

        final date = DateTime(_focusedMonth.year, _focusedMonth.month, dayNumber);
        final isSelected = _isSameDay(date, _selectedDate);
        final isToday = _isSameDay(date, DateTime.now());
        final hasSchedule = scheduleDates.contains(dayNumber);
        final isSunday = date.weekday == DateTime.sunday;
        final isSaturday = date.weekday == DateTime.saturday;

        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _selectedDate = date);
          },
          child: AnimatedContainer(
            duration: DS.durationFast,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : (isToday ? AppColors.primarySoft : Colors.transparent),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  '$dayNumber',
                  style: DS.textSm(
                    color: isSelected
                        ? Colors.white
                        : (isSunday
                            ? AppColors.error
                            : (isSaturday ? AppColors.primary : AppColors.textPrimary)),
                    weight: isToday || isSelected ? DS.weightBold : DS.weightMedium,
                  ),
                ),
                if (hasSchedule && !isSelected)
                  Positioned(
                    bottom: 4,
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Set<int> _getScheduleDates() {
    // Mock 스케줄 데이터
    return {3, 5, 8, 12, 15, 18, 22, 25, 28};
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _buildScheduleList() {
    final schedules = _getSchedulesForDate(_selectedDate);

    return Container(
      margin: const EdgeInsets.only(top: DS.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DS.screenPadding),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DS.space3,
                    vertical: DS.space1,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: DS.borderRadiusXs,
                  ),
                  child: Text(
                    '${_selectedDate.month}/${_selectedDate.day}',
                    style: DS.textSm(
                      color: Colors.white,
                      weight: DS.weightBold,
                    ),
                  ),
                ),
                const SizedBox(width: DS.space2),
                Text(
                  _getWeekdayName(_selectedDate.weekday),
                  style: DS.textBase(
                    color: AppColors.textSecondary,
                    weight: DS.weightMedium,
                  ),
                ),
                const Spacer(),
                Text(
                  '${schedules.length}개의 일정',
                  style: DS.textSm(color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
          const SizedBox(height: DS.space3),
          Expanded(
            child: schedules.isEmpty
                ? _buildEmptySchedule()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: DS.screenPadding),
                    itemCount: schedules.length,
                    itemBuilder: (context, index) {
                      return _buildScheduleCard(schedules[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _getWeekdayName(int weekday) {
    const names = ['', '월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
    return names[weekday];
  }

  List<Map<String, dynamic>> _getSchedulesForDate(DateTime date) {
    // Mock 스케줄 데이터
    if (!_getScheduleDates().contains(date.day)) return [];

    final mockSchedules = [
      {
        'id': '1',
        'title': '정기 라이브 공연',
        'idolName': '하늘별',
        'idolImage': 'https://ui-avatars.com/api/?name=하늘별&background=5046E5&color=fff',
        'time': '19:00 - 21:00',
        'location': '아키하바라 라이브홀',
        'type': 'LIVE',
        'isBookmarked': true,
      },
      {
        'id': '2',
        'title': '팬 사인회',
        'idolName': '루나',
        'idolImage': 'https://ui-avatars.com/api/?name=루나&background=FF6B9D&color=fff',
        'time': '14:00 - 16:00',
        'location': '이케부쿠로 이벤트홀',
        'type': 'EVENT',
        'isBookmarked': false,
      },
    ];

    if (_selectedIdolId != null) {
      // 필터 적용
      return mockSchedules.where((s) => s['idolName'] == '하늘별').toList();
    }

    return mockSchedules;
  }

  Widget _buildEmptySchedule() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy_rounded,
            size: 64,
            color: AppColors.textHint.withValues(alpha: 0.5),
          ),
          const SizedBox(height: DS.space4),
          Text(
            '이 날은 일정이 없어요',
            style: DS.textLg(color: AppColors.textSecondary),
          ),
          const SizedBox(height: DS.space2),
          Text(
            '다른 날짜를 선택해보세요',
            style: DS.textSm(color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(Map<String, dynamic> schedule) {
    final typeColors = {
      'LIVE': AppColors.primary,
      'EVENT': AppColors.secondary,
      'BROADCAST': AppColors.success,
    };

    final typeLabels = {
      'LIVE': '라이브',
      'EVENT': '이벤트',
      'BROADCAST': '방송',
    };

    final color = typeColors[schedule['type']] ?? AppColors.primary;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        // TODO: 스케줄 상세 페이지
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: DS.space3),
        padding: const EdgeInsets.all(DS.space4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: DS.borderRadiusLg,
          border: Border.all(color: AppColors.border),
          boxShadow: AppColors.cardShadow(opacity: 0.04),
        ),
        child: Row(
          children: [
            // 시간 표시 바
            Container(
              width: 4,
              height: 60,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: DS.space4),
            // 아이돌 프로필
            CircleAvatar(
              radius: 24,
              backgroundColor: color.withValues(alpha: 0.1),
              backgroundImage: schedule['idolImage'] != null
                  ? NetworkImage(schedule['idolImage'])
                  : null,
            ),
            const SizedBox(width: DS.space3),
            // 일정 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          typeLabels[schedule['type']] ?? '',
                          style: DS.textXs(
                            color: color,
                            weight: DS.weightSemibold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        schedule['idolName'] ?? '',
                        style: DS.textXs(
                          color: AppColors.textSecondary,
                          weight: DS.weightMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    schedule['title'] ?? '',
                    style: DS.textBase(weight: DS.weightBold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        schedule['time'] ?? '',
                        style: DS.textXs(color: AppColors.textSecondary),
                      ),
                      const SizedBox(width: DS.space3),
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          schedule['location'] ?? '',
                          style: DS.textXs(color: AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // 북마크 버튼
            IconButton(
              onPressed: () {
                HapticFeedback.selectionClick();
                // TODO: 북마크 토글
              },
              icon: Icon(
                schedule['isBookmarked'] == true
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                color: schedule['isBookmarked'] == true
                    ? AppColors.primary
                    : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

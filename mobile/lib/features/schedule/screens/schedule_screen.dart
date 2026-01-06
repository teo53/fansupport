import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/mock/mock_data.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedMonth = DateTime.now();

  final List<Map<String, dynamic>> _schedules = [
    {
      'id': '1',
      'title': '민지 생일 팬미팅',
      'date': DateTime(2026, 1, 7, 14, 0),
      'type': 'fanmeeting',
      'idol': 'MINJI',
      'imageUrl': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200',
    },
    {
      'id': '2',
      'title': 'PIPO 신년 라이브',
      'date': DateTime(2026, 1, 10, 20, 0),
      'type': 'live',
      'idol': 'PIPO',
      'imageUrl': 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=200',
    },
    {
      'id': '3',
      'title': '앨범 발매 기념 이벤트',
      'date': DateTime(2026, 1, 15, 18, 0),
      'type': 'event',
      'idol': 'YUNA',
      'imageUrl': 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200',
    },
    {
      'id': '4',
      'title': '영상통화 팬사인회',
      'date': DateTime(2026, 1, 20, 15, 0),
      'type': 'videocall',
      'idol': 'SAKURA',
      'imageUrl': 'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=200',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PipoColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: _buildHeader(),
            ),

            // Calendar
            SliverToBoxAdapter(
              child: _buildCalendar(),
            ),

            // Upcoming schedules title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  PipoSpacing.xl, PipoSpacing.xxl, PipoSpacing.xl, PipoSpacing.md,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '다가오는 일정',
                      style: PipoTypography.titleLarge.copyWith(
                        color: PipoColors.textPrimary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: PipoColors.primarySoft,
                        borderRadius: BorderRadius.circular(PipoRadius.sm),
                      ),
                      child: Text(
                        '${_schedules.length}개',
                        style: PipoTypography.labelSmall.copyWith(
                          color: PipoColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Schedule list
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: PipoSpacing.xl),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final schedule = _schedules[index];
                    return _buildScheduleCard(schedule);
                  },
                  childCount: _schedules.length,
                ),
              ),
            ),

            // Bottom spacing
            SliverToBoxAdapter(
              child: SizedBox(height: PipoSpacing.screen + 40),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        PipoSpacing.xl,
        PipoSpacing.lg,
        PipoSpacing.xl,
        PipoSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '캘린더',
                style: PipoTypography.headlineMedium.copyWith(
                  color: PipoColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '좋아하는 크리에이터의 일정을 확인하세요',
                style: PipoTypography.bodySmall.copyWith(
                  color: PipoColors.textSecondary,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              // Add schedule
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: PipoColors.primarySoft,
                borderRadius: BorderRadius.circular(PipoRadius.md),
              ),
              child: const Icon(
                Icons.add_rounded,
                color: PipoColors.primary,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    final daysInMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final startingWeekday = firstDayOfMonth.weekday % 7;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: PipoSpacing.xl),
      padding: const EdgeInsets.all(PipoSpacing.lg),
      decoration: BoxDecoration(
        color: PipoColors.surface,
        borderRadius: BorderRadius.circular(PipoRadius.xl),
        boxShadow: PipoShadows.sm,
      ),
      child: Column(
        children: [
          // Month navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _focusedMonth = DateTime(
                      _focusedMonth.year,
                      _focusedMonth.month - 1,
                    );
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: PipoColors.backgroundAlt,
                    borderRadius: BorderRadius.circular(PipoRadius.sm),
                  ),
                  child: const Icon(
                    Icons.chevron_left_rounded,
                    color: PipoColors.textSecondary,
                    size: 20,
                  ),
                ),
              ),
              Text(
                '${_focusedMonth.year}년 ${_focusedMonth.month}월',
                style: PipoTypography.titleMedium.copyWith(
                  color: PipoColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _focusedMonth = DateTime(
                      _focusedMonth.year,
                      _focusedMonth.month + 1,
                    );
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: PipoColors.backgroundAlt,
                    borderRadius: BorderRadius.circular(PipoRadius.sm),
                  ),
                  child: const Icon(
                    Icons.chevron_right_rounded,
                    color: PipoColors.textSecondary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: PipoSpacing.lg),

          // Weekday headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['일', '월', '화', '수', '목', '금', '토'].map((day) {
              final isWeekend = day == '일' || day == '토';
              return SizedBox(
                width: 36,
                child: Center(
                  child: Text(
                    day,
                    style: PipoTypography.caption.copyWith(
                      color: isWeekend
                          ? (day == '일' ? PipoColors.error : PipoColors.primary)
                          : PipoColors.textTertiary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: PipoSpacing.md),

          // Calendar grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: startingWeekday + daysInMonth,
            itemBuilder: (context, index) {
              if (index < startingWeekday) {
                return const SizedBox();
              }

              final day = index - startingWeekday + 1;
              final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
              final isToday = _isSameDay(date, DateTime.now());
              final isSelected = _isSameDay(date, _selectedDate);
              final hasEvent = _schedules.any((s) => _isSameDay(s['date'], date));
              final isWeekend = date.weekday == 7 || date.weekday == 6;

              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _selectedDate = date;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? PipoColors.primary
                        : isToday
                            ? PipoColors.primarySoft
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(PipoRadius.sm),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        '$day',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected || isToday
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : isToday
                                  ? PipoColors.primary
                                  : isWeekend
                                      ? (date.weekday == 7
                                          ? PipoColors.error
                                          : PipoColors.primary)
                                      : PipoColors.textPrimary,
                        ),
                      ),
                      if (hasEvent && !isSelected)
                        Positioned(
                          bottom: 4,
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: PipoColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(Map<String, dynamic> schedule) {
    final date = schedule['date'] as DateTime;
    final type = schedule['type'] as String;

    Color typeColor;
    IconData typeIcon;
    switch (type) {
      case 'fanmeeting':
        typeColor = PipoColors.purple;
        typeIcon = Icons.groups_rounded;
        break;
      case 'live':
        typeColor = PipoColors.primary;
        typeIcon = Icons.videocam_rounded;
        break;
      case 'event':
        typeColor = PipoColors.teal;
        typeIcon = Icons.celebration_rounded;
        break;
      case 'videocall':
        typeColor = PipoColors.orange;
        typeIcon = Icons.phone_in_talk_rounded;
        break;
      default:
        typeColor = PipoColors.textSecondary;
        typeIcon = Icons.event_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: PipoSpacing.md),
      padding: const EdgeInsets.all(PipoSpacing.lg),
      decoration: BoxDecoration(
        color: PipoColors.surface,
        borderRadius: BorderRadius.circular(PipoRadius.lg),
        boxShadow: PipoShadows.sm,
      ),
      child: Row(
        children: [
          // Date box
          Container(
            width: 52,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(PipoRadius.md),
            ),
            child: Column(
              children: [
                Text(
                  '${date.month}/${date.day}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: typeColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getWeekdayName(date.weekday),
                  style: TextStyle(
                    fontSize: 10,
                    color: typeColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: PipoSpacing.md),

          // Info
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
                        color: typeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(typeIcon, size: 12, color: typeColor),
                          const SizedBox(width: 4),
                          Text(
                            _getTypeName(type),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: typeColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                      style: PipoTypography.caption.copyWith(
                        color: PipoColors.textTertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  schedule['title'],
                  style: PipoTypography.titleSmall.copyWith(
                    color: PipoColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  schedule['idol'],
                  style: PipoTypography.caption.copyWith(
                    color: PipoColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Avatar
          CircleAvatar(
            radius: 22,
            backgroundColor: PipoColors.primarySoft,
            backgroundImage: CachedNetworkImageProvider(schedule['imageUrl']),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _getWeekdayName(int weekday) {
    const names = ['', '월', '화', '수', '목', '금', '토', '일'];
    return names[weekday];
  }

  String _getTypeName(String type) {
    switch (type) {
      case 'fanmeeting':
        return '팬미팅';
      case 'live':
        return '라이브';
      case 'event':
        return '이벤트';
      case 'videocall':
        return '영상통화';
      default:
        return '일정';
    }
  }
}

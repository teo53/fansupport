import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/mock/mock_data.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  String _selectedLocation = '전체';

  final List<String> _locations = ['전체', '서울', '도쿄', '오사카', '나고야', '후쿠오카'];

  List<Map<String, dynamic>> get _events => MockData.events;

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    final dayString = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
    return _events.where((event) {
      final matchDate = event['date'] == dayString;
      final matchLocation = _selectedLocation == '전체' || event['location'] == _selectedLocation;
      return matchDate && matchLocation;
    }).toList();
  }

  List<Map<String, dynamic>> get _filteredEvents {
    if (_selectedLocation == '전체') return _events;
    return _events.where((e) => e['location'] == _selectedLocation).toList();
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final selectedDayEvents = _selectedDay != null ? _getEventsForDay(_selectedDay!) : [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('공연 일정', style: TextStyle(fontSize: Responsive.sp(18))),
        actions: [
          PopupMenuButton<String>(
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_on, size: Responsive.sp(18)),
                SizedBox(width: Responsive.wp(1)),
                Text(
                  _selectedLocation,
                  style: TextStyle(fontSize: Responsive.sp(14)),
                ),
                Icon(Icons.arrow_drop_down, size: Responsive.sp(20)),
              ],
            ),
            onSelected: (value) => setState(() => _selectedLocation = value),
            itemBuilder: (context) => _locations
                .map((loc) => PopupMenuItem(
                      value: loc,
                      child: Row(
                        children: [
                          if (_selectedLocation == loc)
                            Icon(Icons.check, size: Responsive.sp(18), color: AppColors.primary),
                          if (_selectedLocation != loc) SizedBox(width: Responsive.sp(18)),
                          SizedBox(width: Responsive.wp(2)),
                          Text(loc),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Calendar
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TableCalendar(
              firstDay: DateTime(2024, 1, 1),
              lastDay: DateTime(2025, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: _calendarFormat,
              startingDayOfWeek: StartingDayOfWeek.sunday,
              locale: 'ko_KR',
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  fontSize: Responsive.sp(18),
                  fontWeight: FontWeight.bold,
                ),
                leftChevronIcon: Icon(Icons.chevron_left, color: AppColors.textPrimary),
                rightChevronIcon: Icon(Icons.chevron_right, color: AppColors.textPrimary),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  fontSize: Responsive.sp(12),
                  color: AppColors.textSecondary,
                ),
                weekendStyle: TextStyle(
                  fontSize: Responsive.sp(12),
                  color: AppColors.error,
                ),
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                todayTextStyle: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: Responsive.sp(14),
                ),
                selectedTextStyle: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: Responsive.sp(14),
                ),
                defaultTextStyle: TextStyle(fontSize: Responsive.sp(14)),
                weekendTextStyle: TextStyle(
                  fontSize: Responsive.sp(14),
                  color: AppColors.error,
                ),
                outsideTextStyle: TextStyle(
                  fontSize: Responsive.sp(14),
                  color: AppColors.textHint,
                ),
                markerDecoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 3,
                markerSize: 6,
                markerMargin: const EdgeInsets.symmetric(horizontal: 0.5),
              ),
              eventLoader: _getEventsForDay,
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  if (events.isEmpty) return null;
                  return Positioned(
                    bottom: 1,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: events.take(3).map((event) {
                        final e = event as Map<String, dynamic>;
                        return Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 0.5),
                          decoration: BoxDecoration(
                            color: Color(e['color'] ?? 0xFF4CAF50),
                            shape: BoxShape.circle,
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
            ),
          ),

          // Event List Header
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.wp(4),
              vertical: Responsive.hp(1.5),
            ),
            child: Row(
              children: [
                Text(
                  _selectedDay != null
                      ? '${_selectedDay!.month}월 ${_selectedDay!.day}일 일정'
                      : '일정',
                  style: TextStyle(
                    fontSize: Responsive.sp(16),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: Responsive.wp(2)),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.wp(2),
                    vertical: Responsive.hp(0.3),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${selectedDayEvents.length}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: Responsive.sp(12),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Event List
          Expanded(
            child: selectedDayEvents.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: Responsive.sp(60),
                          color: AppColors.textHint,
                        ),
                        SizedBox(height: Responsive.hp(2)),
                        Text(
                          '이 날에 예정된 공연이 없습니다',
                          style: TextStyle(
                            fontSize: Responsive.sp(14),
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: Responsive.wp(4)),
                    itemCount: selectedDayEvents.length,
                    itemBuilder: (context, index) {
                      return _buildEventCard(selectedDayEvents[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    final color = Color(event['color'] ?? 0xFF4CAF50);
    final performers = event['performers'] as List<dynamic>? ?? [];

    return Card(
      margin: EdgeInsets.only(bottom: Responsive.hp(1.5)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        onTap: () => _showEventDetail(event),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(Responsive.wp(4)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border(
              left: BorderSide(color: color, width: 4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category & Time
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.wp(2),
                      vertical: Responsive.hp(0.3),
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _getCategoryName(event['category']),
                      style: TextStyle(
                        fontSize: Responsive.sp(11),
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.access_time,
                    size: Responsive.sp(14),
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: Responsive.wp(1)),
                  Text(
                    event['time'] ?? '',
                    style: TextStyle(
                      fontSize: Responsive.sp(13),
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: Responsive.hp(1)),

              // Title
              Text(
                event['title'] ?? '',
                style: TextStyle(
                  fontSize: Responsive.sp(16),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: Responsive.hp(0.5)),

              // Venue & Location
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: Responsive.sp(14),
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: Responsive.wp(1)),
                  Expanded(
                    child: Text(
                      '${event['venue']} · ${event['location']}',
                      style: TextStyle(
                        fontSize: Responsive.sp(13),
                        color: AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: Responsive.hp(1.5)),

              // Performers & Price
              Row(
                children: [
                  // Performer Avatars
                  if (performers.isNotEmpty) ...[
                    SizedBox(
                      width: performers.length > 3
                          ? Responsive.wp(20)
                          : Responsive.wp(6) * performers.length +
                              Responsive.wp(2) * (performers.length - 1),
                      height: Responsive.wp(6),
                      child: Stack(
                        children: performers.take(4).toList().asMap().entries.map((entry) {
                          final idx = entry.key;
                          final performer = entry.value as Map<String, dynamic>;
                          return Positioned(
                            left: idx * Responsive.wp(4.5),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.cardBackground,
                                  width: 2,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: Responsive.wp(3),
                                backgroundImage: performer['profileImage'] != null
                                    ? CachedNetworkImageProvider(performer['profileImage'])
                                    : null,
                                backgroundColor: color.withValues(alpha: 0.2),
                                child: performer['profileImage'] == null
                                    ? Icon(Icons.person, size: Responsive.sp(12), color: color)
                                    : null,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    if (performers.length > 4)
                      Text(
                        '+${performers.length - 4}',
                        style: TextStyle(
                          fontSize: Responsive.sp(12),
                          color: AppColors.textSecondary,
                        ),
                      ),
                    SizedBox(width: Responsive.wp(2)),
                  ],

                  const Spacer(),

                  // Price
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.wp(3),
                      vertical: Responsive.hp(0.5),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '￦${_formatNumber(event['price'] ?? 0)}',
                      style: TextStyle(
                        fontSize: Responsive.sp(14),
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
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

  void _showEventDetail(Map<String, dynamic> event) {
    final color = Color(event['color'] ?? 0xFF4CAF50);
    final performers = event['performers'] as List<dynamic>? ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: Responsive.screenHeight * 0.7,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: EdgeInsets.symmetric(vertical: Responsive.hp(1.5)),
              width: Responsive.wp(10),
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(Responsive.wp(5)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.wp(3),
                        vertical: Responsive.hp(0.5),
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getCategoryName(event['category']),
                        style: TextStyle(
                          fontSize: Responsive.sp(13),
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: Responsive.hp(2)),

                    // Title
                    Text(
                      event['title'] ?? '',
                      style: TextStyle(
                        fontSize: Responsive.sp(24),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: Responsive.hp(3)),

                    // Info Rows
                    _buildInfoRow(Icons.calendar_today, '날짜', _formatDate(event['date'])),
                    SizedBox(height: Responsive.hp(1.5)),
                    _buildInfoRow(Icons.access_time, '시간', event['time'] ?? ''),
                    SizedBox(height: Responsive.hp(1.5)),
                    _buildInfoRow(Icons.location_on, '장소', '${event['venue']}\n${event['location']}'),
                    SizedBox(height: Responsive.hp(1.5)),
                    _buildInfoRow(Icons.confirmation_number, '티켓 가격', '￦${_formatNumber(event['price'] ?? 0)}'),

                    if (performers.isNotEmpty) ...[
                      SizedBox(height: Responsive.hp(3)),
                      Text(
                        '출연진',
                        style: TextStyle(
                          fontSize: Responsive.sp(16),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: Responsive.hp(1.5)),
                      Wrap(
                        spacing: Responsive.wp(3),
                        runSpacing: Responsive.hp(1),
                        children: performers.map((performer) {
                          final p = performer as Map<String, dynamic>;
                          return GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              context.go('/idols/${p['id']}');
                            },
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: Responsive.wp(8),
                                  backgroundImage: p['profileImage'] != null
                                      ? CachedNetworkImageProvider(p['profileImage'])
                                      : null,
                                  backgroundColor: color.withValues(alpha: 0.2),
                                  child: p['profileImage'] == null
                                      ? Icon(Icons.person, size: Responsive.sp(24), color: color)
                                      : null,
                                ),
                                SizedBox(height: Responsive.hp(0.5)),
                                Text(
                                  p['name'] ?? '',
                                  style: TextStyle(
                                    fontSize: Responsive.sp(12),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],

                    SizedBox(height: Responsive.hp(4)),

                    // Action Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('티켓 예매 기능은 준비 중입니다')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          padding: EdgeInsets.symmetric(vertical: Responsive.hp(2)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          '티켓 예매하기',
                          style: TextStyle(
                            fontSize: Responsive.sp(16),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: Responsive.sp(20), color: AppColors.textSecondary),
        SizedBox(width: Responsive.wp(3)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: Responsive.sp(12),
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: Responsive.hp(0.3)),
            Text(
              value,
              style: TextStyle(
                fontSize: Responsive.sp(15),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getCategoryName(String? category) {
    final names = {
      'LIVE': '라이브',
      'CONCERT': '콘서트',
      'FAN_MEETING': '팬미팅',
      'BIRTHDAY': '생일파티',
      'SPECIAL': '스페셜',
    };
    return names[category] ?? '이벤트';
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    final parts = dateStr.split('-');
    if (parts.length != 3) return dateStr;
    return '${parts[0]}년 ${int.parse(parts[1])}월 ${int.parse(parts[2])}일';
  }
}

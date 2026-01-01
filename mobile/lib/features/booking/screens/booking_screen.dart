import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/widgets/custom_button.dart';

class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({super.key});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? _selectedCafe;
  String? _selectedTimeSlot;
  int _numberOfGuests = 1;
  bool _isLoading = false;

  final _cafes = [
    {'name': '사쿠라 메이드카페', 'address': '도쿄 아키하바라 전기가 1-2-3', 'rating': 4.8},
    {'name': '네코 메이드카페', 'address': '오사카 닛폰바시 덴덴타운 4-5-6', 'rating': 4.6},
    {'name': '프린세스 코스프레 카페', 'address': '도쿄 이케부쿠로 선샤인 7-8-9', 'rating': 4.9},
  ];

  final _timeSlots = [
    '11:00',
    '11:30',
    '12:00',
    '12:30',
    '13:00',
    '13:30',
    '14:00',
    '14:30',
    '15:00',
    '15:30',
    '16:00',
    '16:30',
    '17:00',
    '17:30',
    '18:00',
    '18:30',
    '19:00',
    '19:30',
  ];

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('메이드카페 예약', style: TextStyle(fontSize: Responsive.sp(18))),
        actions: [
          TextButton(
            onPressed: () => _showMyBookings(context),
            child: Text('내 예약', style: TextStyle(fontSize: Responsive.sp(14))),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.wp(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cafe Selection
            Text(
              '카페 선택',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: Responsive.sp(16),
              ),
            ),
            SizedBox(height: Responsive.hp(1.5)),
            ...List.generate(
              _cafes.length,
              (index) => _buildCafeOption(_cafes[index]),
            ),
            SizedBox(height: Responsive.hp(3)),

            // Calendar
            Text(
              '날짜 선택',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: Responsive.sp(16),
              ),
            ),
            SizedBox(height: Responsive.hp(1.5)),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: EdgeInsets.all(Responsive.wp(2)),
                child: TableCalendar(
                  firstDay: DateTime.now(),
                  lastDay: DateTime.now().add(const Duration(days: 60)),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  calendarFormat: CalendarFormat.month,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  locale: 'ko_KR',
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(
                      fontSize: Responsive.sp(16),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  calendarStyle: CalendarStyle(
                    selectedDecoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    defaultTextStyle: TextStyle(fontSize: Responsive.sp(14)),
                    weekendTextStyle: TextStyle(
                      fontSize: Responsive.sp(14),
                      color: AppColors.error,
                    ),
                  ),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                      _selectedTimeSlot = null;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: Responsive.hp(3)),

            // Time Slots
            if (_selectedDay != null) ...[
              Text(
                '시간 선택',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: Responsive.sp(16),
                ),
              ),
              SizedBox(height: Responsive.hp(1.5)),
              Wrap(
                spacing: Responsive.wp(2),
                runSpacing: Responsive.hp(1),
                children: _timeSlots.map((time) {
                  // Simulate availability
                  final isAvailable = _timeSlots.indexOf(time) % 3 != 0;
                  final isSelected = _selectedTimeSlot == time;
                  return InkWell(
                    onTap: isAvailable
                        ? () => setState(() => _selectedTimeSlot = time)
                        : null,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: (Responsive.screenWidth - Responsive.wp(14)) / 4,
                      padding:
                          EdgeInsets.symmetric(vertical: Responsive.hp(1.5)),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : isAvailable
                                ? null
                                : AppColors.border,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : isAvailable
                                  ? AppColors.border
                                  : AppColors.border,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          time,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : isAvailable
                                    ? AppColors.textPrimary
                                    : AppColors.textHint,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            fontSize: Responsive.sp(13),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: Responsive.hp(3)),
            ],

            // Number of Guests
            Text(
              '인원 수',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: Responsive.sp(16),
              ),
            ),
            SizedBox(height: Responsive.hp(1.5)),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.wp(4),
                  vertical: Responsive.hp(1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: _numberOfGuests > 1
                          ? () => setState(() => _numberOfGuests--)
                          : null,
                      icon: Icon(Icons.remove_circle_outline,
                          size: Responsive.sp(28)),
                      color: _numberOfGuests > 1
                          ? AppColors.primary
                          : AppColors.textHint,
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: Responsive.wp(4)),
                      child: Text(
                        '$_numberOfGuests명',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: Responsive.sp(20),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _numberOfGuests < 10
                          ? () => setState(() => _numberOfGuests++)
                          : null,
                      icon: Icon(Icons.add_circle_outline,
                          size: Responsive.sp(28)),
                      color: _numberOfGuests < 10
                          ? AppColors.primary
                          : AppColors.textHint,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: Responsive.hp(4)),

            // Submit Button
            GradientButton(
              onPressed: _selectedCafe != null &&
                      _selectedDay != null &&
                      _selectedTimeSlot != null
                  ? () => _showConfirmation(context)
                  : null,
              isLoading: _isLoading,
              child: Text(
                '예약하기',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: Responsive.sp(16),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: Responsive.hp(4)),

            // Upcoming Bookings
            Text(
              '다가오는 예약',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: Responsive.sp(16),
              ),
            ),
            SizedBox(height: Responsive.hp(1.5)),
            _buildUpcomingBooking(context),
            SizedBox(height: Responsive.hp(4)),
          ],
        ),
      ),
    );
  }

  Widget _buildCafeOption(Map<String, dynamic> cafe) {
    final isSelected = _selectedCafe == cafe['name'];
    return Card(
      margin: EdgeInsets.only(bottom: Responsive.hp(1)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () => setState(() => _selectedCafe = cafe['name']),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(Responsive.wp(3)),
          child: Row(
            children: [
              Container(
                width: Responsive.wp(12),
                height: Responsive.wp(12),
                decoration: BoxDecoration(
                  color: AppColors.maidCategory.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.local_cafe,
                  color: AppColors.maidCategory,
                  size: Responsive.sp(24),
                ),
              ),
              SizedBox(width: Responsive.wp(3)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cafe['name'] as String,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: Responsive.sp(15),
                      ),
                    ),
                    SizedBox(height: Responsive.hp(0.5)),
                    Text(
                      cafe['address'] as String,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: Responsive.sp(12),
                      ),
                    ),
                    SizedBox(height: Responsive.hp(0.5)),
                    Row(
                      children: [
                        Icon(Icons.star,
                            color: AppColors.gold, size: Responsive.sp(14)),
                        SizedBox(width: Responsive.wp(1)),
                        Text(
                          '${cafe['rating']}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: Responsive.sp(12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isSelected ? AppColors.primary : AppColors.textHint,
                size: Responsive.sp(24),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingBooking(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(Responsive.wp(4)),
        child: Row(
          children: [
            Container(
              width: Responsive.wp(14),
              height: Responsive.wp(14),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '20',
                    style: TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                      fontSize: Responsive.sp(18),
                    ),
                  ),
                  Text(
                    '1월',
                    style: TextStyle(
                      color: AppColors.success,
                      fontSize: Responsive.sp(12),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: Responsive.wp(3)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '사쿠라 메이드카페',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: Responsive.sp(15),
                    ),
                  ),
                  SizedBox(height: Responsive.hp(0.5)),
                  Text(
                    '14:00 | 2명',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: Responsive.sp(13),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.wp(2),
                vertical: Responsive.hp(0.5),
              ),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '확정',
                style: TextStyle(
                  color: AppColors.success,
                  fontSize: Responsive.sp(12),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMyBookings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: Responsive.hp(60),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(Responsive.wp(4)),
              child: Column(
                children: [
                  Container(
                    width: Responsive.wp(10),
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(height: Responsive.hp(2)),
                  Text(
                    '내 예약 내역',
                    style: TextStyle(
                      fontSize: Responsive.sp(18),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: Responsive.wp(4)),
                children: [
                  _buildBookingHistoryItem(
                      '사쿠라 메이드카페', '2025.01.20', '14:00', 2, '확정'),
                  _buildBookingHistoryItem(
                      '네코 메이드카페', '2025.01.15', '15:30', 3, '완료'),
                  _buildBookingHistoryItem(
                      '프린세스 코스프레 카페', '2025.01.10', '13:00', 2, '완료'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingHistoryItem(
      String cafe, String date, String time, int guests, String status) {
    final isCompleted = status == '완료';
    return Card(
      margin: EdgeInsets.only(bottom: Responsive.hp(1.5)),
      child: Padding(
        padding: EdgeInsets.all(Responsive.wp(4)),
        child: Row(
          children: [
            Container(
              width: Responsive.wp(12),
              height: Responsive.wp(12),
              decoration: BoxDecoration(
                color:
                    (isCompleted ? AppColors.textSecondary : AppColors.success)
                        .withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.local_cafe,
                color:
                    isCompleted ? AppColors.textSecondary : AppColors.success,
                size: Responsive.sp(24),
              ),
            ),
            SizedBox(width: Responsive.wp(3)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cafe,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: Responsive.sp(14),
                    ),
                  ),
                  SizedBox(height: Responsive.hp(0.5)),
                  Text(
                    '$date $time | $guests명',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: Responsive.sp(12),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.wp(2),
                vertical: Responsive.hp(0.5),
              ),
              decoration: BoxDecoration(
                color:
                    (isCompleted ? AppColors.textSecondary : AppColors.success)
                        .withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color:
                      isCompleted ? AppColors.textSecondary : AppColors.success,
                  fontSize: Responsive.sp(11),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('예약 확인', style: TextStyle(fontSize: Responsive.sp(18))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildConfirmRow('카페', _selectedCafe!),
            _buildConfirmRow(
              '날짜',
              '${_selectedDay!.year}.${_selectedDay!.month.toString().padLeft(2, '0')}.${_selectedDay!.day.toString().padLeft(2, '0')}',
            ),
            _buildConfirmRow('시간', _selectedTimeSlot!),
            _buildConfirmRow('인원', '$_numberOfGuests명'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소', style: TextStyle(fontSize: Responsive.sp(14))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _handleBooking();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: Text('예약하기', style: TextStyle(fontSize: Responsive.sp(14))),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.hp(1)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: Responsive.sp(14),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: Responsive.sp(14),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleBooking() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);

    if (!mounted) return;
    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: Responsive.wp(20),
              height: Responsive.wp(20),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: Responsive.sp(50),
              ),
            ),
            SizedBox(height: Responsive.hp(3)),
            Text(
              '예약 완료!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: Responsive.sp(22),
              ),
            ),
            SizedBox(height: Responsive.hp(1)),
            Text(
              '예약 확인서가 이메일로 발송됩니다',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: Responsive.sp(14),
              ),
            ),
            SizedBox(height: Responsive.hp(3)),
            CustomButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _selectedCafe = null;
                  _selectedDay = null;
                  _selectedTimeSlot = null;
                  _numberOfGuests = 1;
                });
              },
              child: Text('확인', style: TextStyle(fontSize: Responsive.sp(16))),
            ),
          ],
        ),
      ),
    );
  }
}

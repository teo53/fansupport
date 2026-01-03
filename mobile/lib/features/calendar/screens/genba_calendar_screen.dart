import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 겐바 유형
enum GenbaType {
  live,       // 라이브/겐바
  ohirome,    // 오히로메 (데뷔/신규 멤버 공개)
  release,    // 리리이베 (릴리즈 이벤트)
  offkai,     // 오프회/특전회
  free,       // 무료 입장
}

/// 겐바 모델
class Genba {
  final String id;
  final String name;
  final String idolName;
  final String? idolImage;
  final GenbaType type;
  final DateTime date;
  final String openTime;
  final String startTime;
  final String venue;
  final int price;
  final bool isFree;
  final bool isScraped;
  final String? presentedBy;

  const Genba({
    required this.id,
    required this.name,
    required this.idolName,
    this.idolImage,
    required this.type,
    required this.date,
    required this.openTime,
    required this.startTime,
    required this.venue,
    required this.price,
    this.isFree = false,
    this.isScraped = false,
    this.presentedBy,
  });
}

/// Mock 겐바 데이터
final List<Genba> mockGenbas = [
  Genba(
    id: 'g1',
    name: 'MONQ 1st RELEASE LIVE',
    idolName: 'MONQ',
    type: GenbaType.release,
    date: DateTime(2025, 5, 23),
    openTime: '18:30',
    startTime: '19:00',
    venue: '레키댐, 위사리즈, 하츠코엔엔',
    price: 3000,
    presentedBy: 'PPI',
  ),
  Genba(
    id: 'g2',
    name: 'IDOLIGHT 정기 라이브',
    idolName: 'IDOLIGHT',
    type: GenbaType.live,
    date: DateTime(2025, 5, 25),
    openTime: '17:00',
    startTime: '17:30',
    venue: '아지토홀',
    price: 2500,
  ),
  Genba(
    id: 'g3',
    name: '하늘별 생일 파티',
    idolName: '하늘별',
    type: GenbaType.offkai,
    date: DateTime(2025, 5, 26),
    openTime: '18:20',
    startTime: '18:40',
    venue: '아로아로홀',
    price: 5000,
    presentedBy: 'PPI',
  ),
  Genba(
    id: 'g4',
    name: '신인 그룹 오히로메',
    idolName: 'NewStars',
    type: GenbaType.ohirome,
    date: DateTime(2025, 5, 28),
    openTime: '19:00',
    startTime: '19:30',
    venue: '신주쿠 BLAZE',
    price: 0,
    isFree: true,
  ),
  Genba(
    id: 'g5',
    name: '무료 버스킹',
    idolName: '루나',
    type: GenbaType.free,
    date: DateTime(2025, 5, 30),
    openTime: '14:00',
    startTime: '14:30',
    venue: '홍대 거리',
    price: 0,
    isFree: true,
  ),
];

class GenbaCalendarScreen extends ConsumerStatefulWidget {
  const GenbaCalendarScreen({super.key});

  @override
  ConsumerState<GenbaCalendarScreen> createState() =>
      _GenbaCalendarScreenState();
}

class _GenbaCalendarScreenState extends ConsumerState<GenbaCalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedMonth = DateTime.now();
  GenbaType? _selectedFilter;
  final Set<String> _scrapedGenbas = {};

  // 나의 오시 (즐겨찾기 아이돌)
  final List<String> _myOshi = ['MONQ', '하늘별', '루나'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('겐바 캘린더'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                _selectedDate = DateTime.now();
                _focusedMonth = DateTime.now();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: () => _showScrapedList(),
          ),
        ],
      ),
      body: Column(
        children: [
          // 월 선택 헤더
          _buildMonthHeader(),

          // 캘린더
          _buildCalendar(),

          // 필터
          _buildFilterChips(),

          // 일정 리스트
          Expanded(
            child: _buildGenbaList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showOshiFilter(),
        backgroundColor: Colors.pink,
        icon: const Icon(Icons.filter_alt),
        label: const Text('오시 필터'),
      ),
    );
  }

  Widget _buildMonthHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _focusedMonth = DateTime(
                  _focusedMonth.year,
                  _focusedMonth.month - 1,
                );
              });
            },
          ),
          Text(
            '${_focusedMonth.year}년 ${_focusedMonth.month}월',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _focusedMonth = DateTime(
                  _focusedMonth.year,
                  _focusedMonth.month + 1,
                );
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    final daysInMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month + 1,
      0,
    ).day;

    final firstDayOfMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month,
      1,
    );
    final startingWeekday = firstDayOfMonth.weekday % 7;

    // 일정 있는 날짜들
    final datesWithGenba = mockGenbas
        .where((g) =>
            g.date.year == _focusedMonth.year &&
            g.date.month == _focusedMonth.month)
        .map((g) => g.date.day)
        .toSet();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          // 요일 헤더
          Row(
            children: ['일', '월', '화', '수', '목', '금', '토'].map((day) {
              final isWeekend = day == '일' || day == '토';
              return Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      color: isWeekend ? Colors.red : Colors.grey[600],
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),

          // 날짜 그리드
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: startingWeekday + daysInMonth,
            itemBuilder: (context, index) {
              if (index < startingWeekday) {
                return const SizedBox.shrink();
              }

              final day = index - startingWeekday + 1;
              final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
              final isSelected = _selectedDate.year == date.year &&
                  _selectedDate.month == date.month &&
                  _selectedDate.day == date.day;
              final isToday = DateTime.now().year == date.year &&
                  DateTime.now().month == date.month &&
                  DateTime.now().day == date.day;
              final hasGenba = datesWithGenba.contains(day);
              final isWeekend = date.weekday == 7 || date.weekday == 6;

              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedDate = date);
                },
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.pink
                        : isToday
                            ? Colors.pink.shade50
                            : null,
                    borderRadius: BorderRadius.circular(8),
                    border: isToday && !isSelected
                        ? Border.all(color: Colors.pink, width: 1)
                        : null,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        '$day',
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : isWeekend
                                  ? (date.weekday == 7 ? Colors.red : Colors.blue)
                                  : Colors.black87,
                          fontWeight:
                              isToday || isSelected ? FontWeight.bold : null,
                        ),
                      ),
                      if (hasGenba)
                        Positioned(
                          bottom: 4,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : Colors.pink,
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

  Widget _buildFilterChips() {
    final filters = [
      (null, '전체', Icons.grid_view),
      (GenbaType.live, '라이브', Icons.music_note),
      (GenbaType.ohirome, '오히로메', Icons.celebration),
      (GenbaType.release, '리리이베', Icons.album),
      (GenbaType.offkai, '오프회', Icons.people),
      (GenbaType.free, '무료', Icons.money_off),
    ];

    return Container(
      height: 50,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter.$1;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    filter.$3,
                    size: 16,
                    color: isSelected ? Colors.white : Colors.grey[700],
                  ),
                  const SizedBox(width: 4),
                  Text(filter.$2),
                ],
              ),
              onSelected: (selected) {
                HapticFeedback.selectionClick();
                setState(() {
                  _selectedFilter = selected ? filter.$1 : null;
                });
              },
              selectedColor: Colors.pink,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontSize: 12,
              ),
              backgroundColor: Colors.grey[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGenbaList() {
    // 선택된 날짜 또는 전체 필터링
    var filteredGenbas = mockGenbas.where((g) {
      // 날짜 필터
      final matchesDate = g.date.year == _selectedDate.year &&
          g.date.month == _selectedDate.month &&
          g.date.day == _selectedDate.day;

      // 타입 필터
      final matchesType =
          _selectedFilter == null || g.type == _selectedFilter;

      return matchesDate && matchesType;
    }).toList();

    if (filteredGenbas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              '이 날은 예정된 겐바가 없어요',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedFilter = null;
                });
              },
              child: const Text('전체 일정 보기'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredGenbas.length,
      itemBuilder: (context, index) =>
          _buildGenbaCard(filteredGenbas[index]),
    );
  }

  Widget _buildGenbaCard(Genba genba) {
    final isScraped = _scrapedGenbas.contains(genba.id);
    final typeInfo = _getTypeInfo(genba.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 정보
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // 타입 뱃지
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: typeInfo.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(typeInfo.icon, size: 12, color: typeInfo.color),
                          const SizedBox(width: 4),
                          Text(
                            typeInfo.label,
                            style: TextStyle(
                              fontSize: 11,
                              color: typeInfo.color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    if (genba.presentedBy != null)
                      Text(
                        'Presented by ${genba.presentedBy}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[500],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // 겐바 이름
                Text(
                  genba.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),

                // 아이돌 이름
                Text(
                  genba.idolName,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 12),

                // 시간/장소 정보
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      'OPEN ${genba.openTime} / START ${genba.startTime}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        genba.venue,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 하단 버튼 영역
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                // 가격
                genba.isFree
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '무료 입장',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      )
                    : Text(
                        '₩${_formatCurrency(genba.price)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                const Spacer(),

                // 스크랩 버튼
                IconButton(
                  icon: Icon(
                    isScraped ? Icons.bookmark : Icons.bookmark_border,
                    color: isScraped ? Colors.pink : Colors.grey,
                  ),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      if (isScraped) {
                        _scrapedGenbas.remove(genba.id);
                      } else {
                        _scrapedGenbas.add(genba.id);
                      }
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isScraped ? '스크랩 취소됨' : '스크랩 완료!',
                        ),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),

                // 예매 버튼
                ElevatedButton(
                  onPressed: () {
                    // TODO: Navigate to booking
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('예매 페이지로 이동')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('예매하기'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ({String label, IconData icon, Color color}) _getTypeInfo(GenbaType type) {
    switch (type) {
      case GenbaType.live:
        return (label: '라이브', icon: Icons.music_note, color: Colors.blue);
      case GenbaType.ohirome:
        return (label: '오히로메', icon: Icons.celebration, color: Colors.orange);
      case GenbaType.release:
        return (label: '리리이베', icon: Icons.album, color: Colors.purple);
      case GenbaType.offkai:
        return (label: '오프회', icon: Icons.people, color: Colors.pink);
      case GenbaType.free:
        return (label: '무료', icon: Icons.money_off, color: Colors.green);
    }
  }

  void _showOshiFilter() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '나의 오시 필터',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '등록된 오시',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _myOshi.map((oshi) {
                      return Chip(
                        label: Text(oshi),
                        avatar: CircleAvatar(
                          backgroundColor: Colors.pink.shade100,
                          child: Text(
                            oshi[0],
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.pink,
                            ),
                          ),
                        ),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () {
                          // Remove oshi
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Add oshi
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('오시 추가하기'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showScrapedList() {
    final scrapedList = mockGenbas.where((g) => _scrapedGenbas.contains(g.id)).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '스크랩한 겐바',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: scrapedList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.bookmark_border,
                              size: 64,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '스크랩한 겐바가 없어요',
                              style: TextStyle(
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: scrapedList.length,
                        itemBuilder: (context, index) =>
                            _buildGenbaCard(scrapedList[index]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}

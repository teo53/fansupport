import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 광고 섹션 타입
enum AdSectionType {
  mainPoster,      // 메인 포스터 섹션
  homeBanner,      // 홈/캘린더 탭 배너 섹션
  idolTab,         // 아이돌 탭 섹션
  genbaDetail,     // 겐바 상세페이지 배너 섹션
}

/// 광고 섹션 정보
class AdSection {
  final AdSectionType type;
  final String name;
  final String description;
  final List<String> features;
  final IconData icon;
  final Color color;

  const AdSection({
    required this.type,
    required this.name,
    required this.description,
    required this.features,
    required this.icon,
    required this.color,
  });
}

/// 광고 섹션 목록 (아지토 기준)
final List<AdSection> adSections = [
  AdSection(
    type: AdSectionType.mainPoster,
    name: '메인 포스터',
    description: '홈탭 메인 포스터 자리\n가장 중요하고 눈에 띄는 위치',
    features: [
      '홈탭 최상단 노출',
      '클릭 시 예매 페이지 이동',
      '최신 오픈 겐바 상단 고정',
    ],
    icon: Icons.photo_size_select_actual_rounded,
    color: Colors.pink,
  ),
  AdSection(
    type: AdSectionType.homeBanner,
    name: '홈/캘린더 배너',
    description: '홈탭 하단 + 캘린더탭 상단 배너',
    features: [
      '영상/음원/이미지 커스텀 가능',
      '클릭 시 이동 페이지 자유 설정',
      '요청 시 배너 무료 제작',
    ],
    icon: Icons.view_carousel_rounded,
    color: Colors.blue,
  ),
  AdSection(
    type: AdSectionType.idolTab,
    name: '아이돌 탭',
    description: '아이돌탭 상단 커버 영역',
    features: [
      '아이돌탭 상단 커버 제공',
      '"오시 추가" 유도 컴포넌트',
      '클릭 시 이동 페이지 자유 설정',
    ],
    icon: Icons.people_rounded,
    color: Colors.purple,
  ),
  AdSection(
    type: AdSectionType.genbaDetail,
    name: '겐바 상세페이지',
    description: '겐바 상세페이지 내 배너',
    features: [
      '겐바 상세 내 배너 노출',
      '클릭 시 이동 페이지 자유 설정',
      '관련 겐바 타겟팅 가능',
    ],
    icon: Icons.article_rounded,
    color: Colors.teal,
  ),
];

/// 기간별 가격 계산 (일당)
int getPricePerDay(int days) {
  if (days == 1) return 30000;
  if (days >= 2 && days <= 6) return 25000;
  if (days >= 7 && days <= 13) return 20000;
  return 15000; // 14일 이상
}

/// 총 가격 계산
int calculateTotalPrice(int days, int sectionCount, {bool applyFullDiscount = false}) {
  int pricePerDay = getPricePerDay(days);
  int total = pricePerDay * days * sectionCount;

  // 풀 섹션 (4개) 할인 15%
  if (applyFullDiscount && sectionCount == 4) {
    total = (total * 0.85).round();
  }

  return total;
}

class AdvertisingPurchaseScreen extends ConsumerStatefulWidget {
  const AdvertisingPurchaseScreen({super.key});

  @override
  ConsumerState<AdvertisingPurchaseScreen> createState() =>
      _AdvertisingPurchaseScreenState();
}

class _AdvertisingPurchaseScreenState
    extends ConsumerState<AdvertisingPurchaseScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 선택된 섹션들
  final Set<AdSectionType> _selectedSections = {};

  // 홍보 기간
  int _promotionDays = 7;

  // 신청자 유형
  String _applicantType = '팬';

  // 신청자 이름 (Presented by OOO)
  final TextEditingController _applicantNameController = TextEditingController();

  // 겐바 정보
  final TextEditingController _genbaNameController = TextEditingController();
  final TextEditingController _genbeDateController = TextEditingController();
  final TextEditingController _linkUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _applicantNameController.dispose();
    _genbaNameController.dispose();
    _genbeDateController.dispose();
    _linkUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('광고 홍보'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.pink,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.pink,
          tabs: const [
            Tab(text: '홍보 신청', icon: Icon(Icons.campaign)),
            Tab(text: '내 광고', icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildApplicationTab(),
          _buildMyAdsTab(),
        ],
      ),
    );
  }

  Widget _buildApplicationTab() {
    final totalPrice = calculateTotalPrice(
      _promotionDays,
      _selectedSections.length,
      applyFullDiscount: _selectedSections.length == 4,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 안내 배너
          _buildInfoBanner(),
          const SizedBox(height: 20),

          // 가격표
          _buildPricingTable(),
          const SizedBox(height: 20),

          // 섹션 선택
          _buildSectionTitle('광고 섹션 선택'),
          const SizedBox(height: 12),
          ...adSections.map((section) => _buildSectionCard(section)),
          const SizedBox(height: 20),

          // 기간 선택
          _buildSectionTitle('홍보 기간'),
          const SizedBox(height: 12),
          _buildDurationSelector(),
          const SizedBox(height: 20),

          // 신청자 정보
          _buildSectionTitle('신청자 정보'),
          const SizedBox(height: 12),
          _buildApplicantInfo(),
          const SizedBox(height: 20),

          // 겐바/아이돌 정보
          _buildSectionTitle('홍보 대상'),
          const SizedBox(height: 12),
          _buildGenbaInfo(),
          const SizedBox(height: 20),

          // 노출 순서 안내
          _buildExposurePriorityInfo(),
          const SizedBox(height: 20),

          // 예상 금액
          _buildTotalPriceCard(totalPrice),
          const SizedBox(height: 16),

          // 신청 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedSections.isNotEmpty
                  ? () => _showConfirmationDialog(totalPrice)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledBackgroundColor: Colors.grey[300],
              ),
              child: Text(
                _selectedSections.isEmpty
                    ? '섹션을 선택해주세요'
                    : '홍보 신청하기',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.pink.shade400, Colors.purple.shade400],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity( 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.campaign, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  '겐바/아이돌 홍보',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('샘탄/오히로메/리리이베/일반 모두 신청 가능'),
          _buildInfoRow('소속사/팀/팬 누구나 홍보 신청 가능'),
          _buildInfoRow('"Presented by OOO" 형태로 신청자 표시'),
          _buildInfoRow('4개 섹션 동시 진행 시 15% 할인'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.white.withOpacity( 0.8), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withOpacity( 0.9),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingTable() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity( 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.payments, color: Colors.pink),
              SizedBox(width: 8),
              Text(
                '가격표 (섹션당)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Table(
            border: TableBorder.all(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            children: [
              TableRow(
                decoration: BoxDecoration(
                  color: Colors.pink.shade50,
                ),
                children: const [
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('기간', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('일당 가격', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              _buildPriceRow('1일', '30,000원/일'),
              _buildPriceRow('2일 ~ 6일', '25,000원/일'),
              _buildPriceRow('7일 ~ 13일', '20,000원/일'),
              _buildPriceRow('14일 ~', '15,000원/일'),
            ],
          ),
        ],
      ),
    );
  }

  TableRow _buildPriceRow(String duration, String price) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(duration),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            price,
            style: const TextStyle(
              color: Colors.pink,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSectionCard(AdSection section) {
    final isSelected = _selectedSections.contains(section.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? section.color : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity( 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            if (isSelected) {
              _selectedSections.remove(section.type);
            } else {
              _selectedSections.add(section.type);
            }
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: section.color.withOpacity( 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(section.icon, color: section.color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      section.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: section.features.map((f) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          f,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[700],
                          ),
                        ),
                      )).toList(),
                    ),
                  ],
                ),
              ),
              Checkbox(
                value: isSelected,
                onChanged: (value) {
                  HapticFeedback.selectionClick();
                  setState(() {
                    if (value == true) {
                      _selectedSections.add(section.type);
                    } else {
                      _selectedSections.remove(section.type);
                    }
                  });
                },
                activeColor: section.color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDurationSelector() {
    final durations = [1, 3, 7, 14, 30];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity( 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: durations.map((days) {
              final isSelected = _promotionDays == days;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _promotionDays = days);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.pink : Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$days일',
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[700],
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '일당 가격',
                style: TextStyle(color: Colors.grey[600]),
              ),
              Text(
                '${_formatCurrency(getPricePerDay(_promotionDays))}원/일',
                style: const TextStyle(
                  color: Colors.pink,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildApplicantInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity( 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 신청자 유형
          const Text(
            '신청자 유형',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Row(
            children: ['소속사', '팀', '팬'].map((type) {
              final isSelected = _applicantType == type;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(type),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _applicantType = type);
                    }
                  },
                  selectedColor: Colors.pink,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // 신청자 이름
          const Text(
            '표시될 이름 (Presented by)',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _applicantNameController,
            decoration: InputDecoration(
              hintText: '예: 하늘별 팬클럽',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenbaInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity( 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _genbaNameController,
            decoration: InputDecoration(
              labelText: '겐바/아이돌 이름',
              hintText: '예: MONQ 1st RELEASE LIVE',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _genbeDateController,
            decoration: InputDecoration(
              labelText: '겐바 날짜',
              hintText: '예: 2025.05.23',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: const Icon(Icons.calendar_today),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _linkUrlController,
            decoration: InputDecoration(
              labelText: '클릭 시 이동할 링크 (선택)',
              hintText: '예: 예매 페이지 URL',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: const Icon(Icons.link),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExposurePriorityInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.amber.shade700),
              const SizedBox(width: 8),
              Text(
                '노출 순서 안내',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildPriorityRow('1순위', '섹션의 수'),
          _buildPriorityRow('2순위', '홍보 기간'),
          _buildPriorityRow('3순위', '신청 날짜'),
          const SizedBox(height: 8),
          Text(
            '→ 동시에 쓰는 섹션의 수가 같다면, 홍보 기간이 길수록 앞에 노출돼요',
            style: TextStyle(
              fontSize: 12,
              color: Colors.amber.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityRow(String rank, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              rank,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.amber.shade800,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(description),
        ],
      ),
    );
  }

  Widget _buildTotalPriceCard(int totalPrice) {
    final isFullPackage = _selectedSections.length == 4;
    final originalPrice = isFullPackage
        ? (totalPrice / 0.85).round()
        : totalPrice;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.pink.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity( 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('선택 섹션'),
              Text(
                '${_selectedSections.length}개',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('홍보 기간'),
              Text(
                '$_promotionDays일',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          if (isFullPackage) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '풀 섹션 할인',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const Text(
                  '-15%',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '예상 결제 금액',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (isFullPackage)
                    Text(
                      '${_formatCurrency(originalPrice)}원',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  Text(
                    '${_formatCurrency(totalPrice)}원',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMyAdsTab() {
    // Mock data for my ads
    final myAds = [
      {
        'name': 'MONQ 1st RELEASE',
        'sections': ['메인 포스터', '홈/캘린더 배너'],
        'period': '2025.05.20 ~ 2025.05.27',
        'status': 'active',
        'presentedBy': '모옹 팬클럽',
      },
      {
        'name': '하늘별 생일 이벤트',
        'sections': ['아이돌 탭'],
        'period': '2025.04.15 ~ 2025.04.22',
        'status': 'completed',
        'presentedBy': '하늘별 응원회',
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity( 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn('진행 중', '1', Colors.green),
              Container(width: 1, height: 40, color: Colors.grey[200]),
              _buildStatColumn('완료', '1', Colors.grey),
              Container(width: 1, height: 40, color: Colors.grey[200]),
              _buildStatColumn('총 지출', '320K', Colors.pink),
            ],
          ),
        ),
        const SizedBox(height: 20),

        const Text(
          '내 광고 내역',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        ...myAds.map((ad) => _buildMyAdCard(ad)),
      ],
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildMyAdCard(Map<String, dynamic> ad) {
    final isActive = ad['status'] == 'active';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity( 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  ad['name'] as String,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isActive ? Colors.green.shade50 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isActive ? '진행 중' : '완료',
                  style: TextStyle(
                    color: isActive ? Colors.green : Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Presented by ${ad['presentedBy']}',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: (ad['sections'] as List<String>).map((section) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.pink.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  section,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.pink.shade700,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.date_range, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(
                ad['period'] as String,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog(int totalPrice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('홍보 신청 확인'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('선택 섹션: ${_selectedSections.length}개'),
            Text('홍보 기간: $_promotionDays일'),
            if (_applicantNameController.text.isNotEmpty)
              Text('Presented by: ${_applicantNameController.text}'),
            const Divider(),
            Text(
              '결제 금액: ${_formatCurrency(totalPrice)}원',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.pink,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessDialog();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink,
              foregroundColor: Colors.white,
            ),
            child: const Text('신청하기'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: Colors.green.shade400,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '신청 완료!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '검토 후 24시간 내에 광고가 게시됩니다.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _tabController.animateTo(1);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                foregroundColor: Colors.white,
              ),
              child: const Text('내 광고 보기'),
            ),
          ),
        ],
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

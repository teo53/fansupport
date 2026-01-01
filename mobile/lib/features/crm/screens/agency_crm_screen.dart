import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/design_system.dart';
import '../../../shared/widgets/contribution_chart.dart';

/// 소속사 CRM 대시보드
/// 입금, 출금, 수익 관리 기능 제공
class AgencyCrmScreen extends ConsumerStatefulWidget {
  const AgencyCrmScreen({super.key});

  @override
  ConsumerState<AgencyCrmScreen> createState() => _AgencyCrmScreenState();
}

class _AgencyCrmScreenState extends ConsumerState<AgencyCrmScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(
              child: _buildHeader(),
            ),
            SliverToBoxAdapter(
              child: _buildRevenueOverview(),
            ),
            SliverToBoxAdapter(
              child: _buildQuickActions(),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(
                tabController: _tabController,
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(),
              _buildDepositsTab(),
              _buildWithdrawalsTab(),
              _buildIdolsTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(DS.screenPadding),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: DS.borderRadiusMd,
                boxShadow: AppColors.cardShadow(opacity: 0.06),
              ),
              child: const Icon(Icons.arrow_back_rounded, size: 22),
            ),
          ),
          const SizedBox(width: DS.space4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '소속사 관리',
                  style: DS.heading3,
                ),
                Text(
                  'CRM 대시보드',
                  style: DS.textSm(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          _buildHeaderButton(
            icon: Icons.settings_outlined,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
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
        child: Icon(icon, size: 22, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildRevenueOverview() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: DS.screenPadding),
      padding: const EdgeInsets.all(DS.space5),
      decoration: BoxDecoration(
        gradient: AppColors.premiumGradient,
        borderRadius: DS.borderRadiusXl,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '이번 달 수익',
                    style: DS.textSm(color: Colors.white.withValues(alpha: 0.8)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₩${_formatCurrency(15680000)}',
                    style: DS.text4xl(color: Colors.white),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DS.space3,
                  vertical: DS.space1,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.2),
                  borderRadius: DS.borderRadiusXs,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.trending_up_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '+23.5%',
                      style: DS.textSm(
                        color: Colors.white,
                        weight: DS.weightBold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: DS.space5),
          Row(
            children: [
              Expanded(
                child: _buildRevenueStat(
                  label: '총 입금',
                  value: '₩${_formatCurrency(18500000)}',
                  icon: Icons.arrow_downward_rounded,
                  color: AppColors.success,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              Expanded(
                child: _buildRevenueStat(
                  label: '총 출금',
                  value: '₩${_formatCurrency(2820000)}',
                  icon: Icons.arrow_upward_rounded,
                  color: AppColors.error,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              Expanded(
                child: _buildRevenueStat(
                  label: '정산 대기',
                  value: '₩${_formatCurrency(4250000)}',
                  icon: Icons.schedule_rounded,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueStat({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 18),
        const SizedBox(height: 4),
        Text(
          label,
          style: DS.textXs(color: Colors.white.withValues(alpha: 0.7)),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: DS.textSm(
            color: Colors.white,
            weight: DS.weightBold,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.all(DS.screenPadding),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              icon: Icons.add_rounded,
              label: '입금 요청',
              color: AppColors.success,
              onTap: () => _showDepositDialog(),
            ),
          ),
          const SizedBox(width: DS.space3),
          Expanded(
            child: _buildActionButton(
              icon: Icons.account_balance_wallet_outlined,
              label: '출금 신청',
              color: AppColors.primary,
              onTap: () => _showWithdrawalDialog(),
            ),
          ),
          const SizedBox(width: DS.space3),
          Expanded(
            child: _buildActionButton(
              icon: Icons.receipt_long_rounded,
              label: '정산 내역',
              color: AppColors.secondary,
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: DS.space4,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: DS.borderRadiusMd,
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: DS.space2),
            Text(
              label,
              style: DS.textSm(
                color: color,
                weight: DS.weightSemibold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DS.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('수익 분석'),
          const SizedBox(height: DS.space4),
          _buildRevenueChart(),
          const SizedBox(height: DS.space6),
          _buildSectionTitle('아이돌별 수익'),
          const SizedBox(height: DS.space4),
          _buildIdolRevenueList(),
          const SizedBox(height: DS.space6),
          _buildSectionTitle('최근 거래'),
          const SizedBox(height: DS.space4),
          _buildRecentTransactions(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: DS.heading4);
  }

  Widget _buildRevenueChart() {
    // Mock 수익 데이터
    final revenueByType = [
      ContributorData(
        id: '1',
        name: '후원',
        profileImage: '',
        percentage: 45.2,
        rank: 1,
      ),
      ContributorData(
        id: '2',
        name: '펀딩',
        profileImage: '',
        percentage: 28.7,
        rank: 2,
      ),
      ContributorData(
        id: '3',
        name: '구독',
        profileImage: '',
        percentage: 18.3,
        rank: 3,
      ),
      ContributorData(
        id: '4',
        name: '데이트권',
        profileImage: '',
        percentage: 7.8,
        rank: 4,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(DS.space5),
      decoration: DS.cardDecoration(),
      child: Column(
        children: [
          ContributionChart(
            contributors: revenueByType,
            size: 160,
            strokeWidth: 20,
            showLegend: true,
          ),
        ],
      ),
    );
  }

  Widget _buildIdolRevenueList() {
    final idolRevenues = [
      {'name': '하늘별', 'revenue': 6500000, 'growth': 12.5},
      {'name': '루나', 'revenue': 4800000, 'growth': 8.2},
      {'name': '유키', 'revenue': 3200000, 'growth': -2.1},
      {'name': '사쿠라', 'revenue': 1180000, 'growth': 25.8},
    ];

    return Container(
      decoration: DS.cardDecoration(),
      child: Column(
        children: idolRevenues.asMap().entries.map((entry) {
          final index = entry.key;
          final idol = entry.value;
          final isLast = index == idolRevenues.length - 1;

          return Container(
            padding: const EdgeInsets.all(DS.space4),
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : Border(
                      bottom: BorderSide(color: AppColors.divider),
                    ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: DS.borderRadiusSm,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: DS.textBase(
                        color: AppColors.primary,
                        weight: DS.weightBold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: DS.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        idol['name'] as String,
                        style: DS.textBase(weight: DS.weightSemibold),
                      ),
                      Text(
                        '₩${_formatCurrency(idol['revenue'] as int)}',
                        style: DS.textSm(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: (idol['growth'] as double) >= 0
                        ? AppColors.success.withValues(alpha: 0.1)
                        : AppColors.error.withValues(alpha: 0.1),
                    borderRadius: DS.borderRadiusXs,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        (idol['growth'] as double) >= 0
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded,
                        size: 14,
                        color: (idol['growth'] as double) >= 0
                            ? AppColors.success
                            : AppColors.error,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${(idol['growth'] as double).abs()}%',
                        style: DS.textXs(
                          color: (idol['growth'] as double) >= 0
                              ? AppColors.success
                              : AppColors.error,
                          weight: DS.weightSemibold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecentTransactions() {
    final transactions = [
      {
        'type': 'deposit',
        'title': '후원 수익',
        'idol': '하늘별',
        'amount': 150000,
        'date': '오늘 14:30'
      },
      {
        'type': 'deposit',
        'title': '펀딩 달성',
        'idol': '루나',
        'amount': 850000,
        'date': '오늘 11:20'
      },
      {
        'type': 'withdrawal',
        'title': '정산 출금',
        'idol': '-',
        'amount': 2000000,
        'date': '어제'
      },
      {
        'type': 'deposit',
        'title': '구독료',
        'idol': '하늘별',
        'amount': 50000,
        'date': '어제'
      },
    ];

    return Container(
      decoration: DS.cardDecoration(),
      child: Column(
        children: transactions.asMap().entries.map((entry) {
          final index = entry.key;
          final tx = entry.value;
          final isLast = index == transactions.length - 1;
          final isDeposit = tx['type'] == 'deposit';

          return Container(
            padding: const EdgeInsets.all(DS.space4),
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : Border(
                      bottom: BorderSide(color: AppColors.divider),
                    ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDeposit
                        ? AppColors.success.withValues(alpha: 0.1)
                        : AppColors.error.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isDeposit
                        ? Icons.arrow_downward_rounded
                        : Icons.arrow_upward_rounded,
                    color: isDeposit ? AppColors.success : AppColors.error,
                    size: 20,
                  ),
                ),
                const SizedBox(width: DS.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx['title'] as String,
                        style: DS.textBase(weight: DS.weightSemibold),
                      ),
                      Row(
                        children: [
                          Text(
                            tx['idol'] as String,
                            style: DS.textXs(color: AppColors.textSecondary),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            tx['date'] as String,
                            style: DS.textXs(color: AppColors.textTertiary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  '${isDeposit ? '+' : '-'}₩${_formatCurrency(tx['amount'] as int)}',
                  style: DS.textBase(
                    color: isDeposit ? AppColors.success : AppColors.error,
                    weight: DS.weightBold,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDepositsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DS.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDepositSummary(),
          const SizedBox(height: DS.space5),
          _buildSectionTitle('입금 내역'),
          const SizedBox(height: DS.space4),
          _buildDepositHistory(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildDepositSummary() {
    return Container(
      padding: const EdgeInsets.all(DS.space5),
      decoration: DS.cardDecoration(),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '이번 달 입금',
                    style: DS.textSm(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₩${_formatCurrency(18500000)}',
                    style: DS.heading2.copyWith(color: AppColors.success),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(DS.space3),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_downward_rounded,
                  color: AppColors.success,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: DS.space5),
          Row(
            children: [
              _buildDepositStat('후원', '₩8,350,000', '45%'),
              _buildDepositStat('펀딩', '₩5,310,000', '29%'),
              _buildDepositStat('기타', '₩4,840,000', '26%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDepositStat(String label, String amount, String percentage) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: DS.textXs(color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(
            amount,
            style: DS.textSm(weight: DS.weightBold),
          ),
          Text(
            percentage,
            style: DS.textXs(color: AppColors.success),
          ),
        ],
      ),
    );
  }

  Widget _buildDepositHistory() {
    // 입금 히스토리 리스트
    return Container(
      decoration: DS.cardDecoration(),
      child: Column(
        children: List.generate(5, (index) {
          return Container(
            padding: const EdgeInsets.all(DS.space4),
            decoration: BoxDecoration(
              border: index < 4
                  ? Border(bottom: BorderSide(color: AppColors.divider))
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_downward_rounded,
                    color: AppColors.success,
                    size: 18,
                  ),
                ),
                const SizedBox(width: DS.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        index % 2 == 0 ? '후원 수익' : '펀딩 달성',
                        style: DS.textBase(weight: DS.weightSemibold),
                      ),
                      Text(
                        '하늘별 • ${5 - index}시간 전',
                        style: DS.textXs(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Text(
                  '+₩${_formatCurrency(150000 * (index + 1))}',
                  style: DS.textBase(
                    color: AppColors.success,
                    weight: DS.weightBold,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildWithdrawalsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DS.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWithdrawalSummary(),
          const SizedBox(height: DS.space5),
          _buildSectionTitle('출금 가능 금액'),
          const SizedBox(height: DS.space4),
          _buildWithdrawableBalance(),
          const SizedBox(height: DS.space5),
          _buildSectionTitle('출금 내역'),
          const SizedBox(height: DS.space4),
          _buildWithdrawalHistory(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildWithdrawalSummary() {
    return Container(
      padding: const EdgeInsets.all(DS.space5),
      decoration: DS.cardDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '이번 달 출금',
                style: DS.textSm(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                '₩${_formatCurrency(2820000)}',
                style: DS.heading2.copyWith(color: AppColors.primary),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(DS.space3),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_upward_rounded,
              color: AppColors.primary,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawableBalance() {
    return Container(
      padding: const EdgeInsets.all(DS.space5),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: DS.borderRadiusLg,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '출금 가능 잔액',
                    style: DS.textSm(color: Colors.white.withValues(alpha: 0.8)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₩${_formatCurrency(12430000)}',
                    style: DS.heading2.copyWith(color: Colors.white),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () => _showWithdrawalDialog(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: DS.space5,
                    vertical: DS.space3,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: DS.borderRadiusSm,
                  ),
                ),
                child: Text(
                  '출금 신청',
                  style: DS.textBase(
                    color: AppColors.primary,
                    weight: DS.weightBold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DS.space4),
          Container(
            padding: const EdgeInsets.all(DS.space3),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: DS.borderRadiusSm,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '출금은 영업일 기준 1-2일 내 처리됩니다',
                    style: DS.textXs(color: Colors.white.withValues(alpha: 0.9)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawalHistory() {
    return Container(
      decoration: DS.cardDecoration(),
      child: Column(
        children: List.generate(3, (index) {
          final statuses = ['완료', '처리중', '완료'];
          final statusColors = [AppColors.success, AppColors.warning, AppColors.success];

          return Container(
            padding: const EdgeInsets.all(DS.space4),
            decoration: BoxDecoration(
              border: index < 2
                  ? Border(bottom: BorderSide(color: AppColors.divider))
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_upward_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: DS.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '정산 출금',
                        style: DS.textBase(weight: DS.weightSemibold),
                      ),
                      Text(
                        '2025.01.${15 - index * 5}',
                        style: DS.textXs(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '-₩${_formatCurrency(1000000 * (index + 1))}',
                      style: DS.textBase(weight: DS.weightBold),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusColors[index].withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        statuses[index],
                        style: DS.textXs(
                          color: statusColors[index],
                          weight: DS.weightMedium,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildIdolsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DS.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIdolStats(),
          const SizedBox(height: DS.space5),
          _buildSectionTitle('소속 아이돌'),
          const SizedBox(height: DS.space4),
          _buildManagedIdols(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildIdolStats() {
    return Container(
      padding: const EdgeInsets.all(DS.space5),
      decoration: DS.cardDecoration(),
      child: Row(
        children: [
          Expanded(
            child: _buildIdolStatItem(
              icon: Icons.people_rounded,
              value: '4',
              label: '소속 아이돌',
              color: AppColors.primary,
            ),
          ),
          Container(
            width: 1,
            height: 50,
            color: AppColors.divider,
          ),
          Expanded(
            child: _buildIdolStatItem(
              icon: Icons.favorite_rounded,
              value: '12.5K',
              label: '총 팬 수',
              color: AppColors.secondary,
            ),
          ),
          Container(
            width: 1,
            height: 50,
            color: AppColors.divider,
          ),
          Expanded(
            child: _buildIdolStatItem(
              icon: Icons.trending_up_rounded,
              value: '15.6M',
              label: '누적 수익',
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdolStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(value, style: DS.textXl(weight: DS.weightBold)),
        Text(label, style: DS.textXs(color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildManagedIdols() {
    final idols = [
      {'name': '하늘별', 'fans': 5200, 'revenue': 6500000, 'active': true},
      {'name': '루나', 'fans': 4100, 'revenue': 4800000, 'active': true},
      {'name': '유키', 'fans': 2300, 'revenue': 3200000, 'active': true},
      {'name': '사쿠라', 'fans': 890, 'revenue': 1180000, 'active': false},
    ];

    return Column(
      children: idols.map((idol) {
        return Container(
          margin: const EdgeInsets.only(bottom: DS.space3),
          padding: const EdgeInsets.all(DS.space4),
          decoration: DS.cardDecoration(),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primarySoft,
                child: Text(
                  (idol['name'] as String).substring(0, 1),
                  style: DS.textLg(
                    color: AppColors.primary,
                    weight: DS.weightBold,
                  ),
                ),
              ),
              const SizedBox(width: DS.space4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          idol['name'] as String,
                          style: DS.textLg(weight: DS.weightBold),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: (idol['active'] as bool)
                                ? AppColors.success.withValues(alpha: 0.1)
                                : AppColors.textTertiary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            (idol['active'] as bool) ? '활동중' : '휴식중',
                            style: DS.textXs(
                              color: (idol['active'] as bool)
                                  ? AppColors.success
                                  : AppColors.textTertiary,
                              weight: DS.weightMedium,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.people_outline_rounded,
                          size: 14,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${_formatCurrency(idol['fans'] as int)}명',
                          style: DS.textSm(color: AppColors.textSecondary),
                        ),
                        const SizedBox(width: DS.space4),
                        const Icon(
                          Icons.monetization_on_outlined,
                          size: 14,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '₩${_formatCurrency(idol['revenue'] as int)}',
                          style: DS.textSm(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _showDepositDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(DS.space5),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: DS.space5),
            Text('입금 요청', style: DS.heading3),
            const SizedBox(height: DS.space2),
            Text(
              '유저들의 후원과 펀딩 금액이 자동으로 입금됩니다',
              style: DS.textSm(color: AppColors.textSecondary),
            ),
            const SizedBox(height: DS.space5),
            Container(
              padding: const EdgeInsets.all(DS.space4),
              decoration: BoxDecoration(
                color: AppColors.backgroundAlt,
                borderRadius: DS.borderRadiusMd,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: DS.space3),
                  Expanded(
                    child: Text(
                      '입금은 실시간으로 반영되며, 대시보드에서 확인할 수 있습니다.',
                      style: DS.textSm(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom + DS.space5),
          ],
        ),
      ),
    );
  }

  void _showWithdrawalDialog() {
    final amountController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(DS.space5),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: DS.space5),
              Text('출금 신청', style: DS.heading3),
              const SizedBox(height: DS.space2),
              Text(
                '출금 가능 금액: ₩${_formatCurrency(12430000)}',
                style: DS.textSm(color: AppColors.textSecondary),
              ),
              const SizedBox(height: DS.space5),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: '출금 금액',
                  hintText: '출금할 금액을 입력하세요',
                  prefixText: '₩ ',
                  filled: true,
                  fillColor: AppColors.backgroundAlt,
                  border: OutlineInputBorder(
                    borderRadius: DS.borderRadiusMd,
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: DS.borderRadiusMd,
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: DS.borderRadiusMd,
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: DS.space4),
              Row(
                children: [
                  _buildQuickAmountButton('100만', () {
                    amountController.text = '1,000,000';
                  }),
                  const SizedBox(width: DS.space2),
                  _buildQuickAmountButton('500만', () {
                    amountController.text = '5,000,000';
                  }),
                  const SizedBox(width: DS.space2),
                  _buildQuickAmountButton('전액', () {
                    amountController.text = '12,430,000';
                  }),
                ],
              ),
              const SizedBox(height: DS.space5),
              SizedBox(
                width: double.infinity,
                height: DS.buttonHeightLg,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('출금 신청이 완료되었습니다'),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: DS.borderRadiusSm,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: DS.borderRadiusMd,
                    ),
                  ),
                  child: Text(
                    '출금 신청하기',
                    style: DS.textLg(
                      color: Colors.white,
                      weight: DS.weightBold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: DS.space5),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAmountButton(String label, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: DS.space2),
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: DS.borderRadiusSm,
          ),
          child: Center(
            child: Text(
              label,
              style: DS.textSm(
                color: AppColors.primary,
                weight: DS.weightMedium,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabController tabController;

  _TabBarDelegate({required this.tabController});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppColors.background,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: DS.screenPadding),
        decoration: BoxDecoration(
          color: AppColors.backgroundAlt,
          borderRadius: DS.borderRadiusMd,
        ),
        child: TabBar(
          controller: tabController,
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.textSecondary,
          indicator: BoxDecoration(
            color: AppColors.primary,
            borderRadius: DS.borderRadiusMd,
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelStyle: DS.textSm(weight: DS.weightSemibold),
          unselectedLabelStyle: DS.textSm(weight: DS.weightMedium),
          tabs: const [
            Tab(text: '개요'),
            Tab(text: '입금'),
            Tab(text: '출금'),
            Tab(text: '아이돌'),
          ],
        ),
      ),
    );
  }

  @override
  double get maxExtent => 60;

  @override
  double get minExtent => 60;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

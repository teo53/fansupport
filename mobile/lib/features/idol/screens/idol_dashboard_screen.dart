import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/models/idol_model.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../live/screens/live_screen.dart';

class IdolDashboardScreen extends StatefulWidget {
  final IdolModel idol;

  const IdolDashboardScreen({super.key, required this.idol});

  @override
  State<IdolDashboardScreen> createState() => _IdolDashboardScreenState();
}

class _IdolDashboardScreenState extends State<IdolDashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(),
            _buildRevenueCard(),
            _buildQuickActions(),
            _buildFanGrowthChart(),
            _buildInsightsSection(),
            _buildTopSupporters(),
            _buildRecentActivity(),
            SliverToBoxAdapter(child: SizedBox(height: Responsive.hp(4))),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(Responsive.wp(4)),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.glassWhite,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
            const SizedBox(width: 12),
            CircleAvatar(
              backgroundImage: NetworkImage(widget.idol.profileImage),
              radius: 20,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.idol.stageName,
                      style: TextStyle(
                        fontSize: Responsive.sp(18),
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.verified,
                        color: AppColors.neonCyan, size: 18),
                  ],
                ),
                Text(
                  'Creator Dashboard',
                  style: TextStyle(
                    fontSize: Responsive.sp(12),
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.glassWhite,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.settings_outlined,
                  color: Colors.white70, size: 22),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueCard() {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: Responsive.wp(4)),
        child: GlassCard(
          showNeonBorder: true,
          neonColor: AppColors.neonPurple,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '이번 달 수익',
                        style: TextStyle(
                          fontSize: Responsive.sp(13),
                          color: Colors.white60,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ShaderMask(
                        shaderCallback: (bounds) =>
                            AppColors.holographicGradient.createShader(bounds),
                        child: Text(
                          '₩ 24,580,000',
                          style: TextStyle(
                            fontSize: Responsive.sp(28),
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.arrow_upward_rounded,
                            color: AppColors.success, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '+23%',
                          style: TextStyle(
                            fontSize: Responsive.sp(13),
                            fontWeight: FontWeight.w700,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMiniStat('구독자', '12,405', Icons.people_alt_rounded),
                  _buildDivider(),
                  _buildMiniStat('후원', '8,450', Icons.favorite_rounded),
                  _buildDivider(),
                  _buildMiniStat('펀딩률', '89%', Icons.trending_up_rounded),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.neonCyan, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: Responsive.sp(16),
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: Responsive.sp(11),
            color: Colors.white54,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40,
      color: Colors.white24,
    );
  }

  Widget _buildQuickActions() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(Responsive.wp(4)),
        child: Row(
          children: [
            _buildActionButton(
              icon: Icons.videocam_rounded,
              label: 'Go Live',
              color: AppColors.neonPink,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => LiveScreen(idol: widget.idol),
                  ),
                );
              },
            ),
            SizedBox(width: Responsive.wp(3)),
            _buildActionButton(
              icon: Icons.send_rounded,
              label: 'Bubble',
              color: AppColors.neonPurple,
              onTap: () => context.push('/message/create', extra: widget.idol),
            ),
            SizedBox(width: Responsive.wp(3)),
            _buildActionButton(
              icon: Icons.currency_exchange_rounded,
              label: '환전',
              color: AppColors.success,
              onTap: () => _showExchangeDialog(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: AppColors.glowShadow(color),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: Responsive.sp(12),
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFanGrowthChart() {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: Responsive.wp(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '오타 성장 추이',
              style: TextStyle(
                fontSize: Responsive.sp(18),
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 180,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 2000,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Colors.white12,
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) => Text(
                            '${(value / 1000).toInt()}K',
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                      rightTitles: const AxisTitles(),
                      topTitles: const AxisTitles(),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const months = [
                              '7월',
                              '8월',
                              '9월',
                              '10월',
                              '11월',
                              '12월'
                            ];
                            if (value.toInt() < months.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  months[value.toInt()],
                                  style: const TextStyle(
                                    color: Colors.white38,
                                    fontSize: 10,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: const [
                          FlSpot(0, 6000),
                          FlSpot(1, 7200),
                          FlSpot(2, 8500),
                          FlSpot(3, 9800),
                          FlSpot(4, 11000),
                          FlSpot(5, 12400),
                        ],
                        isCurved: true,
                        gradient: AppColors.neonBorderGradient,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.neonPurple.withValues(alpha: 0.3),
                              AppColors.neonPurple.withValues(alpha: 0.0),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                    minY: 4000,
                    maxY: 14000,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(Responsive.wp(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '인사이트',
              style: TextStyle(
                fontSize: Responsive.sp(18),
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInsightCard(
                    icon: Icons.access_time_rounded,
                    title: '최적 포스팅 시간',
                    value: '오후 8-10시',
                    trend: '+45% 참여율',
                    color: AppColors.neonCyan,
                  ),
                ),
                SizedBox(width: Responsive.wp(3)),
                Expanded(
                  child: _buildInsightCard(
                    icon: Icons.loyalty_rounded,
                    title: '오타 충성도',
                    value: '92.5%',
                    trend: '상위 5%',
                    color: AppColors.holoGold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard({
    required IconData icon,
    required String title,
    required String value,
    required String trend,
    required Color color,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: Responsive.sp(11),
                    color: Colors.white60,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: Responsive.sp(18),
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            trend,
            style: TextStyle(
              fontSize: Responsive.sp(11),
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSupporters() {
    final supporters = [
      {'name': '별빛오타', 'amount': '₩2,450,000', 'rank': 1},
      {'name': 'forever_fan', 'amount': '₩1,890,000', 'rank': 2},
      {'name': '응원단장', 'amount': '₩1,234,000', 'rank': 3},
    ];

    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: Responsive.wp(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Top Supporters',
                  style: TextStyle(
                    fontSize: Responsive.sp(18),
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('전체보기',
                      style: TextStyle(color: AppColors.neonCyan)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...supporters.map((s) => _buildSupporterItem(
                  s['name'] as String,
                  s['amount'] as String,
                  s['rank'] as int,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildSupporterItem(String name, String amount, int rank) {
    final rankColors = [AppColors.holoGold, AppColors.silver, AppColors.bronze];
    final color = rank <= 3 ? rankColors[rank - 1] : Colors.white54;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.glassWhite,
        borderRadius: BorderRadius.circular(12),
        border: rank == 1
            ? Border.all(color: AppColors.holoGold.withValues(alpha: 0.5))
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    final activities = [
      {'user': 'user_99', 'action': 'Sent a Short Cake 🍰', 'time': '2m ago'},
      {'user': 'fan_club', 'action': 'Sent a Cake Tower 🏰', 'time': '5m ago'},
      {'user': 'lovelive', 'action': '스토리에 반응했어요', 'time': '12m ago'},
    ];

    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(Responsive.wp(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: Responsive.sp(18),
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            ...activities.map((a) => _buildActivityItem(
                  a['user']!,
                  a['action']!,
                  a['time']!,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String user, String action, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.glassWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.neonPurple.withValues(alpha: 0.3),
            child: Text(
              user[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    text: user,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    children: [
                      TextSpan(
                        text: ' $action',
                        style: const TextStyle(fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showExchangeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('환전 신청',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        content: const Text(
          '현재 환전 가능한 금액은\n₩ 24,580,000 입니다.\n\n신청하시겠습니까?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('환전 신청이 완료되었습니다.'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            child: const Text('신청', style: TextStyle(color: AppColors.success)),
          ),
        ],
      ),
    );
  }
}

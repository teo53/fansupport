import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/mock/mock_analytics_data.dart';
import '../../../core/mock/mock_data.dart';
import '../../../shared/models/idol_model.dart';
import '../../../shared/models/idol_post_model.dart';
import '../../live/screens/live_screen.dart';

/// 아이돌 CRM 대시보드
/// 실시간 구독자, 매출, 게시물 통계, 피크 시간 분석
class IdolCrmDashboardScreen extends ConsumerStatefulWidget {
  final IdolModel? idol;

  const IdolCrmDashboardScreen({super.key, this.idol});

  @override
  ConsumerState<IdolCrmDashboardScreen> createState() => _IdolCrmDashboardScreenState();
}

class _IdolCrmDashboardScreenState extends ConsumerState<IdolCrmDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Timer? _realtimeTimer;
  int _todayRevenue = 3200000;
  int _liveViewers = 0;
  int _newSubscribersToday = 12;

  IdolModel get _idol => widget.idol ?? MockData.idolModels.first;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _startRealtimeUpdates();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _realtimeTimer?.cancel();
    super.dispose();
  }

  void _startRealtimeUpdates() {
    _realtimeTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          _todayRevenue += (DateTime.now().second % 3) * 5000;
          if (DateTime.now().second % 15 == 0) {
            _newSubscribersToday += 1;
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(),
                  _buildPostsTab(),
                  _buildAnalyticsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildGoLiveButton(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back_ios_new, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 22,
            backgroundImage: CachedNetworkImageProvider(_idol.profileImage),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _idol.stageName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (_idol.isVerified)
                      const Icon(Icons.verified, color: AppColors.primary, size: 18),
                  ],
                ),
                const Text(
                  '아이돌 CRM 대시보드',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: Colors.grey,
        indicatorColor: AppColors.primary,
        indicatorWeight: 3,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        tabs: const [
          Tab(text: '개요', icon: Icon(Icons.dashboard_outlined, size: 18)),
          Tab(text: '게시물', icon: Icon(Icons.feed_outlined, size: 18)),
          Tab(text: '분석', icon: Icon(Icons.analytics_outlined, size: 18)),
        ],
      ),
    );
  }

  // ==================== 개요 탭 ====================
  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 실시간 상태 카드
          _buildRealtimeStatusCard(),
          const SizedBox(height: 16),

          // 매출 요약 그리드
          _buildRevenueSummaryGrid(),
          const SizedBox(height: 20),

          // 빠른 액션 버튼
          _buildQuickActions(),
          const SizedBox(height: 20),

          // 최근 팬 활동
          _buildRecentFanActivity(),
        ],
      ),
    );
  }

  Widget _buildRealtimeStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withBlue(180)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      '실시간',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (_liveViewers > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.videocam, color: Colors.white, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        'LIVE $_liveViewers',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '오늘 매출',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₩${_formatMoney(_todayRevenue)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: Colors.white24,
              ),
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      '오늘 신규 구독',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '+$_newSubscribersToday',
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          '명',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueSummaryGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _buildSummaryCard(
          title: '총 구독자',
          value: '${_idol.subscriberCount}명',
          subtitle: '+${((_idol.subscriberCount) * 0.08).toInt()}명 이번 달',
          icon: Icons.people,
          color: Colors.purple,
        ),
        _buildSummaryCard(
          title: '월 매출',
          value: '₩${_formatMoney(52000000)}',
          subtitle: '+18.5% 전월대비',
          icon: Icons.trending_up,
          color: Colors.green,
        ),
        _buildSummaryCard(
          title: '버블 메시지',
          value: '156개',
          subtitle: '이번 달 발송',
          icon: Icons.chat_bubble,
          color: Colors.blue,
        ),
        _buildSummaryCard(
          title: '선물 수익',
          value: '₩${_formatMoney(14500000)}',
          subtitle: '🎁 1,245개',
          icon: Icons.card_giftcard,
          color: Colors.pink,
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '빠른 액션',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.videocam,
                label: '라이브 시작',
                color: Colors.red,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => LiveScreen(idol: _idol)),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.send,
                label: '메시지 발송',
                color: AppColors.primary,
                onTap: () => context.push('/message/create', extra: _idol),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.currency_exchange,
                label: '환전 신청',
                color: Colors.green,
                onTap: () => _showWithdrawDialog(),
              ),
            ),
          ],
        ),
      ],
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
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentFanActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '최근 팬 활동',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildActivityItem('user_99', '🍰 케이크 선물', '₩50,000', '2분 전'),
              _buildActivityItem('fan_club_prez', '🏰 케이크 타워 선물', '₩100,000', '5분 전'),
              _buildActivityItem('lovelive', '💎 프리미엄 구독 시작', '₩15,000', '8분 전'),
              _buildActivityItem('새로운팬', '💬 버블 구독 시작', '₩4,900', '12분 전'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(String user, String action, String amount, String time) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey[200],
            child: Text(
              user[0].toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
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
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14),
                    children: [
                      TextSpan(
                        text: ' $action',
                        style: const TextStyle(fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                ),
                Text(time, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(color: Colors.green[600], fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ==================== 게시물 탭 ====================
  Widget _buildPostsTab() {
    final posts = MockAnalyticsData.idolPosts
        .where((p) => p.idolId == _idol.id)
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 게시물 통계 요약
        _buildPostStatsSummary(posts),
        const SizedBox(height: 20),

        // 게시물 목록
        const Text(
          '내 게시물',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...posts.map((post) => _buildPostCard(post)),
      ],
    );
  }

  Widget _buildPostStatsSummary(List<IdolPost> posts) {
    final totalViews = posts.fold(0, (sum, p) => sum + p.viewCount);
    final totalLikes = posts.fold(0, (sum, p) => sum + p.likeCount);
    final totalBookmarks = posts.fold(0, (sum, p) => sum + p.bookmarkCount);
    final avgEngagement = posts.isEmpty ? 0.0 : posts.fold(0.0, (sum, p) => sum + p.engagementRate) / posts.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '게시물 통계',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildPostStat('👁️ 조회수', _formatNumber(totalViews))),
              Expanded(child: _buildPostStat('❤️ 좋아요', _formatNumber(totalLikes))),
              Expanded(child: _buildPostStat('🔖 스크랩', _formatNumber(totalBookmarks))),
              Expanded(child: _buildPostStat('📊 참여율', '${avgEngagement.toStringAsFixed(1)}%')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPostStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildPostCard(IdolPost post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getVisibilityColor(post.visibility).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${post.visibilityIcon} ${post.visibilityLabel}',
                  style: TextStyle(
                    color: _getVisibilityColor(post.visibility),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                _formatTimeAgo(post.createdAt),
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            post.content,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildPostMetric(Icons.visibility_outlined, post.viewCount),
              const SizedBox(width: 16),
              _buildPostMetric(Icons.favorite_outline, post.likeCount),
              const SizedBox(width: 16),
              _buildPostMetric(Icons.chat_bubble_outline, post.commentCount),
              const SizedBox(width: 16),
              _buildPostMetric(Icons.bookmark_outline, post.bookmarkCount),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '참여율 ${post.engagementRate.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPostMetric(IconData icon, int count) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          _formatNumber(count),
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
      ],
    );
  }

  Color _getVisibilityColor(PostVisibility visibility) {
    switch (visibility) {
      case PostVisibility.public:
        return Colors.green;
      case PostVisibility.subscribers:
        return Colors.purple;
      case PostVisibility.premium:
        return Colors.orange;
      case PostVisibility.vip:
        return Colors.amber;
    }
  }

  // ==================== 분석 탭 ====================
  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 시간대별 활동 분석
          _buildHourlyActivityChart(),
          const SizedBox(height: 20),

          // 피크 시간 분석
          _buildPeakTimeAnalysis(),
          const SizedBox(height: 20),

          // 추천 전략
          _buildRecommendations(),
        ],
      ),
    );
  }

  Widget _buildHourlyActivityChart() {
    final hourlyData = MockAnalyticsData.hourlyRevenue;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '시간대별 팬 활동',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '결제 및 구독이 가장 활발한 시간대를 확인하세요',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 600000,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() % 6 == 0) {
                          return Text('${value.toInt()}시', style: TextStyle(color: Colors.grey[600], fontSize: 10));
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                barGroups: hourlyData.map((h) {
                  final isPeak = h.hour >= 20 && h.hour <= 23;
                  return BarChartGroupData(
                    x: h.hour,
                    barRods: [
                      BarChartRodData(
                        toY: h.revenue.toDouble(),
                        color: isPeak ? AppColors.primary : Colors.grey[300],
                        width: 6,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeakTimeAnalysis() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '피크 타임 분석',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.access_time, color: Colors.orange, size: 28),
                      const SizedBox(height: 8),
                      const Text(
                        '21:00',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange),
                      ),
                      Text('최고 결제 시간', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.blue, size: 28),
                      const SizedBox(height: 8),
                      const Text(
                        '토요일',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                      Text('최고 결제 요일', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade50, Colors.orange.shade50],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb, color: Colors.amber),
              const SizedBox(width: 8),
              const Text(
                'AI 추천 전략',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildRecommendationItem(
            '🎬 라이브 방송',
            '토요일 21시에 라이브 시작을 권장합니다.\n이 시간대에 결제 전환율이 35% 높습니다.',
          ),
          const SizedBox(height: 12),
          _buildRecommendationItem(
            '💬 버블 메시지',
            '주 3-4회 버블 발송 시 구독 유지율이 최적화됩니다.\n현재 발송 빈도는 적절합니다.',
          ),
          const SizedBox(height: 12),
          _buildRecommendationItem(
            '📸 콘텐츠',
            '이미지 포함 게시물의 참여율이 2.3배 높습니다.\n셀카나 비하인드 사진 공유를 권장합니다.',
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(String title, String description) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(color: Colors.grey[700], fontSize: 12, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildGoLiveButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        HapticFeedback.mediumImpact();
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => LiveScreen(idol: _idol)),
        );
      },
      backgroundColor: Colors.red,
      icon: const Icon(Icons.videocam, color: Colors.white),
      label: const Text('Go Live', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }

  void _showWithdrawDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('환전 신청'),
        content: const Text('현재 환전 가능한 금액은 52,000,000원입니다.\n신청하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => context.pop(), child: const Text('취소')),
          TextButton(
            onPressed: () {
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('환전 신청이 완료되었습니다.')),
              );
            },
            child: const Text('신청', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  String _formatMoney(int amount) {
    if (amount >= 100000000) return '${(amount / 100000000).toStringAsFixed(1)}억';
    if (amount >= 10000000) return '${(amount / 10000000).toStringAsFixed(1)}천만';
    if (amount >= 10000) return '${(amount / 10000).toStringAsFixed(0)}만';
    return amount.toString();
  }

  String _formatNumber(int num) {
    if (num >= 10000) return '${(num / 10000).toStringAsFixed(1)}만';
    if (num >= 1000) return '${(num / 1000).toStringAsFixed(1)}천';
    return num.toString();
  }

  String _formatTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    return '${diff.inDays}일 전';
  }
}

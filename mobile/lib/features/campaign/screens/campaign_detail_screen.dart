import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/mock/mock_data.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../auth/providers/auth_provider.dart';

class CampaignDetailScreen extends ConsumerStatefulWidget {
  final String campaignId;

  const CampaignDetailScreen({super.key, required this.campaignId});

  @override
  ConsumerState<CampaignDetailScreen> createState() => _CampaignDetailScreenState();
}

class _CampaignDetailScreenState extends ConsumerState<CampaignDetailScreen> {
  int? _selectedRewardAmount;
  bool _isLoading = false;

  Map<String, dynamic>? get _campaign {
    try {
      return MockData.campaigns.firstWhere((c) => c['id'] == widget.campaignId);
    } catch (e) {
      return MockData.campaigns.isNotEmpty ? MockData.campaigns.first : null;
    }
  }

  Map<String, dynamic>? get _creator {
    final campaign = _campaign;
    if (campaign == null) return null;
    try {
      return MockData.idols.firstWhere((i) => i['id'] == campaign['creatorId']);
    } catch (e) {
      return MockData.idols.isNotEmpty ? MockData.idols.first : null;
    }
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  String _getCategoryName(String? category) {
    final names = {
      'UNDERGROUND_IDOL': '지하 아이돌',
      'MAID_CAFE': '메이드카페',
      'COSPLAYER': '코스플레이어',
      'VTuber': 'VTuber',
    };
    return names[category] ?? '아이돌';
  }

  int _calculateDaysLeft(String endDateStr) {
    final endDate = DateTime.parse(endDateStr);
    final now = DateTime.now();
    return endDate.difference(now).inDays;
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final campaign = _campaign;
    final creator = _creator;
    final user = ref.watch(currentUserProvider);
    final walletBalance = user?.walletBalance ?? 0;

    if (campaign == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('펀딩')),
        body: const Center(child: Text('캠페인을 찾을 수 없습니다')),
      );
    }

    final currentAmount = campaign['currentAmount'] as int;
    final goalAmount = campaign['goalAmount'] as int;
    final progress = currentAmount / goalAmount;
    final daysLeft = _calculateDaysLeft(campaign['endDate']);
    final supporters = campaign['supporters'] as int;
    final rewards = campaign['rewards'] as List<dynamic>;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: Responsive.hp(25),
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: campaign['coverImage'] != null
                  ? CachedNetworkImage(
                      imageUrl: campaign['coverImage'],
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        decoration: const BoxDecoration(
                          gradient: AppColors.primaryGradient,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.campaign,
                            size: Responsive.sp(60),
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        decoration: const BoxDecoration(
                          gradient: AppColors.primaryGradient,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.campaign,
                            size: Responsive.sp(60),
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    )
                  : Container(
                      decoration: const BoxDecoration(
                        gradient: AppColors.primaryGradient,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.campaign,
                          size: Responsive.sp(60),
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.share, size: Responsive.sp(24)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('공유 기능은 준비 중입니다')),
                  );
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(Responsive.wp(4)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Creator Info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: Responsive.wp(5),
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        backgroundImage: creator?['profileImage'] != null
                            ? CachedNetworkImageProvider(creator!['profileImage'])
                            : null,
                        child: creator?['profileImage'] == null
                            ? Icon(
                                Icons.person,
                                color: AppColors.primary,
                                size: Responsive.sp(20),
                              )
                            : null,
                      ),
                      SizedBox(width: Responsive.wp(3)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  creator?['stageName'] ?? '아이돌',
                                  style: TextStyle(
                                    fontSize: Responsive.sp(15),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: Responsive.wp(1)),
                                if (creator?['isVerified'] ?? false)
                                  Icon(
                                    Icons.verified,
                                    size: Responsive.sp(16),
                                    color: AppColors.primary,
                                  ),
                              ],
                            ),
                            Text(
                              _getCategoryName(creator?['category']),
                              style: TextStyle(
                                fontSize: Responsive.sp(12),
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Responsive.hp(2.5)),

                  // Title
                  Text(
                    campaign['title'] ?? '캠페인',
                    style: TextStyle(
                      fontSize: Responsive.sp(22),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: Responsive.hp(2)),

                  // Progress Card
                  Container(
                    padding: EdgeInsets.all(Responsive.wp(5)),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.1),
                          AppColors.secondary.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
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
                                  '￦${_formatNumber(currentAmount)}',
                                  style: TextStyle(
                                    fontSize: Responsive.sp(22),
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                                Text(
                                  '목표 ￦${_formatNumber(goalAmount)}',
                                  style: TextStyle(
                                    fontSize: Responsive.sp(13),
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: Responsive.wp(4),
                                vertical: Responsive.hp(1),
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${(progress * 100).toInt()}%',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: Responsive.sp(14),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: Responsive.hp(2)),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress.clamp(0.0, 1.0),
                            backgroundColor: Colors.white,
                            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                            minHeight: Responsive.hp(1.5),
                          ),
                        ),
                        SizedBox(height: Responsive.hp(2)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(context, Icons.people, '$supporters명', '후원자'),
                            _buildStatItem(
                              context,
                              Icons.timer,
                              daysLeft > 0 ? 'D-$daysLeft' : '마감',
                              '남은 기간',
                              color: daysLeft <= 7 ? AppColors.error : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: Responsive.hp(3)),

                  // Description
                  Text(
                    '프로젝트 소개',
                    style: TextStyle(
                      fontSize: Responsive.sp(18),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: Responsive.hp(1.5)),
                  Text(
                    campaign['description'] ?? '',
                    style: TextStyle(
                      fontSize: Responsive.sp(14),
                      height: 1.8,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: Responsive.hp(4)),

                  // Rewards
                  Text(
                    '리워드',
                    style: TextStyle(
                      fontSize: Responsive.sp(18),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: Responsive.hp(2)),
                  ...rewards.map((reward) => _buildRewardTier(
                    context,
                    amount: reward['amount'] as int,
                    title: reward['title'] as String,
                    description: reward['description'] as String,
                    supporters: reward['supporters'] as int,
                    limit: reward['limit'] as int?,
                    isPopular: reward['isPopular'] ?? false,
                    walletBalance: walletBalance,
                  )),
                  SizedBox(height: Responsive.hp(12)),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(Responsive.wp(4)),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    size: Responsive.sp(16),
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: Responsive.wp(1)),
                  Text(
                    '보유 코인: ￦${_formatNumber(walletBalance)}',
                    style: TextStyle(
                      fontSize: Responsive.sp(13),
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: Responsive.hp(1)),
              GradientButton(
                onPressed: daysLeft > 0 ? () => _showContributeSheet(context, rewards, walletBalance) : null,
                child: Text(
                  daysLeft > 0 ? '펀딩 참여하기' : '펀딩이 종료되었습니다',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: Responsive.sp(16),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String value,
    String label, {
    Color? color,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: Responsive.sp(20), color: color ?? AppColors.textSecondary),
            SizedBox(width: Responsive.wp(1)),
            Text(
              value,
              style: TextStyle(
                fontSize: Responsive.sp(16),
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(height: Responsive.hp(0.5)),
        Text(
          label,
          style: TextStyle(
            fontSize: Responsive.sp(12),
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildRewardTier(
    BuildContext context, {
    required int amount,
    required String title,
    required String description,
    required int supporters,
    int? limit,
    bool isPopular = false,
    required int walletBalance,
  }) {
    final canAfford = walletBalance >= amount;
    final isSoldOut = limit != null && supporters >= limit;

    return Card(
      margin: EdgeInsets.only(bottom: Responsive.hp(1.5)),
      child: Opacity(
        opacity: isSoldOut ? 0.5 : 1.0,
        child: Padding(
          padding: EdgeInsets.all(Responsive.wp(4)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '￦${_formatNumber(amount)}',
                    style: TextStyle(
                      fontSize: Responsive.sp(18),
                      fontWeight: FontWeight.bold,
                      color: canAfford ? AppColors.primary : AppColors.textHint,
                    ),
                  ),
                  Row(
                    children: [
                      if (!canAfford && !isSoldOut)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: Responsive.wp(2),
                            vertical: Responsive.hp(0.5),
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '잔액 부족',
                            style: TextStyle(
                              color: AppColors.error,
                              fontSize: Responsive.sp(10),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (isSoldOut)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: Responsive.wp(2),
                            vertical: Responsive.hp(0.5),
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.textSecondary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '품절',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: Responsive.sp(10),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (isPopular && !isSoldOut) ...[
                        SizedBox(width: Responsive.wp(2)),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: Responsive.wp(2),
                            vertical: Responsive.hp(0.5),
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '인기',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: Responsive.sp(10),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              SizedBox(height: Responsive.hp(1)),
              Text(
                title,
                style: TextStyle(
                  fontSize: Responsive.sp(15),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: Responsive.hp(0.5)),
              Text(
                description,
                style: TextStyle(
                  fontSize: Responsive.sp(13),
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: Responsive.hp(1.5)),
              Row(
                children: [
                  Icon(Icons.people, size: Responsive.sp(16), color: AppColors.textSecondary),
                  SizedBox(width: Responsive.wp(1)),
                  Text(
                    '$supporters명 참여',
                    style: TextStyle(
                      fontSize: Responsive.sp(12),
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (limit != null) ...[
                    SizedBox(width: Responsive.wp(3)),
                    Text(
                      '(한정 $limit개)',
                      style: TextStyle(
                        fontSize: Responsive.sp(12),
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showContributeSheet(BuildContext context, List<dynamic> rewards, int walletBalance) {
    _selectedRewardAmount = null;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final selectedReward = rewards.firstWhere(
            (r) => r['amount'] == _selectedRewardAmount,
            orElse: () => null,
          );
          final canProceed = _selectedRewardAmount != null &&
              walletBalance >= _selectedRewardAmount! &&
              !(selectedReward?['limit'] != null &&
                  (selectedReward?['supporters'] ?? 0) >= selectedReward?['limit']);

          return Container(
            height: Responsive.hp(75),
            padding: EdgeInsets.all(Responsive.wp(6)),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: Responsive.wp(10),
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: Responsive.hp(3)),
                Text(
                  '펀딩 참여하기',
                  style: TextStyle(
                    fontSize: Responsive.sp(22),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: Responsive.hp(1)),
                Text(
                  '리워드를 선택해주세요',
                  style: TextStyle(
                    fontSize: Responsive.sp(14),
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: Responsive.hp(3)),
                Expanded(
                  child: ListView.builder(
                    itemCount: rewards.length,
                    itemBuilder: (context, index) {
                      final reward = rewards[index];
                      final amount = reward['amount'] as int;
                      final canAfford = walletBalance >= amount;
                      final isSoldOut = reward['limit'] != null &&
                          (reward['supporters'] ?? 0) >= reward['limit'];
                      final isSelected = _selectedRewardAmount == amount;

                      return Card(
                        margin: EdgeInsets.only(bottom: Responsive.hp(1.5)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected ? AppColors.primary : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: InkWell(
                          onTap: canAfford && !isSoldOut
                              ? () {
                                  setModalState(() {
                                    _selectedRewardAmount = amount;
                                  });
                                }
                              : null,
                          borderRadius: BorderRadius.circular(12),
                          child: Opacity(
                            opacity: canAfford && !isSoldOut ? 1.0 : 0.5,
                            child: Padding(
                              padding: EdgeInsets.all(Responsive.wp(4)),
                              child: Row(
                                children: [
                                  Radio<int>(
                                    value: amount,
                                    groupValue: _selectedRewardAmount,
                                    onChanged: canAfford && !isSoldOut
                                        ? (value) {
                                            setModalState(() {
                                              _selectedRewardAmount = value;
                                            });
                                          }
                                        : null,
                                    activeColor: AppColors.primary,
                                  ),
                                  SizedBox(width: Responsive.wp(2)),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '￦${_formatNumber(amount)}',
                                          style: TextStyle(
                                            fontSize: Responsive.sp(16),
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        SizedBox(height: Responsive.hp(0.5)),
                                        Text(
                                          reward['title'] as String,
                                          style: TextStyle(
                                            fontSize: Responsive.sp(14),
                                          ),
                                        ),
                                        if (isSoldOut)
                                          Text(
                                            '품절',
                                            style: TextStyle(
                                              fontSize: Responsive.sp(12),
                                              color: AppColors.error,
                                            ),
                                          ),
                                        if (!canAfford && !isSoldOut)
                                          Text(
                                            '잔액 부족',
                                            style: TextStyle(
                                              fontSize: Responsive.sp(12),
                                              color: AppColors.error,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: Responsive.hp(2)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      size: Responsive.sp(16),
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: Responsive.wp(1)),
                    Text(
                      '보유 코인: ￦${_formatNumber(walletBalance)}',
                      style: TextStyle(
                        fontSize: Responsive.sp(13),
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Responsive.hp(2)),
                GradientButton(
                  onPressed: canProceed
                      ? () => _handleContribute(context, selectedReward)
                      : null,
                  isLoading: _isLoading,
                  child: Text(
                    _selectedRewardAmount != null
                        ? '￦${_formatNumber(_selectedRewardAmount!)} 펀딩하기'
                        : '리워드를 선택해주세요',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: Responsive.sp(16),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _handleContribute(BuildContext context, Map<String, dynamic>? reward) async {
    if (_selectedRewardAmount == null || reward == null) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));

    final currentBalance = ref.read(currentUserProvider)?.walletBalance ?? 0;
    ref.read(authStateProvider.notifier).updateWalletBalance(currentBalance - _selectedRewardAmount!);

    setState(() => _isLoading = false);
    if (!mounted) return;

    Navigator.pop(context);

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
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_circle, color: AppColors.success, size: Responsive.sp(50)),
            ),
            SizedBox(height: Responsive.hp(3)),
            Text(
              '펀딩 참여 완료!',
              style: TextStyle(fontSize: Responsive.sp(22), fontWeight: FontWeight.bold),
            ),
            SizedBox(height: Responsive.hp(1)),
            Text(
              '${reward['title']} 리워드에\n참여해주셔서 감사합니다',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: Responsive.sp(14), color: AppColors.textSecondary),
            ),
            SizedBox(height: Responsive.hp(3)),
            CustomButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('확인', style: TextStyle(fontSize: Responsive.sp(16))),
            ),
          ],
        ),
      ),
    );
  }
}

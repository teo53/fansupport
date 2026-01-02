import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../auth/providers/auth_provider.dart';
import '../../agency/screens/agency_crm_dashboard_screen.dart';
import '../../idol/screens/idol_crm_dashboard_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Responsive.init(context);
    final user = ref.watch(currentUserProvider);

    // Route to role-specific dashboard
    final userRole = user?.role.toUpperCase() ?? 'FAN';

    // Agency accounts see CRM Dashboard directly
    if (userRole == 'AGENCY') {
      return const AgencyCrmDashboardScreen();
    }

    // Idol accounts see Idol CRM Dashboard
    if (userRole == 'IDOL') {
      return const IdolCrmDashboardScreen();
    }

    // Fan accounts see the regular profile
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '마이페이지',
          style: TextStyle(fontSize: Responsive.sp(18)),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, size: Responsive.sp(24)),
            onPressed: () => _showSettingsSheet(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: EdgeInsets.all(Responsive.wp(6)),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: Responsive.wp(14),
                      backgroundColor: Colors.white,
                      backgroundImage: user?.profileImage != null
                          ? CachedNetworkImageProvider(user!.profileImage!)
                          : null,
                      child: user?.profileImage == null
                          ? Icon(
                              Icons.person,
                              size: Responsive.sp(50),
                              color: AppColors.primary,
                            )
                          : null,
                    ),
                  ),
                  SizedBox(height: Responsive.hp(2)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        user?.nickname ?? '닉네임',
                        style: TextStyle(
                          fontSize: Responsive.sp(22),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (user?.isVerified ?? false) ...[
                        SizedBox(width: Responsive.wp(1)),
                        Icon(
                          Icons.verified,
                          color: AppColors.primary,
                          size: Responsive.sp(20),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: Responsive.hp(0.5)),
                  Text(
                    user?.email ?? 'email@example.com',
                    style: TextStyle(
                      fontSize: Responsive.sp(14),
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: Responsive.hp(2)),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.edit, size: Responsive.sp(18)),
                    label: Text(
                      '프로필 수정',
                      style: TextStyle(fontSize: Responsive.sp(14)),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.wp(6),
                        vertical: Responsive.hp(1.2),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Quick Stats
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Responsive.wp(4)),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(Responsive.wp(4)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        context,
                        _formatCurrency(user?.walletBalance ?? 0),
                        '보유 코인',
                        Icons.monetization_on,
                      ),
                      Container(
                        width: 1,
                        height: Responsive.hp(5),
                        color: AppColors.divider,
                      ),
                      _buildStatItem(
                          context, '3', '구독 중', Icons.card_membership),
                      Container(
                        width: 1,
                        height: Responsive.hp(5),
                        color: AppColors.divider,
                      ),
                      _buildStatItem(context, '8', '후원 횟수', Icons.favorite),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: Responsive.hp(3)),

            // Menu List
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Responsive.wp(4)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '활동',
                    style: TextStyle(
                      fontSize: Responsive.sp(14),
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: Responsive.hp(1)),
                  _buildMenuItem(
                    context,
                    icon: Icons.account_balance_wallet,
                    title: '지갑',
                    subtitle: '잔액 확인 및 충전',
                    onTap: () => context.go('/wallet'),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.card_membership,
                    title: '내 구독',
                    subtitle: '구독 중인 아이돌 관리',
                    onTap: () => _showSubscriptionList(context),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.favorite,
                    title: '후원 내역',
                    subtitle: '보낸 후원 확인',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.campaign,
                    title: '참여한 펀딩',
                    subtitle: '펀딩 참여 내역',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.calendar_today,
                    title: '예약 내역',
                    subtitle: '메이드카페 예약 확인',
                    onTap: () {},
                  ),
                  SizedBox(height: Responsive.hp(3)),
                  Text(
                    '설정',
                    style: TextStyle(
                      fontSize: Responsive.sp(14),
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: Responsive.hp(1)),
                  _buildMenuItem(
                    context,
                    icon: Icons.notifications,
                    title: '알림 설정',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.payment,
                    title: '결제 수단',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.security,
                    title: '보안 설정',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.help,
                    title: '고객센터',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.info,
                    title: '앱 정보',
                    subtitle: '버전 1.0.0',
                    onTap: () {},
                  ),
                  SizedBox(height: Responsive.hp(2)),
                  _buildMenuItem(
                    context,
                    icon: Icons.logout,
                    title: '로그아웃',
                    color: AppColors.error,
                    onTap: () => _showLogoutDialog(context, ref),
                  ),
                ],
              ),
            ),
            SizedBox(height: Responsive.hp(4)),

            // Developer Menu (For Role Testing)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Responsive.wp(4)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '개발자 메뉴 (Debug)',
                    style: TextStyle(
                      fontSize: Responsive.sp(14),
                      fontWeight: FontWeight.w600,
                      color: Colors.redAccent,
                    ),
                  ),
                  SizedBox(height: Responsive.hp(1)),
                  _buildMenuItem(
                    context,
                    icon: Icons.business,
                    title: 'Agency CRM Dashboard',
                    subtitle: '소속사 계정 미리보기',
                    color: Colors.redAccent,
                    onTap: () => context.push('/agency/crm'),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.mic_external_on,
                    title: 'Idol CRM Dashboard',
                    subtitle: '아이돌 계정 미리보기',
                    color: Colors.redAccent,
                    onTap: () => context.push('/idol/crm'),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.campaign,
                    title: 'Campaigns (펀딩)',
                    subtitle: '펀딩/캠페인 페이지',
                    color: Colors.orange,
                    onTap: () => context.push('/campaigns'),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.ads_click,
                    title: 'Advertising',
                    subtitle: '광고 구매',
                    color: Colors.purple,
                    onTap: () => context.push('/advertising'),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.feed,
                    title: 'Idol Posts Feed',
                    subtitle: '아이돌 게시글 피드',
                    color: Colors.pink,
                    onTap: () => context.push('/posts'),
                  ),
                ],
              ),
            ),
            SizedBox(height: Responsive.hp(4)),
          ],
        ),
      ),
    );
  }

  void _showSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(Responsive.wp(4)),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('다크 모드'),
              trailing: Switch(
                value: false,
                onChanged: (value) {},
                activeColor: AppColors.primary,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('언어'),
              trailing: const Text('한국어'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: const Text('푸시 알림'),
              trailing: Switch(
                value: true,
                onChanged: (value) {},
                activeColor: AppColors.primary,
              ),
            ),
            SizedBox(height: Responsive.hp(2)),
          ],
        ),
      ),
    );
  }

  void _showSubscriptionList(BuildContext context) {
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
                    '내 구독',
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
                  _buildSubscriptionItem(context, '하늘별', '골드', AppColors.gold),
                  _buildSubscriptionItem(context, '루나', '실버', AppColors.silver),
                  _buildSubscriptionItem(
                      context, '유키', '브론즈', AppColors.bronze),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionItem(
      BuildContext context, String name, String tier, Color tierColor) {
    return Card(
      margin: EdgeInsets.only(bottom: Responsive.hp(1.5)),
      child: ListTile(
        contentPadding: EdgeInsets.all(Responsive.wp(3)),
        leading: CircleAvatar(
          radius: Responsive.wp(6),
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Icon(Icons.person,
              color: AppColors.primary, size: Responsive.sp(24)),
        ),
        title: Row(
          children: [
            Text(
              name,
              style: TextStyle(
                fontSize: Responsive.sp(15),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: Responsive.wp(1)),
            Icon(Icons.verified,
                color: AppColors.primary, size: Responsive.sp(16)),
          ],
        ),
        subtitle: Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.wp(2),
                vertical: Responsive.hp(0.3),
              ),
              decoration: BoxDecoration(
                color: tierColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                tier,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: Responsive.sp(10),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: Responsive.wp(2)),
            Text(
              '다음 결제: 2025.01.15',
              style: TextStyle(
                fontSize: Responsive.sp(12),
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        trailing: TextButton(
          onPressed: () {},
          child: Text(
            '관리',
            style: TextStyle(fontSize: Responsive.sp(13)),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String value,
    String label,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: Responsive.sp(24)),
        SizedBox(height: Responsive.hp(1)),
        Text(
          value,
          style: TextStyle(
            fontSize: Responsive.sp(16),
            fontWeight: FontWeight.bold,
          ),
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

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Color? color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: Responsive.hp(1)),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: Responsive.wp(4),
          vertical: Responsive.hp(0.3),
        ),
        leading: Container(
          width: Responsive.wp(10),
          height: Responsive.wp(10),
          decoration: BoxDecoration(
            color: (color ?? AppColors.primary).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon,
              color: color ?? AppColors.primary, size: Responsive.sp(22)),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w500,
            fontSize: Responsive.sp(15),
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  fontSize: Responsive.sp(12),
                  color: AppColors.textSecondary,
                ),
              )
            : null,
        trailing: Icon(
          Icons.chevron_right,
          color: AppColors.textSecondary,
          size: Responsive.sp(22),
        ),
        onTap: onTap,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          '로그아웃',
          style: TextStyle(fontSize: Responsive.sp(18)),
        ),
        content: Text(
          '정말 로그아웃 하시겠습니까?',
          style: TextStyle(fontSize: Responsive.sp(14)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '취소',
              style: TextStyle(fontSize: Responsive.sp(14)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(authStateProvider.notifier).logout();
              Navigator.pop(context);
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text(
              '로그아웃',
              style: TextStyle(fontSize: Responsive.sp(14)),
            ),
          ),
        ],
      ),
    );
  }
}

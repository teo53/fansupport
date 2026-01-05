import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../auth/providers/auth_provider.dart';

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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '마이페이지',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: AppColors.textPrimary),
            onPressed: () => _showSettingsSheet(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(Responsive.wp(6)),
              margin: EdgeInsets.only(bottom: Responsive.wp(4)),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border, width: 2),
                    ),
                    child: ClipOval(
                      child: user?.profileImage != null
                          ? CachedNetworkImage(
                              imageUrl: user!.profileImage!,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: AppColors.backgroundAlt,
                              child: Icon(
                                Icons.person,
                                size: 50,
                                color: AppColors.textSecondary,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        user?.nickname ?? '닉네임',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (user?.isVerified ?? false) ...[
                        const SizedBox(width: 6),
                        Icon(
                          Icons.verified,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    user?.email ?? 'email@example.com',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('프로필 수정'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Quick Stats
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Responsive.wp(6)),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      _formatCurrency(user?.walletBalance ?? 0),
                      '보유 코인',
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: AppColors.border,
                    ),
                    _buildStatItem('3', '구독 중'),
                    Container(
                      width: 1,
                      height: 40,
                      color: AppColors.border,
                    ),
                    _buildStatItem('8', '후원 횟수'),
                  ],
                ),
              ),
            ),
            SizedBox(height: Responsive.wp(6)),

            // Menu List - Activity
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Responsive.wp(6)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '활동',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        _buildMenuItem(
                          context,
                          icon: Icons.account_balance_wallet,
                          title: '지갑',
                          onTap: () => context.go('/wallet'),
                        ),
                        Divider(height: 1, color: AppColors.border),
                        _buildMenuItem(
                          context,
                          icon: Icons.card_membership,
                          title: '내 구독',
                          onTap: () {},
                        ),
                        Divider(height: 1, color: AppColors.border),
                        _buildMenuItem(
                          context,
                          icon: Icons.favorite,
                          title: '후원 내역',
                          onTap: () {},
                        ),
                        Divider(height: 1, color: AppColors.border),
                        _buildMenuItem(
                          context,
                          icon: Icons.campaign,
                          title: '참여한 펀딩',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: Responsive.wp(6)),

            // Menu List - Creator/Agency Management
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Responsive.wp(6)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '크리에이터/소속사',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'PRO',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.1),
                          AppColors.primaryLight.withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2),
                    ),
                    child: Column(
                      children: [
                        _buildMenuItem(
                          context,
                          icon: Icons.dashboard_outlined,
                          title: '소속사 대시보드',
                          subtitle: '소속 크리에이터 관리',
                          onTap: () => context.go('/agency'),
                          iconColor: AppColors.primary,
                        ),
                        Divider(height: 1, color: AppColors.border),
                        _buildMenuItem(
                          context,
                          icon: Icons.person_add_outlined,
                          title: '크리에이터 등록',
                          subtitle: '새로운 크리에이터 추가',
                          onTap: () => context.go('/crm/register-idol'),
                          iconColor: AppColors.primary,
                        ),
                        Divider(height: 1, color: AppColors.border),
                        _buildMenuItem(
                          context,
                          icon: Icons.analytics_outlined,
                          title: '내 크리에이터 페이지',
                          subtitle: '활동 통계 및 관리',
                          onTap: () {
                            // TODO: Navigate to idol dashboard with current user's idol profile
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('크리에이터 프로필이 필요합니다')),
                            );
                          },
                          iconColor: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: Responsive.wp(6)),

            // Menu List - Settings
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Responsive.wp(6)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '설정',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        _buildMenuItem(
                          context,
                          icon: Icons.notifications,
                          title: '알림 설정',
                          onTap: () {},
                        ),
                        Divider(height: 1, color: AppColors.border),
                        _buildMenuItem(
                          context,
                          icon: Icons.payment,
                          title: '결제 수단',
                          onTap: () {},
                        ),
                        Divider(height: 1, color: AppColors.border),
                        _buildMenuItem(
                          context,
                          icon: Icons.security,
                          title: '보안 설정',
                          onTap: () {},
                        ),
                        Divider(height: 1, color: AppColors.border),
                        _buildMenuItem(
                          context,
                          icon: Icons.help,
                          title: '고객센터',
                          onTap: () {},
                        ),
                        Divider(height: 1, color: AppColors.border),
                        _buildMenuItem(
                          context,
                          icon: Icons.info,
                          title: '앱 정보',
                          trailing: Text(
                            'v1.0.0',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: Responsive.wp(6)),

            // Logout
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Responsive.wp(6)),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: _buildMenuItem(
                  context,
                  icon: Icons.logout,
                  title: '로그아웃',
                  color: AppColors.error,
                  onTap: () => _showLogoutDialog(context, ref),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
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
    Widget? trailing,
    Color? color,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? color ?? AppColors.textPrimary, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: color ?? AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 8.0),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            trailing ??
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
          ],
        ),
      ),
    );
  }

  void _showSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
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
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃 하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
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
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );
  }
}

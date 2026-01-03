import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/services/local_storage_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(darkModeProvider);
    final isPushEnabled = ref.watch(pushNotificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          '설정',
          style: TextStyle(
            fontFamily: TypographyTokens.fontFamily,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        children: [
          // Appearance Section
          _buildSectionHeader('화면'),
          _buildSwitchTile(
            icon: Icons.dark_mode_rounded,
            title: '다크 모드',
            subtitle: '어두운 테마로 전환합니다',
            value: isDarkMode,
            onChanged: (value) {
              ref.read(darkModeProvider.notifier).set(value);
            },
          ),
          _buildListTile(
            icon: Icons.language_rounded,
            title: '언어',
            subtitle: '한국어',
            onTap: () => _showLanguageDialog(context),
          ),

          SizedBox(height: Spacing.base),

          // Notifications Section
          _buildSectionHeader('알림'),
          _buildSwitchTile(
            icon: Icons.notifications_rounded,
            title: '푸시 알림',
            subtitle: '앱 알림을 받습니다',
            value: isPushEnabled,
            onChanged: (value) {
              ref.read(pushNotificationsProvider.notifier).toggle();
            },
          ),
          _buildListTile(
            icon: Icons.email_rounded,
            title: '이메일 알림',
            subtitle: '중요 소식을 이메일로 받습니다',
            onTap: () {},
          ),

          SizedBox(height: Spacing.base),

          // Account Section
          _buildSectionHeader('계정'),
          _buildListTile(
            icon: Icons.person_rounded,
            title: '프로필 수정',
            onTap: () => context.push('/profile/edit'),
          ),
          _buildListTile(
            icon: Icons.lock_rounded,
            title: '비밀번호 변경',
            onTap: () {},
          ),
          _buildListTile(
            icon: Icons.payment_rounded,
            title: '결제 수단 관리',
            onTap: () {},
          ),

          SizedBox(height: Spacing.base),

          // Support Section
          _buildSectionHeader('지원'),
          _buildListTile(
            icon: Icons.help_rounded,
            title: '도움말',
            onTap: () {},
          ),
          _buildListTile(
            icon: Icons.feedback_rounded,
            title: '피드백 보내기',
            onTap: () {},
          ),
          _buildListTile(
            icon: Icons.info_rounded,
            title: '앱 정보',
            subtitle: '버전 1.0.0',
            onTap: () => _showAppInfo(context),
          ),

          SizedBox(height: Spacing.base),

          // Danger Zone
          _buildSectionHeader('계정 관리'),
          _buildListTile(
            icon: Icons.logout_rounded,
            title: '로그아웃',
            color: AppColors.error,
            onTap: () => _showLogoutDialog(context, ref),
          ),
          _buildListTile(
            icon: Icons.delete_forever_rounded,
            title: '계정 삭제',
            color: AppColors.error,
            onTap: () => _showDeleteAccountDialog(context),
          ),

          SizedBox(height: Spacing.xxl),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        Spacing.base,
        Spacing.base,
        Spacing.base,
        Spacing.sm,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          fontFamily: TypographyTokens.fontFamily,
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? color,
    required VoidCallback onTap,
  }) {
    return Container(
      color: AppColors.surface,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: (color ?? AppColors.primary).withOpacity(0.1),
            borderRadius: BorderRadius.circular(Radii.sm),
          ),
          child: Icon(
            icon,
            color: color ?? AppColors.primary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: color ?? AppColors.textPrimary,
            fontFamily: TypographyTokens.fontFamily,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontFamily: TypographyTokens.fontFamily,
                ),
              )
            : null,
        trailing: Icon(
          Icons.chevron_right,
          color: AppColors.textTertiary,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      color: AppColors.surface,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(Radii.sm),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            fontFamily: TypographyTokens.fontFamily,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontFamily: TypographyTokens.fontFamily,
                ),
              )
            : null,
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('언어 선택'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Text('🇰🇷'),
              title: const Text('한국어'),
              trailing: const Icon(Icons.check, color: AppColors.primary),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Text('🇺🇸'),
              title: const Text('English'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Text('🇯🇵'),
              title: const Text('日本語'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showAppInfo(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Idol Support',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.favorite,
          color: Colors.white,
          size: 28,
        ),
      ),
      children: [
        const Text('아이돌과 팬이 함께하는 공간'),
        const SizedBox(height: 8),
        const Text('© 2025 Idol Support'),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃 하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () {
              Navigator.pop(context);
              context.go('/login');
            },
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('계정 삭제'),
        content: const Text(
          '계정을 삭제하면 모든 데이터가 영구적으로 삭제됩니다. 이 작업은 취소할 수 없습니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('계정 삭제 기능은 백엔드 연동 후 활성화됩니다')),
              );
            },
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}

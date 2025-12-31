import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/demo_feedback.dart';
import '../../auth/providers/auth_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _pushNotification = true;
  bool _emailNotification = true;
  bool _marketingNotification = false;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _darkMode = false;
  String _language = '한국어';

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('설정', style: TextStyle(fontSize: Responsive.sp(18))),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 알림 설정
            _buildSectionHeader('알림 설정'),
            _buildSettingCard([
              _buildSwitchTile(
                icon: Icons.notifications_outlined,
                title: '푸시 알림',
                subtitle: '앱 푸시 알림을 받습니다',
                value: _pushNotification,
                onChanged: (v) => setState(() => _pushNotification = v),
              ),
              _buildDivider(),
              _buildSwitchTile(
                icon: Icons.email_outlined,
                title: '이메일 알림',
                subtitle: '이메일로 알림을 받습니다',
                value: _emailNotification,
                onChanged: (v) => setState(() => _emailNotification = v),
              ),
              _buildDivider(),
              _buildSwitchTile(
                icon: Icons.campaign_outlined,
                title: '마케팅 알림',
                subtitle: '이벤트 및 프로모션 정보를 받습니다',
                value: _marketingNotification,
                onChanged: (v) => setState(() => _marketingNotification = v),
              ),
            ]),

            // 소리 및 진동
            _buildSectionHeader('소리 및 진동'),
            _buildSettingCard([
              _buildSwitchTile(
                icon: Icons.volume_up_outlined,
                title: '소리',
                subtitle: '알림 소리를 재생합니다',
                value: _soundEnabled,
                onChanged: (v) => setState(() => _soundEnabled = v),
              ),
              _buildDivider(),
              _buildSwitchTile(
                icon: Icons.vibration_outlined,
                title: '진동',
                subtitle: '알림 시 진동을 울립니다',
                value: _vibrationEnabled,
                onChanged: (v) {
                  setState(() => _vibrationEnabled = v);
                  if (v) HapticFeedback.mediumImpact();
                },
              ),
            ]),

            // 화면 설정
            _buildSectionHeader('화면 설정'),
            _buildSettingCard([
              _buildSwitchTile(
                icon: Icons.dark_mode_outlined,
                title: '다크 모드',
                subtitle: '어두운 테마를 사용합니다',
                value: _darkMode,
                onChanged: (v) {
                  setState(() => _darkMode = v);
                  DemoFeedback.showSettingChanged(context, '다크 모드', v);
                },
              ),
              _buildDivider(),
              _buildNavigationTile(
                icon: Icons.language_outlined,
                title: '언어',
                value: _language,
                onTap: () => _showLanguageDialog(),
              ),
            ]),

            // 계정
            _buildSectionHeader('계정'),
            _buildSettingCard([
              _buildNavigationTile(
                icon: Icons.lock_outline_rounded,
                title: '비밀번호 변경',
                onTap: () => context.push('/settings/change-password'),
              ),
              _buildDivider(),
              _buildNavigationTile(
                icon: Icons.security_outlined,
                title: '개인정보 보호',
                onTap: () => _showPrivacySettings(),
              ),
              _buildDivider(),
              _buildNavigationTile(
                icon: Icons.devices_outlined,
                title: '로그인 기기 관리',
                onTap: () => _showDeviceManagement(),
              ),
            ]),

            // 지원
            _buildSectionHeader('지원'),
            _buildSettingCard([
              _buildNavigationTile(
                icon: Icons.help_outline_rounded,
                title: '자주 묻는 질문',
                onTap: () => _showFAQ(),
              ),
              _buildDivider(),
              _buildNavigationTile(
                icon: Icons.headset_mic_outlined,
                title: '고객센터',
                onTap: () => _showCustomerService(),
              ),
              _buildDivider(),
              _buildNavigationTile(
                icon: Icons.bug_report_outlined,
                title: '버그 신고',
                onTap: () => _showBugReport(),
              ),
            ]),

            // 정보
            _buildSectionHeader('정보'),
            _buildSettingCard([
              _buildNavigationTile(
                icon: Icons.description_outlined,
                title: '이용약관',
                onTap: () => _showTerms(),
              ),
              _buildDivider(),
              _buildNavigationTile(
                icon: Icons.privacy_tip_outlined,
                title: '개인정보 처리방침',
                onTap: () => _showPrivacyPolicy(),
              ),
              _buildDivider(),
              _buildInfoTile(
                icon: Icons.info_outline_rounded,
                title: '앱 버전',
                value: '1.0.0 (1)',
              ),
            ]),

            // 로그아웃 & 탈퇴
            SizedBox(height: Responsive.hp(2)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Responsive.wp(4)),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _showLogoutDialog(),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: Responsive.hp(1.8)),
                        side: const BorderSide(color: AppColors.textSecondary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        '로그아웃',
                        style: TextStyle(
                          fontSize: Responsive.sp(15),
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: Responsive.hp(1.5)),
                  TextButton(
                    onPressed: () => _showDeleteAccountDialog(),
                    child: Text(
                      '회원 탈퇴',
                      style: TextStyle(
                        fontSize: Responsive.sp(13),
                        color: AppColors.textHint,
                        decoration: TextDecoration.underline,
                      ),
                    ),
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        Responsive.wp(4),
        Responsive.hp(2.5),
        Responsive.wp(4),
        Responsive.hp(1),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: Responsive.sp(13),
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildSettingCard(List<Widget> children) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: Responsive.wp(4)),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: Responsive.wp(14),
      endIndent: Responsive.wp(4),
      color: AppColors.border,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: Responsive.wp(4),
        vertical: Responsive.hp(0.5),
      ),
      leading: Container(
        width: Responsive.wp(10),
        height: Responsive.wp(10),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: Responsive.sp(20)),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: Responsive.sp(15),
          fontWeight: FontWeight.w500,
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
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }

  Widget _buildNavigationTile({
    required IconData icon,
    required String title,
    String? value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: Responsive.wp(4),
        vertical: Responsive.hp(0.5),
      ),
      leading: Container(
        width: Responsive.wp(10),
        height: Responsive.wp(10),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: Responsive.sp(20)),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: Responsive.sp(15),
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null)
            Text(
              value,
              style: TextStyle(
                fontSize: Responsive.sp(14),
                color: AppColors.textSecondary,
              ),
            ),
          SizedBox(width: Responsive.wp(1)),
          Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textHint,
            size: Responsive.sp(20),
          ),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: Responsive.wp(4),
        vertical: Responsive.hp(0.5),
      ),
      leading: Container(
        width: Responsive.wp(10),
        height: Responsive.wp(10),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: Responsive.sp(20)),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: Responsive.sp(15),
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Text(
        value,
        style: TextStyle(
          fontSize: Responsive.sp(14),
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    final languages = ['한국어', 'English', '日本語', '中文'];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(Responsive.wp(4)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: Responsive.wp(10),
              height: 4,
              margin: EdgeInsets.only(bottom: Responsive.hp(2)),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              '언어 선택',
              style: TextStyle(
                fontSize: Responsive.sp(18),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: Responsive.hp(2)),
            ...languages.map((lang) => ListTile(
                  title: Text(lang),
                  trailing: _language == lang
                      ? Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () {
                    setState(() => _language = lang);
                    Navigator.pop(context);
                    if (lang != '한국어') {
                      DemoFeedback.showComingSoon(context, '다국어 지원');
                    } else {
                      DemoFeedback.showSuccess(context, '언어가 변경되었습니다');
                    }
                  },
                )),
            SizedBox(height: Responsive.hp(2)),
          ],
        ),
      ),
    );
  }

  void _showPrivacySettings() {
    DemoFeedback.showComingSoon(context, '개인정보 보호 설정');
  }

  void _showDeviceManagement() {
    DemoFeedback.showComingSoon(context, '기기 관리');
  }

  void _showFAQ() {
    DemoFeedback.showComingSoon(context, 'FAQ');
  }

  void _showCustomerService() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(Responsive.wp(4)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: Responsive.wp(10),
              height: 4,
              margin: EdgeInsets.only(bottom: Responsive.hp(2)),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              '고객센터',
              style: TextStyle(
                fontSize: Responsive.sp(18),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: Responsive.hp(3)),
            _buildContactItem(Icons.email_outlined, '이메일', 'support@fansupport.com'),
            SizedBox(height: Responsive.hp(2)),
            _buildContactItem(Icons.phone_outlined, '전화', '1588-0000'),
            SizedBox(height: Responsive.hp(2)),
            _buildContactItem(Icons.access_time, '운영시간', '평일 09:00 - 18:00'),
            SizedBox(height: Responsive.hp(3)),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: Responsive.sp(20)),
        SizedBox(width: Responsive.wp(3)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: Responsive.sp(12),
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: Responsive.sp(15),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showBugReport() {
    DemoFeedback.showSuccess(context, '버그 신고가 접수되었습니다', icon: Icons.bug_report);
  }

  void _showTerms() {
    DemoFeedback.showComingSoon(context, '이용약관');
  }

  void _showPrivacyPolicy() {
    DemoFeedback.showComingSoon(context, '개인정보 처리방침');
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃 하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '취소',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authStateProvider.notifier).logout();
              context.go('/login');
            },
            child: Text(
              '로그아웃',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error),
            SizedBox(width: Responsive.wp(2)),
            const Text('회원 탈퇴'),
          ],
        ),
        content: const Text(
          '탈퇴 시 모든 데이터가 삭제되며 복구할 수 없습니다.\n정말 탈퇴하시겠습니까?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '취소',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              DemoFeedback.showComingSoon(context, '회원 탈퇴');
            },
            child: Text(
              '탈퇴하기',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      backgroundColor: PipoColors.background,
      appBar: AppBar(
        title: const Text('설정'),
        backgroundColor: PipoColors.surface,
        elevation: 0,
      ),
      body: ListView(
        padding: PipoSpacing.screenPadding,
        children: [
          // Appearance Section
          _SectionHeader(title: '화면 설정'),
          const SizedBox(height: PipoSpacing.md),
          _SettingCard(
            children: [
              _SettingTile(
                icon: Icons.brightness_6_outlined,
                title: '다크 모드',
                trailing: Switch(
                  value: themeMode == ThemeMode.dark,
                  onChanged: (_) {
                    ref.read(themeModeProvider.notifier).toggleTheme();
                  },
                  activeColor: PipoColors.primary,
                ),
              ),
              const Divider(height: 1),
              _SettingTile(
                icon: Icons.language_outlined,
                title: '언어',
                subtitle: settings.languageName,
                onTap: () => _showLanguageDialog(context, ref, settings.language),
              ),
              const Divider(height: 1),
              _SettingTile(
                icon: Icons.text_fields_outlined,
                title: '글자 크기',
                subtitle: settings.fontSizeLabel,
                onTap: () => _showFontSizeDialog(context, ref, settings.fontSize),
              ),
            ],
          ),
          const SizedBox(height: PipoSpacing.xxl),

          // Notifications Section
          _SectionHeader(title: '알림 설정'),
          const SizedBox(height: PipoSpacing.md),
          _SettingCard(
            children: [
              _SettingTile(
                icon: Icons.notifications_outlined,
                title: '알림 허용',
                subtitle: '모든 알림을 받습니다',
                trailing: Switch(
                  value: settings.notificationsEnabled,
                  onChanged: (value) {
                    ref
                        .read(settingsProvider.notifier)
                        .toggleNotifications(value);
                  },
                  activeColor: PipoColors.primary,
                ),
              ),
              if (settings.notificationsEnabled) ...[
                const Divider(height: 1),
                _SettingTile(
                  icon: Icons.push_pin_outlined,
                  title: '푸시 알림',
                  subtitle: '실시간 알림을 받습니다',
                  trailing: Switch(
                    value: settings.pushNotificationsEnabled,
                    onChanged: (value) {
                      ref
                          .read(settingsProvider.notifier)
                          .togglePushNotifications(value);
                    },
                    activeColor: PipoColors.primary,
                  ),
                ),
                const Divider(height: 1),
                _SettingTile(
                  icon: Icons.email_outlined,
                  title: '이메일 알림',
                  subtitle: '중요한 소식을 이메일로 받습니다',
                  trailing: Switch(
                    value: settings.emailNotificationsEnabled,
                    onChanged: (value) {
                      ref
                          .read(settingsProvider.notifier)
                          .toggleEmailNotifications(value);
                    },
                    activeColor: PipoColors.primary,
                  ),
                ),
                const Divider(height: 1),
                _SettingTile(
                  icon: Icons.volume_up_outlined,
                  title: '소리',
                  trailing: Switch(
                    value: settings.soundEnabled,
                    onChanged: (value) {
                      ref.read(settingsProvider.notifier).toggleSound(value);
                    },
                    activeColor: PipoColors.primary,
                  ),
                ),
                const Divider(height: 1),
                _SettingTile(
                  icon: Icons.vibration_outlined,
                  title: '진동',
                  trailing: Switch(
                    value: settings.vibrationEnabled,
                    onChanged: (value) {
                      ref.read(settingsProvider.notifier).toggleVibration(value);
                    },
                    activeColor: PipoColors.primary,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: PipoSpacing.xxl),

          // Data & Performance Section
          _SectionHeader(title: '데이터 및 성능'),
          const SizedBox(height: PipoSpacing.md),
          _SettingCard(
            children: [
              _SettingTile(
                icon: Icons.data_saver_off_outlined,
                title: '데이터 절약 모드',
                subtitle: '이미지 품질을 낮추고 자동 재생을 끕니다',
                trailing: Switch(
                  value: settings.dataSaverMode,
                  onChanged: (value) {
                    ref.read(settingsProvider.notifier).toggleDataSaver(value);
                  },
                  activeColor: PipoColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: PipoSpacing.xxl),

          // About Section
          _SectionHeader(title: '정보'),
          const SizedBox(height: PipoSpacing.md),
          _SettingCard(
            children: [
              _SettingTile(
                icon: Icons.info_outline,
                title: '앱 버전',
                subtitle: '1.0.0',
                onTap: () {},
              ),
              const Divider(height: 1),
              _SettingTile(
                icon: Icons.description_outlined,
                title: '이용약관',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('이용약관 페이지 준비 중입니다')),
                  );
                },
              ),
              const Divider(height: 1),
              _SettingTile(
                icon: Icons.privacy_tip_outlined,
                title: '개인정보 처리방침',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('개인정보 처리방침 페이지 준비 중입니다')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: PipoSpacing.xxl),

          // Reset Button
          TextButton(
            onPressed: () => _showResetDialog(context, ref),
            style: TextButton.styleFrom(
              foregroundColor: PipoColors.error,
              padding: const EdgeInsets.symmetric(vertical: PipoSpacing.lg),
            ),
            child: const Text(
              '설정 초기화',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: PipoSpacing.xxxl),
        ],
      ),
    );
  }

  void _showLanguageDialog(
      BuildContext context, WidgetRef ref, String currentLanguage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('언어 선택'),
        contentPadding: const EdgeInsets.symmetric(vertical: PipoSpacing.lg),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LanguageOption(
              language: 'ko',
              label: '한국어',
              isSelected: currentLanguage == 'ko',
              onTap: () {
                ref.read(settingsProvider.notifier).setLanguage('ko');
                Navigator.pop(context);
              },
            ),
            _LanguageOption(
              language: 'en',
              label: 'English',
              isSelected: currentLanguage == 'en',
              onTap: () {
                ref.read(settingsProvider.notifier).setLanguage('en');
                Navigator.pop(context);
              },
            ),
            _LanguageOption(
              language: 'ja',
              label: '日本語',
              isSelected: currentLanguage == 'ja',
              onTap: () {
                ref.read(settingsProvider.notifier).setLanguage('ja');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFontSizeDialog(
      BuildContext context, WidgetRef ref, double currentSize) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('글자 크기'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _FontSizeOption(
              size: 14.0,
              label: '작게',
              isSelected: currentSize == 14.0,
              onTap: () {
                ref.read(settingsProvider.notifier).setFontSize(14.0);
                Navigator.pop(context);
              },
            ),
            _FontSizeOption(
              size: 16.0,
              label: '보통',
              isSelected: currentSize == 16.0,
              onTap: () {
                ref.read(settingsProvider.notifier).setFontSize(16.0);
                Navigator.pop(context);
              },
            ),
            _FontSizeOption(
              size: 18.0,
              label: '크게',
              isSelected: currentSize == 18.0,
              onTap: () {
                ref.read(settingsProvider.notifier).setFontSize(18.0);
                Navigator.pop(context);
              },
            ),
            _FontSizeOption(
              size: 20.0,
              label: '매우 크게',
              isSelected: currentSize == 20.0,
              onTap: () {
                ref.read(settingsProvider.notifier).setFontSize(20.0);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('설정 초기화'),
        content: const Text('모든 설정을 초기화하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              ref.read(settingsProvider.notifier).resetToDefaults();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('설정이 초기화되었습니다')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: PipoColors.error),
            child: const Text('초기화'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: PipoSpacing.sm),
      child: Text(
        title,
        style: PipoTypography.labelLarge.copyWith(
          color: PipoColors.textSecondary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SettingCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PipoColors.surface,
        borderRadius: BorderRadius.circular(PipoRadius.xl),
        boxShadow: PipoShadows.sm,
      ),
      child: Column(children: children),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: PipoColors.primarySoft,
          borderRadius: BorderRadius.circular(PipoRadius.md),
        ),
        child: Icon(icon, color: PipoColors.primary, size: 22),
      ),
      title: Text(
        title,
        style: PipoTypography.bodyLarge.copyWith(
          color: PipoColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: PipoTypography.bodySmall.copyWith(
                color: PipoColors.textSecondary,
              ),
            )
          : null,
      trailing: trailing ??
          (onTap != null
              ? const Icon(Icons.chevron_right, color: PipoColors.textTertiary)
              : null),
      onTap: onTap,
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String language;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.language,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      trailing: isSelected
          ? const Icon(Icons.check, color: PipoColors.primary)
          : null,
      onTap: onTap,
    );
  }
}

class _FontSizeOption extends StatelessWidget {
  final double size;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FontSizeOption({
    required this.size,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        label,
        style: TextStyle(fontSize: size),
      ),
      trailing: isSelected
          ? const Icon(Icons.check, color: PipoColors.primary)
          : null,
      onTap: onTap,
    );
  }
}

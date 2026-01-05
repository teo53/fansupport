import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';

/// 🎨 PIPO - Bubble Style Login Screen
/// 애니메이션 + 깔끔한 UI + Coral Pink
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _slideController.forward();
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    HapticFeedback.mediumImpact();
    if (_formKey.currentState!.validate()) {
      await ref.read(authStateProvider.notifier).login(
            _emailController.text.trim(),
            _passwordController.text,
          );
    }
  }

  Future<void> _handleDemoLogin() async {
    HapticFeedback.mediumImpact();
    // Show Role Selection Modal (Bubble Style)
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.all(Responsive.wp(6)),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)), // Bubble style
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle Bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Title
            Text(
              '데모 로그인 계정 선택',
              style: TextStyle(
                fontSize: 24, // Bubble style - larger
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '아래 계정 중 하나를 선택하여 앱을 체험해보세요',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // Demo Role Options (Bubble Style)
            _buildDemoRoleOption(
              icon: Icons.favorite_rounded,
              title: '팬 (Fan)',
              subtitle: '아이돌을 후원하고 소통하는 사용자',
              color: AppColors.primary,
              isFeatured: true,
              onTap: () {
                Navigator.pop(context);
                ref.read(authStateProvider.notifier).loginAsDemo('FAN');
              },
            ),
            const SizedBox(height: 12),
            _buildDemoRoleOption(
              icon: Icons.star_rounded,
              title: '아이돌 (Idol)',
              subtitle: '팬들과 소통하고 후원을 받는 아이돌',
              color: AppColors.secondary,
              onTap: () {
                Navigator.pop(context);
                ref.read(authStateProvider.notifier).loginAsDemo('IDOL');
              },
            ),
            const SizedBox(height: 12),
            _buildDemoRoleOption(
              icon: Icons.business_rounded,
              title: '소속사 (Agency)',
              subtitle: '아이돌을 관리하고 통계를 확인하는 소속사',
              color: AppColors.textPrimary,
              onTap: () {
                Navigator.pop(context);
                ref.read(authStateProvider.notifier).loginAsDemo('AGENCY');
              },
            ),
            SizedBox(height: Responsive.hp(4)),
          ],
        ),
      ),
    );
  }

  /// 🎨 Demo Role Option Card (Bubble Style)
  Widget _buildDemoRoleOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool isFeatured = false,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(20), // Bubble style - wider padding
        decoration: BoxDecoration(
          color: color.withValues(alpha: isFeatured ? 0.08 : 0.04),
          borderRadius: BorderRadius.circular(20), // Bubble style
          border: Border.all(
            color: color.withValues(alpha: isFeatured ? 0.3 : 0.15),
            width: isFeatured ? 2.0 : 1.0,
          ),
          boxShadow: isFeatured
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16), // Bubble style
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: color.withValues(alpha: 0.5),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final authState = ref.watch(authStateProvider);
    final isLoading = authState.value?.isLoading ?? false;
    final error = authState.value?.error;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: Responsive.wp(6)),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: Responsive.hp(4)),

                      // ============================================
                      // 🎨 Logo (Bubble Style with Gradient)
                      // ============================================
                      Center(
                        child: Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(28), // Bubble style
                            boxShadow: AppColors.glowShadow(
                              AppColors.primary,
                              opacity: 0.25,
                            ),
                          ),
                          child: const Icon(
                            Icons.favorite_rounded,
                            color: Colors.white,
                            size: 48,
                          ),
                        ),
                      ),
                      SizedBox(height: Responsive.hp(3)),

                      // ============================================
                      // 📝 Title
                      // ============================================
                      Text(
                        'PIPO',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 40, // Bubble style - larger
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          letterSpacing: -1.5,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '좋아하는 아이돌을 응원하세요',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                          letterSpacing: -0.2,
                        ),
                      ),
                      SizedBox(height: Responsive.hp(5)),

                      // ============================================
                      // ⚠️ Error Message
                      // ============================================
                      if (error != null) ...[
                        Container(
                          padding: const EdgeInsets.all(18), // Bubble style
                          decoration: BoxDecoration(
                            color: AppColors.errorSoft,
                            borderRadius: BorderRadius.circular(16), // Bubble style
                            border: Border.all(
                              color: AppColors.error.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline_rounded,
                                color: AppColors.error,
                                size: 22,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  error,
                                  style: TextStyle(
                                    color: AppColors.error,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: Responsive.hp(2)),
                      ],

                      // ============================================
                      // ✏️ Email Field (CustomTextField)
                      // ============================================
                      CustomTextField(
                        controller: _emailController,
                        label: '이메일',
                        hintText: 'example@email.com',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '이메일을 입력해주세요';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                            return '올바른 이메일 형식이 아닙니다';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: Responsive.hp(2)),

                      // ============================================
                      // 🔒 Password Field (CustomTextField)
                      // ============================================
                      CustomTextField(
                        controller: _passwordController,
                        label: '비밀번호',
                        hintText: '비밀번호를 입력하세요',
                        obscureText: _obscurePassword,
                        prefixIcon: Icons.lock_outlined,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _handleLogin(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '비밀번호를 입력해주세요';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: Responsive.hp(3)),

                      // ============================================
                      // 🔵 Login Button (CustomButton - Gradient)
                      // ============================================
                      GradientButton(
                        onPressed: isLoading ? null : _handleLogin,
                        text: '로그인',
                        height: 60,
                        gradient: AppColors.ctaGradient, // CTA gradient
                        isLoading: isLoading,
                        enableGlow: true,
                      ),
                      SizedBox(height: Responsive.hp(2)),

                      // ============================================
                      // 🎯 Demo Login Button
                      // ============================================
                      CustomButton(
                        onPressed: isLoading ? null : _handleDemoLogin,
                        text: '데모 계정으로 체험하기',
                        height: 60,
                        isOutlined: true,
                        backgroundColor: Colors.transparent,
                        foregroundColor: AppColors.primary,
                        prefixIcon: Icons.rocket_launch_rounded,
                      ),
                      SizedBox(height: Responsive.hp(3)),

                      // ============================================
                      // 📌 Divider
                      // ============================================
                      Row(
                        children: [
                          Expanded(
                            child: Divider(color: AppColors.border, thickness: 1),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              '또는',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(color: AppColors.border, thickness: 1),
                          ),
                        ],
                      ),
                      SizedBox(height: Responsive.hp(3)),

                      // ============================================
                      // 🔗 Register Link
                      // ============================================
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '계정이 없으신가요?',
                            style: TextStyle(
                              fontSize: 15,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.go('/register'),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                            ),
                            child: Text(
                              '회원가입',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: Responsive.hp(4)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

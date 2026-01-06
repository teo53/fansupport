import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/design_system.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
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
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '체험 계정 선택',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDemoOption(
              icon: Icons.person,
              title: '일반 팬',
              color: PipoColors.primary,
              onTap: () {
                Navigator.pop(context);
                ref.read(authStateProvider.notifier).loginAsDemo('FAN');
              },
            ),
            const SizedBox(height: 10),
            _buildDemoOption(
              icon: Icons.star,
              title: '아이돌',
              color: PipoColors.purple,
              onTap: () {
                Navigator.pop(context);
                ref.read(authStateProvider.notifier).loginAsDemo('IDOL');
              },
            ),
            const SizedBox(height: 10),
            _buildDemoOption(
              icon: Icons.business,
              title: '소속사',
              color: PipoColors.teal,
              onTap: () {
                Navigator.pop(context);
                ref.read(authStateProvider.notifier).loginAsDemo('AGENCY');
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoOption({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const Spacer(),
            Icon(Icons.chevron_right, color: color.withOpacity(0.6)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isLoading = authState.value?.isLoading ?? false;
    final error = authState.value?.error;
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: PipoColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Top spacing (flexible)
                  SizedBox(height: screenHeight * 0.05),

                  // Logo & Title (compact)
                  _buildCompactHeader(),

                  SizedBox(height: screenHeight * 0.03),

                  // Error message
                  if (error != null) ...[
                    _buildErrorMessage(error),
                    const SizedBox(height: 12),
                  ],

                  // Login form (expanded to fill space)
                  Expanded(
                    child: Column(
                      children: [
                        // Email field
                        CustomTextField(
                          controller: _emailController,
                          hintText: '이메일',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_outlined,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '이메일을 입력해주세요';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // Password field
                        CustomTextField(
                          controller: _passwordController,
                          hintText: '비밀번호',
                          obscureText: _obscurePassword,
                          prefixIcon: Icons.lock_outlined,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: PipoColors.textTertiary,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() => _obscurePassword = !_obscurePassword);
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '비밀번호를 입력해주세요';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),

                        // Forgot password
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {},
                            child: Text(
                              '비밀번호 찾기',
                              style: TextStyle(
                                fontSize: 13,
                                color: PipoColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),

                        const Spacer(),

                        // Buttons
                        _buildButtons(isLoading),

                        SizedBox(height: bottomPadding > 0 ? 8 : 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactHeader() {
    return Column(
      children: [
        // Logo box
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: PipoColors.primary.withOpacity(0.2),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'PIPO',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: PipoColors.primary,
                fontStyle: FontStyle.italic,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'PIPO',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: PipoColors.primary,
            fontStyle: FontStyle.italic,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '좋아하는 크리에이터를 응원하세요',
          style: TextStyle(
            fontSize: 14,
            color: PipoColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(String error) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: PipoColors.errorLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: PipoColors.error, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(color: PipoColors.error, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons(bool isLoading) {
    return Column(
      children: [
        // Login button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: GradientButton(
            onPressed: isLoading ? null : _handleLogin,
            isLoading: isLoading,
            child: const Text('로그인', style: TextStyle(fontSize: 16)),
          ),
        ),
        const SizedBox(height: 10),

        // Demo button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            onPressed: isLoading ? null : _handleDemoLogin,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: PipoColors.primary.withOpacity(0.3)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.rocket_launch_rounded,
                    color: PipoColors.primary, size: 18),
                const SizedBox(width: 8),
                Text(
                  '체험하기',
                  style: TextStyle(
                    color: PipoColors.primary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Divider
        Row(
          children: [
            Expanded(child: Divider(color: PipoColors.border)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                '간편 로그인',
                style: TextStyle(
                  color: PipoColors.textTertiary,
                  fontSize: 12,
                ),
              ),
            ),
            Expanded(child: Divider(color: PipoColors.border)),
          ],
        ),
        const SizedBox(height: 16),

        // Social buttons row
        Row(
          children: [
            Expanded(child: _buildSocialButton('카카오', AppColors.kakao, Colors.black)),
            const SizedBox(width: 10),
            Expanded(child: _buildSocialButton('N', AppColors.naver, Colors.white)),
            const SizedBox(width: 10),
            Expanded(child: _buildSocialButton('G', Colors.white, AppColors.google, hasBorder: true)),
            const SizedBox(width: 10),
            Expanded(child: _buildSocialButton('', AppColors.apple, Colors.white, icon: Icons.apple)),
          ],
        ),
        const SizedBox(height: 20),

        // Register link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '계정이 없으신가요? ',
              style: TextStyle(fontSize: 14, color: PipoColors.textSecondary),
            ),
            GestureDetector(
              onTap: () => context.go('/register'),
              child: Text(
                '회원가입',
                style: TextStyle(
                  fontSize: 14,
                  color: PipoColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton(String text, Color bgColor, Color textColor,
      {bool hasBorder = false, IconData? icon}) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('준비 중입니다'), duration: Duration(seconds: 1)),
        );
      },
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: hasBorder ? Border.all(color: PipoColors.border) : null,
        ),
        child: Center(
          child: icon != null
              ? Icon(icon, color: textColor, size: 22)
              : Text(
                  text,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    );
  }
}

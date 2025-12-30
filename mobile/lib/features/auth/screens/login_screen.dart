import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';

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
      _slideController.forward();
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
    await ref.read(authStateProvider.notifier).loginAsDemo();
  }

  Future<void> _handleSocialLogin(String provider) async {
    HapticFeedback.lightImpact();
    // TODO: Implement social login
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$provider 로그인 준비 중입니다'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
      body: Stack(
        children: [
          // Background Decorations
          _buildBackgroundDecorations(),

          // Main Content
          SafeArea(
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
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: Responsive.hp(8)),

                        // Logo & Title
                        _buildHeader(),
                        SizedBox(height: Responsive.hp(5)),

                        // Error Message
                        if (error != null) ...[
                          _buildErrorMessage(error),
                          SizedBox(height: Responsive.hp(2)),
                        ],

                        // Login Form Card
                        _buildLoginForm(),
                        SizedBox(height: Responsive.hp(2.5)),

                        // Demo Button
                        _buildDemoButton(isLoading),
                        SizedBox(height: Responsive.hp(3)),

                        // Divider
                        _buildDivider(),
                        SizedBox(height: Responsive.hp(3)),

                        // Social Login Buttons
                        _buildSocialButtons(),
                        SizedBox(height: Responsive.hp(4)),

                        // Register Link
                        _buildRegisterLink(),
                        SizedBox(height: Responsive.hp(4)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundDecorations() {
    return Stack(
      children: [
        // Top gradient circle
        Positioned(
          top: -Responsive.hp(15),
          right: -Responsive.wp(20),
          child: Container(
            width: Responsive.wp(80),
            height: Responsive.wp(80),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.15),
                  AppColors.primary.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
        // Bottom gradient circle
        Positioned(
          bottom: -Responsive.hp(10),
          left: -Responsive.wp(30),
          child: Container(
            width: Responsive.wp(70),
            height: Responsive.wp(70),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.secondary.withValues(alpha: 0.1),
                  AppColors.secondary.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
        // Accent dots
        Positioned(
          top: Responsive.hp(20),
          left: Responsive.wp(10),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.neonPink.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          top: Responsive.hp(35),
          right: Responsive.wp(15),
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.neonPurple.withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Column(
        children: [
          // Animated Logo
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.8, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (context, scale, child) {
              return Transform.scale(scale: scale, child: child);
            },
            child: Container(
              width: Responsive.wp(22),
              height: Responsive.wp(22),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(Responsive.wp(6)),
                boxShadow: AppColors.glowShadow(AppColors.primary),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Shimmer effect
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Responsive.wp(6)),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.2),
                          Colors.transparent,
                          Colors.white.withValues(alpha: 0.1),
                        ],
                      ),
                    ),
                  ),
                  Icon(
                    Icons.favorite_rounded,
                    color: Colors.white,
                    size: Responsive.wp(11),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: Responsive.hp(3)),

          // App Name with Gradient
          ShaderMask(
            shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
            child: Text(
              '아이돌 서포트',
              style: TextStyle(
                fontSize: Responsive.sp(30),
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
                fontFamily: 'Pretendard',
              ),
            ),
          ),
          SizedBox(height: Responsive.hp(1)),
          Text(
            '좋아하는 아이돌을 응원하세요',
            style: TextStyle(
              fontSize: Responsive.sp(15),
              color: AppColors.textSecondary,
              fontFamily: 'Pretendard',
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(String error) {
    return Container(
      padding: EdgeInsets.all(Responsive.wp(4)),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.error_outline_rounded,
              color: AppColors.error,
              size: Responsive.sp(20),
            ),
          ),
          SizedBox(width: Responsive.wp(3)),
          Expanded(
            child: Text(
              error,
              style: TextStyle(
                color: AppColors.error,
                fontSize: Responsive.sp(13),
                fontWeight: FontWeight.w500,
                fontFamily: 'Pretendard',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    final authState = ref.watch(authStateProvider);
    final isLoading = authState.value?.isLoading ?? false;

    return Container(
      padding: EdgeInsets.all(Responsive.wp(5)),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: AppColors.softShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email Field
          _buildInputLabel('이메일'),
          SizedBox(height: Responsive.hp(1)),
          CustomTextField(
            controller: _emailController,
            hintText: 'example@email.com',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '이메일을 입력해주세요';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return '올바른 이메일 형식이 아닙니다';
              }
              return null;
            },
          ),
          SizedBox(height: Responsive.hp(2)),

          // Password Field
          _buildInputLabel('비밀번호'),
          SizedBox(height: Responsive.hp(1)),
          CustomTextField(
            controller: _passwordController,
            hintText: '비밀번호를 입력하세요',
            obscureText: _obscurePassword,
            prefixIcon: Icons.lock_outlined,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.textTertiary,
              ),
              onPressed: () {
                HapticFeedback.selectionClick();
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
          SizedBox(height: Responsive.hp(1.5)),

          // Forgot Password
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                context.push('/forgot-password');
              },
              child: Text(
                '비밀번호를 잊으셨나요?',
                style: TextStyle(
                  fontSize: Responsive.sp(13),
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Pretendard',
                ),
              ),
            ),
          ),
          SizedBox(height: Responsive.hp(2.5)),

          // Login Button
          GradientButton(
            onPressed: isLoading ? null : _handleLogin,
            isLoading: isLoading,
            height: 54,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '로그인',
                  style: TextStyle(fontSize: Responsive.sp(16)),
                ),
                if (!isLoading) ...[
                  SizedBox(width: Responsive.wp(2)),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: Responsive.sp(18),
                    color: Colors.white,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: Responsive.sp(14),
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        fontFamily: 'Pretendard',
      ),
    );
  }

  Widget _buildDemoButton(bool isLoading) {
    return GestureDetector(
      onTap: isLoading ? null : _handleDemoLogin,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          gradient: AppColors.neonGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.neonPink.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
              spreadRadius: -4,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Shimmer overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.15),
                    Colors.transparent,
                    Colors.white.withValues(alpha: 0.1),
                  ],
                ),
              ),
            ),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.rocket_launch_rounded,
                    color: Colors.white,
                    size: Responsive.sp(20),
                  ),
                  SizedBox(width: Responsive.wp(2)),
                  Text(
                    '데모로 체험하기',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: Responsive.sp(16),
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Pretendard',
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.border,
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: Responsive.wp(4)),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.backgroundAlt,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              '간편 로그인',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: Responsive.sp(12),
                fontWeight: FontWeight.w500,
                fontFamily: 'Pretendard',
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.border,
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Column(
      children: [
        // Kakao
        SocialButton.kakao(
          onPressed: () => _handleSocialLogin('카카오'),
        ),
        SizedBox(height: Responsive.hp(1.5)),

        // Row of Naver, Google, Apple
        Row(
          children: [
            Expanded(
              child: _buildCompactSocialButton(
                icon: Text(
                  'N',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: AppColors.naver,
                onTap: () => _handleSocialLogin('네이버'),
              ),
            ),
            SizedBox(width: Responsive.wp(3)),
            Expanded(
              child: _buildCompactSocialButton(
                icon: Text(
                  'G',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.google,
                  ),
                ),
                backgroundColor: Colors.white,
                hasBorder: true,
                onTap: () => _handleSocialLogin('Google'),
              ),
            ),
            SizedBox(width: Responsive.wp(3)),
            Expanded(
              child: _buildCompactSocialButton(
                icon: Icon(Icons.apple, color: Colors.white, size: 22),
                backgroundColor: AppColors.apple,
                onTap: () => _handleSocialLogin('Apple'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompactSocialButton({
    required Widget icon,
    required Color backgroundColor,
    required VoidCallback onTap,
    bool hasBorder = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: hasBorder ? Border.all(color: AppColors.border) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(child: icon),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '계정이 없으신가요?',
            style: TextStyle(
              fontSize: Responsive.sp(14),
              color: AppColors.textSecondary,
              fontFamily: 'Pretendard',
            ),
          ),
          SizedBox(width: Responsive.wp(1)),
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              context.go('/register');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '회원가입',
                style: TextStyle(
                  fontSize: Responsive.sp(14),
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontFamily: 'Pretendard',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

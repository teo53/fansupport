import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../../core/theme/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _floatController;
  late AnimationController _pulseController;

  final List<OnboardingData> _pages = [
    OnboardingData(
      icon: Icons.favorite_rounded,
      title: '좋아하는 아이돌을\n응원하세요',
      subtitle: '지하 아이돌, 메이드카페, VTuber까지\n다양한 크리에이터를 후원할 수 있어요',
      gradient: const LinearGradient(
        colors: [Color(0xFFFF5A5F), Color(0xFFE84C51)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      backgroundColor: const Color(0xFF1a1a2e),
    ),
    OnboardingData(
      icon: Icons.chat_bubble_rounded,
      title: '특별한 소통을\n경험하세요',
      subtitle: 'Bubble 메시지, 1:1 영상통화,\nVIP 팬미팅까지 다양한 경험이 기다려요',
      gradient: const LinearGradient(
        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      backgroundColor: const Color(0xFF1e1b4b),
    ),
    OnboardingData(
      icon: Icons.campaign_rounded,
      title: '팬들과 함께\n꿈을 이루세요',
      subtitle: '생일 광고, 지하철 광고, 전광판까지\n펀딩으로 함께 만들어가요',
      gradient: const LinearGradient(
        colors: [Color(0xFF14B8A6), Color(0xFF06B6D4)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      backgroundColor: const Color(0xFF0f2a2a),
    ),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    _floatController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _floatController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _nextPage() {
    HapticFeedback.lightImpact();
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    } else {
      widget.onComplete();
    }
  }

  void _skip() {
    HapticFeedback.lightImpact();
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          color: _pages[_currentPage].backgroundColor,
        ),
        child: Stack(
          children: [
            // Animated background elements
            ..._buildBackgroundElements(),

            // Page content
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
                HapticFeedback.selectionClick();
              },
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                return _buildPage(_pages[index], index);
              },
            ),

            // Bottom navigation
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Page indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _pages.length,
                          (index) => _buildIndicator(index),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Buttons
                      Row(
                        children: [
                          // Skip button
                          if (_currentPage < _pages.length - 1)
                            Expanded(
                              child: TextButton(
                                onPressed: _skip,
                                child: Text(
                                  '건너뛰기',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            )
                          else
                            const Expanded(child: SizedBox()),

                          const SizedBox(width: 16),

                          // Next/Start button
                          Expanded(
                            flex: 2,
                            child: _buildNextButton(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBackgroundElements() {
    return [
      // Top gradient orb
      AnimatedBuilder(
        animation: _floatController,
        builder: (context, child) {
          return Positioned(
            top: -100 + (_floatController.value * 30),
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _pages[_currentPage].gradient.colors[0].withOpacity(0.3),
                    _pages[_currentPage].gradient.colors[0].withOpacity(0),
                  ],
                ),
              ),
            ),
          );
        },
      ),

      // Bottom gradient orb
      AnimatedBuilder(
        animation: _floatController,
        builder: (context, child) {
          return Positioned(
            bottom: -150 - (_floatController.value * 20),
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _pages[_currentPage].gradient.colors[1].withOpacity(0.2),
                    _pages[_currentPage].gradient.colors[1].withOpacity(0),
                  ],
                ),
              ),
            ),
          );
        },
      ),

      // Floating particles
      ...List.generate(15, (index) => _buildFloatingParticle(index)),
    ];
  }

  Widget _buildFloatingParticle(int index) {
    final random = math.Random(index);
    final size = 4.0 + random.nextDouble() * 8;
    final initialX = random.nextDouble() * MediaQuery.of(context).size.width;
    final initialY = random.nextDouble() * MediaQuery.of(context).size.height;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final offset = math.sin((_pulseController.value * 2 * math.pi) + index) * 20;
        final opacity = 0.2 + (math.sin((_pulseController.value * 2 * math.pi) + index) * 0.3);

        return Positioned(
          left: initialX,
          top: initialY + offset,
          child: Opacity(
            opacity: opacity.clamp(0.1, 0.5),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPage(OnboardingData data, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),

          // Animated icon
          AnimatedBuilder(
            animation: _floatController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, math.sin(_floatController.value * math.pi) * 15),
                child: child,
              );
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Glow effect
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      width: 160 + (_pulseController.value * 40),
                      height: 160 + (_pulseController.value * 40),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            data.gradient.colors[0].withOpacity(0.3 - (_pulseController.value * 0.2)),
                            data.gradient.colors[0].withOpacity(0),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // Icon container
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    gradient: data.gradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: data.gradient.colors[0].withOpacity(0.5),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Icon(
                    data.icon,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 60),

          // Title
          TweenAnimationBuilder<double>(
            key: ValueKey('title_$index'),
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 30 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Text(
              data.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.3,
                letterSpacing: -0.5,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Subtitle
          TweenAnimationBuilder<double>(
            key: ValueKey('subtitle_$index'),
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Text(
              data.subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.white.withOpacity(0.7),
                height: 1.6,
              ),
            ),
          ),

          const Spacer(flex: 3),
        ],
      ),
    );
  }

  Widget _buildIndicator(int index) {
    final isActive = index == _currentPage;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 32 : 8,
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        gradient: isActive ? _pages[_currentPage].gradient : null,
        color: isActive ? null : Colors.white.withOpacity(0.3),
      ),
    );
  }

  Widget _buildNextButton() {
    final isLastPage = _currentPage == _pages.length - 1;

    return GestureDetector(
      onTap: _nextPage,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 56,
        decoration: BoxDecoration(
          gradient: _pages[_currentPage].gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _pages[_currentPage].gradient.colors[0].withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isLastPage ? '시작하기' : '다음',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isLastPage ? Icons.rocket_launch_rounded : Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingData {
  final IconData icon;
  final String title;
  final String subtitle;
  final LinearGradient gradient;
  final Color backgroundColor;

  const OnboardingData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.backgroundColor,
  });
}

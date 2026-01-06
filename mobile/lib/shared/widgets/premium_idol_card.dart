import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/design_system.dart';
import '../../core/utils/responsive.dart';

/// Premium Idol Card - WOW 효과가 적용된 아이돌 카드
/// 3D 틸트, 글로우, 패럴랙스 효과가 적용됨
class PremiumIdolCard extends StatefulWidget {
  final String id;
  final String name;
  final String imageUrl;
  final String category;
  final int rank;
  final bool isLive;
  final bool isNew;
  final VoidCallback? onTap;

  const PremiumIdolCard({
    super.key,
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.category,
    this.rank = 0,
    this.isLive = false,
    this.isNew = false,
    this.onTap,
  });

  @override
  State<PremiumIdolCard> createState() => _PremiumIdolCardState();
}

class _PremiumIdolCardState extends State<PremiumIdolCard>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _liveController;
  late Animation<double> _glowAnimation;
  late Animation<double> _liveAnimation;

  double _rotateX = 0;
  double _rotateY = 0;
  bool _isPressed = false;
  double _lightX = 0.5;
  double _lightY = 0.5;

  @override
  void initState() {
    super.initState();

    // 글로우 애니메이션
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _glowAnimation = Tween(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _glowController.repeat(reverse: true);

    // 라이브 펄스 애니메이션
    _liveController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _liveAnimation = Tween(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _liveController, curve: Curves.easeInOut),
    );
    if (widget.isLive) {
      _liveController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    _liveController.dispose();
    super.dispose();
  }

  void _handlePanUpdate(DragUpdateDetails details, Size size) {
    if (!_isPressed) return;
    setState(() {
      _rotateY = ((details.localPosition.dx / size.width) - 0.5) * 20;
      _rotateX = -((details.localPosition.dy / size.height) - 0.5) * 20;
      _lightX = details.localPosition.dx / size.width;
      _lightY = details.localPosition.dy / size.height;
    });
  }

  void _handlePanStart() {
    HapticFeedback.lightImpact();
    setState(() => _isPressed = true);
  }

  void _handlePanEnd() {
    setState(() {
      _isPressed = false;
      _rotateX = 0;
      _rotateY = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            widget.onTap?.call();
          },
          onPanStart: (_) => _handlePanStart(),
          onPanUpdate: (details) => _handlePanUpdate(details, constraints.biggest),
          onPanEnd: (_) => _handlePanEnd(),
          onPanCancel: _handlePanEnd,
          child: AnimatedContainer(
            duration: _isPressed ? Duration.zero : const Duration(milliseconds: 400),
            curve: Curves.easeOutBack,
            transformAlignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.002)
              ..rotateX(_rotateX * math.pi / 180)
              ..rotateY(_rotateY * math.pi / 180)
              ..scale(_isPressed ? 1.02 : 1.0),
            child: Container(
              width: Responsive.wp(42),
              height: Responsive.hp(28),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  // 메인 그림자
                  BoxShadow(
                    color: Colors.black.withOpacity(_isPressed ? 0.3 : 0.15),
                    blurRadius: _isPressed ? 30 : 20,
                    offset: Offset(0, _isPressed ? 15 : 10),
                    spreadRadius: _isPressed ? 5 : 0,
                  ),
                  // 컬러 글로우
                  if (_isPressed)
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 40,
                      spreadRadius: 5,
                    ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // 배경 이미지 (패럴랙스)
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 100),
                      top: -10 + (_rotateX * 0.3),
                      left: -10 + (_rotateY * 0.3),
                      right: -10 - (_rotateY * 0.3),
                      bottom: -10 - (_rotateX * 0.3),
                      child: CachedNetworkImage(
                        imageUrl: widget.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppColors.backgroundAlt,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.backgroundAlt,
                          child: Icon(Icons.person, size: 40, color: AppColors.textTertiary),
                        ),
                      ),
                    ),

                    // 그라데이션 오버레이
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.3),
                            Colors.black.withOpacity(0.8),
                          ],
                          stops: const [0.3, 0.6, 1.0],
                        ),
                      ),
                    ),

                    // 빛 반사 효과
                    if (_isPressed)
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 50),
                        top: 0,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              center: Alignment(_lightX * 2 - 1, _lightY * 2 - 1),
                              radius: 1.0,
                              colors: [
                                Colors.white.withOpacity(0.25),
                                Colors.white.withOpacity(0.0),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // 랭킹 뱃지
                    if (widget.rank > 0)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: _buildRankBadge(),
                      ),

                    // NEW 뱃지
                    if (widget.isNew)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: _buildNewBadge(),
                      ),

                    // LIVE 뱃지
                    if (widget.isLive)
                      Positioned(
                        top: widget.isNew ? 44 : 12,
                        right: 12,
                        child: AnimatedBuilder(
                          animation: _liveAnimation,
                          builder: (context, child) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withOpacity(0.5),
                                    blurRadius: 8 * _liveAnimation.value,
                                    spreadRadius: 2 * (_liveAnimation.value - 1),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'LIVE',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                    // 하단 정보
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 카테고리
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.category,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // 이름
                          Text(
                            widget.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: Responsive.sp(18),
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 홀로그래픽 오버레이
                    AnimatedBuilder(
                      animation: _glowAnimation,
                      builder: (context, child) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(0.05 * _glowAnimation.value),
                                Colors.transparent,
                                AppColors.primary.withOpacity(0.05 * _glowAnimation.value),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRankBadge() {
    final colors = {
      1: [const Color(0xFFFFD700), const Color(0xFFFFA500)], // Gold
      2: [const Color(0xFFC0C0C0), const Color(0xFF808080)], // Silver
      3: [const Color(0xFFCD7F32), const Color(0xFF8B4513)], // Bronze
    };

    final badgeColors = colors[widget.rank] ?? [AppColors.primary, AppColors.primaryDark];

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: badgeColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: badgeColors[0].withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '#${widget.rank}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildNewBadge() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3 + _glowAnimation.value * 0.2),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: const Text(
            'NEW',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        );
      },
    );
  }
}

/// 스켈레톤 버전 (로딩용)
class PremiumIdolCardSkeleton extends StatefulWidget {
  const PremiumIdolCardSkeleton({super.key});

  @override
  State<PremiumIdolCardSkeleton> createState() => _PremiumIdolCardSkeletonState();
}

class _PremiumIdolCardSkeletonState extends State<PremiumIdolCardSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _shimmerAnimation = Tween(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Container(
      width: Responsive.wp(42),
      height: Responsive.hp(28),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(24),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: AnimatedBuilder(
          animation: _shimmerAnimation,
          builder: (context, child) {
            return ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey[300]!,
                    Colors.grey[100]!,
                    Colors.grey[300]!,
                  ],
                  stops: [
                    _shimmerAnimation.value - 1,
                    _shimmerAnimation.value,
                    _shimmerAnimation.value + 1,
                  ],
                ).createShader(bounds);
              },
              blendMode: BlendMode.srcATop,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.grey[200]!,
                      Colors.grey[300]!,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 60,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 100,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';

/// ============================================================
/// WOW EFFECTS - Premium UI Components for PIPO
/// ============================================================

/// 1. 3D 틸트 카드 - 손가락 위치에 따라 기울어지는 효과
class Tilt3DCard extends StatefulWidget {
  final Widget child;
  final double maxTiltAngle;
  final double depth;
  final bool enableGlow;

  const Tilt3DCard({
    super.key,
    required this.child,
    this.maxTiltAngle = 15.0,
    this.depth = 0.002,
    this.enableGlow = true,
  });

  @override
  State<Tilt3DCard> createState() => _Tilt3DCardState();
}

class _Tilt3DCardState extends State<Tilt3DCard> {
  double _rotateX = 0;
  double _rotateY = 0;
  double _glowX = 0.5;
  double _glowY = 0.5;
  bool _isPressed = false;

  void _updateRotation(Offset localPosition, Size size) {
    setState(() {
      // 카드 중심 기준 -1 ~ 1 값으로 정규화
      _rotateY = ((localPosition.dx / size.width) - 0.5) * 2 * widget.maxTiltAngle;
      _rotateX = -((localPosition.dy / size.height) - 0.5) * 2 * widget.maxTiltAngle;
      _glowX = localPosition.dx / size.width;
      _glowY = localPosition.dy / size.height;
    });
  }

  void _resetRotation() {
    setState(() {
      _rotateX = 0;
      _rotateY = 0;
      _isPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        setState(() => _isPressed = true);
        HapticFeedback.lightImpact();
      },
      onPanUpdate: (details) {
        final RenderBox box = context.findRenderObject() as RenderBox;
        _updateRotation(details.localPosition, box.size);
      },
      onPanEnd: (_) => _resetRotation(),
      onPanCancel: _resetRotation,
      child: AnimatedContainer(
        duration: _isPressed ? Duration.zero : const Duration(milliseconds: 400),
        curve: Curves.easeOutBack,
        transformAlignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, widget.depth)
          ..rotateX(_rotateX * math.pi / 180)
          ..rotateY(_rotateY * math.pi / 180)
          ..scale(_isPressed ? 1.02 : 1.0),
        child: Stack(
          children: [
            widget.child,
            // 빛 반사 효과
            if (widget.enableGlow && _isPressed)
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: RadialGradient(
                        center: Alignment(_glowX * 2 - 1, _glowY * 2 - 1),
                        radius: 0.8,
                        colors: [
                          Colors.white.withOpacity(0.3),
                          Colors.white.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 2. 파티클 배경 효과 - 플로팅 파티클 애니메이션
class ParticleBackground extends StatefulWidget {
  final int particleCount;
  final Color color;
  final double maxSize;
  final Widget? child;

  const ParticleBackground({
    super.key,
    this.particleCount = 30,
    this.color = AppColors.primary,
    this.maxSize = 6,
    this.child,
  });

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _Particle {
  double x, y, size, speedX, speedY, opacity;
  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speedX,
    required this.speedY,
    required this.opacity,
  });
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();

    _initParticles();
  }

  void _initParticles() {
    for (int i = 0; i < widget.particleCount; i++) {
      _particles.add(_Particle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * widget.maxSize + 2,
        speedX: (_random.nextDouble() - 0.5) * 0.002,
        speedY: -_random.nextDouble() * 0.003 - 0.001,
        opacity: _random.nextDouble() * 0.5 + 0.2,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            // 파티클 위치 업데이트
            for (var p in _particles) {
              p.x += p.speedX;
              p.y += p.speedY;
              if (p.y < -0.1) {
                p.y = 1.1;
                p.x = _random.nextDouble();
              }
              if (p.x < 0) p.x = 1;
              if (p.x > 1) p.x = 0;
            }

            return CustomPaint(
              painter: _ParticlePainter(
                particles: _particles,
                color: widget.color,
              ),
              size: Size.infinite,
            );
          },
        ),
        if (widget.child != null) widget.child!,
      ],
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final Color color;

  _ParticlePainter({required this.particles, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in particles) {
      final paint = Paint()
        ..color = color.withOpacity(p.opacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(p.x * size.width, p.y * size.height),
        p.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// 3. 스프링 버튼 - 튕기는 효과의 버튼
class SpringButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleDown;
  final Duration duration;

  const SpringButton({
    super.key,
    required this.child,
    this.onTap,
    this.scaleDown = 0.92,
    this.duration = const Duration(milliseconds: 150),
  });

  @override
  State<SpringButton> createState() => _SpringButtonState();
}

class _SpringButtonState extends State<SpringButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: widget.scaleDown)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: widget.scaleDown, end: 1.05)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.05, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 20,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.mediumImpact();
    _controller.forward(from: 0).then((_) {
      widget.onTap?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap != null ? _handleTap : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}

/// 4. 네온 글로우 텍스트
class NeonGlowText extends StatefulWidget {
  final String text;
  final double fontSize;
  final Color glowColor;
  final bool animate;

  const NeonGlowText({
    super.key,
    required this.text,
    this.fontSize = 24,
    this.glowColor = AppColors.primary,
    this.animate = true,
  });

  @override
  State<NeonGlowText> createState() => _NeonGlowTextState();
}

class _NeonGlowTextState extends State<NeonGlowText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _glowAnimation = Tween(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            // 글로우 레이어 1
            Text(
              widget.text,
              style: TextStyle(
                fontSize: widget.fontSize,
                fontWeight: FontWeight.bold,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 6
                  ..color = widget.glowColor.withOpacity(0.2 * _glowAnimation.value),
                shadows: [
                  Shadow(
                    color: widget.glowColor.withOpacity(0.5 * _glowAnimation.value),
                    blurRadius: 20 * _glowAnimation.value,
                  ),
                ],
              ),
            ),
            // 글로우 레이어 2
            Text(
              widget.text,
              style: TextStyle(
                fontSize: widget.fontSize,
                fontWeight: FontWeight.bold,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 3
                  ..color = widget.glowColor.withOpacity(0.5 * _glowAnimation.value),
              ),
            ),
            // 메인 텍스트
            Text(
              widget.text,
              style: TextStyle(
                fontSize: widget.fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// 5. 카드 입장 애니메이션 - 순차적으로 나타나는 효과
class StaggeredListAnimation extends StatelessWidget {
  final List<Widget> children;
  final Duration itemDelay;
  final Duration animationDuration;
  final Offset slideOffset;

  const StaggeredListAnimation({
    super.key,
    required this.children,
    this.itemDelay = const Duration(milliseconds: 100),
    this.animationDuration = const Duration(milliseconds: 400),
    this.slideOffset = const Offset(0, 30),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(children.length, (index) {
        return TweenAnimationBuilder<double>(
          key: ValueKey(index),
          tween: Tween(begin: 0.0, end: 1.0),
          duration: animationDuration,
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(
                slideOffset.dx * (1 - value),
                slideOffset.dy * (1 - value),
              ),
              child: Opacity(
                opacity: value,
                child: children[index],
              ),
            );
          },
        );
      }),
    );
  }
}

/// 6. 쉬머 버튼 - 빛나는 효과가 지나가는 버튼
class ShimmerButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Gradient gradient;
  final BorderRadius borderRadius;

  const ShimmerButton({
    super.key,
    required this.child,
    this.onTap,
    this.gradient = AppColors.primaryGradient,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
  });

  @override
  State<ShimmerButton> createState() => _ShimmerButtonState();
}

class _ShimmerButtonState extends State<ShimmerButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap?.call();
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: widget.gradient,
          borderRadius: widget.borderRadius,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: widget.borderRadius,
          child: Stack(
            children: [
              widget.child,
              // 쉬머 효과
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _shimmerController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(
                        (_shimmerController.value * 3 - 1) * 200,
                        0,
                      ),
                      child: Container(
                        width: 100,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0),
                              Colors.white.withOpacity(0.3),
                              Colors.white.withOpacity(0),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 7. 패럴랙스 스크롤 이미지
class ParallaxImage extends StatelessWidget {
  final String imageUrl;
  final double height;
  final double parallaxFactor;
  final Widget? overlay;

  const ParallaxImage({
    super.key,
    required this.imageUrl,
    this.height = 300,
    this.parallaxFactor = 0.3,
    this.overlay,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ClipRect(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Flow(
                  delegate: _ParallaxFlowDelegate(
                    scrollable: Scrollable.of(context),
                    listItemContext: context,
                    backgroundImageKey: GlobalKey(),
                    parallaxFactor: parallaxFactor,
                  ),
                  children: [
                    Image.network(
                      imageUrl,
                      key: GlobalKey(),
                      height: height * (1 + parallaxFactor),
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
                if (overlay != null) overlay!,
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ParallaxFlowDelegate extends FlowDelegate {
  final ScrollableState scrollable;
  final BuildContext listItemContext;
  final GlobalKey backgroundImageKey;
  final double parallaxFactor;

  _ParallaxFlowDelegate({
    required this.scrollable,
    required this.listItemContext,
    required this.backgroundImageKey,
    required this.parallaxFactor,
  }) : super(repaint: scrollable.position);

  @override
  BoxConstraints getConstraintsForChild(int i, BoxConstraints constraints) {
    return BoxConstraints.tightFor(width: constraints.maxWidth);
  }

  @override
  void paintChildren(FlowPaintingContext context) {
    final scrollableBox = scrollable.context.findRenderObject() as RenderBox;
    final listItemBox = listItemContext.findRenderObject() as RenderBox;
    final listItemOffset = listItemBox.localToGlobal(
      listItemBox.size.centerLeft(Offset.zero),
      ancestor: scrollableBox,
    );

    final viewportDimension = scrollable.position.viewportDimension;
    final scrollFraction = (listItemOffset.dy / viewportDimension).clamp(0.0, 1.0);

    final verticalAlignment = Alignment(0, scrollFraction * 2 - 1);
    final childSize = context.getChildSize(0) ?? Size.zero;

    final backgroundRect = verticalAlignment.inscribe(
      Size(childSize.width, childSize.height * (1 + parallaxFactor)),
      Offset.zero & context.size,
    );

    context.paintChild(
      0,
      transform: Transform.translate(
        offset: Offset(0, backgroundRect.top * parallaxFactor),
      ).transform,
    );
  }

  @override
  bool shouldRepaint(_ParallaxFlowDelegate oldDelegate) {
    return scrollable != oldDelegate.scrollable ||
        listItemContext != oldDelegate.listItemContext ||
        backgroundImageKey != oldDelegate.backgroundImageKey;
  }
}

/// 8. 플로팅 액션 메뉴 - 확장 가능한 FAB
class ExpandableFab extends StatefulWidget {
  final List<FloatingActionButton> children;
  final IconData mainIcon;
  final Color? backgroundColor;

  const ExpandableFab({
    super.key,
    required this.children,
    this.mainIcon = Icons.add,
    this.backgroundColor,
  });

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(widget.children.length, (index) {
          return ScaleTransition(
            scale: CurvedAnimation(
              parent: _controller,
              curve: Interval(
                (index / widget.children.length) * 0.5,
                0.5 + (index / widget.children.length) * 0.5,
                curve: Curves.easeOutBack,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: widget.children[index],
            ),
          );
        }).reversed,
        FloatingActionButton(
          onPressed: _toggle,
          backgroundColor: widget.backgroundColor ?? AppColors.primary,
          child: AnimatedRotation(
            turns: _isOpen ? 0.125 : 0,
            duration: const Duration(milliseconds: 300),
            child: Icon(widget.mainIcon),
          ),
        ),
      ],
    );
  }
}

/// 9. 리플 배지 - 알림 표시용 펄싱 효과
class RippleBadge extends StatefulWidget {
  final int count;
  final Color color;

  const RippleBadge({
    super.key,
    required this.count,
    this.color = AppColors.error,
  });

  @override
  State<RippleBadge> createState() => _RippleBadgeState();
}

class _RippleBadgeState extends State<RippleBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.count <= 0) return const SizedBox.shrink();

    return SizedBox(
      width: 24,
      height: 24,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 리플 효과 1
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: 1 + (_controller.value * 0.5),
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color.withOpacity(0.3 * (1 - _controller.value)),
                  ),
                ),
              );
            },
          ),
          // 리플 효과 2 (지연)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final delayedValue = ((_controller.value + 0.5) % 1.0);
              return Transform.scale(
                scale: 1 + (delayedValue * 0.5),
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color.withOpacity(0.3 * (1 - delayedValue)),
                  ),
                ),
              );
            },
          ),
          // 뱃지 본체
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(0.4),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                widget.count > 99 ? '99+' : widget.count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 10. 그라데이션 보더 카드
class GradientBorderCard extends StatelessWidget {
  final Widget child;
  final double borderWidth;
  final Gradient gradient;
  final BorderRadius borderRadius;
  final Color? backgroundColor;

  const GradientBorderCard({
    super.key,
    required this.child,
    this.borderWidth = 2,
    this.gradient = AppColors.primaryGradient,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        margin: EdgeInsets.all(borderWidth),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(borderRadius.topLeft.x - borderWidth),
          ),
        ),
        child: child,
      ),
    );
  }
}

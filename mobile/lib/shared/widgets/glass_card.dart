import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// A premium glassmorphism card widget with frosted glass effect
/// and optional neon border glow.
class GlassCard extends StatefulWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final bool showNeonBorder;
  final Color? neonColor;
  final double blurAmount;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 24,
    this.showNeonBorder = false,
    this.neonColor,
    this.blurAmount = 20,
    this.onTap,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    if (widget.showNeonBorder) {
      _shimmerController.repeat();
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => _setPressed(true) : null,
      onTapUp: widget.onTap != null ? (_) => _setPressed(false) : null,
      onTapCancel: widget.onTap != null ? () => _setPressed(false) : null,
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: widget.showNeonBorder
                ? AppColors.glowShadow(
                    widget.neonColor ?? AppColors.neonPurple,
                    opacity: 0.4,
                  )
                : AppColors.cardShadow(opacity: 0.08),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: widget.blurAmount,
                sigmaY: widget.blurAmount,
              ),
              child: AnimatedBuilder(
                animation: _shimmerController,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.glassWhite,
                          AppColors.glassOverlay,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                      border: widget.showNeonBorder
                          ? _buildNeonBorder()
                          : Border.all(
                              color: AppColors.glassBorder,
                              width: 1.5,
                            ),
                    ),
                    padding: widget.padding ?? const EdgeInsets.all(16),
                    child: widget.child,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Border _buildNeonBorder() {
    final progress = _shimmerController.value;
    final color = Color.lerp(
      widget.neonColor ?? AppColors.neonPink,
      AppColors.neonCyan,
      progress,
    )!;
    return Border.all(color: color, width: 2);
  }

  void _setPressed(bool pressed) {
    setState(() => _isPressed = pressed);
  }
}

/// A holographic shimmer overlay for photocards
class HolographicOverlay extends StatefulWidget {
  final Widget child;
  final double intensity;

  const HolographicOverlay({
    super.key,
    required this.child,
    this.intensity = 0.3,
  });

  @override
  State<HolographicOverlay> createState() => _HolographicOverlayState();
}

class _HolographicOverlayState extends State<HolographicOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
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
    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return IgnorePointer(
                child: ShaderMask(
                  shaderCallback: (bounds) {
                    return LinearGradient(
                      colors: [
                        AppColors.holoGold.withValues(alpha: widget.intensity),
                        AppColors.holoPink.withValues(alpha: widget.intensity),
                        AppColors.holoBlue.withValues(alpha: widget.intensity),
                        AppColors.holoGreen.withValues(alpha: widget.intensity),
                        AppColors.holoGold.withValues(alpha: widget.intensity),
                      ],
                      stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                      begin: Alignment(
                        -1 + 2 * _controller.value,
                        -1 + 2 * _controller.value,
                      ),
                      end: Alignment(
                        1 + 2 * _controller.value,
                        1 + 2 * _controller.value,
                      ),
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.overlay,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// 3D Flip Card Widget for photocards
class FlipCard3D extends StatefulWidget {
  final Widget front;
  final Widget back;
  final Duration duration;
  final VoidCallback? onFlip;

  const FlipCard3D({
    super.key,
    required this.front,
    required this.back,
    this.duration = const Duration(milliseconds: 600),
    this.onFlip,
  });

  @override
  State<FlipCard3D> createState() => _FlipCard3DState();
}

class _FlipCard3DState extends State<FlipCard3D>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flip() {
    if (_controller.isAnimating) return;

    widget.onFlip?.call();

    if (_showFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    _showFront = !_showFront;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flip,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * 3.14159;
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle);

          return Transform(
            transform: transform,
            alignment: Alignment.center,
            child: _animation.value < 0.5
                ? widget.front
                : Transform(
                    transform: Matrix4.identity()..rotateY(3.14159),
                    alignment: Alignment.center,
                    child: widget.back,
                  ),
          );
        },
      ),
    );
  }
}

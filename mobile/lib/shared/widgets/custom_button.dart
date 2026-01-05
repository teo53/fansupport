import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';

/// 🎨 PIPO - Bubble Style Buttons
/// Coral Pink 기반의 트렌디한 버튼 컴포넌트

// ============================================
// 🔘 CustomButton (Primary/Outlined)
// ============================================
class CustomButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isLoading;
  final bool isOutlined;
  final double? width;
  final double height;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final bool enableGlow;

  const CustomButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isLoading = false,
    this.isOutlined = false,
    this.width,
    this.height = 60, // Bubble style - 56px → 60px
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
    this.padding,
    this.enableGlow = true,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.forward();
      HapticFeedback.lightImpact();
    }
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.circular(20); // Bubble style - 더 둥글게
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.width ?? double.infinity,
              height: widget.height,
              decoration: BoxDecoration(
                color: widget.isOutlined
                    ? Colors.transparent
                    : (isEnabled
                        ? (widget.backgroundColor ?? AppColors.primary)
                        : AppColors.disabled),
                borderRadius: radius,
                border: widget.isOutlined
                    ? Border.all(
                        color: isEnabled
                            ? (widget.backgroundColor ?? AppColors.primary)
                            : AppColors.disabled,
                        width: 1.5,
                      )
                    : null,
                boxShadow: !widget.isOutlined && isEnabled && widget.enableGlow
                    ? AppColors.glowShadow(
                        widget.backgroundColor ?? AppColors.primary,
                        opacity: 0.20,
                      )
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.isLoading ? null : widget.onPressed,
                  borderRadius: radius,
                  splashColor: widget.isOutlined
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : Colors.white.withValues(alpha: 0.1),
                  highlightColor: widget.isOutlined
                      ? AppColors.primary.withValues(alpha: 0.05)
                      : Colors.white.withValues(alpha: 0.05),
                  child: Padding(
                    padding: widget.padding ??
                        const EdgeInsets.symmetric(horizontal: 28), // 더 넓게
                    child: Center(
                      child: widget.isLoading
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  widget.isOutlined
                                      ? AppColors.primary
                                      : Colors.white,
                                ),
                              ),
                            )
                          : DefaultTextStyle(
                              style: TextStyle(
                                color: widget.isOutlined
                                    ? (widget.foregroundColor ?? AppColors.primary)
                                    : (widget.foregroundColor ?? Colors.white),
                                fontSize: 17, // Bubble style - 더 크게
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Pretendard',
                                letterSpacing: -0.2,
                              ),
                              child: widget.child,
                            ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================================
// 🌟 GradientButton (Premium CTA)
// ============================================
class GradientButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isLoading;
  final double? width;
  final double height;
  final Gradient gradient;
  final BorderRadius? borderRadius;
  final bool enableGlow;
  final bool enableHaptic;

  const GradientButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isLoading = false,
    this.width,
    this.height = 60,
    this.gradient = AppColors.ctaGradient, // CTA gradient 사용
    this.borderRadius,
    this.enableGlow = true,
    this.enableHaptic = true,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _glowAnimation = Tween<double>(begin: 0.20, end: 0.35).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.forward();
      if (widget.enableHaptic) {
        HapticFeedback.mediumImpact();
      }
    }
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.circular(20);
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.width ?? double.infinity,
              height: widget.height,
              decoration: BoxDecoration(
                gradient: isEnabled ? widget.gradient : null,
                color: isEnabled ? null : AppColors.disabled,
                borderRadius: radius,
                boxShadow: isEnabled && widget.enableGlow
                    ? [
                        BoxShadow(
                          color: AppColors.primaryDark
                              .withValues(alpha: _glowAnimation.value),
                          blurRadius: 28,
                          offset: const Offset(0, 10),
                          spreadRadius: -4,
                        ),
                      ]
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.isLoading ? null : widget.onPressed,
                  borderRadius: radius,
                  splashColor: Colors.white.withValues(alpha: 0.2),
                  highlightColor: Colors.white.withValues(alpha: 0.1),
                  child: Center(
                    child: widget.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : DefaultTextStyle(
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Pretendard',
                              letterSpacing: -0.2,
                            ),
                            child: widget.child,
                          ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================================
// ⭕ CircleIconButton (아이콘 버튼)
// ============================================
class CircleIconButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;
  final bool hasShadow;
  final bool hasBorder;

  const CircleIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.size = 52, // Bubble style - 48px → 52px
    this.backgroundColor,
    this.iconColor,
    this.hasShadow = false,
    this.hasBorder = false,
  });

  @override
  State<CircleIconButton> createState() => _CircleIconButtonState();
}

class _CircleIconButtonState extends State<CircleIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (widget.onPressed != null) {
          _controller.forward();
          HapticFeedback.selectionClick();
        }
      },
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? AppColors.backgroundAlt,
            shape: BoxShape.circle,
            border: widget.hasBorder
                ? Border.all(color: AppColors.border, width: 1)
                : null,
            boxShadow: widget.hasShadow ? AppColors.softShadow() : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onPressed,
              borderRadius: BorderRadius.circular(widget.size / 2),
              child: Icon(
                widget.icon,
                size: widget.size * 0.45,
                color: widget.iconColor ?? AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================
// 🔑 SocialButton (소셜 로그인)
// ============================================
class SocialButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final Widget icon;
  final Color backgroundColor;
  final Color textColor;
  final bool isLoading;

  const SocialButton({
    super.key,
    required this.onPressed,
    required this.label,
    required this.icon,
    required this.backgroundColor,
    this.textColor = Colors.black,
    this.isLoading = false,
  });

  factory SocialButton.kakao({
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return SocialButton(
      onPressed: onPressed,
      label: '카카오로 계속하기',
      icon: const Text('💬', style: TextStyle(fontSize: 22)),
      backgroundColor: AppColors.kakao,
      textColor: const Color(0xFF381E1F),
      isLoading: isLoading,
    );
  }

  factory SocialButton.naver({
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return SocialButton(
      onPressed: onPressed,
      label: '네이버로 계속하기',
      icon: const Text('N',
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
      backgroundColor: AppColors.naver,
      textColor: Colors.white,
      isLoading: isLoading,
    );
  }

  factory SocialButton.google({
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return SocialButton(
      onPressed: onPressed,
      label: 'Google로 계속하기',
      icon: const Text('G',
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary)),
      backgroundColor: Colors.white,
      textColor: AppColors.textPrimary,
      isLoading: isLoading,
    );
  }

  factory SocialButton.apple({
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return SocialButton(
      onPressed: onPressed,
      label: 'Apple로 계속하기',
      icon: const Icon(Icons.apple, size: 26, color: Colors.white),
      backgroundColor: AppColors.apple,
      textColor: Colors.white,
      isLoading: isLoading,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60, // Bubble style
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20), // 더 둥글게
        border: backgroundColor == Colors.white
            ? Border.all(color: AppColors.border, width: 1.5)
            : null,
        boxShadow: AppColors.softShadow(opacity: 0.03),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                SizedBox(width: 32, child: Center(child: icon)),
                const SizedBox(width: 16),
                Expanded(
                  child: isLoading
                      ? Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(textColor),
                            ),
                          ),
                        )
                      : Text(
                          label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Pretendard',
                            letterSpacing: -0.2,
                          ),
                        ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================
// 🏷️ ChipButton (필터/태그)
// ============================================
class ChipButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? selectedColor;

  const ChipButton({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onPressed,
    this.icon,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = selectedColor ?? AppColors.primary;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onPressed?.call();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: icon != null ? 14 : 18,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color : AppColors.backgroundAlt,
          borderRadius: BorderRadius.circular(16), // Bubble style
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                fontFamily: 'Pretendard',
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

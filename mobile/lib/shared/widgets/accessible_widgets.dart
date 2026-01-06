import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/design_system.dart';
import '../../core/utils/accessibility_helper.dart';

/// Accessible Icon Button with proper semantics
class AccessibleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String semanticsLabel;
  final String? semanticsHint;
  final Color? color;
  final double size;
  final EdgeInsetsGeometry padding;

  const AccessibleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.semanticsLabel,
    this.semanticsHint,
    this.color,
    this.size = 24,
    this.padding = const EdgeInsets.all(12),
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticsLabel,
      hint: semanticsHint,
      child: AccessibilityHelper.ensureMinTapTarget(
        IconButton(
          icon: Icon(icon),
          onPressed: onPressed,
          color: color ?? PipoColors.textPrimary,
          iconSize: size,
          padding: padding,
          tooltip: semanticsLabel,
        ),
      ),
    );
  }
}

/// Accessible Image with proper semantics
class AccessibleImage extends StatelessWidget {
  final String imageUrl;
  final String semanticsLabel;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const AccessibleImage({
    super.key,
    required this.imageUrl,
    required this.semanticsLabel,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    Widget image = Semantics(
      image: true,
      label: semanticsLabel,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => Container(
          width: width,
          height: height,
          color: PipoColors.border,
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          width: width,
          height: height,
          color: PipoColors.backgroundSecondary,
          child: Icon(
            Icons.broken_image_outlined,
            color: PipoColors.textTertiary,
          ),
        ),
      ),
    );

    if (borderRadius != null) {
      image = ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }

    return image;
  }
}

/// Accessible Counter with formatted speech
class AccessibleCounter extends StatelessWidget {
  final int value;
  final String label;
  final TextStyle? valueStyle;
  final TextStyle? labelStyle;

  const AccessibleCounter({
    super.key,
    required this.value,
    required this.label,
    this.valueStyle,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${AccessibilityHelper.formatNumberForScreenReader(value)} $label',
      child: ExcludeSemantics(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AccessibilityHelper.formatCompactNumber(value),
              style: valueStyle ??
                  PipoTypography.titleLarge.copyWith(
                    color: PipoColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: labelStyle ??
                  PipoTypography.caption.copyWith(
                    color: PipoColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Accessible Currency Display
class AccessibleCurrency extends StatelessWidget {
  final int amount;
  final String? prefix;
  final TextStyle? style;

  const AccessibleCurrency({
    super.key,
    required this.amount,
    this.prefix,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AccessibilityHelper.formatCurrencyForScreenReader(amount),
      child: ExcludeSemantics(
        child: Text(
          '${prefix ?? ''}${AccessibilityHelper.formatCompactNumber(amount)}원',
          style: style ??
              PipoTypography.labelLarge.copyWith(
                color: PipoColors.primary,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}

/// Accessible Badge
class AccessibleBadge extends StatelessWidget {
  final String text;
  final String semanticsLabel;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;

  const AccessibleBadge({
    super.key,
    required this.text,
    required this.semanticsLabel,
    this.backgroundColor = PipoColors.primary,
    this.textColor = Colors.white,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel,
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: PipoSpacing.sm,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(PipoRadius.sm),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 12, color: textColor),
                const SizedBox(width: 4),
              ],
              Text(
                text,
                style: PipoTypography.caption.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Accessible Card with proper tap target
class AccessibleCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final String? semanticsLabel;
  final String? semanticsHint;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;

  const AccessibleCard({
    super.key,
    required this.child,
    this.onTap,
    this.semanticsLabel,
    this.semanticsHint,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      padding: padding ?? const EdgeInsets.all(PipoSpacing.lg),
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? PipoColors.surface,
        borderRadius: borderRadius ?? BorderRadius.circular(PipoRadius.xl),
        boxShadow: boxShadow ?? PipoShadows.sm,
      ),
      child: child,
    );

    if (onTap != null) {
      card = Semantics(
        button: true,
        label: semanticsLabel,
        hint: semanticsHint ?? '탭하여 자세히 보기',
        child: AccessibilityHelper.ensureMinTapTarget(
          InkWell(
            onTap: onTap,
            borderRadius:
                borderRadius ?? BorderRadius.circular(PipoRadius.xl),
            child: card,
          ),
        ),
      );
    }

    return card;
  }
}

/// Accessible Toggle (Switch/Checkbox) with label
class AccessibleToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String label;
  final String? description;
  final IconData? icon;

  const AccessibleToggle({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.description,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: value,
      label: label,
      hint: description,
      child: InkWell(
        onTap: () => onChanged(!value),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: PipoSpacing.md,
            horizontal: PipoSpacing.lg,
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: PipoColors.primarySoft,
                    borderRadius: BorderRadius.circular(PipoRadius.md),
                  ),
                  child: Icon(icon, color: PipoColors.primary, size: 22),
                ),
                const SizedBox(width: PipoSpacing.md),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: PipoTypography.bodyLarge.copyWith(
                        color: PipoColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        description!,
                        style: PipoTypography.bodySmall.copyWith(
                          color: PipoColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              ExcludeSemantics(
                child: Switch(
                  value: value,
                  onChanged: onChanged,
                  activeColor: PipoColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

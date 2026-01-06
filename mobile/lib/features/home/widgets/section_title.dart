import 'package:flutter/material.dart';
import '../../../core/theme/design_system.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onTap;

  const SectionTitle({
    super.key,
    required this.title,
    this.actionText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        PipoSpacing.xl, PipoSpacing.xxxl, PipoSpacing.xl, PipoSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: PipoTypography.titleLarge.copyWith(
              color: PipoColors.textPrimary,
            ),
          ),
          if (actionText != null)
            GestureDetector(
              onTap: onTap,
              child: Row(
                children: [
                  Text(
                    actionText!,
                    style: PipoTypography.labelSmall.copyWith(
                      color: PipoColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: PipoColors.primary,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

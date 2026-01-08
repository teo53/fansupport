import 'package:flutter/material.dart';
import '../../../core/theme/design_system.dart';
import '../services/content_filter_service.dart';

/// Widget showing content filter warning
class ContentWarning extends StatelessWidget {
  final ContentFilterResult result;
  final VoidCallback? onDismiss;
  final VoidCallback? onLearnMore;

  const ContentWarning({
    super.key,
    required this.result,
    this.onDismiss,
    this.onLearnMore,
  });

  @override
  Widget build(BuildContext context) {
    if (!result.needsWarning) return const SizedBox.shrink();

    final color = result.severity == ContentSeverity.high
        ? PipoColors.error
        : PipoColors.warning;

    return Container(
      margin: const EdgeInsets.only(top: PipoSpacing.sm),
      padding: const EdgeInsets.all(PipoSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(PipoRadius.md),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                result.severity == ContentSeverity.high
                    ? Icons.error_rounded
                    : Icons.warning_rounded,
                size: 20,
                color: color,
              ),
              const SizedBox(width: PipoSpacing.sm),
              Expanded(
                child: Text(
                  result.severity == ContentSeverity.high
                      ? '요청 불가'
                      : '주의',
                  style: PipoTypography.titleSmall.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (onDismiss != null && result.canProceed)
                GestureDetector(
                  onTap: onDismiss,
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: color,
                  ),
                ),
            ],
          ),
          const SizedBox(height: PipoSpacing.xs),
          Text(
            ContentFilterService().getWarningMessage(result.severity),
            style: PipoTypography.bodySmall.copyWith(
              color: PipoColors.textSecondary,
            ),
          ),
          if (onLearnMore != null) ...[
            const SizedBox(height: PipoSpacing.sm),
            GestureDetector(
              onTap: onLearnMore,
              child: Text(
                '커뮤니티 가이드라인 보기',
                style: PipoTypography.labelSmall.copyWith(
                  color: color,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Inline content filter indicator
class ContentFilterIndicator extends StatelessWidget {
  final bool isFiltering;
  final ContentSeverity? severity;

  const ContentFilterIndicator({
    super.key,
    required this.isFiltering,
    this.severity,
  });

  @override
  Widget build(BuildContext context) {
    if (!isFiltering && severity == null) {
      return const SizedBox.shrink();
    }

    if (isFiltering) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: PipoColors.textTertiary,
            ),
          ),
          const SizedBox(width: PipoSpacing.xs),
          Text(
            '검토 중...',
            style: PipoTypography.labelSmall.copyWith(
              color: PipoColors.textTertiary,
            ),
          ),
        ],
      );
    }

    if (severity == ContentSeverity.none) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            size: 14,
            color: PipoColors.success,
          ),
          const SizedBox(width: PipoSpacing.xs),
          Text(
            '검토 완료',
            style: PipoTypography.labelSmall.copyWith(
              color: PipoColors.success,
            ),
          ),
        ],
      );
    }

    final color = severity == ContentSeverity.high
        ? PipoColors.error
        : PipoColors.warning;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          severity == ContentSeverity.high
              ? Icons.error_outline_rounded
              : Icons.warning_amber_rounded,
          size: 14,
          color: color,
        ),
        const SizedBox(width: PipoSpacing.xs),
        Text(
          severity == ContentSeverity.high ? '부적절한 내용' : '주의 필요',
          style: PipoTypography.labelSmall.copyWith(
            color: color,
          ),
        ),
      ],
    );
  }
}

/// Community guidelines dialog
class GuidelinesDialog extends StatelessWidget {
  const GuidelinesDialog({super.key});

  static Future<void> show(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const GuidelinesDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final guidelines = ContentFilterService().getProhibitedContentGuidelines();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: const BoxDecoration(
        color: PipoColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(PipoRadius.xl)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: PipoSpacing.sm),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: PipoColors.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(PipoSpacing.lg),
            child: Row(
              children: [
                const Icon(
                  Icons.policy_rounded,
                  color: PipoColors.primary,
                ),
                const SizedBox(width: PipoSpacing.sm),
                Text(
                  '커뮤니티 가이드라인',
                  style: PipoTypography.heading2.copyWith(
                    color: PipoColors.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  color: PipoColors.textSecondary,
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: PipoSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '안전하고 즐거운 팬 커뮤니티를 위해\n다음 내용은 요청할 수 없습니다:',
                    style: PipoTypography.bodyMedium.copyWith(
                      color: PipoColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: PipoSpacing.lg),

                  ...guidelines.map((guideline) => Padding(
                    padding: const EdgeInsets.only(bottom: PipoSpacing.md),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: PipoColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: PipoSpacing.md),
                        Expanded(
                          child: Text(
                            guideline,
                            style: PipoTypography.bodyMedium.copyWith(
                              color: PipoColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),

                  const SizedBox(height: PipoSpacing.lg),

                  Container(
                    padding: const EdgeInsets.all(PipoSpacing.md),
                    decoration: BoxDecoration(
                      color: PipoColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(PipoRadius.md),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          size: 20,
                          color: PipoColors.textSecondary,
                        ),
                        const SizedBox(width: PipoSpacing.sm),
                        Expanded(
                          child: Text(
                            '가이드라인 위반 시 계정이 제한될 수 있습니다.',
                            style: PipoTypography.labelSmall.copyWith(
                              color: PipoColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: PipoSpacing.xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

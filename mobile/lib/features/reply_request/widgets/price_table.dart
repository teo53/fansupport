import 'package:flutter/material.dart';
import '../../../core/theme/design_system.dart';
import '../models/reply_request_model.dart';

/// Price breakdown table showing base price + SLA multiplier
class PriceTable extends StatelessWidget {
  final ReplyProduct product;
  final ReplySLA? selectedSla;
  final double? customBasePrice;

  const PriceTable({
    super.key,
    required this.product,
    this.selectedSla,
    this.customBasePrice,
  });

  double get basePrice => customBasePrice ?? product.basePrice;

  double get slaMultiplier => selectedSla?.priceMultiplier ?? 1.0;

  double get slaPrice => basePrice * (slaMultiplier - 1.0);

  double get totalPrice => basePrice * slaMultiplier;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PipoSpacing.md),
      decoration: BoxDecoration(
        color: PipoColors.surfaceVariant,
        borderRadius: BorderRadius.circular(PipoRadius.md),
        border: Border.all(
          color: PipoColors.border,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '가격 정보',
            style: PipoTypography.titleSmall.copyWith(
              color: PipoColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: PipoSpacing.md),

          // Base price row
          _buildPriceRow(
            label: '기본 가격',
            sublabel: product.contentType.displayName,
            amount: basePrice,
          ),

          // SLA price row (if selected)
          if (selectedSla != null) ...[
            const SizedBox(height: PipoSpacing.sm),
            _buildPriceRow(
              label: 'SLA 추가금',
              sublabel: '${selectedSla!.name} (×${slaMultiplier.toStringAsFixed(1)})',
              amount: slaPrice,
              isAddition: true,
            ),
          ],

          const SizedBox(height: PipoSpacing.sm),
          const Divider(color: PipoColors.border),
          const SizedBox(height: PipoSpacing.sm),

          // Total row
          _buildTotalRow(),
        ],
      ),
    );
  }

  Widget _buildPriceRow({
    required String label,
    required String sublabel,
    required double amount,
    bool isAddition = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: PipoTypography.bodyMedium.copyWith(
                color: PipoColors.textPrimary,
              ),
            ),
            Text(
              sublabel,
              style: PipoTypography.labelSmall.copyWith(
                color: PipoColors.textTertiary,
              ),
            ),
          ],
        ),
        Text(
          '${isAddition ? '+' : ''}${_formatPrice(amount)}원',
          style: PipoTypography.bodyMedium.copyWith(
            color: isAddition ? PipoColors.primary : PipoColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTotalRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '총 결제 금액',
          style: PipoTypography.titleSmall.copyWith(
            color: PipoColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          '${_formatPrice(totalPrice)}원',
          style: PipoTypography.heading2.copyWith(
            color: PipoColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _formatPrice(double price) {
    if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(price % 1000 == 0 ? 0 : 1)}K';
    }
    return price.toStringAsFixed(0);
  }
}

/// Compact price display for list items
class PriceTag extends StatelessWidget {
  final double price;
  final String? label;
  final bool isHighlighted;

  const PriceTag({
    super.key,
    required this.price,
    this.label,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PipoSpacing.sm,
        vertical: PipoSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isHighlighted
            ? PipoColors.primary.withOpacity(0.1)
            : PipoColors.surfaceVariant,
        borderRadius: BorderRadius.circular(PipoRadius.sm),
        border: isHighlighted
            ? Border.all(color: PipoColors.primary, width: 1)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label != null) ...[
            Text(
              label!,
              style: PipoTypography.labelSmall.copyWith(
                color: isHighlighted
                    ? PipoColors.primary
                    : PipoColors.textTertiary,
              ),
            ),
            const SizedBox(width: PipoSpacing.xs),
          ],
          Text(
            '${_formatPrice(price)}원',
            style: PipoTypography.labelMedium.copyWith(
              color: isHighlighted
                  ? PipoColors.primary
                  : PipoColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    if (price >= 10000) {
      return '${(price / 10000).toStringAsFixed(price % 10000 == 0 ? 0 : 1)}만';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(price % 1000 == 0 ? 0 : 1)}천';
    }
    return price.toStringAsFixed(0);
  }
}

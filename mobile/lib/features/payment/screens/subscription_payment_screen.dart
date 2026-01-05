/// 💳 구독 결제
/// Toss Payments 통합
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/format_utils.dart';
import '../../../shared/models/subscription_tier.dart';

class SubscriptionPaymentScreen extends ConsumerStatefulWidget {
  final String idolId;
  final String idolName;
  final String? idolProfileImage;

  const SubscriptionPaymentScreen({
    super.key,
    required this.idolId,
    required this.idolName,
    this.idolProfileImage,
  });

  @override
  ConsumerState<SubscriptionPaymentScreen> createState() =>
      _SubscriptionPaymentScreenState();
}

class _SubscriptionPaymentScreenState
    extends ConsumerState<SubscriptionPaymentScreen> {
  SubscriptionTier _selectedTier = SubscriptionTier.standard;
  bool _isProcessing = false;
  bool _agreeToTerms = false;

  int get _amount {
    switch (_selectedTier) {
      case SubscriptionTier.none:
        return 0;
      case SubscriptionTier.standard:
        return 3900;
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '구독하기',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            fontFamily: 'Pretendard',
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppColors.divider,
            height: 1,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.wp(4),
                vertical: 20,
              ),
              children: [
                // Idol info
                _buildIdolInfo(),

                const SizedBox(height: 24),

                // Subscription tier selection
                _buildTierSelection(),

                const SizedBox(height: 24),

                // Benefits
                _buildBenefits(),

                const SizedBox(height: 24),

                // Terms agreement
                _buildTermsAgreement(),

                const SizedBox(height: 24),
              ],
            ),
          ),

          // Payment button
          _buildPaymentButton(),
        ],
      ),
    );
  }

  Widget _buildIdolInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.softShadow(),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundImage: widget.idolProfileImage != null
                ? NetworkImage(widget.idolProfileImage!)
                : null,
            child: widget.idolProfileImage == null
                ? const Icon(Icons.person, size: 32)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.idolName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Pretendard',
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '구독하고 특별한 혜택을 받으세요',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontFamily: 'Pretendard',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierSelection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.softShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '구독 플랜',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: 'Pretendard',
            ),
          ),
          const SizedBox(height: 16),

          // Standard tier (only option)
          _buildTierCard(
            tier: SubscriptionTier.standard,
            name: '일반 구독',
            price: 3900,
            icon: Icons.favorite,
            color: AppColors.primary,
            features: [
              'Bubble 메시지 수신',
              '히든정산 작성 (나와 아이돌만 보기)',
              '정산 게시글 작성',
              '댓글 작성',
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTierCard({
    required SubscriptionTier tier,
    required String name,
    required int price,
    required IconData icon,
    required Color color,
    required List<String> features,
    bool isRecommended = false,
  }) {
    final isSelected = _selectedTier == tier;

    return GestureDetector(
      onTap: () => setState(() => _selectedTier = tier),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : AppColors.backgroundAlt,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? color : AppColors.textPrimary,
                              fontFamily: 'Pretendard',
                            ),
                          ),
                          if (isRecommended) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.warning,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                '추천',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  fontFamily: 'Pretendard',
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${FormatUtils.formatCurrency(price)}/월',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: color,
                          fontFamily: 'Pretendard',
                        ),
                      ),
                    ],
                  ),
                ),
                Radio<SubscriptionTier>(
                  value: tier,
                  groupValue: _selectedTier,
                  activeColor: color,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedTier = value);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...features.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: color,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        feature,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontFamily: 'Pretendard',
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefits() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.primary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.favorite,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                '구독 혜택',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Pretendard',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildBenefitItem('💌', 'Bubble 메시지로 아이돌과 소통'),
          _buildBenefitItem('🔒', '히든정산으로 1:1 비공개 소통'),
          _buildBenefitItem('📸', '정산 게시글 작성 및 열람'),
          _buildBenefitItem('💬', '댓글 작성 및 소통'),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                fontFamily: 'Pretendard',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsAgreement() {
    return GestureDetector(
      onTap: () => setState(() => _agreeToTerms = !_agreeToTerms),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _agreeToTerms ? AppColors.primary : AppColors.border,
            width: _agreeToTerms ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              _agreeToTerms
                  ? Icons.check_box_rounded
                  : Icons.check_box_outline_blank_rounded,
              color: _agreeToTerms ? AppColors.primary : AppColors.textTertiary,
              size: 24,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                '구독 약관 및 환불 정책에 동의합니다',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Pretendard',
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.textTertiary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentButton() {
    final canProceed = _agreeToTerms && !_isProcessing;

    return Container(
      padding: EdgeInsets.all(Responsive.wp(4)),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '결제 금액',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Pretendard',
                  ),
                ),
                Text(
                  FormatUtils.formatCurrency(_amount),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    fontFamily: 'Pretendard',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canProceed ? _processPayment : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.border,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Text(
                        '구독하기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontFamily: 'Pretendard',
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '매월 자동 결제됩니다. 언제든지 구독을 취소할 수 있습니다.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textTertiary,
                fontFamily: 'Pretendard',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);

    try {
      // TODO: Integrate Toss Payments SDK
      // 1. Generate order ID
      // final orderId = 'order_${DateTime.now().millisecondsSinceEpoch}';

      // 2. Call Toss Payments
      // await TossPayments.requestPayment(
      //   amount: _amount,
      //   orderId: orderId,
      //   orderName: '${widget.idolName} ${_selectedTier.displayName}',
      //   customerName: 'User Name', // TODO: Get from user profile
      //   successUrl: 'pipo://payment/success',
      //   failUrl: 'pipo://payment/fail',
      // );

      // Mock delay
      await Future.delayed(const Duration(seconds: 2));

      // 3. On success, update subscription status
      // TODO: Call backend API to activate subscription
      // await _activateSubscription(orderId);

      if (mounted) {
        Navigator.pop(context);
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('결제 실패: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                size: 64,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '구독 완료!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                fontFamily: 'Pretendard',
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${widget.idolName}님을 구독했습니다',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontFamily: 'Pretendard',
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '확인',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontFamily: 'Pretendard',
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

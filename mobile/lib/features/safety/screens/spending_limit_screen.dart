import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/design_system.dart';
import '../../../shared/widgets/glass_card.dart';
import '../services/spending_limit_service.dart';

/// Screen for managing spending limits
class SpendingLimitScreen extends ConsumerStatefulWidget {
  const SpendingLimitScreen({super.key});

  @override
  ConsumerState<SpendingLimitScreen> createState() => _SpendingLimitScreenState();
}

class _SpendingLimitScreenState extends ConsumerState<SpendingLimitScreen> {
  final _spendingService = SpendingLimitService();
  bool _isLoading = true;
  bool _isEnabled = false;
  SpendingLimits _limits = const SpendingLimits(
    daily: 100000,
    weekly: 500000,
    monthly: 1000000,
  );
  SpendingStats _spending = const SpendingStats(
    daily: 0,
    weekly: 0,
    monthly: 0,
  );

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _spendingService.initialize();
    setState(() {
      _isEnabled = _spendingService.isEnabled;
      _limits = _spendingService.getLimits();
      _spending = _spendingService.getSpending();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PipoColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
          color: PipoColors.textPrimary,
        ),
        title: Text(
          '지출 한도 관리',
          style: PipoTypography.titleLarge.copyWith(
            color: PipoColors.textPrimary,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(PipoSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(),
                  const SizedBox(height: PipoSpacing.lg),
                  _buildEnableToggle(),
                  if (_isEnabled) ...[
                    const SizedBox(height: PipoSpacing.lg),
                    _buildCurrentSpending(),
                    const SizedBox(height: PipoSpacing.lg),
                    _buildLimitSettings(),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(PipoSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            PipoColors.primary.withOpacity(0.1),
            PipoColors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(PipoRadius.md),
        border: Border.all(color: PipoColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(PipoSpacing.sm),
            decoration: BoxDecoration(
              color: PipoColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(PipoRadius.sm),
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: PipoColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: PipoSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '건강한 팬 활동을 위해',
                  style: PipoTypography.titleSmall.copyWith(
                    color: PipoColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '지출 한도를 설정하면 과도한 지출을 방지하고\n예산 내에서 팬 활동을 즐길 수 있습니다.',
                  style: PipoTypography.labelSmall.copyWith(
                    color: PipoColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnableToggle() {
    return GlassCard(
      child: Row(
        children: [
          const Icon(
            Icons.savings_outlined,
            color: PipoColors.textSecondary,
            size: 24,
          ),
          const SizedBox(width: PipoSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '지출 한도 활성화',
                  style: PipoTypography.titleSmall.copyWith(
                    color: PipoColors.textPrimary,
                  ),
                ),
                Text(
                  '일/주/월 단위로 지출을 제한합니다',
                  style: PipoTypography.labelSmall.copyWith(
                    color: PipoColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isEnabled,
            onChanged: (value) async {
              await _spendingService.setEnabled(value);
              setState(() => _isEnabled = value);
            },
            activeColor: PipoColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentSpending() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '현재 지출 현황',
          style: PipoTypography.titleSmall.copyWith(
            color: PipoColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: PipoSpacing.md),
        _buildSpendingProgress('오늘', _spending.daily, _limits.daily),
        const SizedBox(height: PipoSpacing.sm),
        _buildSpendingProgress('이번 주', _spending.weekly, _limits.weekly),
        const SizedBox(height: PipoSpacing.sm),
        _buildSpendingProgress('이번 달', _spending.monthly, _limits.monthly),
      ],
    );
  }

  Widget _buildSpendingProgress(String label, double spent, double limit) {
    final progress = limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;
    final isWarning = progress >= 0.8;
    final isOver = progress >= 1.0;

    return GlassCard(
      padding: const EdgeInsets.all(PipoSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: PipoTypography.bodyMedium.copyWith(
                  color: PipoColors.textPrimary,
                ),
              ),
              Text(
                '${_formatCurrency(spent)} / ${_formatCurrency(limit)}',
                style: PipoTypography.labelMedium.copyWith(
                  color: isOver
                      ? PipoColors.error
                      : (isWarning ? PipoColors.warning : PipoColors.textSecondary),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: PipoSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: PipoColors.border,
              valueColor: AlwaysStoppedAnimation(
                isOver
                    ? PipoColors.error
                    : (isWarning ? PipoColors.warning : PipoColors.primary),
              ),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLimitSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '한도 설정',
          style: PipoTypography.titleSmall.copyWith(
            color: PipoColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: PipoSpacing.md),
        _buildLimitSelector(
          label: '일일 한도',
          currentLimit: _limits.daily,
          options: _spendingService.getDailyLimitOptions(),
          onSelected: (amount) async {
            final newLimits = SpendingLimits(
              daily: amount,
              weekly: _limits.weekly,
              monthly: _limits.monthly,
            );
            await _spendingService.setLimits(newLimits);
            setState(() => _limits = newLimits);
          },
        ),
        const SizedBox(height: PipoSpacing.md),
        _buildLimitSelector(
          label: '주간 한도',
          currentLimit: _limits.weekly,
          options: _spendingService.getWeeklyLimitOptions(),
          onSelected: (amount) async {
            final newLimits = SpendingLimits(
              daily: _limits.daily,
              weekly: amount,
              monthly: _limits.monthly,
            );
            await _spendingService.setLimits(newLimits);
            setState(() => _limits = newLimits);
          },
        ),
        const SizedBox(height: PipoSpacing.md),
        _buildLimitSelector(
          label: '월간 한도',
          currentLimit: _limits.monthly,
          options: _spendingService.getMonthlyLimitOptions(),
          onSelected: (amount) async {
            final newLimits = SpendingLimits(
              daily: _limits.daily,
              weekly: _limits.weekly,
              monthly: amount,
            );
            await _spendingService.setLimits(newLimits);
            setState(() => _limits = newLimits);
          },
        ),
      ],
    );
  }

  Widget _buildLimitSelector({
    required String label,
    required double currentLimit,
    required List<LimitOption> options,
    required Function(double) onSelected,
  }) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: PipoTypography.bodyMedium.copyWith(
              color: PipoColors.textPrimary,
            ),
          ),
          const SizedBox(height: PipoSpacing.sm),
          Wrap(
            spacing: PipoSpacing.sm,
            runSpacing: PipoSpacing.sm,
            children: options.map((option) {
              final isSelected = option.amount == currentLimit;
              return GestureDetector(
                onTap: () => onSelected(option.amount),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: PipoSpacing.md,
                    vertical: PipoSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? PipoColors.primary
                        : PipoColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(PipoRadius.sm),
                    border: Border.all(
                      color: isSelected ? PipoColors.primary : PipoColors.border,
                    ),
                  ),
                  child: Text(
                    option.label,
                    style: PipoTypography.labelMedium.copyWith(
                      color: isSelected ? Colors.white : PipoColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 10000) {
      return '${(amount / 10000).toStringAsFixed(amount % 10000 == 0 ? 0 : 1)}만원';
    }
    return '${amount.toStringAsFixed(0)}원';
  }
}

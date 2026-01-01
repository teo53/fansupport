import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/mock/mock_data.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../auth/providers/auth_provider.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  int? _selectedChargeAmount;

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final user = ref.watch(currentUserProvider);
    final walletBalance = user?.walletBalance ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '지갑',
          style: TextStyle(fontSize: Responsive.sp(18)),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.wp(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(Responsive.wp(6)),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '보유 코인',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: Responsive.sp(14),
                    ),
                  ),
                  SizedBox(height: Responsive.hp(1)),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.monetization_on,
                        color: Colors.white,
                        size: Responsive.sp(32),
                      ),
                      SizedBox(width: Responsive.wp(2)),
                      Text(
                        _formatCurrency(walletBalance),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: Responsive.sp(32),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: Responsive.wp(1)),
                      Padding(
                        padding: EdgeInsets.only(bottom: Responsive.hp(0.5)),
                        child: Text(
                          'KRW',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: Responsive.sp(14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Responsive.hp(3)),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showChargeSheet(context),
                          icon: Icon(Icons.add, size: Responsive.sp(20)),
                          label: Text(
                            '충전하기',
                            style: TextStyle(fontSize: Responsive.sp(14)),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                            padding: EdgeInsets.symmetric(vertical: Responsive.hp(1.5)),
                          ),
                        ),
                      ),
                      SizedBox(width: Responsive.wp(3)),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showTransactionHistory(context),
                          icon: Icon(Icons.receipt_long, size: Responsive.sp(20)),
                          label: Text(
                            '내역',
                            style: TextStyle(fontSize: Responsive.sp(14)),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white),
                            padding: EdgeInsets.symmetric(vertical: Responsive.hp(1.5)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: Responsive.hp(4)),

            // Recent Transactions
            Text(
              '최근 거래 내역',
              style: TextStyle(
                fontSize: Responsive.sp(18),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: Responsive.hp(2)),
            ...MockData.transactions.map((tx) => _buildTransactionItem(context, tx)),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  void _showChargeSheet(BuildContext context) {
    _selectedChargeAmount = null;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            left: Responsive.wp(4),
            right: Responsive.wp(4),
            top: Responsive.hp(3),
            bottom: MediaQuery.of(context).viewInsets.bottom + Responsive.hp(3),
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: Responsive.wp(10),
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: Responsive.hp(3)),
              Text(
                '코인 충전',
                style: TextStyle(
                  fontSize: Responsive.sp(22),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: Responsive.hp(3)),
              Wrap(
                spacing: Responsive.wp(3),
                runSpacing: Responsive.hp(1.5),
                children: [5000, 10000, 30000, 50000, 100000].map((amount) {
                  final isSelected = _selectedChargeAmount == amount;
                  return InkWell(
                    onTap: () {
                      setModalState(() {
                        _selectedChargeAmount = amount;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: (Responsive.screenWidth - Responsive.wp(14)) / 3,
                      padding: EdgeInsets.symmetric(vertical: Responsive.hp(2)),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : null,
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.monetization_on,
                            color: isSelected ? Colors.white : AppColors.accent,
                            size: Responsive.sp(28),
                          ),
                          SizedBox(height: Responsive.hp(1)),
                          Text(
                            '￦${_formatCurrency(amount)}',
                            style: TextStyle(
                              fontSize: Responsive.sp(14),
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: Responsive.hp(3)),
              GradientButton(
                onPressed: _selectedChargeAmount != null
                    ? () {
                        final amount = _selectedChargeAmount!;
                        final currentBalance = ref.read(currentUserProvider)?.walletBalance ?? 0;
                        ref.read(authStateProvider.notifier).updateWalletBalance(currentBalance + amount);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('￦${_formatCurrency(amount)} 충전 완료! (데모)'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    : null,
                child: Text(
                  '충전하기',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: Responsive.sp(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTransactionHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: Responsive.hp(70),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(Responsive.wp(4)),
              child: Column(
                children: [
                  Container(
                    width: Responsive.wp(10),
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(height: Responsive.hp(2)),
                  Text(
                    '전체 거래 내역',
                    style: TextStyle(
                      fontSize: Responsive.sp(18),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: Responsive.wp(4)),
                itemCount: MockData.transactions.length,
                itemBuilder: (context, index) =>
                    _buildTransactionItem(context, MockData.transactions[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(BuildContext context, Map<String, dynamic> tx) {
    final isPositive = tx['amount'] > 0;
    final typeIcons = {
      'DEPOSIT': Icons.arrow_downward,
      'SUPPORT': Icons.favorite,
      'SUBSCRIPTION': Icons.card_membership,
      'CAMPAIGN': Icons.campaign,
    };
    final typeColors = {
      'DEPOSIT': AppColors.success,
      'SUPPORT': AppColors.primary,
      'SUBSCRIPTION': AppColors.secondary,
      'CAMPAIGN': AppColors.accent,
    };

    final icon = typeIcons[tx['type']] ?? Icons.monetization_on;
    final color = typeColors[tx['type']] ?? AppColors.primary;
    final date = DateTime.parse(tx['createdAt']);

    return Card(
      margin: EdgeInsets.only(bottom: Responsive.hp(1)),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: Responsive.wp(4),
          vertical: Responsive.hp(0.5),
        ),
        leading: Container(
          width: Responsive.wp(11),
          height: Responsive.wp(11),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: Responsive.sp(22)),
        ),
        title: Text(
          tx['description'],
          style: TextStyle(
            fontSize: Responsive.sp(14),
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}',
          style: TextStyle(
            fontSize: Responsive.sp(12),
            color: AppColors.textSecondary,
          ),
        ),
        trailing: Text(
          '${isPositive ? '+' : ''}￦${_formatCurrency(tx['amount'].abs())}',
          style: TextStyle(
            fontSize: Responsive.sp(15),
            color: isPositive ? AppColors.success : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/mock/mock_data.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/wallet_provider.dart';
import '../repositories/supabase_wallet_repository.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  int? _selectedChargeAmount;
  String? _selectedPaymentMethod;
  final List<Map<String, dynamic>> _linkedAccounts = [];

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
                    color: AppColors.primary.withOpacity(0.3),
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
            _buildRecentTransactions(),
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
    _selectedPaymentMethod = null;
    int currentStep = 0; // 0: amount, 1: payment method

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
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
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
                Row(
                  children: [
                    if (currentStep > 0)
                      IconButton(
                        onPressed: () => setModalState(() => currentStep = 0),
                        icon: const Icon(Icons.arrow_back),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    if (currentStep > 0) SizedBox(width: Responsive.wp(2)),
                    Text(
                      currentStep == 0 ? '코인 충전' : '결제 방법 선택',
                      style: TextStyle(
                        fontSize: Responsive.sp(22),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Responsive.hp(3)),

                // Step indicator
                Row(
                  children: [
                    _buildStepIndicator(1, '금액', currentStep >= 0),
                    Expanded(child: Container(height: 2, color: currentStep >= 1 ? AppColors.primary : AppColors.border)),
                    _buildStepIndicator(2, '결제', currentStep >= 1),
                  ],
                ),
                SizedBox(height: Responsive.hp(3)),

                if (currentStep == 0) ...[
                  // Amount selection
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
                        ? () => setModalState(() => currentStep = 1)
                        : null,
                    child: Text(
                      '다음',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: Responsive.sp(16),
                      ),
                    ),
                  ),
                ] else if (currentStep == 1) ...[
                  // Payment method selection
                  Text(
                    '충전 금액: ￦${_formatCurrency(_selectedChargeAmount ?? 0)}',
                    style: TextStyle(
                      fontSize: Responsive.sp(16),
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: Responsive.hp(2)),

                  // Payment methods
                  _buildPaymentMethodCard(
                    setModalState,
                    id: 'card',
                    icon: Icons.credit_card,
                    title: '신용/체크카드',
                    subtitle: '모든 카드 사용 가능',
                    color: Colors.blue,
                  ),
                  SizedBox(height: Responsive.hp(1.5)),
                  _buildPaymentMethodCard(
                    setModalState,
                    id: 'bank',
                    icon: Icons.account_balance,
                    title: '계좌이체',
                    subtitle: '실시간 계좌이체',
                    color: Colors.green,
                  ),
                  SizedBox(height: Responsive.hp(1.5)),
                  _buildPaymentMethodCard(
                    setModalState,
                    id: 'kakao',
                    icon: Icons.chat_bubble,
                    title: '카카오페이',
                    subtitle: '카카오페이로 간편결제',
                    color: const Color(0xFFFEE500),
                    iconColor: Colors.black87,
                  ),
                  SizedBox(height: Responsive.hp(1.5)),
                  _buildPaymentMethodCard(
                    setModalState,
                    id: 'naver',
                    icon: Icons.payment,
                    title: '네이버페이',
                    subtitle: '네이버페이로 간편결제',
                    color: const Color(0xFF03C75A),
                  ),

                  // Linked accounts section
                  if (_linkedAccounts.isNotEmpty) ...[
                    SizedBox(height: Responsive.hp(3)),
                    Text(
                      '연결된 계좌',
                      style: TextStyle(
                        fontSize: Responsive.sp(14),
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: Responsive.hp(1)),
                    ..._linkedAccounts.map((account) => _buildLinkedAccountCard(
                      setModalState,
                      account: account,
                    )),
                  ],

                  // Add account button
                  SizedBox(height: Responsive.hp(2)),
                  OutlinedButton.icon(
                    onPressed: () => _showLinkAccountDialog(context, setModalState),
                    icon: const Icon(Icons.add),
                    label: const Text('계좌 연결하기'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.wp(4),
                        vertical: Responsive.hp(1.5),
                      ),
                    ),
                  ),

                  SizedBox(height: Responsive.hp(3)),
                  GradientButton(
                    onPressed: _selectedPaymentMethod != null
                        ? () async {
                            final amount = _selectedChargeAmount!;
                            final currentBalance = ref.read(currentUserProvider)?.walletBalance ?? 0;

                            // Show processing dialog
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => AlertDialog(
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const CircularProgressIndicator(),
                                    SizedBox(height: Responsive.hp(2)),
                                    const Text('결제 처리 중...'),
                                  ],
                                ),
                              ),
                            );

                            // Simulate payment processing
                            await Future.delayed(const Duration(seconds: 2));

                            // Update balance
                            ref.read(authStateProvider.notifier).updateWalletBalance(currentBalance + amount);

                            // Close dialogs
                            if (context.mounted) {
                              Navigator.pop(context); // Close processing dialog
                              Navigator.pop(context); // Close bottom sheet

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('￦${_formatCurrency(amount)} 충전 완료!'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            }
                          }
                        : null,
                    child: Text(
                      '￦${_formatCurrency(_selectedChargeAmount ?? 0)} 결제하기',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: Responsive.sp(16),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.border,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$step',
              style: TextStyle(
                color: isActive ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isActive ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodCard(
    StateSetter setModalState, {
    required String id,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    Color? iconColor,
  }) {
    final isSelected = _selectedPaymentMethod == id;
    return InkWell(
      onTap: () => setModalState(() => _selectedPaymentMethod = id),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(Responsive.wp(3)),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? AppColors.primary.withOpacity(0.05) : null,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor ?? color, size: 22),
            ),
            SizedBox(width: Responsive.wp(3)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: Responsive.sp(14),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: Responsive.sp(12),
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: id,
              groupValue: _selectedPaymentMethod,
              onChanged: (value) => setModalState(() => _selectedPaymentMethod = value),
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkedAccountCard(
    StateSetter setModalState, {
    required Map<String, dynamic> account,
  }) {
    final isSelected = _selectedPaymentMethod == 'linked_${account['id']}';
    return InkWell(
      onTap: () => setModalState(() => _selectedPaymentMethod = 'linked_${account['id']}'),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: EdgeInsets.only(bottom: Responsive.hp(1)),
        padding: EdgeInsets.all(Responsive.wp(3)),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? AppColors.primary.withOpacity(0.05) : null,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.backgroundAlt,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.account_balance, color: AppColors.primary, size: 22),
            ),
            SizedBox(width: Responsive.wp(3)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account['bankName'] ?? '연결된 계좌',
                    style: TextStyle(
                      fontSize: Responsive.sp(14),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    account['accountNumber'] ?? '',
                    style: TextStyle(
                      fontSize: Responsive.sp(12),
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: 'linked_${account['id']}',
              groupValue: _selectedPaymentMethod,
              onChanged: (value) => setModalState(() => _selectedPaymentMethod = value),
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  void _showLinkAccountDialog(BuildContext context, StateSetter setModalState) {
    final bankController = TextEditingController();
    final accountController = TextEditingController();
    String? selectedBank;

    final banks = ['국민은행', '신한은행', '우리은행', '하나은행', 'IBK기업은행', '농협은행', '카카오뱅크', '토스뱅크'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('계좌 연결'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedBank,
                decoration: InputDecoration(
                  labelText: '은행 선택',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                items: banks.map((bank) => DropdownMenuItem(
                  value: bank,
                  child: Text(bank),
                )).toList(),
                onChanged: (value) => setDialogState(() => selectedBank = value),
              ),
              SizedBox(height: Responsive.hp(2)),
              TextField(
                controller: accountController,
                decoration: InputDecoration(
                  labelText: '계좌번호',
                  hintText: '- 없이 입력',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedBank != null && accountController.text.isNotEmpty) {
                  setState(() {
                    _linkedAccounts.add({
                      'id': DateTime.now().millisecondsSinceEpoch.toString(),
                      'bankName': selectedBank,
                      'accountNumber': '****${accountController.text.substring(accountController.text.length - 4)}',
                    });
                  });
                  setModalState(() {}); // Refresh parent
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('계좌가 연결되었습니다'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              child: const Text('연결'),
            ),
          ],
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

  Widget _buildRecentTransactions() {
    final transactionsAsync = ref.watch(transactionsProvider(5));

    return transactionsAsync.when(
      data: (transactions) {
        if (transactions.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(Responsive.wp(8)),
              child: Text(
                '아직 거래 내역이 없습니다',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: Responsive.sp(14),
                ),
              ),
            ),
          );
        }
        return Column(
          children: transactions.map((tx) {
            return _buildSupabaseTransactionItem(context, tx);
          }).toList(),
        );
      },
      loading: () => Center(
        child: Padding(
          padding: EdgeInsets.all(Responsive.wp(4)),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) {
        // Fall back to mock data on error
        return Column(
          children: MockData.transactions
              .take(5)
              .map((tx) => _buildTransactionItem(context, tx))
              .toList(),
        );
      },
    );
  }

  Widget _buildSupabaseTransactionItem(BuildContext context, Transaction tx) {
    final isPositive = tx.amount > 0;
    final typeIcons = {
      'DEPOSIT': Icons.arrow_downward,
      'CHARGE': Icons.arrow_downward,
      'SUPPORT': Icons.favorite,
      'SUBSCRIPTION': Icons.card_membership,
      'CAMPAIGN': Icons.campaign,
    };
    final typeColors = {
      'DEPOSIT': AppColors.success,
      'CHARGE': AppColors.success,
      'SUPPORT': AppColors.primary,
      'SUBSCRIPTION': AppColors.secondary,
      'CAMPAIGN': AppColors.accent,
    };

    final icon = typeIcons[tx.type] ?? Icons.monetization_on;
    final color = typeColors[tx.type] ?? AppColors.primary;

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
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: Responsive.sp(22)),
        ),
        title: Text(
          tx.description ?? '거래',
          style: TextStyle(
            fontSize: Responsive.sp(14),
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          '${tx.createdAt.year}.${tx.createdAt.month.toString().padLeft(2, '0')}.${tx.createdAt.day.toString().padLeft(2, '0')}',
          style: TextStyle(
            fontSize: Responsive.sp(12),
            color: AppColors.textSecondary,
          ),
        ),
        trailing: Text(
          '${isPositive ? '+' : ''}￦${_formatCurrency(tx.amount.toInt().abs())}',
          style: TextStyle(
            fontSize: Responsive.sp(15),
            color: isPositive ? AppColors.success : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
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
            color: color.withOpacity(0.1),
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

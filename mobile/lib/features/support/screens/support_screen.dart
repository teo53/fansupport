import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/mock/mock_data.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../auth/providers/auth_provider.dart';

class SupportScreen extends ConsumerStatefulWidget {
  final String receiverId;

  const SupportScreen({super.key, required this.receiverId});

  @override
  ConsumerState<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends ConsumerState<SupportScreen> {
  int _selectedAmount = 5000;
  final _messageController = TextEditingController();
  bool _isAnonymous = false;
  bool _isLoading = false;

  final _presetAmounts = [1000, 3000, 5000, 10000, 30000, 50000];

  Map<String, dynamic>? get _idol {
    try {
      return MockData.idols.firstWhere((idol) => idol['id'] == widget.receiverId);
    } catch (e) {
      return MockData.idols.first;
    }
  }

  String _getCategoryName(String? category) {
    final names = {
      'UNDERGROUND_IDOL': '지하 아이돌',
      'MAID_CAFE': '메이드카페',
      'COSPLAYER': '코스플레이어',
      'VTuber': 'VTuber',
    };
    return names[category] ?? '아이돌';
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final user = ref.watch(currentUserProvider);
    final walletBalance = user?.walletBalance ?? 0;
    final idol = _idol;

    return Scaffold(
      appBar: AppBar(
        title: Text('후원하기', style: TextStyle(fontSize: Responsive.sp(18))),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.wp(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Receiver Info
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: EdgeInsets.all(Responsive.wp(4)),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: Responsive.wp(8),
                      backgroundImage: idol != null
                          ? CachedNetworkImageProvider(idol['profileImage'])
                          : null,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                    ),
                    SizedBox(width: Responsive.wp(4)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                idol?['stageName'] ?? '아이돌 이름',
                                style: TextStyle(
                                  fontSize: Responsive.sp(18),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: Responsive.wp(1)),
                              if (idol?['isVerified'] ?? false)
                                Icon(Icons.verified, size: Responsive.sp(18), color: AppColors.primary),
                            ],
                          ),
                          SizedBox(height: Responsive.hp(0.5)),
                          Text(
                            _getCategoryName(idol?['category']),
                            style: TextStyle(
                              fontSize: Responsive.sp(13),
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: Responsive.hp(3)),

            // Amount Selection
            Text(
              '후원 금액',
              style: TextStyle(
                fontSize: Responsive.sp(16),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: Responsive.hp(1.5)),
            Wrap(
              spacing: Responsive.wp(2),
              runSpacing: Responsive.hp(1),
              children: _presetAmounts.map((amount) {
                final isSelected = _selectedAmount == amount;
                final canAfford = walletBalance >= amount;
                return InkWell(
                  onTap: canAfford ? () => setState(() => _selectedAmount = amount) : null,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: (Responsive.screenWidth - Responsive.wp(14)) / 3,
                    padding: EdgeInsets.symmetric(vertical: Responsive.hp(2)),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : null,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : canAfford
                                ? AppColors.border
                                : AppColors.border.withOpacity(0.5),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.favorite,
                          color: isSelected
                              ? Colors.white
                              : canAfford
                                  ? AppColors.primary
                                  : AppColors.textHint,
                          size: Responsive.sp(24),
                        ),
                        SizedBox(height: Responsive.hp(1)),
                        Text(
                          '￦${_formatNumber(amount)}',
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : canAfford
                                    ? AppColors.textPrimary
                                    : AppColors.textHint,
                            fontWeight: FontWeight.w600,
                            fontSize: Responsive.sp(13),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: Responsive.hp(3)),

            // Message
            CustomTextField(
              controller: _messageController,
              label: '응원 메시지 (선택)',
              hintText: '응원의 한마디를 남겨주세요',
              maxLines: 3,
            ),
            SizedBox(height: Responsive.hp(2)),

            // Anonymous Option
            CheckboxListTile(
              value: _isAnonymous,
              onChanged: (value) => setState(() => _isAnonymous = value ?? false),
              title: Text('익명으로 후원하기', style: TextStyle(fontSize: Responsive.sp(14))),
              subtitle: Text('닉네임이 공개되지 않습니다', style: TextStyle(fontSize: Responsive.sp(12))),
              activeColor: AppColors.primary,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            ),
            SizedBox(height: Responsive.hp(3)),

            // Summary
            Container(
              padding: EdgeInsets.all(Responsive.wp(4)),
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('후원 금액', style: TextStyle(fontSize: Responsive.sp(14))),
                      Text('￦${_formatNumber(_selectedAmount)}', style: TextStyle(fontSize: Responsive.sp(14))),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: Responsive.hp(1.5)),
                    child: const Divider(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '총 결제 금액',
                        style: TextStyle(fontSize: Responsive.sp(16), fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '￦${_formatNumber(_selectedAmount)}',
                        style: TextStyle(
                          fontSize: Responsive.sp(20),
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: Responsive.hp(3)),

            // Support Button
            GradientButton(
              onPressed: walletBalance >= _selectedAmount ? () => _handleSupport(context) : null,
              isLoading: _isLoading,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite, color: Colors.white, size: Responsive.sp(20)),
                  SizedBox(width: Responsive.wp(2)),
                  Text(
                    '후원하기',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: Responsive.sp(16),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: Responsive.hp(2)),

            // Balance Info
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    size: Responsive.sp(16),
                    color: walletBalance >= _selectedAmount ? AppColors.textSecondary : AppColors.error,
                  ),
                  SizedBox(width: Responsive.wp(1)),
                  Text(
                    '보유 코인: ￦${_formatNumber(walletBalance)}',
                    style: TextStyle(
                      fontSize: Responsive.sp(13),
                      color: walletBalance >= _selectedAmount ? AppColors.textSecondary : AppColors.error,
                    ),
                  ),
                  if (walletBalance < _selectedAmount) ...[
                    SizedBox(width: Responsive.wp(2)),
                    TextButton(
                      onPressed: () => context.go('/wallet'),
                      child: Text('충전하기', style: TextStyle(fontSize: Responsive.sp(13))),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  void _handleSupport(BuildContext context) async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));

    final currentBalance = ref.read(currentUserProvider)?.walletBalance ?? 0;
    ref.read(authStateProvider.notifier).updateWalletBalance(currentBalance - _selectedAmount);

    setState(() => _isLoading = false);
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: Responsive.wp(20),
              height: Responsive.wp(20),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_circle, color: AppColors.success, size: Responsive.sp(50)),
            ),
            SizedBox(height: Responsive.hp(3)),
            Text(
              '후원 완료!',
              style: TextStyle(fontSize: Responsive.sp(22), fontWeight: FontWeight.bold),
            ),
            SizedBox(height: Responsive.hp(1)),
            Text(
              '${_idol?['stageName'] ?? '아이돌'}님께\n소중한 마음이 전달되었습니다',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: Responsive.sp(14), color: AppColors.textSecondary),
            ),
            SizedBox(height: Responsive.hp(3)),
            CustomButton(
              onPressed: () {
                Navigator.pop(context);
                context.go('/');
              },
              child: Text('확인', style: TextStyle(fontSize: Responsive.sp(16))),
            ),
          ],
        ),
      ),
    );
  }
}

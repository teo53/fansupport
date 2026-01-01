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
  int _selectedAmount = 0;
  String? _selectedGiftName;
  final _messageController = TextEditingController();
  bool _isLoading = false;

  Widget _buildGiftCard(String name, int price, String emoji) {
    final isSelected = _selectedGiftName == name;
    final user = ref.read(currentUserProvider);
    final canAfford = (user?.walletBalance ?? 0) >= price;

    return InkWell(
      onTap: canAfford
          ? () => setState(() {
                _selectedAmount = price;
                _selectedGiftName = name;
              })
          : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(name,
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: Responsive.sp(13))),
            const SizedBox(height: 4),
            Text('￦${_formatNumber(price)}',
                style: TextStyle(
                    color: canAfford ? Colors.black54 : Colors.red,
                    fontSize: Responsive.sp(12))),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic>? get _idol {
    try {
      return MockData.idols
          .firstWhere((idol) => idol['id'] == widget.receiverId);
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
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
                                Icon(Icons.verified,
                                    size: Responsive.sp(18),
                                    color: AppColors.primary),
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

            // Gift Selection
            Text(
              '선물 보내기',
              style: TextStyle(
                fontSize: Responsive.sp(16),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: Responsive.hp(1.5)),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: Responsive.wp(2),
              crossAxisSpacing: Responsive.wp(2),
              childAspectRatio: 0.75,
              children: [
                _buildGiftCard('조각 케이크', 1000, '🍰'),
                _buildGiftCard('홀 케이크', 30000, '🎂'),
                _buildGiftCard('케이크 타워', 100000, '🏰'),
                _buildGiftCard('장미 꽃다발', 5000, '🌹'),
                _buildGiftCard('샴페인', 50000, '🍾'),
                _buildGiftCard('명품 가방', 500000, '👜'),
              ],
            ),
            SizedBox(height: Responsive.hp(3)),

            // Message
            CustomTextField(
              controller: _messageController,
              label: '응원 메시지 (선택)',
              hintText: '선물과 함께 보낼 메시지를 작성하세요',
              maxLines: 3,
            ),
            SizedBox(height: Responsive.hp(2)),

            // Summary
            if (_selectedGiftName != null)
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
                        Text('선택한 선물',
                            style: TextStyle(fontSize: Responsive.sp(14))),
                        Text(_selectedGiftName!,
                            style: TextStyle(
                                fontSize: Responsive.sp(14),
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: Responsive.hp(1.5)),
                      child: const Divider(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '결제 금액',
                          style: TextStyle(
                              fontSize: Responsive.sp(16),
                              fontWeight: FontWeight.w600),
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
              onPressed: walletBalance >= _selectedAmount
                  ? () => _handleSupport(context)
                  : null,
              isLoading: _isLoading,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite,
                      color: Colors.white, size: Responsive.sp(20)),
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
                    color: walletBalance >= _selectedAmount
                        ? AppColors.textSecondary
                        : AppColors.error,
                  ),
                  SizedBox(width: Responsive.wp(1)),
                  Text(
                    '보유 코인: ￦${_formatNumber(walletBalance)}',
                    style: TextStyle(
                      fontSize: Responsive.sp(13),
                      color: walletBalance >= _selectedAmount
                          ? AppColors.textSecondary
                          : AppColors.error,
                    ),
                  ),
                  if (walletBalance < _selectedAmount) ...[
                    SizedBox(width: Responsive.wp(2)),
                    TextButton(
                      onPressed: () => context.go('/wallet'),
                      child: Text('충전하기',
                          style: TextStyle(fontSize: Responsive.sp(13))),
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
    ref
        .read(authStateProvider.notifier)
        .updateWalletBalance(currentBalance - _selectedAmount);

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
              child: Icon(Icons.check_circle,
                  color: AppColors.success, size: Responsive.sp(50)),
            ),
            SizedBox(height: Responsive.hp(3)),
            Text(
              '후원 완료!',
              style: TextStyle(
                  fontSize: Responsive.sp(22), fontWeight: FontWeight.bold),
            ),
            SizedBox(height: Responsive.hp(1)),
            Text(
              '${_idol?['stageName'] ?? '아이돌'}님께\n소중한 마음이 전달되었습니다',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: Responsive.sp(14), color: AppColors.textSecondary),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/design_system.dart';
import '../../../shared/widgets/glass_card.dart';

/// Request Composer Screen - Create a new reply request
/// Can be accessed from:
/// 1. Center tab (global - select creator first)
/// 2. Creator profile (pre-filled creator)
class RequestComposerScreen extends ConsumerStatefulWidget {
  final String? creatorId;

  const RequestComposerScreen({
    super.key,
    this.creatorId,
  });

  @override
  ConsumerState<RequestComposerScreen> createState() => _RequestComposerScreenState();
}

class _RequestComposerScreenState extends ConsumerState<RequestComposerScreen> {
  String? _selectedCreatorId;
  String? _selectedProductId;
  String? _selectedSlaId;
  final _messageController = TextEditingController();
  bool _isAnonymous = false;

  @override
  void initState() {
    super.initState();
    _selectedCreatorId = widget.creatorId;
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PipoColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          color: PipoColors.textPrimary,
          onPressed: () => context.pop(),
        ),
        title: Text(
          '리프 요청하기',
          style: PipoTypography.titleLarge.copyWith(
            color: PipoColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: _selectedCreatorId == null
          ? _buildCreatorSelection()
          : _buildRequestForm(),
    );
  }

  Widget _buildCreatorSelection() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_search_rounded,
            size: 64,
            color: PipoColors.textTertiary,
          ),
          const SizedBox(height: PipoSpacing.md),
          Text(
            '크리에이터를 선택해주세요',
            style: PipoTypography.titleLarge.copyWith(
              color: PipoColors.textPrimary,
            ),
          ),
          const SizedBox(height: PipoSpacing.sm),
          Text(
            '탐색 탭에서 원하는 크리에이터를 찾아\n리프를 요청할 수 있습니다',
            style: PipoTypography.bodyMedium.copyWith(
              color: PipoColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: PipoSpacing.xl),
          ElevatedButton.icon(
            onPressed: () => context.go('/explore'),
            icon: const Icon(Icons.explore_rounded),
            label: const Text('크리에이터 탐색하기'),
            style: ElevatedButton.styleFrom(
              backgroundColor: PipoColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: PipoSpacing.xl,
                vertical: PipoSpacing.md,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(PipoRadius.lg),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestForm() {
    // TODO: Fetch creator data and products from API
    final creator = _getMockCreator();
    final products = _getMockProducts();

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(PipoSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Creator info
                _buildCreatorCard(creator),
                const SizedBox(height: PipoSpacing.lg),

                // Product selection
                _buildSectionTitle('형식 선택'),
                const SizedBox(height: PipoSpacing.sm),
                _buildProductSelection(products),
                const SizedBox(height: PipoSpacing.lg),

                // SLA selection
                if (_selectedProductId != null) ...[
                  _buildSectionTitle('배송 속도'),
                  const SizedBox(height: PipoSpacing.sm),
                  _buildSlaSelection(),
                  const SizedBox(height: PipoSpacing.lg),
                ],

                // Message input
                _buildSectionTitle('요청 메시지'),
                const SizedBox(height: PipoSpacing.sm),
                _buildMessageInput(),
                const SizedBox(height: PipoSpacing.md),

                // Prohibited content notice
                _buildProhibitedContentNotice(),
                const SizedBox(height: PipoSpacing.lg),

                // Anonymous toggle
                _buildAnonymousToggle(),
                const SizedBox(height: PipoSpacing.lg),

                // Price summary
                if (_selectedProductId != null && _selectedSlaId != null)
                  _buildPriceSummary(),
              ],
            ),
          ),
        ),
        _buildBottomBar(),
      ],
    );
  }

  Widget _buildCreatorCard(Map<String, dynamic> creator) {
    return GlassCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: PipoColors.surfaceVariant,
            child: const Icon(Icons.person, color: PipoColors.textTertiary),
          ),
          const SizedBox(width: PipoSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      creator['name'] ?? '',
                      style: PipoTypography.titleMedium.copyWith(
                        color: PipoColors.textPrimary,
                      ),
                    ),
                    if (creator['isVerified'] == true) ...[
                      const SizedBox(width: PipoSpacing.xs),
                      const Icon(
                        Icons.verified_rounded,
                        size: 18,
                        color: PipoColors.primary,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: PipoSpacing.xs),
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 14,
                      color: PipoColors.textTertiary,
                    ),
                    const SizedBox(width: PipoSpacing.xs),
                    Text(
                      '평균 응답: ${creator['avgResponseTime']}',
                      style: PipoTypography.labelSmall.copyWith(
                        color: PipoColors.textTertiary,
                      ),
                    ),
                    const SizedBox(width: PipoSpacing.md),
                    Icon(
                      Icons.thumb_up_outlined,
                      size: 14,
                      color: PipoColors.textTertiary,
                    ),
                    const SizedBox(width: PipoSpacing.xs),
                    Text(
                      '${creator['fulfillmentRate']}%',
                      style: PipoTypography.labelSmall.copyWith(
                        color: PipoColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: PipoSpacing.sm,
              vertical: PipoSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: PipoColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(PipoRadius.sm),
            ),
            child: Text(
              '${creator['remainingSlots']}슬롯',
              style: PipoTypography.labelSmall.copyWith(
                color: PipoColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: PipoTypography.titleSmall.copyWith(
        color: PipoColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildProductSelection(List<Map<String, dynamic>> products) {
    return Column(
      children: products.map((product) {
        final isSelected = _selectedProductId == product['id'];
        return GlassCard(
          margin: const EdgeInsets.only(bottom: PipoSpacing.sm),
          onTap: () {
            setState(() {
              _selectedProductId = product['id'];
              _selectedSlaId = null;
            });
          },
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected
                      ? PipoColors.primary.withOpacity(0.1)
                      : PipoColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(PipoRadius.md),
                ),
                child: Icon(
                  _getProductIcon(product['contentType']),
                  color: isSelected ? PipoColors.primary : PipoColors.textSecondary,
                ),
              ),
              const SizedBox(width: PipoSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name'] ?? '',
                      style: PipoTypography.titleSmall.copyWith(
                        color: PipoColors.textPrimary,
                      ),
                    ),
                    if (product['description'] != null)
                      Text(
                        product['description'],
                        style: PipoTypography.labelSmall.copyWith(
                          color: PipoColors.textTertiary,
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                '${product['basePrice']}원',
                style: PipoTypography.titleSmall.copyWith(
                  color: PipoColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: PipoSpacing.sm),
              Radio<String>(
                value: product['id'],
                groupValue: _selectedProductId,
                onChanged: (value) {
                  setState(() {
                    _selectedProductId = value;
                    _selectedSlaId = null;
                  });
                },
                activeColor: PipoColors.primary,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSlaSelection() {
    final slaOptions = _getMockSlaOptions();

    return Row(
      children: slaOptions.map((sla) {
        final isSelected = _selectedSlaId == sla['id'];
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedSlaId = sla['id'];
              });
            },
            child: Container(
              margin: EdgeInsets.only(
                right: sla != slaOptions.last ? PipoSpacing.sm : 0,
              ),
              padding: const EdgeInsets.all(PipoSpacing.md),
              decoration: BoxDecoration(
                color: isSelected ? PipoColors.primary.withOpacity(0.1) : PipoColors.surface,
                borderRadius: BorderRadius.circular(PipoRadius.lg),
                border: Border.all(
                  color: isSelected ? PipoColors.primary : PipoColors.border,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    sla['name'],
                    style: PipoTypography.titleSmall.copyWith(
                      color: isSelected ? PipoColors.primary : PipoColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: PipoSpacing.xs),
                  Text(
                    '${sla['hours']}시간',
                    style: PipoTypography.labelSmall.copyWith(
                      color: PipoColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: PipoSpacing.xs),
                  Text(
                    '${sla['multiplier']}x',
                    style: PipoTypography.labelSmall.copyWith(
                      color: isSelected ? PipoColors.primary : PipoColors.textTertiary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMessageInput() {
    return TextField(
      controller: _messageController,
      maxLines: 4,
      maxLength: 1000,
      decoration: InputDecoration(
        hintText: '어떤 내용의 리프를 원하시나요?\n예: 생일 축하 메시지, 응원 한마디, 팬미팅 기념 인사...',
        hintStyle: PipoTypography.bodyMedium.copyWith(
          color: PipoColors.textTertiary,
        ),
        filled: true,
        fillColor: PipoColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PipoRadius.lg),
          borderSide: BorderSide(color: PipoColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PipoRadius.lg),
          borderSide: BorderSide(color: PipoColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PipoRadius.lg),
          borderSide: BorderSide(color: PipoColors.primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildProhibitedContentNotice() {
    return Container(
      padding: const EdgeInsets.all(PipoSpacing.md),
      decoration: BoxDecoration(
        color: PipoColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(PipoRadius.md),
        border: Border.all(color: PipoColors.warning.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: PipoColors.warning,
            size: 20,
          ),
          const SizedBox(width: PipoSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '금지된 요청',
                  style: PipoTypography.labelMedium.copyWith(
                    color: PipoColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: PipoSpacing.xs),
                Text(
                  '성적/폭력적 콘텐츠, 개인정보 요청, 불법 행위 등은 금지됩니다. 위반 시 요청이 거절되며 환불되지 않을 수 있습니다.',
                  style: PipoTypography.bodySmall.copyWith(
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

  Widget _buildAnonymousToggle() {
    return GlassCard(
      child: Row(
        children: [
          Icon(
            Icons.visibility_off_rounded,
            color: PipoColors.textSecondary,
          ),
          const SizedBox(width: PipoSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '익명으로 요청',
                  style: PipoTypography.titleSmall.copyWith(
                    color: PipoColors.textPrimary,
                  ),
                ),
                Text(
                  '크리에이터에게 내 이름이 표시되지 않습니다',
                  style: PipoTypography.labelSmall.copyWith(
                    color: PipoColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isAnonymous,
            onChanged: (value) {
              setState(() {
                _isAnonymous = value;
              });
            },
            activeColor: PipoColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSummary() {
    // Calculate price based on selections
    final basePrice = 5000;
    final multiplier = _selectedSlaId == 'express' ? 2.0 : _selectedSlaId == 'priority' ? 1.5 : 1.0;
    final totalPrice = (basePrice * multiplier).toInt();

    return GlassCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '기본 가격',
                style: PipoTypography.bodyMedium.copyWith(
                  color: PipoColors.textSecondary,
                ),
              ),
              Text(
                '${basePrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}원',
                style: PipoTypography.bodyMedium.copyWith(
                  color: PipoColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: PipoSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SLA 추가',
                style: PipoTypography.bodyMedium.copyWith(
                  color: PipoColors.textSecondary,
                ),
              ),
              Text(
                '${multiplier}x',
                style: PipoTypography.bodyMedium.copyWith(
                  color: PipoColors.textPrimary,
                ),
              ),
            ],
          ),
          const Divider(height: PipoSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '총 결제 금액',
                style: PipoTypography.titleMedium.copyWith(
                  color: PipoColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${totalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}원',
                style: PipoTypography.titleLarge.copyWith(
                  color: PipoColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final canSubmit = _selectedProductId != null &&
        _selectedSlaId != null &&
        _messageController.text.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(PipoSpacing.md),
      decoration: BoxDecoration(
        color: PipoColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: ElevatedButton(
          onPressed: canSubmit ? _submitRequest : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: PipoColors.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: PipoColors.surfaceVariant,
            disabledForegroundColor: PipoColors.textTertiary,
            padding: const EdgeInsets.symmetric(vertical: PipoSpacing.md),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(PipoRadius.lg),
            ),
            minimumSize: const Size(double.infinity, 56),
          ),
          child: const Text(
            '리프 요청하기',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  void _submitRequest() {
    // TODO: Implement API call
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('요청 완료'),
        content: const Text('리프 요청이 성공적으로 전송되었습니다!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/inbox');
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  IconData _getProductIcon(String contentType) {
    switch (contentType) {
      case 'TEXT':
        return Icons.message_rounded;
      case 'VOICE':
        return Icons.mic_rounded;
      case 'PHOTO':
        return Icons.camera_alt_rounded;
      case 'VIDEO':
        return Icons.videocam_rounded;
      default:
        return Icons.mail_rounded;
    }
  }

  Map<String, dynamic> _getMockCreator() {
    return {
      'id': _selectedCreatorId,
      'name': 'Sakura',
      'isVerified': true,
      'avgResponseTime': '12시간',
      'fulfillmentRate': 98,
      'remainingSlots': 5,
    };
  }

  List<Map<String, dynamic>> _getMockProducts() {
    return [
      {
        'id': 'text',
        'name': '텍스트 메시지',
        'description': '최대 500자 텍스트 답장',
        'contentType': 'TEXT',
        'basePrice': '3,000',
      },
      {
        'id': 'voice',
        'name': '보이스 메시지',
        'description': '최대 60초 음성 메시지',
        'contentType': 'VOICE',
        'basePrice': '10,000',
      },
      {
        'id': 'photo',
        'name': '사진',
        'description': '셀카 또는 손글씨 사진',
        'contentType': 'PHOTO',
        'basePrice': '8,000',
      },
      {
        'id': 'video',
        'name': '영상 메시지',
        'description': '최대 30초 영상',
        'contentType': 'VIDEO',
        'basePrice': '20,000',
      },
    ];
  }

  List<Map<String, dynamic>> _getMockSlaOptions() {
    return [
      {'id': 'standard', 'name': 'Standard', 'hours': 48, 'multiplier': '1.0'},
      {'id': 'priority', 'name': 'Priority', 'hours': 24, 'multiplier': '1.5'},
      {'id': 'express', 'name': 'Express', 'hours': 12, 'multiplier': '2.0'},
    ];
  }
}

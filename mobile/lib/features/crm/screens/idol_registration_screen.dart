import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/widgets/custom_button.dart';

class IdolRegistrationScreen extends ConsumerStatefulWidget {
  const IdolRegistrationScreen({super.key});

  @override
  ConsumerState<IdolRegistrationScreen> createState() => _IdolRegistrationScreenState();
}

class _IdolRegistrationScreenState extends ConsumerState<IdolRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  // Form controllers
  final _stageNameController = TextEditingController();
  final _realNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _agencyNameController = TextEditingController();
  final _agencyEmailController = TextEditingController();
  final _twitterController = TextEditingController();
  final _instagramController = TextEditingController();
  final _youtubeController = TextEditingController();
  final _tiktokController = TextEditingController();

  String _selectedCategory = 'UNDERGROUND_IDOL';
  bool _isAgencyRegistration = false;
  bool _offersMealDate = false;
  bool _offersCafeDate = false;
  bool _hasBubble = false;
  int _mealDatePrice = 1500000;
  int _cafeDatePrice = 1000000;
  int _bubblePrice = 4500;

  @override
  void dispose() {
    _stageNameController.dispose();
    _realNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _descriptionController.dispose();
    _agencyNameController.dispose();
    _agencyEmailController.dispose();
    _twitterController.dispose();
    _instagramController.dispose();
    _youtubeController.dispose();
    _tiktokController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          '아이돌 등록',
          style: TextStyle(
            fontSize: Responsive.sp(18),
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Progress Indicator
          _buildProgressIndicator(),

          // Form Content
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(Responsive.wp(5)),
                child: _buildCurrentStep(),
              ),
            ),
          ),

          // Bottom Buttons
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final steps = ['기본 정보', 'SNS 계정', '서비스 설정', '완료'];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.wp(5),
        vertical: Responsive.hp(2),
      ),
      child: Row(
        children: List.generate(steps.length, (index) {
          final isCompleted = index < _currentStep;
          final isCurrent = index == _currentStep;

          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted || isCurrent
                        ? AppColors.primary
                        : AppColors.border,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isCurrent ? Colors.white : AppColors.textSecondary,
                              fontSize: Responsive.sp(12),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                if (index < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isCompleted ? AppColors.primary : AppColors.border,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildBasicInfoStep();
      case 1:
        return _buildSnsStep();
      case 2:
        return _buildServiceSettingsStep();
      case 3:
        return _buildCompletionStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildBasicInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Registration Type Toggle
        Container(
          padding: EdgeInsets.all(Responsive.wp(4)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(PipoRadius.lg),
            boxShadow: AppColors.softShadow(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '등록 유형',
                style: TextStyle(
                  fontSize: Responsive.sp(16),
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: Responsive.hp(2)),
              Row(
                children: [
                  Expanded(
                    child: _buildTypeButton(
                      '개인 아이돌',
                      Icons.person,
                      !_isAgencyRegistration,
                      () => setState(() => _isAgencyRegistration = false),
                    ),
                  ),
                  SizedBox(width: Responsive.wp(3)),
                  Expanded(
                    child: _buildTypeButton(
                      '소속사/매니저',
                      Icons.business,
                      _isAgencyRegistration,
                      () => setState(() => _isAgencyRegistration = true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: Responsive.hp(2)),

        // Agency Info (if agency registration)
        if (_isAgencyRegistration) ...[
          _buildSectionCard(
            '소속사 정보',
            [
              _buildTextField(
                controller: _agencyNameController,
                label: '소속사명',
                hint: '예: 스타라이트 엔터테인먼트',
                prefixIcon: Icons.business,
              ),
              SizedBox(height: Responsive.hp(2)),
              _buildTextField(
                controller: _agencyEmailController,
                label: '소속사 이메일',
                hint: 'agency@example.com',
                prefixIcon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
          SizedBox(height: Responsive.hp(2)),
        ],

        // Idol Basic Info
        _buildSectionCard(
          '아이돌 기본 정보',
          [
            _buildTextField(
              controller: _stageNameController,
              label: '활동명 (필수)',
              hint: '예: 하늘별',
              prefixIcon: Icons.star,
              validator: (value) => value?.isEmpty ?? true ? '활동명을 입력해주세요' : null,
            ),
            SizedBox(height: Responsive.hp(2)),
            _buildTextField(
              controller: _realNameController,
              label: '실명 (비공개)',
              hint: '본인 확인용으로만 사용됩니다',
              prefixIcon: Icons.person,
            ),
            SizedBox(height: Responsive.hp(2)),
            _buildTextField(
              controller: _emailController,
              label: '이메일 (필수)',
              hint: 'idol@example.com',
              prefixIcon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value?.isEmpty ?? true) return '이메일을 입력해주세요';
                if (!value!.contains('@')) return '올바른 이메일 형식이 아닙니다';
                return null;
              },
            ),
            SizedBox(height: Responsive.hp(2)),
            _buildTextField(
              controller: _phoneController,
              label: '연락처',
              hint: '010-0000-0000',
              prefixIcon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        SizedBox(height: Responsive.hp(2)),

        // Category Selection
        _buildSectionCard(
          '카테고리',
          [
            _buildCategorySelector(),
          ],
        ),
        SizedBox(height: Responsive.hp(2)),

        // Bio & Description
        _buildSectionCard(
          '소개',
          [
            _buildTextField(
              controller: _bioController,
              label: '한줄 소개',
              hint: '짧은 자기소개를 작성해주세요',
              prefixIcon: Icons.format_quote,
            ),
            SizedBox(height: Responsive.hp(2)),
            _buildTextField(
              controller: _descriptionController,
              label: '상세 소개',
              hint: '활동 이력, 특기, 매력 포인트 등을 자유롭게 작성해주세요',
              prefixIcon: Icons.description,
              maxLines: 4,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSnsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(Responsive.wp(4)),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(PipoRadius.lg),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white, size: Responsive.sp(20)),
              SizedBox(width: Responsive.wp(3)),
              Expanded(
                child: Text(
                  'SNS 계정을 연결하면 팬들이 쉽게 팔로우할 수 있어요!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: Responsive.sp(13),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: Responsive.hp(2)),

        _buildSectionCard(
          'SNS 계정 연결',
          [
            _buildSnsField(
              controller: _twitterController,
              label: 'Twitter (X)',
              hint: '@username',
              icon: Icons.close,
              color: Colors.black,
            ),
            SizedBox(height: Responsive.hp(2)),
            _buildSnsField(
              controller: _instagramController,
              label: 'Instagram',
              hint: '@username',
              icon: Icons.camera_alt,
              color: const Color(0xFFE4405F),
            ),
            SizedBox(height: Responsive.hp(2)),
            _buildSnsField(
              controller: _youtubeController,
              label: 'YouTube',
              hint: '채널 URL 또는 @handle',
              icon: Icons.play_arrow,
              color: const Color(0xFFFF0000),
            ),
            SizedBox(height: Responsive.hp(2)),
            _buildSnsField(
              controller: _tiktokController,
              label: 'TikTok',
              hint: '@username',
              icon: Icons.music_note,
              color: Colors.black,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildServiceSettingsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date Ticket Settings
        _buildSectionCard(
          '데이트권 설정',
          [
            _buildServiceToggle(
              '식사 데이트권',
              '팬과 함께 식사하는 프리미엄 경험',
              Icons.restaurant,
              _offersMealDate,
              (value) => setState(() => _offersMealDate = value),
              priceWidget: _offersMealDate ? _buildPriceField(
                value: _mealDatePrice,
                onChanged: (v) => setState(() => _mealDatePrice = v),
                min: 500000,
                max: 3000000,
                step: 100000,
              ) : null,
            ),
            SizedBox(height: Responsive.hp(2)),
            _buildServiceToggle(
              '카페 데이트권',
              '카페에서 팬과 티타임',
              Icons.local_cafe,
              _offersCafeDate,
              (value) => setState(() => _offersCafeDate = value),
              priceWidget: _offersCafeDate ? _buildPriceField(
                value: _cafeDatePrice,
                onChanged: (v) => setState(() => _cafeDatePrice = v),
                min: 300000,
                max: 2000000,
                step: 100000,
              ) : null,
            ),
          ],
        ),
        SizedBox(height: Responsive.hp(2)),

        // Bubble Settings
        _buildSectionCard(
          '버블 메시지 설정',
          [
            _buildServiceToggle(
              '버블 서비스 활성화',
              '팬들에게 특별한 메시지를 보내세요',
              Icons.chat_bubble,
              _hasBubble,
              (value) => setState(() => _hasBubble = value),
              priceWidget: _hasBubble ? _buildPriceField(
                value: _bubblePrice,
                onChanged: (v) => setState(() => _bubblePrice = v),
                min: 2000,
                max: 10000,
                step: 500,
                label: '월 구독료',
              ) : null,
            ),
          ],
        ),
        SizedBox(height: Responsive.hp(2)),

        // Commission Info
        Container(
          padding: EdgeInsets.all(Responsive.wp(4)),
          decoration: BoxDecoration(
            color: AppColors.infoSoft,
            borderRadius: BorderRadius.circular(PipoRadius.lg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info, color: AppColors.info, size: Responsive.sp(20)),
                  SizedBox(width: Responsive.wp(2)),
                  Text(
                    '수수료 안내',
                    style: TextStyle(
                      fontSize: Responsive.sp(15),
                      fontWeight: FontWeight.w700,
                      color: AppColors.info,
                    ),
                  ),
                ],
              ),
              SizedBox(height: Responsive.hp(1.5)),
              _buildCommissionRow('후원금', '10%'),
              _buildCommissionRow('데이트권', '15%'),
              _buildCommissionRow('버블 구독', '20%'),
              _buildCommissionRow('광고 펀딩', '5%'),
              SizedBox(height: Responsive.hp(1)),
              Text(
                '* 정산은 매월 15일에 진행됩니다',
                style: TextStyle(
                  fontSize: Responsive.sp(11),
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionStep() {
    return Column(
      children: [
        SizedBox(height: Responsive.hp(5)),
        Container(
          width: Responsive.wp(25),
          height: Responsive.wp(25),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.primaryGradient,
            boxShadow: AppColors.glowShadow(AppColors.primary),
          ),
          child: Icon(
            Icons.check,
            color: Colors.white,
            size: Responsive.sp(50),
          ),
        ),
        SizedBox(height: Responsive.hp(4)),
        Text(
          '등록 신청이 완료되었습니다!',
          style: TextStyle(
            fontSize: Responsive.sp(22),
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: Responsive.hp(1.5)),
        Text(
          '심사 후 24시간 이내에\n등록 결과를 이메일로 안내해드립니다.',
          style: TextStyle(
            fontSize: Responsive.sp(14),
            color: AppColors.textSecondary,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: Responsive.hp(4)),

        // Summary Card
        Container(
          padding: EdgeInsets.all(Responsive.wp(4)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(PipoRadius.lg),
            boxShadow: AppColors.softShadow(),
          ),
          child: Column(
            children: [
              _buildSummaryRow('활동명', _stageNameController.text),
              _buildSummaryRow('카테고리', _getCategoryName(_selectedCategory)),
              _buildSummaryRow('이메일', _emailController.text),
              if (_offersMealDate)
                _buildSummaryRow('식사 데이트권', '${_formatCurrency(_mealDatePrice)}원'),
              if (_offersCafeDate)
                _buildSummaryRow('카페 데이트권', '${_formatCurrency(_cafeDatePrice)}원'),
              if (_hasBubble)
                _buildSummaryRow('버블 구독', '월 ${_formatCurrency(_bubblePrice)}원'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTypeButton(String label, IconData icon, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.wp(4),
          vertical: Responsive.hp(2),
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(PipoRadius.md),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.textSecondary,
              size: Responsive.sp(28),
            ),
            SizedBox(height: Responsive.hp(1)),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontSize: Responsive.sp(13),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(Responsive.wp(4)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(PipoRadius.lg),
        boxShadow: AppColors.softShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: Responsive.sp(16),
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: Responsive.hp(2)),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: maxLines == 1
            ? Icon(prefixIcon, color: AppColors.primary)
            : null,
        filled: true,
        fillColor: AppColors.inputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PipoRadius.md),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PipoRadius.md),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PipoRadius.md),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    final categories = [
      {'value': 'UNDERGROUND_IDOL', 'label': '지하 아이돌', 'icon': Icons.mic},
      {'value': 'MAID_CAFE', 'label': '메이드카페', 'icon': Icons.emoji_people},
      {'value': 'COSPLAYER', 'label': '코스플레이어', 'icon': Icons.camera_alt},
      {'value': 'VTuber', 'label': 'VTuber', 'icon': Icons.smart_display},
    ];

    return Wrap(
      spacing: Responsive.wp(2),
      runSpacing: Responsive.hp(1),
      children: categories.map((cat) {
        final isSelected = _selectedCategory == cat['value'];
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() => _selectedCategory = cat['value'] as String);
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.wp(4),
              vertical: Responsive.hp(1.2),
            ),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.inputBackground,
              borderRadius: BorderRadius.circular(PipoRadius.xl),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  cat['icon'] as IconData,
                  size: Responsive.sp(16),
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
                SizedBox(width: Responsive.wp(1.5)),
                Text(
                  cat['label'] as String,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontSize: Responsive.sp(13),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSnsField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(PipoRadius.md),
          ),
          child: Icon(icon, color: color, size: Responsive.sp(22)),
        ),
        SizedBox(width: Responsive.wp(3)),
        Expanded(
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              filled: true,
              fillColor: AppColors.inputBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(PipoRadius.md),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(PipoRadius.md),
                borderSide: BorderSide(color: color, width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceToggle(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged, {
    Widget? priceWidget,
  }) {
    return Container(
      padding: EdgeInsets.all(Responsive.wp(3)),
      decoration: BoxDecoration(
        color: value ? AppColors.primarySoft : AppColors.inputBackground,
        borderRadius: BorderRadius.circular(PipoRadius.md),
        border: Border.all(
          color: value ? AppColors.primary : Colors.transparent,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(Responsive.wp(2.5)),
                decoration: BoxDecoration(
                  color: value ? AppColors.primary : AppColors.border,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: value ? Colors.white : AppColors.textSecondary,
                  size: Responsive.sp(20),
                ),
              ),
              SizedBox(width: Responsive.wp(3)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: Responsive.sp(15),
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
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: AppColors.primary,
              ),
            ],
          ),
          if (priceWidget != null) ...[
            SizedBox(height: Responsive.hp(1.5)),
            priceWidget,
          ],
        ],
      ),
    );
  }

  Widget _buildPriceField({
    required int value,
    required ValueChanged<int> onChanged,
    required int min,
    required int max,
    required int step,
    String label = '가격 설정',
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: Responsive.sp(13),
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '${_formatCurrency(value)}원',
              style: TextStyle(
                fontSize: Responsive.sp(16),
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: Responsive.hp(1)),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.border,
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withValues(alpha: 0.2),
          ),
          child: Slider(
            value: value.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: ((max - min) / step).round(),
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
      ],
    );
  }

  Widget _buildCommissionRow(String service, String rate) {
    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.hp(0.8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            service,
            style: TextStyle(
              fontSize: Responsive.sp(13),
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            rate,
            style: TextStyle(
              fontSize: Responsive.sp(13),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.hp(1.2)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: Responsive.sp(13),
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: Responsive.sp(14),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: EdgeInsets.all(Responsive.wp(5)),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentStep > 0 && _currentStep < 3)
              Expanded(
                child: CustomButton(
                  onPressed: () => setState(() => _currentStep--),
                  isOutlined: true,
                  child: Text(
                    '이전',
                    style: TextStyle(fontSize: Responsive.sp(15)),
                  ),
                ),
              ),
            if (_currentStep > 0 && _currentStep < 3)
              SizedBox(width: Responsive.wp(3)),
            Expanded(
              flex: _currentStep == 0 || _currentStep == 3 ? 1 : 1,
              child: GradientButton(
                onPressed: _handleNext,
                child: Text(
                  _currentStep == 3
                      ? '홈으로 돌아가기'
                      : _currentStep == 2
                          ? '등록 신청'
                          : '다음',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: Responsive.sp(15),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleNext() {
    HapticFeedback.lightImpact();

    if (_currentStep == 0) {
      if (_formKey.currentState?.validate() ?? false) {
        setState(() => _currentStep++);
      }
    } else if (_currentStep < 3) {
      setState(() => _currentStep++);
    } else {
      Navigator.of(context).pop();
    }
  }

  String _getCategoryName(String category) {
    final names = {
      'UNDERGROUND_IDOL': '지하 아이돌',
      'MAID_CAFE': '메이드카페',
      'COSPLAYER': '코스플레이어',
      'VTuber': 'VTuber',
    };
    return names[category] ?? '기타';
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}

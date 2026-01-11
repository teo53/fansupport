import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';
import '../providers/phone_verification_provider.dart';

enum AccountType { fan, idol, agency }

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();

  // Form Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _realNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _verificationCodeController = TextEditingController();
  final _birthDateController = TextEditingController();

  // State
  int _currentStep = 0;
  AccountType _accountType = AccountType.fan;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  DateTime? _selectedBirthDate;

  // 약관 동의
  bool _agreeAll = false;
  bool _agreeTerms = false;          // 서비스 이용약관 (필수)
  bool _agreePrivacy = false;        // 개인정보 처리방침 (필수)
  bool _agreeAge = false;            // 만 14세 이상 (필수)
  bool _agreeMarketing = false;      // 마케팅 정보 수신 (선택)

  @override
  void dispose() {
    _pageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nicknameController.dispose();
    _realNameController.dispose();
    _phoneController.dispose();
    _verificationCodeController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  void _updateAgreeAll() {
    setState(() {
      _agreeAll = _agreeTerms && _agreePrivacy && _agreeAge && _agreeMarketing;
    });
  }

  void _toggleAllAgreements(bool? value) {
    setState(() {
      _agreeAll = value ?? false;
      _agreeTerms = _agreeAll;
      _agreePrivacy = _agreeAll;
      _agreeAge = _agreeAll;
      _agreeMarketing = _agreeAll;
    });
  }

  bool get _requiredAgreementsChecked => _agreeTerms && _agreePrivacy && _agreeAge;

  void _nextStep() {
    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep--);
    }
  }

  Future<void> _selectBirthDate() async {
    final now = DateTime.now();
    final initialDate = _selectedBirthDate ?? DateTime(now.year - 20, 1, 1);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year - 14, now.month, now.day),
      locale: const Locale('ko', 'KR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedBirthDate = picked;
        _birthDateController.text = '${picked.year}년 ${picked.month}월 ${picked.day}일';
      });
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_requiredAgreementsChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('필수 약관에 동의해주세요'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      await ref.read(authStateProvider.notifier).register(
            _emailController.text.trim(),
            _passwordController.text,
            _nicknameController.text.trim(),
            realName: _realNameController.text.trim(),
            phone: _phoneController.text.trim(),
            birthDate: _selectedBirthDate?.toIso8601String(),
            accountType: _accountType.name.toUpperCase(),
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('회원가입 중 오류가 발생했습니다: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isLoading = authState.value?.isLoading ?? false;
    final error = authState.value?.error;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            _currentStep == 0 ? Icons.close : Icons.arrow_back,
            color: AppColors.textPrimary,
          ),
          onPressed: () {
            if (_currentStep == 0) {
              context.go('/login');
            } else {
              _previousStep();
            }
          },
        ),
        title: Text(
          '회원가입',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildProgressIndicator(),
          if (error != null) _buildErrorBanner(error),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1AccountType(),
                _buildStep2BasicInfo(),
                _buildStep3Agreements(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: List.generate(3, (index) {
          final isActive = index <= _currentStep;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
              height: 4,
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildErrorBanner(String error) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(error, style: TextStyle(color: AppColors.error, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1AccountType() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '어떤 계정으로\n가입하시겠어요?',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '가입 후에도 계정 유형을 변경할 수 있어요',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          _buildAccountTypeCard(
            type: AccountType.fan,
            icon: Icons.favorite_rounded,
            title: '일반 팬',
            description: '아이돌과 크리에이터를 응원하고\n후원하는 일반 사용자',
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),
          _buildAccountTypeCard(
            type: AccountType.idol,
            icon: Icons.star_rounded,
            title: '아이돌 / 크리에이터',
            description: '팬들과 소통하고 후원을 받는\n아이돌 또는 인플루언서',
            color: Colors.amber,
          ),
          const SizedBox(height: 16),
          _buildAccountTypeCard(
            type: AccountType.agency,
            icon: Icons.business_rounded,
            title: '소속사 / 기획사',
            description: '소속 아이돌을 관리하고\n통계를 확인하는 소속사',
            color: Colors.blueGrey,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('다음', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountTypeCard({
    required AccountType type,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    final isSelected = _accountType == type;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _accountType = type);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                  ),
                ],
              ),
            ),
            Radio<AccountType>(
              value: type,
              groupValue: _accountType,
              onChanged: (value) {
                if (value != null) setState(() => _accountType = value);
              },
              activeColor: color,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2BasicInfo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '기본 정보를\n입력해주세요',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3),
            ),
            const SizedBox(height: 8),
            Text('안전한 서비스 이용을 위해 필요해요', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
            const SizedBox(height: 28),
            _buildInputLabel('실명', required: true),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _realNameController,
              hintText: '본인 이름을 입력하세요',
              prefixIcon: Icons.person_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) return '실명을 입력해주세요';
                if (value.length < 2) return '2자 이상 입력해주세요';
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildInputLabel('닉네임', required: true),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _nicknameController,
              hintText: '서비스에서 사용할 닉네임',
              prefixIcon: Icons.badge_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) return '닉네임을 입력해주세요';
                if (value.length < 2 || value.length > 20) return '2~20자로 입력해주세요';
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildInputLabel('이메일', required: true),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _emailController,
              hintText: 'example@email.com',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) return '이메일을 입력해주세요';
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return '올바른 이메일 형식이 아닙니다';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildInputLabel('휴대폰 번호', required: true),
            const SizedBox(height: 8),
            _buildPhoneVerificationSection(),
            const SizedBox(height: 20),
            _buildInputLabel('생년월일', required: true),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _selectBirthDate,
              child: AbsorbPointer(
                child: CustomTextField(
                  controller: _birthDateController,
                  hintText: '생년월일을 선택하세요',
                  prefixIcon: Icons.cake_outlined,
                  suffixIcon: Icon(Icons.calendar_today, size: 20, color: AppColors.textSecondary),
                  validator: (value) {
                    if (value == null || value.isEmpty) return '생년월일을 선택해주세요';
                    return null;
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildInputLabel('비밀번호', required: true),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _passwordController,
              hintText: '8자 이상, 영문/숫자 포함',
              obscureText: _obscurePassword,
              prefixIcon: Icons.lock_outlined,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: AppColors.textTertiary,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return '비밀번호를 입력해주세요';
                if (value.length < 8) return '8자 이상 입력해주세요';
                if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(value)) {
                  return '영문과 숫자를 포함해주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _confirmPasswordController,
              hintText: '비밀번호 확인',
              obscureText: _obscureConfirmPassword,
              prefixIcon: Icons.lock_outlined,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: AppColors.textTertiary,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return '비밀번호 확인을 입력해주세요';
                if (value != _passwordController.text) return '비밀번호가 일치하지 않습니다';
                return null;
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) _nextStep();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('다음', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label, {bool required = false}) {
    return Row(
      children: [
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        if (required) Text(' *', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
      ],
    );
  }

  Widget _buildPhoneVerificationSection() {
    final phoneState = ref.watch(phoneVerificationProvider);
    final phoneNotifier = ref.read(phoneVerificationProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Phone number input row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CustomTextField(
                controller: _phoneController,
                hintText: '01012345678',
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_android_outlined,
                enabled: !phoneState.isVerified,
                validator: (value) {
                  if (value == null || value.isEmpty) return '휴대폰 번호를 입력해주세요';
                  if (!RegExp(r'^01[0-9]{8,9}$').hasMatch(value)) {
                    return '올바른 휴대폰 번호를 입력해주세요';
                  }
                  if (!phoneState.isVerified) {
                    return '휴대폰 인증이 필요합니다';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: phoneState.isVerified || phoneState.isLoading
                    ? null
                    : () async {
                        final phone = _phoneController.text.trim();
                        if (phone.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('휴대폰 번호를 입력해주세요'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                          return;
                        }
                        await phoneNotifier.sendVerificationCode(phone);
                        if (mounted && phoneState.error == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('인증번호가 발송되었습니다'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: phoneState.isVerified
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.primary.withOpacity(0.1),
                  foregroundColor: phoneState.isVerified ? AppColors.success : AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: phoneState.isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : phoneState.isVerified
                        ? const Icon(Icons.check, size: 20)
                        : Text(
                            phoneState.remainingSeconds != null
                                ? '${phoneState.remainingSeconds}초'
                                : '인증',
                          ),
              ),
            ),
          ],
        ),

        // Verification code input (shown after code is sent)
        if (phoneState.isCodeSent && !phoneState.isVerified) ...[
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _verificationCodeController,
                  hintText: '인증번호 6자리',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.pin_outlined,
                  maxLength: 6,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    final code = _verificationCodeController.text.trim();
                    if (code.length != 6) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('6자리 인증번호를 입력해주세요'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                      return;
                    }
                    final success = await phoneNotifier.verifyCode(code);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success ? '인증이 완료되었습니다' : '인증번호가 일치하지 않습니다'),
                          backgroundColor: success ? AppColors.success : AppColors.error,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('확인'),
                ),
              ),
            ],
          ),
        ],

        // Verification status message
        if (phoneState.isVerified)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success, size: 16),
                const SizedBox(width: 4),
                Text(
                  '인증이 완료되었습니다',
                  style: TextStyle(color: AppColors.success, fontSize: 13),
                ),
              ],
            ),
          ),

        // Error message
        if (phoneState.error != null && !phoneState.isVerified)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              phoneState.error!,
              style: TextStyle(color: AppColors.error, fontSize: 13),
            ),
          ),
      ],
    );
  }

  Widget _buildStep3Agreements() {
    final authState = ref.watch(authStateProvider);
    final isLoading = authState.value?.isLoading ?? false;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '서비스 이용 약관에\n동의해주세요',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _toggleAllAgreements(!_agreeAll),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _agreeAll ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: _agreeAll ? AppColors.primary : AppColors.border, width: 2),
                    ),
                    child: _agreeAll ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
                  ),
                ),
                const SizedBox(width: 12),
                Text('전체 동의', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildAgreementItem(title: '서비스 이용약관', required: true, value: _agreeTerms, onChanged: (v) {
            setState(() => _agreeTerms = v ?? false);
            _updateAgreeAll();
          }),
          _buildAgreementItem(title: '개인정보 수집 및 이용 동의', required: true, value: _agreePrivacy, onChanged: (v) {
            setState(() => _agreePrivacy = v ?? false);
            _updateAgreeAll();
          }),
          _buildAgreementItem(title: '만 14세 이상입니다', required: true, value: _agreeAge, onChanged: (v) {
            setState(() => _agreeAge = v ?? false);
            _updateAgreeAll();
          }),
          _buildAgreementItem(title: '마케팅 정보 수신 동의', required: false, value: _agreeMarketing, onChanged: (v) {
            setState(() => _agreeMarketing = v ?? false);
            _updateAgreeAll();
          }),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.backgroundAlt, borderRadius: BorderRadius.circular(8)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '필수 약관에 동의하지 않으면 서비스 이용이 제한될 수 있습니다.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: (isLoading || !_requiredAgreementsChecked) ? null : _handleRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.border,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('가입 완료', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildAgreementItem({
    required String title,
    required bool required,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => onChanged(!value),
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: value ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: value ? AppColors.primary : AppColors.border, width: 1.5),
              ),
              child: value ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(!value),
              child: Row(
                children: [
                  Text(
                    required ? '[필수] ' : '[선택] ',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: required ? AppColors.primary : AppColors.textSecondary),
                  ),
                  Expanded(child: Text(title, style: TextStyle(fontSize: 14, color: AppColors.textPrimary))),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

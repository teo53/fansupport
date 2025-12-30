import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('비밀번호 변경', style: TextStyle(fontSize: Responsive.sp(18))),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.wp(5)),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: Responsive.hp(2)),

              // Security Info
              Container(
                padding: EdgeInsets.all(Responsive.wp(4)),
                decoration: BoxDecoration(
                  color: AppColors.infoSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.security, color: AppColors.info, size: Responsive.sp(24)),
                    SizedBox(width: Responsive.wp(3)),
                    Expanded(
                      child: Text(
                        '안전한 비밀번호를 위해 8자 이상, 영문/숫자/특수문자를 조합해주세요.',
                        style: TextStyle(
                          fontSize: Responsive.sp(13),
                          color: AppColors.info,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: Responsive.hp(4)),

              // Current Password
              _buildPasswordField(
                controller: _currentPasswordController,
                label: '현재 비밀번호',
                hint: '현재 비밀번호를 입력하세요',
                obscureText: _obscureCurrent,
                onToggleVisibility: () => setState(() => _obscureCurrent = !_obscureCurrent),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '현재 비밀번호를 입력해주세요';
                  }
                  return null;
                },
              ),
              SizedBox(height: Responsive.hp(3)),

              // New Password
              _buildPasswordField(
                controller: _newPasswordController,
                label: '새 비밀번호',
                hint: '새 비밀번호를 입력하세요',
                obscureText: _obscureNew,
                onToggleVisibility: () => setState(() => _obscureNew = !_obscureNew),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '새 비밀번호를 입력해주세요';
                  }
                  if (value.length < 8) {
                    return '비밀번호는 8자 이상이어야 합니다';
                  }
                  if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(value)) {
                    return '영문과 숫자를 모두 포함해주세요';
                  }
                  if (value == _currentPasswordController.text) {
                    return '현재 비밀번호와 다른 비밀번호를 입력해주세요';
                  }
                  return null;
                },
              ),
              SizedBox(height: Responsive.hp(1)),
              _buildPasswordStrengthIndicator(),
              SizedBox(height: Responsive.hp(3)),

              // Confirm Password
              _buildPasswordField(
                controller: _confirmPasswordController,
                label: '새 비밀번호 확인',
                hint: '새 비밀번호를 다시 입력하세요',
                obscureText: _obscureConfirm,
                onToggleVisibility: () => setState(() => _obscureConfirm = !_obscureConfirm),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '비밀번호 확인을 입력해주세요';
                  }
                  if (value != _newPasswordController.text) {
                    return '비밀번호가 일치하지 않습니다';
                  }
                  return null;
                },
              ),
              SizedBox(height: Responsive.hp(5)),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: Responsive.hp(2)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: Responsive.sp(20),
                          height: Responsive.sp(20),
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          '비밀번호 변경',
                          style: TextStyle(
                            fontSize: Responsive.sp(16),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: Responsive.sp(14),
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: Responsive.hp(1)),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          style: TextStyle(fontSize: Responsive.sp(15)),
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.textHint),
            prefixIcon: Icon(Icons.lock_outline, color: AppColors.textSecondary),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: AppColors.textSecondary,
              ),
              onPressed: onToggleVisibility,
            ),
            filled: true,
            fillColor: AppColors.inputBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.error),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    final password = _newPasswordController.text;
    int strength = 0;

    if (password.length >= 8) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
    if (RegExp(r'[a-z]').hasMatch(password)) strength++;
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength++;

    Color getColor() {
      if (strength <= 1) return AppColors.error;
      if (strength <= 2) return AppColors.warning;
      if (strength <= 3) return Colors.orange;
      return AppColors.success;
    }

    String getText() {
      if (password.isEmpty) return '';
      if (strength <= 1) return '매우 약함';
      if (strength <= 2) return '약함';
      if (strength <= 3) return '보통';
      if (strength <= 4) return '강함';
      return '매우 강함';
    }

    if (password.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: Responsive.hp(1)),
        Row(
          children: List.generate(5, (index) {
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: index < 4 ? Responsive.wp(1) : 0),
                decoration: BoxDecoration(
                  color: index < strength ? getColor() : AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        SizedBox(height: Responsive.hp(0.5)),
        Text(
          getText(),
          style: TextStyle(
            fontSize: Responsive.sp(12),
            color: getColor(),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('비밀번호가 변경되었습니다'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    }
  }
}

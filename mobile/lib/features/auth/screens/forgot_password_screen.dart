import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('비밀번호 찾기', style: TextStyle(fontSize: Responsive.sp(18))),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(Responsive.wp(5)),
          child: _emailSent ? _buildSuccessView() : _buildFormView(),
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: Responsive.hp(3)),

          // Icon
          Center(
            child: Container(
              width: Responsive.wp(25),
              height: Responsive.wp(25),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_reset_rounded,
                size: Responsive.sp(50),
                color: AppColors.primary,
              ),
            ),
          ),
          SizedBox(height: Responsive.hp(4)),

          // Title
          Text(
            '비밀번호를 잊으셨나요?',
            style: TextStyle(
              fontSize: Responsive.sp(24),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: Responsive.hp(1)),
          Text(
            '가입하신 이메일 주소를 입력하시면\n비밀번호 재설정 링크를 보내드립니다.',
            style: TextStyle(
              fontSize: Responsive.sp(14),
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          SizedBox(height: Responsive.hp(4)),

          // Email Field
          Text(
            '이메일',
            style: TextStyle(
              fontSize: Responsive.sp(14),
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: Responsive.hp(1)),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(fontSize: Responsive.sp(15)),
            decoration: InputDecoration(
              hintText: 'example@email.com',
              hintStyle: TextStyle(color: AppColors.textHint),
              prefixIcon: Icon(Icons.email_outlined, color: AppColors.textSecondary),
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
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '이메일을 입력해주세요';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return '올바른 이메일 형식을 입력해주세요';
              }
              return null;
            },
          ),
          SizedBox(height: Responsive.hp(4)),

          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _sendResetEmail,
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
                      '재설정 링크 보내기',
                      style: TextStyle(
                        fontSize: Responsive.sp(16),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          SizedBox(height: Responsive.hp(3)),

          // Back to login
          Center(
            child: TextButton(
              onPressed: () => context.pop(),
              child: Text(
                '로그인으로 돌아가기',
                style: TextStyle(
                  fontSize: Responsive.sp(14),
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      children: [
        SizedBox(height: Responsive.hp(8)),

        // Success Icon
        Container(
          width: Responsive.wp(30),
          height: Responsive.wp(30),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.mark_email_read_rounded,
            size: Responsive.sp(60),
            color: AppColors.success,
          ),
        ),
        SizedBox(height: Responsive.hp(4)),

        Text(
          '이메일을 확인해주세요',
          style: TextStyle(
            fontSize: Responsive.sp(24),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: Responsive.hp(2)),
        Text(
          '${_emailController.text}로\n비밀번호 재설정 링크를 보냈습니다.',
          style: TextStyle(
            fontSize: Responsive.sp(15),
            color: AppColors.textSecondary,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: Responsive.hp(2)),
        Container(
          padding: EdgeInsets.all(Responsive.wp(4)),
          decoration: BoxDecoration(
            color: AppColors.infoSoft,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.info, size: Responsive.sp(20)),
              SizedBox(width: Responsive.wp(2)),
              Expanded(
                child: Text(
                  '이메일이 도착하지 않으면 스팸 폴더를 확인해주세요.',
                  style: TextStyle(
                    fontSize: Responsive.sp(13),
                    color: AppColors.info,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: Responsive.hp(4)),

        // Resend Button
        TextButton(
          onPressed: _isLoading ? null : _sendResetEmail,
          child: Text(
            '이메일 다시 보내기',
            style: TextStyle(
              fontSize: Responsive.sp(15),
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: Responsive.hp(2)),

        // Back to login
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => context.go('/login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: Responsive.hp(2)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              '로그인으로 돌아가기',
              style: TextStyle(
                fontSize: Responsive.sp(16),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoading = false;
        _emailSent = true;
      });
    }
  }
}

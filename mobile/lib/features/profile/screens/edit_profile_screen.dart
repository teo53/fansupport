import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/mock/mock_data.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _nicknameController;
  late TextEditingController _bioController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  String? _profileImage;
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final user = MockData.demoUser;
    _nicknameController = TextEditingController(text: user.nickname);
    _bioController = TextEditingController(text: '지하돌 덕후 5년차 🎤');
    _emailController = TextEditingController(text: user.email);
    _phoneController = TextEditingController(text: '010-1234-5678');
    _profileImage = user.profileImage;
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _bioController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _markAsChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (_hasChanges) {
          final discard = await _showDiscardDialog();
          if (discard == true && context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('프로필 수정', style: TextStyle(fontSize: Responsive.sp(18))),
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () async {
              if (_hasChanges) {
                final discard = await _showDiscardDialog();
                if (discard == true) context.pop();
              } else {
                context.pop();
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: _hasChanges && !_isLoading ? _saveProfile : null,
              child: _isLoading
                  ? SizedBox(
                      width: Responsive.sp(18),
                      height: Responsive.sp(18),
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      '저장',
                      style: TextStyle(
                        fontSize: Responsive.sp(16),
                        fontWeight: FontWeight.w600,
                        color: _hasChanges ? AppColors.primary : AppColors.textHint,
                      ),
                    ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(Responsive.wp(4)),
          child: Column(
            children: [
              // 프로필 이미지
              _buildProfileImageSection(),
              SizedBox(height: Responsive.hp(4)),

              // 기본 정보
              _buildSectionTitle('기본 정보'),
              SizedBox(height: Responsive.hp(1.5)),
              _buildTextField(
                controller: _nicknameController,
                label: '닉네임',
                hint: '닉네임을 입력하세요',
                maxLength: 20,
                onChanged: (_) => _markAsChanged(),
              ),
              SizedBox(height: Responsive.hp(2)),
              _buildTextField(
                controller: _bioController,
                label: '자기소개',
                hint: '자기소개를 입력하세요',
                maxLength: 100,
                maxLines: 3,
                onChanged: (_) => _markAsChanged(),
              ),

              SizedBox(height: Responsive.hp(3)),

              // 연락처 정보
              _buildSectionTitle('연락처 정보'),
              SizedBox(height: Responsive.hp(1.5)),
              _buildTextField(
                controller: _emailController,
                label: '이메일',
                hint: '이메일을 입력하세요',
                keyboardType: TextInputType.emailAddress,
                enabled: false,
                suffixIcon: Icons.lock_outline,
              ),
              SizedBox(height: Responsive.hp(2)),
              _buildTextField(
                controller: _phoneController,
                label: '전화번호',
                hint: '전화번호를 입력하세요',
                keyboardType: TextInputType.phone,
                onChanged: (_) => _markAsChanged(),
              ),

              SizedBox(height: Responsive.hp(3)),

              // SNS 연동
              _buildSectionTitle('SNS 연동'),
              SizedBox(height: Responsive.hp(1.5)),
              _buildSocialLinkCard(
                icon: 'assets/icons/twitter.png',
                name: 'Twitter',
                isConnected: true,
                username: '@starfan_kr',
              ),
              SizedBox(height: Responsive.hp(1)),
              _buildSocialLinkCard(
                icon: 'assets/icons/instagram.png',
                name: 'Instagram',
                isConnected: false,
              ),

              SizedBox(height: Responsive.hp(4)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImageSection() {
    return Center(
      child: Stack(
        children: [
          Container(
            width: Responsive.wp(28),
            height: Responsive.wp(28),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border, width: 3),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipOval(
              child: _profileImage != null
                  ? CachedNetworkImage(
                      imageUrl: _profileImage!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: AppColors.inputBackground,
                        child: Icon(
                          Icons.person,
                          size: Responsive.sp(40),
                          color: AppColors.textHint,
                        ),
                      ),
                    )
                  : Container(
                      color: AppColors.inputBackground,
                      child: Icon(
                        Icons.person,
                        size: Responsive.sp(40),
                        color: AppColors.textHint,
                      ),
                    ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _showImagePickerOptions,
              child: Container(
                width: Responsive.wp(9),
                height: Responsive.wp(9),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: Responsive.sp(18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: Responsive.sp(16),
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int? maxLength,
    int maxLines = 1,
    TextInputType? keyboardType,
    bool enabled = true,
    IconData? suffixIcon,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: Responsive.sp(13),
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: Responsive.hp(0.8)),
        TextField(
          controller: controller,
          maxLength: maxLength,
          maxLines: maxLines,
          keyboardType: keyboardType,
          enabled: enabled,
          onChanged: onChanged,
          style: TextStyle(
            fontSize: Responsive.sp(15),
            color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.textHint,
              fontSize: Responsive.sp(15),
            ),
            filled: true,
            fillColor: enabled ? AppColors.inputBackground : AppColors.border.withValues(alpha: 0.5),
            counterStyle: TextStyle(
              fontSize: Responsive.sp(11),
              color: AppColors.textHint,
            ),
            suffixIcon: suffixIcon != null
                ? Icon(suffixIcon, color: AppColors.textHint, size: Responsive.sp(18))
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: Responsive.wp(4),
              vertical: Responsive.hp(1.8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLinkCard({
    required String icon,
    required String name,
    required bool isConnected,
    String? username,
  }) {
    return Container(
      padding: EdgeInsets.all(Responsive.wp(4)),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isConnected ? AppColors.primary.withValues(alpha: 0.3) : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: Responsive.wp(10),
            height: Responsive.wp(10),
            decoration: BoxDecoration(
              color: _getSocialColor(name).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getSocialIcon(name),
              color: _getSocialColor(name),
              size: Responsive.sp(22),
            ),
          ),
          SizedBox(width: Responsive.wp(3)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: Responsive.sp(15),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isConnected && username != null)
                  Text(
                    username,
                    style: TextStyle(
                      fontSize: Responsive.sp(13),
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          if (isConnected)
            TextButton(
              onPressed: () => _disconnectSocial(name),
              child: Text(
                '연결 해제',
                style: TextStyle(
                  fontSize: Responsive.sp(13),
                  color: AppColors.error,
                ),
              ),
            )
          else
            ElevatedButton(
              onPressed: () => _connectSocial(name),
              style: ElevatedButton.styleFrom(
                backgroundColor: _getSocialColor(name),
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.wp(4),
                  vertical: Responsive.hp(1),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                '연결',
                style: TextStyle(
                  fontSize: Responsive.sp(13),
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _getSocialIcon(String name) {
    switch (name.toLowerCase()) {
      case 'twitter':
        return Icons.flutter_dash; // Placeholder
      case 'instagram':
        return Icons.camera_alt_outlined;
      default:
        return Icons.link;
    }
  }

  Color _getSocialColor(String name) {
    switch (name.toLowerCase()) {
      case 'twitter':
        return const Color(0xFF1DA1F2);
      case 'instagram':
        return const Color(0xFFE4405F);
      default:
        return AppColors.primary;
    }
  }

  void _showImagePickerOptions() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(Responsive.wp(4)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: Responsive.wp(10),
              height: 4,
              margin: EdgeInsets.only(bottom: Responsive.hp(2)),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              '프로필 사진 변경',
              style: TextStyle(
                fontSize: Responsive.sp(18),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: Responsive.hp(2)),
            ListTile(
              leading: Container(
                width: Responsive.wp(12),
                height: Responsive.wp(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.camera_alt_rounded, color: AppColors.primary),
              ),
              title: const Text('카메라로 촬영'),
              onTap: () {
                Navigator.pop(context);
                _markAsChanged();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('카메라 기능은 준비 중입니다')),
                );
              },
            ),
            ListTile(
              leading: Container(
                width: Responsive.wp(12),
                height: Responsive.wp(12),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.photo_library_rounded, color: AppColors.secondary),
              ),
              title: const Text('앨범에서 선택'),
              onTap: () {
                Navigator.pop(context);
                _markAsChanged();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('앨범 기능은 준비 중입니다')),
                );
              },
            ),
            if (_profileImage != null)
              ListTile(
                leading: Container(
                  width: Responsive.wp(12),
                  height: Responsive.wp(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.delete_outline_rounded, color: AppColors.error),
                ),
                title: Text(
                  '기본 이미지로 변경',
                  style: TextStyle(color: AppColors.error),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _profileImage = null;
                    _hasChanges = true;
                  });
                },
              ),
            SizedBox(height: Responsive.hp(2)),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showDiscardDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('변경사항 취소'),
        content: const Text('저장하지 않은 변경사항이 있습니다.\n정말 나가시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              '취소',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              '나가기',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _saveProfile() async {
    setState(() => _isLoading = true);

    // 저장 시뮬레이션
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('프로필이 저장되었습니다'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    }
  }

  void _connectSocial(String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$name 연동 기능은 준비 중입니다')),
    );
  }

  void _disconnectSocial(String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('$name 연결 해제'),
        content: Text('$name 계정 연동을 해제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '취소',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _markAsChanged();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$name 연결이 해제되었습니다')),
              );
            },
            child: Text(
              '해제',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

/// 💬 Bubble 메시지 작성
/// 아이돌 → 구독자 메시지 발송
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/models/subscription_tier.dart';

enum BubbleTargetAudience {
  all,       // 전체 구독자 (일반 + 프리미엄)
  standard,  // 일반 구독자만
  premium,   // 프리미엄 구독자만
}

extension BubbleTargetAudienceExtension on BubbleTargetAudience {
  String get displayName {
    switch (this) {
      case BubbleTargetAudience.all:
        return '전체 구독자';
      case BubbleTargetAudience.standard:
        return '일반 구독자';
      case BubbleTargetAudience.premium:
        return '프리미엄 구독자';
    }
  }

  IconData get icon {
    switch (this) {
      case BubbleTargetAudience.all:
        return Icons.people;
      case BubbleTargetAudience.standard:
        return Icons.favorite;
      case BubbleTargetAudience.premium:
        return Icons.star;
    }
  }

  Color get color {
    switch (this) {
      case BubbleTargetAudience.all:
        return AppColors.primary;
      case BubbleTargetAudience.standard:
        return AppColors.info;
      case BubbleTargetAudience.premium:
        return AppColors.neonPurple;
    }
  }
}

class BubbleComposeScreen extends ConsumerStatefulWidget {
  const BubbleComposeScreen({super.key});

  @override
  ConsumerState<BubbleComposeScreen> createState() =>
      _BubbleComposeScreenState();
}

class _BubbleComposeScreenState extends ConsumerState<BubbleComposeScreen> {
  final _messageController = TextEditingController();
  final _imagePicker = ImagePicker();
  final List<XFile> _selectedImages = [];
  BubbleTargetAudience _targetAudience = BubbleTargetAudience.all;
  bool _isSending = false;

  // Mock subscriber counts - TODO: Replace with actual data
  final int _totalSubscribers = 1247;
  final int _standardSubscribers = 823;
  final int _premiumSubscribers = 424;

  int get _targetSubscriberCount {
    switch (_targetAudience) {
      case BubbleTargetAudience.all:
        return _totalSubscribers;
      case BubbleTargetAudience.standard:
        return _standardSubscribers;
      case BubbleTargetAudience.premium:
        return _premiumSubscribers;
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final images = await _imagePicker.pickMultiImage(
      maxWidth: 1920,
      imageQuality: 85,
    );

    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images);
        // Limit to 4 images
        if (_selectedImages.length > 4) {
          _selectedImages.removeRange(4, _selectedImages.length);
        }
      });
    }
  }

  Future<void> _pickCamera() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        if (_selectedImages.length < 4) {
          _selectedImages.add(image);
        }
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty && _selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('메시지 또는 이미지를 입력해주세요'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      // TODO: Upload images to storage
      // TODO: Send message via API
      // final imageUrls = await _uploadImages();
      // await _sendBubbleMessage(
      //   message: _messageController.text.trim(),
      //   images: imageUrls,
      //   targetAudience: _targetAudience,
      // );

      // Mock delay
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('메시지가 ${_targetSubscriberCount}명의 구독자에게 전송되었습니다'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('전송 실패: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, size: 24),
          onPressed: _isSending ? null : () => Navigator.pop(context),
        ),
        title: const Text(
          'Bubble 메시지 보내기',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            fontFamily: 'Pretendard',
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isSending ? null : _sendMessage,
            child: _isSending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    '전송',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                      fontFamily: 'Pretendard',
                    ),
                  ),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppColors.divider,
            height: 1,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.wp(4),
                vertical: 16,
              ),
              children: [
                // Target audience selector
                _buildTargetAudienceSelector(),

                const SizedBox(height: 20),

                // Message input
                _buildMessageInput(),

                const SizedBox(height: 16),

                // Image attachments
                if (_selectedImages.isNotEmpty) ...[
                  _buildImageGrid(),
                  const SizedBox(height: 16),
                ],

                // Add media buttons
                _buildMediaButtons(),

                const SizedBox(height: 24),

                // Preview section
                _buildPreviewSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetAudienceSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.softShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '수신 대상',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              fontFamily: 'Pretendard',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildAudienceChip(BubbleTargetAudience.all),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildAudienceChip(BubbleTargetAudience.standard),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildAudienceChip(BubbleTargetAudience.premium),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _targetAudience.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  _targetAudience.icon,
                  size: 16,
                  color: _targetAudience.color,
                ),
                const SizedBox(width: 8),
                Text(
                  '$_targetSubscriberCount명에게 전송됩니다',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _targetAudience.color,
                    fontFamily: 'Pretendard',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudienceChip(BubbleTargetAudience audience) {
    final isSelected = _targetAudience == audience;

    return GestureDetector(
      onTap: () => setState(() => _targetAudience = audience),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? audience.color.withValues(alpha: 0.15)
              : AppColors.backgroundAlt,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? audience.color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              audience.icon,
              size: 20,
              color: isSelected ? audience.color : AppColors.textSecondary,
            ),
            const SizedBox(height: 4),
            Text(
              audience.displayName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? audience.color : AppColors.textSecondary,
                fontFamily: 'Pretendard',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.softShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '메시지',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Pretendard',
                ),
              ),
              Text(
                '${_messageController.text.length}/1000',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                  fontFamily: 'Pretendard',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _messageController,
            maxLength: 1000,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: '구독자에게 보낼 메시지를 입력하세요...',
              hintStyle: TextStyle(
                color: AppColors.textTertiary,
                fontFamily: 'Pretendard',
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              counterText: '',
              contentPadding: const EdgeInsets.all(12),
            ),
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              fontFamily: 'Pretendard',
            ),
            onChanged: (value) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGrid() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.softShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '첨부 이미지',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Pretendard',
                ),
              ),
              Text(
                '${_selectedImages.length}/4',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                  fontFamily: 'Pretendard',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _selectedImages.length,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(_selectedImages[index].path),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => _removeImage(index),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMediaButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildMediaButton(
            icon: Icons.image_outlined,
            label: '갤러리',
            onTap: _selectedImages.length < 4 ? _pickImages : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMediaButton(
            icon: Icons.camera_alt_outlined,
            label: '카메라',
            onTap: _selectedImages.length < 4 ? _pickCamera : null,
          ),
        ),
      ],
    );
  }

  Widget _buildMediaButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    final isDisabled = onTap == null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isDisabled
              ? AppColors.backgroundAlt
              : AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDisabled
                ? AppColors.border
                : AppColors.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isDisabled ? AppColors.textTertiary : AppColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDisabled ? AppColors.textTertiary : AppColors.primary,
                fontFamily: 'Pretendard',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewSection() {
    if (_messageController.text.isEmpty && _selectedImages.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.softShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '미리보기',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              fontFamily: 'Pretendard',
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.backgroundAlt,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_messageController.text.isNotEmpty) ...[
                  Text(
                    _messageController.text,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                ],
                if (_selectedImages.isNotEmpty) ...[
                  if (_messageController.text.isNotEmpty)
                    const SizedBox(height: 8),
                  Text(
                    '🖼️ 이미지 ${_selectedImages.length}개',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

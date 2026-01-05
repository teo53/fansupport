/// 📝 게시글 작성 화면
/// 정산/메시/--시 등 모든 게시글 작성
library;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/models/post_type.dart';

class PostCreateScreen extends ConsumerStatefulWidget {
  final PostType? initialType;

  const PostCreateScreen({
    super.key,
    this.initialType,
  });

  @override
  ConsumerState<PostCreateScreen> createState() => _PostCreateScreenState();
}

class _PostCreateScreenState extends ConsumerState<PostCreateScreen> {
  final _contentController = TextEditingController();
  final _imagePicker = ImagePicker();

  PostType _selectedType = PostType.general;
  List<XFile> _selectedImages = [];
  bool _isSubscriberOnly = false;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialType != null) {
      _selectedType = widget.initialType!;
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final images = await _imagePicker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
          // 최대 4장 제한
          if (_selectedImages.length > 4) {
            _selectedImages = _selectedImages.take(4).toList();
          }
        });
      }
    } catch (e) {
      _showError('이미지를 선택할 수 없습니다');
    }
  }

  Future<void> _pickCamera() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null && _selectedImages.length < 4) {
        setState(() {
          _selectedImages.add(image);
        });
      }
    } catch (e) {
      _showError('카메라를 사용할 수 없습니다');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _submitPost() async {
    if (_contentController.text.trim().isEmpty) {
      _showError('내용을 입력해주세요');
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // TODO: Implement actual upload logic
      // 1. Upload images to storage
      // 2. Create post with image URLs
      // 3. Send to backend API

      await Future.delayed(const Duration(seconds: 2)); // Simulated upload

      if (mounted) {
        Navigator.pop(context, true); // Return true for success
        _showSuccess('게시글이 등록되었습니다');
      }
    } catch (e) {
      _showError('게시글 등록에 실패했습니다');
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
      ),
    );
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
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '게시글 작성',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            fontFamily: 'Pretendard',
          ),
        ),
        actions: [
          if (_isUploading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _submitPost,
              child: const Text(
                '올리기',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Pretendard',
                ),
              ),
            ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Post Type Selector
              _buildTypeSelector(),

              const Divider(height: 1),

              // Content Input
              _buildContentInput(),

              // Image Grid
              if (_selectedImages.isNotEmpty)
                _buildImageGrid(),

              // Image Picker Buttons
              _buildImagePickerButtons(),

              // Options
              _buildOptions(),

              SizedBox(height: Responsive.hp(10)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.wp(4),
        vertical: 16,
      ),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '게시글 종류',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              fontFamily: 'Pretendard',
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTypeChip(PostType.general),
              _buildTypeChip(PostType.cheki),
              _buildTypeChip(PostType.hiddenCheki),
              _buildTypeChip(PostType.mealDate),
              _buildTypeChip(PostType.birthdayTime),
              _buildTypeChip(PostType.announcement),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(PostType type) {
    final isSelected = _selectedType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
          // 히든정산 선택 시 자동으로 구독자 전용 체크
          if (type == PostType.hiddenCheki) {
            _isSubscriberOnly = true;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? type.backgroundColor : AppColors.backgroundAlt,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? type.color : Colors.transparent,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              type.icon,
              size: 16,
              color: isSelected ? type.color : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              type.displayName,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? type.color : AppColors.textSecondary,
                fontFamily: 'Pretendard',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentInput() {
    return Container(
      padding: EdgeInsets.all(Responsive.wp(4)),
      color: Colors.white,
      child: TextField(
        controller: _contentController,
        maxLines: null,
        minLines: 5,
        maxLength: 2000,
        decoration: const InputDecoration(
          hintText: '내용을 입력하세요...\n\n체키 정산, 메시, 일상 등 자유롭게 공유해보세요!',
          hintStyle: TextStyle(
            fontSize: 15,
            color: AppColors.textTertiary,
            fontFamily: 'Pretendard',
          ),
          border: InputBorder.none,
          counterText: '',
        ),
        style: const TextStyle(
          fontSize: 15,
          height: 1.6,
          fontFamily: 'Pretendard',
        ),
      ),
    );
  }

  Widget _buildImageGrid() {
    return Container(
      padding: EdgeInsets.all(Responsive.wp(4)),
      color: Colors.white,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
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
                    padding: const EdgeInsets.all(6),
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
    );
  }

  Widget _buildImagePickerButtons() {
    return Container(
      padding: EdgeInsets.all(Responsive.wp(4)),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _selectedImages.length < 4 ? _pickImages : null,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: _selectedImages.length < 4
                      ? AppColors.primarySoft
                      : AppColors.backgroundAlt,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedImages.length < 4
                        ? AppColors.primary.withValues(alpha: 0.3)
                        : AppColors.border,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_outlined,
                      color: _selectedImages.length < 4
                          ? AppColors.primary
                          : AppColors.textTertiary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '갤러리 (${_selectedImages.length}/4)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _selectedImages.length < 4
                            ? AppColors.primary
                            : AppColors.textTertiary,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: _selectedImages.length < 4 ? _pickCamera : null,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: _selectedImages.length < 4
                      ? AppColors.infoSoft
                      : AppColors.backgroundAlt,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedImages.length < 4
                        ? AppColors.info.withValues(alpha: 0.3)
                        : AppColors.border,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt_outlined,
                      color: _selectedImages.length < 4
                          ? AppColors.info
                          : AppColors.textTertiary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '카메라',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _selectedImages.length < 4
                            ? AppColors.info
                            : AppColors.textTertiary,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptions() {
    // 히든정산은 무조건 구독자 전용
    final canToggleSubscriber = _selectedType != PostType.hiddenCheki;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(Responsive.wp(4)),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '옵션',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              fontFamily: 'Pretendard',
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: canToggleSubscriber
                ? () {
                    setState(() {
                      _isSubscriberOnly = !_isSubscriberOnly;
                    });
                  }
                : null,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isSubscriberOnly
                    ? AppColors.neonPurple.withValues(alpha: 0.1)
                    : AppColors.backgroundAlt,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isSubscriberOnly
                      ? AppColors.neonPurple
                      : AppColors.border,
                  width: _isSubscriberOnly ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isSubscriberOnly
                        ? Icons.check_box_rounded
                        : Icons.check_box_outline_blank_rounded,
                    color: _isSubscriberOnly
                        ? AppColors.neonPurple
                        : AppColors.textTertiary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '구독자 전용',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: _isSubscriberOnly
                                ? AppColors.neonPurple
                                : AppColors.textPrimary,
                            fontFamily: 'Pretendard',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _selectedType == PostType.hiddenCheki
                              ? '히든정산은 자동으로 구독자 전용입니다'
                              : '구독자만 볼 수 있는 게시글로 설정',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontFamily: 'Pretendard',
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_selectedType == PostType.hiddenCheki)
                    const Icon(
                      Icons.lock,
                      color: AppColors.neonPurple,
                      size: 20,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../models/idol_model.dart';

/// 👤 아이돌 아바타 위젯 - 네트워크 실패 시 카테고리별 아이콘 표시
class IdolAvatar extends StatelessWidget {
  final String? imageUrl;
  final IdolCategory? category;
  final double size;
  final bool showBorder;
  final Color? borderColor;
  final double borderWidth;

  const IdolAvatar({
    super.key,
    this.imageUrl,
    this.category,
    this.size = 48,
    this.showBorder = false,
    this.borderColor,
    this.borderWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: showBorder
            ? Border.all(
                color: borderColor ?? Colors.white,
                width: borderWidth,
              )
            : null,
        boxShadow: showBorder
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: ClipOval(
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildPlaceholder(),
                errorWidget: (context, url, error) => _buildCategoryIcon(),
              )
            : _buildCategoryIcon(),
      ),
    );
  }

  /// 로딩 중 플레이스홀더
  Widget _buildPlaceholder() {
    return Container(
      color: _getCategoryColor().withOpacity(0.1),
      child: Center(
        child: SizedBox(
          width: size * 0.3,
          height: size * 0.3,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(_getCategoryColor()),
          ),
        ),
      ),
    );
  }

  /// 카테고리별 아이콘
  Widget _buildCategoryIcon() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getCategoryColor(),
            _getCategoryColor().withOpacity(0.7),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          _getCategoryIconData(),
          size: size * 0.5,
          color: Colors.white,
        ),
      ),
    );
  }

  /// 카테고리별 색상
  Color _getCategoryColor() {
    switch (category) {
      case IdolCategory.undergroundIdol:
        return AppColors.undergroundCategory;
      case IdolCategory.maidCafe:
        return AppColors.maidCategory;
      case IdolCategory.cosplayer:
        return AppColors.cosplayCategory;
      case IdolCategory.vtuber:
        return AppColors.vtuberCategory;
      case IdolCategory.streamer:
        return AppColors.streamerCategory;
      default:
        return AppColors.primary;
    }
  }

  /// 카테고리별 아이콘
  IconData _getCategoryIconData() {
    switch (category) {
      case IdolCategory.undergroundIdol:
        return Icons.mic_rounded; // 마이크
      case IdolCategory.maidCafe:
        return Icons.local_cafe_rounded; // 커피잔
      case IdolCategory.cosplayer:
        return Icons.photo_camera_rounded; // 카메라
      case IdolCategory.vtuber:
        return Icons.videocam_rounded; // 비디오
      case IdolCategory.streamer:
        return Icons.stream_rounded; // 스트리밍
      default:
        return Icons.person_rounded; // 기본 사람 아이콘
    }
  }
}

/// 정사각형 아이돌 이미지 (카드용)
class IdolImage extends StatelessWidget {
  final String? imageUrl;
  final IdolCategory? category;
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const IdolImage({
    super.key,
    this.imageUrl,
    this.category,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildPlaceholder(),
                errorWidget: (context, url, error) => _buildCategoryIcon(),
              )
            : _buildCategoryIcon(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: _getCategoryColor().withOpacity(0.1),
      child: Center(
        child: SizedBox(
          width: width * 0.2,
          height: width * 0.2,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation(_getCategoryColor()),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryIcon() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getCategoryColor(),
            _getCategoryColor().withOpacity(0.7),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          _getCategoryIconData(),
          size: width * 0.4,
          color: Colors.white.withOpacity(0.9),
        ),
      ),
    );
  }

  Color _getCategoryColor() {
    switch (category) {
      case IdolCategory.undergroundIdol:
        return AppColors.undergroundCategory;
      case IdolCategory.maidCafe:
        return AppColors.maidCategory;
      case IdolCategory.cosplayer:
        return AppColors.cosplayCategory;
      case IdolCategory.vtuber:
        return AppColors.vtuberCategory;
      case IdolCategory.streamer:
        return AppColors.streamerCategory;
      default:
        return AppColors.primary;
    }
  }

  IconData _getCategoryIconData() {
    switch (category) {
      case IdolCategory.undergroundIdol:
        return Icons.mic_rounded;
      case IdolCategory.maidCafe:
        return Icons.local_cafe_rounded;
      case IdolCategory.cosplayer:
        return Icons.photo_camera_rounded;
      case IdolCategory.vtuber:
        return Icons.videocam_rounded;
      case IdolCategory.streamer:
        return Icons.stream_rounded;
      default:
        return Icons.person_rounded;
    }
  }
}

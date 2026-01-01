import 'package:flutter/material.dart';

/// 이미지 유틸리티
/// 이미지 로딩, 캐싱, 에러 처리
class ImageUtils {
  /// 네트워크 이미지 위젯 생성
  /// 로딩/에러 상태 자동 처리
  static Widget networkImage({
    required String url,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
    BorderRadius? borderRadius,
    String? semanticLabel,
  }) {
    Widget image = Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      semanticLabel: semanticLabel,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholder ?? _buildPlaceholder(width, height);
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ?? _buildErrorWidget(width, height);
      },
    );

    if (borderRadius != null) {
      image = ClipRRect(
        borderRadius: borderRadius,
        child: image,
      );
    }

    return image;
  }

  /// 프로필 이미지 (원형)
  static Widget profileImage({
    required String? url,
    required double size,
    String? name,
    String? semanticLabel,
  }) {
    if (url == null || url.isEmpty) {
      return _buildInitialsAvatar(name ?? '?', size);
    }

    return ClipOval(
      child: networkImage(
        url: url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        semanticLabel: semanticLabel ?? '$name 프로필 이미지',
        placeholder: _buildPlaceholder(size, size, circular: true),
        errorWidget: _buildInitialsAvatar(name ?? '?', size),
      ),
    );
  }

  /// 커버 이미지 (배너)
  static Widget coverImage({
    required String? url,
    required double height,
    double? width,
    String? semanticLabel,
  }) {
    if (url == null || url.isEmpty) {
      return Container(
        width: width,
        height: height,
        color: Colors.grey[300],
        child: const Icon(Icons.image, color: Colors.grey),
      );
    }

    return networkImage(
      url: url,
      width: width,
      height: height,
      fit: BoxFit.cover,
      semanticLabel: semanticLabel ?? '커버 이미지',
    );
  }

  /// 갤러리 이미지 (정사각형)
  static Widget galleryImage({
    required String url,
    double? size,
    String? semanticLabel,
    VoidCallback? onTap,
  }) {
    final image = networkImage(
      url: url,
      width: size,
      height: size,
      fit: BoxFit.cover,
      borderRadius: BorderRadius.circular(8),
      semanticLabel: semanticLabel ?? '갤러리 이미지',
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: image,
      );
    }

    return image;
  }

  /// 이니셜 아바타 생성
  static Widget _buildInitialsAvatar(String name, double size) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];
    final colorIndex = name.hashCode % colors.length;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors[colorIndex],
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// 로딩 플레이스홀더
  static Widget _buildPlaceholder(double? width, double? height, {bool circular = false}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        shape: circular ? BoxShape.circle : BoxShape.rectangle,
      ),
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  /// 에러 위젯
  static Widget _buildErrorWidget(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: const Center(
        child: Icon(Icons.broken_image, color: Colors.grey),
      ),
    );
  }

  /// 이미지 URL 유효성 검사
  static bool isValidImageUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    try {
      final uri = Uri.parse(url);
      return uri.scheme == 'http' || uri.scheme == 'https';
    } catch (_) {
      return false;
    }
  }

  /// 이미지 캐시 키 생성
  static String getCacheKey(String url, {int? width, int? height}) {
    final buffer = StringBuffer(url);
    if (width != null) buffer.write('_w$width');
    if (height != null) buffer.write('_h$height');
    return buffer.toString();
  }
}

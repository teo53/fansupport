import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/config/cache_config.dart';
import '../../core/utils/memory_manager.dart';

/// Optimized image widget with automatic caching and memory management
class OptimizedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool isAvatar;
  final BorderRadius? borderRadius;

  const OptimizedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.isAvatar = false,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final cacheManager = isAvatar
        ? AppCacheConfig.avatarCache
        : AppCacheConfig.imageCache;

    Widget image = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      cacheManager: cacheManager,
      maxWidthDiskCache: isAvatar ? 200 : 800,
      maxHeightDiskCache: isAvatar ? 200 : 800,
      memCacheWidth: isAvatar ? 200 : 600,
      memCacheHeight: isAvatar ? 200 : 600,
      placeholder: (context, url) => placeholder ??
        Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      errorWidget: (context, url, error) => errorWidget ??
        Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: const Icon(Icons.error_outline, color: Colors.grey),
        ),
    );

    if (borderRadius != null) {
      image = ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }

    return image;
  }
}

/// Optimized avatar image with circular clipping
class OptimizedAvatar extends StatelessWidget {
  final String imageUrl;
  final double radius;
  final Color? backgroundColor;
  final Widget? fallback;

  const OptimizedAvatar({
    super.key,
    required this.imageUrl,
    required this.radius,
    this.backgroundColor,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? Colors.grey[200],
      child: ClipOval(
        child: OptimizedImage(
          imageUrl: imageUrl,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          isAvatar: true,
          errorWidget: fallback ??
            Icon(
              Icons.person,
              size: radius,
              color: Colors.grey,
            ),
        ),
      ),
    );
  }
}

/// Lazy loading image for lists
class LazyImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;

  const LazyImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  State<LazyImage> createState() => _LazyImageState();
}

class _LazyImageState extends State<LazyImage> {
  bool _shouldLoad = false;

  @override
  void initState() {
    super.initState();
    // Delay loading slightly to improve initial render performance
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() => _shouldLoad = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_shouldLoad) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: Colors.grey[200],
      );
    }

    return OptimizedImage(
      imageUrl: widget.imageUrl,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
    );
  }
}

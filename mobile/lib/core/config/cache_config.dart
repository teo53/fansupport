import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Custom cache configuration for images and other assets
///
/// Provides optimized caching strategy with custom TTL and size limits
class AppCacheConfig {
  /// Image cache configuration
  static const String imageCacheKey = 'pipoImageCache';
  static const Duration imageCacheDuration = Duration(days: 7);
  static const int imageCacheMaxItems = 200;

  /// Create custom cache manager for images
  static CacheManager get imageCache => CacheManager(
        Config(
          imageCacheKey,
          stalePeriod: imageCacheDuration,
          maxNrOfCacheObjects: imageCacheMaxItems,
          repo: JsonCacheInfoRepository(databaseName: imageCacheKey),
          fileService: HttpFileService(),
        ),
      );

  /// Avatar cache (smaller, longer TTL)
  static const String avatarCacheKey = 'pipoAvatarCache';
  static const Duration avatarCacheDuration = Duration(days: 30);
  static const int avatarCacheMaxItems = 100;

  static CacheManager get avatarCache => CacheManager(
        Config(
          avatarCacheKey,
          stalePeriod: avatarCacheDuration,
          maxNrOfCacheObjects: avatarCacheMaxItems,
          repo: JsonCacheInfoRepository(databaseName: avatarCacheKey),
          fileService: HttpFileService(),
        ),
      );

  /// Clear all image caches
  static Future<void> clearAllImageCaches() async {
    await imageCache.emptyCache();
    await avatarCache.emptyCache();
  }

  /// Get total cache size
  static Future<int> getTotalCacheSize() async {
    int totalSize = 0;

    final imageFiles = await imageCache.getFileFromCache(imageCacheKey);
    if (imageFiles != null) {
      totalSize += await imageFiles.file.length();
    }

    final avatarFiles = await avatarCache.getFileFromCache(avatarCacheKey);
    if (avatarFiles != null) {
      totalSize += await avatarFiles.file.length();
    }

    return totalSize;
  }
}

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../config/cache_config.dart';
import 'logger.dart';

/// Memory management utilities
///
/// Provides tools for monitoring and managing app memory usage
class MemoryManager {
  /// Clear image cache when memory warning is received
  static Future<void> handleMemoryPressure() async {
    AppLogger.warning('Memory pressure detected, clearing caches', 'MEMORY');

    // Clear image cache
    imageCache.clear();
    imageCache.clearLiveImages();

    // Clear custom caches
    await AppCacheConfig.clearAllImageCaches();

    AppLogger.info('Caches cleared due to memory pressure', 'MEMORY');
  }

  /// Optimize image size based on screen dimensions
  static Size getOptimalImageSize(BuildContext context, {
    double widthFactor = 1.0,
    double heightFactor = 1.0,
  }) {
    final size = MediaQuery.of(context).size;
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

    return Size(
      size.width * widthFactor * devicePixelRatio,
      size.height * heightFactor * devicePixelRatio,
    );
  }

  /// Calculate optimal thumbnail size
  static Size getThumbnailSize(BuildContext context, {
    double maxWidth = 200,
    double maxHeight = 200,
  }) {
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    return Size(
      maxWidth * devicePixelRatio,
      maxHeight * devicePixelRatio,
    );
  }

  /// Preload critical images
  static Future<void> preloadImages(
    BuildContext context,
    List<ImageProvider> images,
  ) async {
    try {
      await Future.wait(
        images.map((image) => precacheImage(image, context)),
      );
      AppLogger.info('Preloaded ${images.length} images', 'MEMORY');
    } catch (e) {
      AppLogger.error('Failed to preload images', tag: 'MEMORY', error: e);
    }
  }

  /// Dispose of unused resources
  static void disposeResources(List<ChangeNotifier> notifiers) {
    for (final notifier in notifiers) {
      try {
        notifier.dispose();
      } catch (e) {
        AppLogger.warning('Failed to dispose notifier: $e', 'MEMORY');
      }
    }
  }

  /// Get memory usage info
  static Map<String, dynamic> getMemoryInfo() {
    final memoryUsage = ui.PlatformDispatcher.instance.views.first.physicalSize;

    return {
      'screen_width': memoryUsage.width,
      'screen_height': memoryUsage.height,
      'device_pixel_ratio': ui.PlatformDispatcher.instance.views.first.devicePixelRatio,
    };
  }

  /// Check if low memory mode should be enabled
  static bool shouldUseLowMemoryMode(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

    // Enable low memory mode for devices with high pixel ratio and large screens
    return devicePixelRatio > 2.5 && (size.width > 1080 || size.height > 1920);
  }
}

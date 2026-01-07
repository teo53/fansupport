import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Memory monitoring and profiling utilities
class MemoryMonitor {
  MemoryMonitor._();

  static final Map<String, int> _widgetRebuildCounts = {};
  static final Map<String, DateTime> _lastRebuildTimes = {};
  static Timer? _memoryCheckTimer;
  static final List<MemorySnapshot> _snapshots = [];

  /// Start memory monitoring
  static void startMonitoring({Duration interval = const Duration(seconds: 10)}) {
    if (!kDebugMode) return;

    _memoryCheckTimer?.cancel();
    _memoryCheckTimer = Timer.periodic(interval, (_) {
      _takeSnapshot();
    });

    developer.log('Memory monitoring started', name: 'MemoryMonitor');
  }

  /// Stop memory monitoring
  static void stopMonitoring() {
    _memoryCheckTimer?.cancel();
    _memoryCheckTimer = null;
    developer.log('Memory monitoring stopped', name: 'MemoryMonitor');
  }

  /// Take a memory snapshot
  static void _takeSnapshot() {
    final snapshot = MemorySnapshot(
      timestamp: DateTime.now(),
      widgetRebuilds: Map.from(_widgetRebuildCounts),
    );

    _snapshots.add(snapshot);

    // Keep only last 100 snapshots
    if (_snapshots.length > 100) {
      _snapshots.removeAt(0);
    }

    if (kDebugMode) {
      developer.log(
        'Memory snapshot: ${_widgetRebuildCounts.length} widgets tracked',
        name: 'MemoryMonitor',
      );
    }
  }

  /// Track widget rebuild
  static void trackRebuild(String widgetName) {
    if (!kDebugMode) return;

    _widgetRebuildCounts[widgetName] = (_widgetRebuildCounts[widgetName] ?? 0) + 1;
    _lastRebuildTimes[widgetName] = DateTime.now();

    // Warn if widget rebuilds too frequently
    if (_widgetRebuildCounts[widgetName]! > 100) {
      developer.log(
        '⚠️ Widget "$widgetName" rebuilt ${_widgetRebuildCounts[widgetName]} times',
        name: 'MemoryMonitor',
        level: 900, // Warning level
      );
    }
  }

  /// Get rebuild count for a widget
  static int getRebuildCount(String widgetName) {
    return _widgetRebuildCounts[widgetName] ?? 0;
  }

  /// Get all widget rebuild statistics
  static Map<String, int> getRebuildStats() {
    return Map.unmodifiable(_widgetRebuildCounts);
  }

  /// Reset rebuild counters
  static void resetCounters() {
    _widgetRebuildCounts.clear();
    _lastRebuildTimes.clear();
    _snapshots.clear();
    developer.log('Reset rebuild counters', name: 'MemoryMonitor');
  }

  /// Print memory report
  static void printReport() {
    if (!kDebugMode) return;

    developer.log('═══════════════════════════════════', name: 'MemoryMonitor');
    developer.log('📊 Memory Monitor Report', name: 'MemoryMonitor');
    developer.log('═══════════════════════════════════', name: 'MemoryMonitor');

    // Sort widgets by rebuild count
    final sortedWidgets = _widgetRebuildCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    developer.log('🔄 Top 10 Most Rebuilt Widgets:', name: 'MemoryMonitor');
    for (var i = 0; i < sortedWidgets.length && i < 10; i++) {
      final entry = sortedWidgets[i];
      developer.log('   ${i + 1}. ${entry.key}: ${entry.value} rebuilds', name: 'MemoryMonitor');
    }

    developer.log('═══════════════════════════════════', name: 'MemoryMonitor');
  }

  /// Get memory snapshots
  static List<MemorySnapshot> getSnapshots() {
    return List.unmodifiable(_snapshots);
  }
}

/// Memory snapshot data
class MemorySnapshot {
  final DateTime timestamp;
  final Map<String, int> widgetRebuilds;

  const MemorySnapshot({
    required this.timestamp,
    required this.widgetRebuilds,
  });
}

/// Widget wrapper to track rebuilds
class RebuildTracker extends StatelessWidget {
  final String name;
  final Widget child;
  final bool enabled;

  const RebuildTracker({
    required this.name,
    required this.child,
    this.enabled = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (enabled && kDebugMode) {
      MemoryMonitor.trackRebuild(name);
    }
    return child;
  }
}

/// Image cache monitor
class ImageCacheMonitor {
  ImageCacheMonitor._();

  /// Get current image cache status
  static ImageCacheStatus getStatus() {
    final cache = PaintingBinding.instance.imageCache;

    return ImageCacheStatus(
      currentSize: cache.currentSize,
      currentSizeBytes: cache.currentSizeBytes,
      maximumSize: cache.maximumSize,
      maximumSizeBytes: cache.maximumSizeBytes,
      liveImageCount: cache.liveImageCount,
      pendingImageCount: cache.pendingImageCount,
    );
  }

  /// Clear image cache
  static void clearCache() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();

    if (kDebugMode) {
      developer.log('Image cache cleared', name: 'ImageCacheMonitor');
    }
  }

  /// Print image cache report
  static void printReport() {
    if (!kDebugMode) return;

    final status = getStatus();

    developer.log('═══════════════════════════════════', name: 'ImageCacheMonitor');
    developer.log('🖼️  Image Cache Report', name: 'ImageCacheMonitor');
    developer.log('═══════════════════════════════════', name: 'ImageCacheMonitor');
    developer.log('Current Images: ${status.currentSize}/${status.maximumSize}', name: 'ImageCacheMonitor');
    developer.log('Current Size: ${_formatBytes(status.currentSizeBytes)}/${_formatBytes(status.maximumSizeBytes)}', name: 'ImageCacheMonitor');
    developer.log('Live Images: ${status.liveImageCount}', name: 'ImageCacheMonitor');
    developer.log('Pending Images: ${status.pendingImageCount}', name: 'ImageCacheMonitor');
    developer.log('Cache Usage: ${(status.currentSizeBytes / status.maximumSizeBytes * 100).toStringAsFixed(1)}%', name: 'ImageCacheMonitor');
    developer.log('═══════════════════════════════════', name: 'ImageCacheMonitor');
  }

  /// Configure image cache
  static void configureCache({
    int? maximumSize,
    int? maximumSizeBytes,
  }) {
    final cache = PaintingBinding.instance.imageCache;

    if (maximumSize != null) {
      cache.maximumSize = maximumSize;
    }

    if (maximumSizeBytes != null) {
      cache.maximumSizeBytes = maximumSizeBytes;
    }

    if (kDebugMode) {
      developer.log(
        'Image cache configured: max=$maximumSize, maxBytes=${maximumSizeBytes != null ? _formatBytes(maximumSizeBytes) : 'default'}',
        name: 'ImageCacheMonitor',
      );
    }
  }

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// Image cache status
class ImageCacheStatus {
  final int currentSize;
  final int currentSizeBytes;
  final int maximumSize;
  final int maximumSizeBytes;
  final int liveImageCount;
  final int pendingImageCount;

  const ImageCacheStatus({
    required this.currentSize,
    required this.currentSizeBytes,
    required this.maximumSize,
    required this.maximumSizeBytes,
    required this.liveImageCount,
    required this.pendingImageCount,
  });
}

/// List scroll performance monitor
class ScrollPerformanceMonitor {
  final String listName;
  final List<Duration> _frameTimes = [];
  DateTime? _lastFrameTime;
  int _droppedFrames = 0;
  static const _targetFrameTime = Duration(milliseconds: 16); // 60 FPS

  ScrollPerformanceMonitor(this.listName);

  /// Track frame
  void trackFrame() {
    final now = DateTime.now();

    if (_lastFrameTime != null) {
      final frameTime = now.difference(_lastFrameTime!);
      _frameTimes.add(frameTime);

      // Count dropped frames (> 16ms for 60 FPS)
      if (frameTime > _targetFrameTime) {
        _droppedFrames++;
      }

      // Keep only last 100 frames
      if (_frameTimes.length > 100) {
        _frameTimes.removeAt(0);
      }
    }

    _lastFrameTime = now;
  }

  /// Get average frame time
  Duration get averageFrameTime {
    if (_frameTimes.isEmpty) return Duration.zero;

    final total = _frameTimes.fold<int>(
      0,
      (sum, duration) => sum + duration.inMicroseconds,
    );

    return Duration(microseconds: total ~/ _frameTimes.length);
  }

  /// Get dropped frame percentage
  double get droppedFramePercentage {
    if (_frameTimes.isEmpty) return 0.0;
    return (_droppedFrames / _frameTimes.length) * 100;
  }

  /// Reset stats
  void reset() {
    _frameTimes.clear();
    _lastFrameTime = null;
    _droppedFrames = 0;
  }

  /// Print report
  void printReport() {
    if (!kDebugMode) return;

    developer.log('═══════════════════════════════════', name: 'ScrollPerformance');
    developer.log('📜 List "$listName" Performance', name: 'ScrollPerformance');
    developer.log('═══════════════════════════════════', name: 'ScrollPerformance');
    developer.log('Average Frame Time: ${averageFrameTime.inMilliseconds}ms', name: 'ScrollPerformance');
    developer.log('Dropped Frames: $_droppedFrames/${_frameTimes.length} (${droppedFramePercentage.toStringAsFixed(1)}%)', name: 'ScrollPerformance');
    developer.log('═══════════════════════════════════', name: 'ScrollPerformance');
  }
}

/// Memory leak detector
class MemoryLeakDetector {
  static final Map<String, WeakReference<Object>> _trackedObjects = {};

  /// Track object for memory leaks
  static void track(String id, Object object) {
    if (!kDebugMode) return;
    _trackedObjects[id] = WeakReference(object);
  }

  /// Check for leaks
  static void checkLeaks() {
    if (!kDebugMode) return;

    final leakedObjects = <String>[];

    _trackedObjects.forEach((id, weakRef) {
      if (weakRef.target != null) {
        leakedObjects.add(id);
      }
    });

    if (leakedObjects.isNotEmpty) {
      developer.log(
        '⚠️ Potential memory leaks detected: ${leakedObjects.join(', ')}',
        name: 'MemoryLeakDetector',
        level: 900,
      );
    } else {
      developer.log('✅ No memory leaks detected', name: 'MemoryLeakDetector');
    }

    // Clean up released objects
    _trackedObjects.removeWhere((key, value) => value.target == null);
  }

  /// Clear all tracked objects
  static void clear() {
    _trackedObjects.clear();
  }
}

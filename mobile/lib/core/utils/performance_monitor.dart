import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'logger.dart';

/// Performance monitoring utility
///
/// Tracks frame rendering performance and identifies jank
class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  final List<Duration> _frameDurations = [];
  Timer? _reportTimer;
  bool _isMonitoring = false;

  /// Start monitoring performance
  void startMonitoring() {
    if (_isMonitoring || kReleaseMode) return;

    _isMonitoring = true;
    _frameDurations.clear();

    SchedulerBinding.instance.addTimingsCallback(_onFrameTiming);

    // Report stats every 10 seconds
    _reportTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _reportStats();
    });

    AppLogger.info('Performance monitoring started', 'PERFORMANCE');
  }

  /// Stop monitoring performance
  void stopMonitoring() {
    if (!_isMonitoring) return;

    _isMonitoring = false;
    _reportTimer?.cancel();
    _reportTimer = null;
    SchedulerBinding.instance.removeTimingsCallback(_onFrameTiming);

    AppLogger.info('Performance monitoring stopped', 'PERFORMANCE');
  }

  void _onFrameTiming(List<FrameTiming> timings) {
    for (final timing in timings) {
      final buildDuration = timing.buildDuration;
      final rasterDuration = timing.rasterDuration;

      _frameDurations.add(buildDuration + rasterDuration);

      // Log jank frames (> 16ms for 60fps)
      if (buildDuration.inMilliseconds > 16 ||
          rasterDuration.inMilliseconds > 16) {
        AppLogger.warning(
          'Jank detected: build=${buildDuration.inMilliseconds}ms, '
          'raster=${rasterDuration.inMilliseconds}ms',
          'PERFORMANCE',
        );
      }
    }

    // Keep only last 100 frames
    if (_frameDurations.length > 100) {
      _frameDurations.removeRange(0, _frameDurations.length - 100);
    }
  }

  void _reportStats() {
    if (_frameDurations.isEmpty) return;

    final avgDuration = _frameDurations.fold<int>(
          0,
          (sum, duration) => sum + duration.inMilliseconds,
        ) /
        _frameDurations.length;

    final maxDuration = _frameDurations.fold<int>(
      0,
      (max, duration) => duration.inMilliseconds > max
          ? duration.inMilliseconds
          : max,
    );

    final jankFrames = _frameDurations.where(
      (duration) => duration.inMilliseconds > 16,
    ).length;

    final fps = _frameDurations.isNotEmpty
        ? 1000 / avgDuration
        : 0;

    AppLogger.info(
      'Performance: avg=${avgDuration.toStringAsFixed(1)}ms, '
      'max=${maxDuration}ms, '
      'fps=${fps.toStringAsFixed(1)}, '
      'jank=$jankFrames/${_frameDurations.length}',
      'PERFORMANCE',
    );
  }

  /// Get current performance metrics
  Map<String, dynamic> getMetrics() {
    if (_frameDurations.isEmpty) {
      return {
        'average_frame_time': 0.0,
        'max_frame_time': 0,
        'fps': 0.0,
        'jank_count': 0,
        'total_frames': 0,
      };
    }

    final avgDuration = _frameDurations.fold<int>(
          0,
          (sum, duration) => sum + duration.inMilliseconds,
        ) /
        _frameDurations.length;

    final maxDuration = _frameDurations.fold<int>(
      0,
      (max, duration) => duration.inMilliseconds > max
          ? duration.inMilliseconds
          : max,
    );

    final jankFrames = _frameDurations.where(
      (duration) => duration.inMilliseconds > 16,
    ).length;

    final fps = avgDuration > 0 ? 1000 / avgDuration : 0;

    return {
      'average_frame_time': avgDuration,
      'max_frame_time': maxDuration,
      'fps': fps,
      'jank_count': jankFrames,
      'total_frames': _frameDurations.length,
    };
  }
}

/// Widget to measure build time
class PerformanceMeasure extends StatefulWidget {
  final Widget child;
  final String tag;

  const PerformanceMeasure({
    super.key,
    required this.child,
    required this.tag,
  });

  @override
  State<PerformanceMeasure> createState() => _PerformanceMeasureState();
}

class _PerformanceMeasureState extends State<PerformanceMeasure> {
  late Stopwatch _stopwatch;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch()..start();
  }

  @override
  Widget build(BuildContext context) {
    _stopwatch.stop();
    final buildTime = _stopwatch.elapsedMilliseconds;

    if (buildTime > 100 && kDebugMode) {
      AppLogger.warning(
        '${widget.tag} build time: ${buildTime}ms',
        'PERFORMANCE',
      );
    }

    _stopwatch.reset();
    _stopwatch.start();

    return widget.child;
  }

  @override
  void dispose() {
    _stopwatch.stop();
    super.dispose();
  }
}

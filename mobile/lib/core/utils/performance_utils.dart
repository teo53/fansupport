import 'dart:async';
import 'package:flutter/foundation.dart';

/// Debouncer for search and input handling
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({this.delay = const Duration(milliseconds: 300)});

  void call(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void dispose() {
    _timer?.cancel();
  }
}

/// Throttler for rate limiting
class Throttler {
  final Duration duration;
  DateTime? _lastActionTime;

  Throttler({this.duration = const Duration(milliseconds: 500)});

  void call(VoidCallback action) {
    final now = DateTime.now();
    if (_lastActionTime == null ||
        now.difference(_lastActionTime!) >= duration) {
      _lastActionTime = now;
      action();
    }
  }
}

/// Lazy loader for heavy computations
class LazyLoader<T> {
  T? _value;
  final T Function() _loader;
  bool _isLoaded = false;

  LazyLoader(this._loader);

  T get value {
    if (!_isLoaded) {
      _value = _loader();
      _isLoaded = true;
    }
    return _value!;
  }

  void reset() {
    _value = null;
    _isLoaded = false;
  }
}

/// Memoization helper
class Memoizer<T> {
  final Map<String, T> _cache = {};
  final Duration? cacheDuration;

  Memoizer({this.cacheDuration});

  T call(String key, T Function() computation) {
    if (_cache.containsKey(key)) {
      return _cache[key]!;
    }

    final result = computation();
    _cache[key] = result;

    // Auto-clear cache after duration
    if (cacheDuration != null) {
      Future.delayed(cacheDuration!, () {
        _cache.remove(key);
      });
    }

    return result;
  }

  void clear([String? key]) {
    if (key != null) {
      _cache.remove(key);
    } else {
      _cache.clear();
    }
  }

  int get size => _cache.length;
}

/// Batch processor for grouping multiple operations
class BatchProcessor<T> {
  final Duration batchDuration;
  final Function(List<T>) onBatch;
  final List<T> _pending = [];
  Timer? _timer;

  BatchProcessor({
    required this.batchDuration,
    required this.onBatch,
  });

  void add(T item) {
    _pending.add(item);

    _timer?.cancel();
    _timer = Timer(batchDuration, _processBatch);
  }

  void _processBatch() {
    if (_pending.isNotEmpty) {
      onBatch(List.from(_pending));
      _pending.clear();
    }
  }

  void dispose() {
    _timer?.cancel();
    _processBatch(); // Process remaining items
  }
}

/// Performance monitor
class PerformanceMonitor {
  static final Map<String, Stopwatch> _timers = {};

  static void start(String key) {
    _timers[key] = Stopwatch()..start();
  }

  static void stop(String key, {String? label}) {
    final stopwatch = _timers[key];
    if (stopwatch != null) {
      stopwatch.stop();
      if (kDebugMode) {
        print('[Performance] ${label ?? key}: ${stopwatch.elapsedMilliseconds}ms');
      }
      _timers.remove(key);
    }
  }

  static void measure(String key, VoidCallback action, {String? label}) {
    start(key);
    action();
    stop(key, label: label);
  }

  static Future<T> measureAsync<T>(
    String key,
    Future<T> Function() action, {
    String? label,
  }) async {
    start(key);
    final result = await action();
    stop(key, label: label);
    return result;
  }
}

/// Simple LRU Cache implementation
class LRUCache<K, V> {
  final int maxSize;
  final Map<K, V> _cache = {};
  final List<K> _keys = [];

  LRUCache({required this.maxSize});

  V? get(K key) {
    if (_cache.containsKey(key)) {
      // Move to end (most recently used)
      _keys.remove(key);
      _keys.add(key);
      return _cache[key];
    }
    return null;
  }

  void put(K key, V value) {
    if (_cache.containsKey(key)) {
      // Update existing
      _keys.remove(key);
    } else if (_cache.length >= maxSize) {
      // Remove least recently used
      final oldestKey = _keys.removeAt(0);
      _cache.remove(oldestKey);
    }

    _cache[key] = value;
    _keys.add(key);
  }

  void remove(K key) {
    _cache.remove(key);
    _keys.remove(key);
  }

  void clear() {
    _cache.clear();
    _keys.clear();
  }

  int get length => _cache.length;
  bool get isFull => _cache.length >= maxSize;
}

/// Rate limiter for API calls
class RateLimiter {
  final int maxCalls;
  final Duration period;
  final List<DateTime> _callTimes = [];

  RateLimiter({
    required this.maxCalls,
    required this.period,
  });

  bool canMakeCall() {
    final now = DateTime.now();
    final cutoff = now.subtract(period);

    // Remove old call times
    _callTimes.removeWhere((time) => time.isBefore(cutoff));

    return _callTimes.length < maxCalls;
  }

  Future<T> execute<T>(Future<T> Function() action) async {
    while (!canMakeCall()) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    _callTimes.add(DateTime.now());
    return await action();
  }
}

import 'dart:convert';
import 'local_storage.dart';
import '../utils/logger.dart';

/// Cache manager for API responses
///
/// Provides caching functionality for API data with expiration
class CacheManager {
  // Cache durations
  static const Duration shortCache = Duration(minutes: 5);
  static const Duration mediumCache = Duration(minutes: 30);
  static const Duration longCache = Duration(hours: 2);
  static const Duration veryLongCache = Duration(days: 1);

  // ============================================================================
  // Generic Cache Operations
  // ============================================================================

  /// Save data to cache
  static Future<bool> set<T>(
    String key,
    T data, {
    Duration expiry = mediumCache,
  }) async {
    try {
      final cacheData = {
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
      };

      return await LocalStorage.setJsonWithExpiry(
        _getCacheKey(key),
        cacheData,
        expiry,
      );
    } catch (e) {
      AppLogger.error('Failed to cache data', tag: 'CACHE', error: e);
      return false;
    }
  }

  /// Get data from cache
  static T? get<T>(String key) {
    try {
      final cacheData = LocalStorage.getJsonWithExpiry(_getCacheKey(key));
      if (cacheData == null) return null;

      return cacheData['data'] as T?;
    } catch (e) {
      AppLogger.error('Failed to get cached data', tag: 'CACHE', error: e);
      return null;
    }
  }

  /// Check if cache exists and is valid
  static bool has(String key) {
    return LocalStorage.getJsonWithExpiry(_getCacheKey(key)) != null;
  }

  /// Remove cached data
  static Future<bool> remove(String key) async {
    try {
      await LocalStorage.remove(_getCacheKey(key));
      await LocalStorage.remove('${_getCacheKey(key)}_expiry');
      return true;
    } catch (e) {
      AppLogger.error('Failed to remove cache', tag: 'CACHE', error: e);
      return false;
    }
  }

  /// Clear all cache
  static Future<void> clearAll() async {
    try {
      final keys = LocalStorage.getKeys();
      for (final key in keys) {
        if (key.startsWith('cache_')) {
          await LocalStorage.remove(key);
        }
      }
      AppLogger.info('All cache cleared', 'CACHE');
    } catch (e) {
      AppLogger.error('Failed to clear all cache', tag: 'CACHE', error: e);
    }
  }

  // ============================================================================
  // Specific Data Type Caching
  // ============================================================================

  /// Cache list of items
  static Future<bool> setList<T>(
    String key,
    List<T> items, {
    Duration expiry = mediumCache,
  }) async {
    try {
      final List<dynamic> serializedItems = items.map((item) {
        if (item is Map) return item;
        if (item is String || item is num || item is bool) return item;
        return item.toString();
      }).toList();

      return await set(key, serializedItems, expiry: expiry);
    } catch (e) {
      AppLogger.error('Failed to cache list', tag: 'CACHE', error: e);
      return false;
    }
  }

  /// Get cached list
  static List<T>? getList<T>(String key) {
    try {
      final data = get<List<dynamic>>(key);
      if (data == null) return null;
      return data.cast<T>();
    } catch (e) {
      AppLogger.error('Failed to get cached list', tag: 'CACHE', error: e);
      return null;
    }
  }

  // ============================================================================
  // API Response Caching
  // ============================================================================

  /// Cache API response
  static Future<bool> cacheApiResponse(
    String endpoint,
    Map<String, dynamic> response, {
    Duration expiry = mediumCache,
  }) async {
    final key = _getApiCacheKey(endpoint);
    return await set(key, response, expiry: expiry);
  }

  /// Get cached API response
  static Map<String, dynamic>? getCachedApiResponse(String endpoint) {
    final key = _getApiCacheKey(endpoint);
    return get<Map<String, dynamic>>(key);
  }

  /// Check if API response is cached
  static bool hasApiCache(String endpoint) {
    return has(_getApiCacheKey(endpoint));
  }

  /// Remove API cache
  static Future<bool> removeApiCache(String endpoint) async {
    return await remove(_getApiCacheKey(endpoint));
  }

  // ============================================================================
  // Image Cache Info (metadata only - actual images cached by CachedNetworkImage)
  // ============================================================================

  /// Save image metadata
  static Future<bool> setImageMetadata(
    String url,
    Map<String, dynamic> metadata,
  ) async {
    final key = _getImageCacheKey(url);
    return await set(key, metadata, expiry: veryLongCache);
  }

  /// Get image metadata
  static Map<String, dynamic>? getImageMetadata(String url) {
    final key = _getImageCacheKey(url);
    return get<Map<String, dynamic>>(key);
  }

  // ============================================================================
  // Cache Statistics
  // ============================================================================

  /// Get cache statistics
  static Map<String, dynamic> getStats() {
    try {
      final keys = LocalStorage.getKeys();
      final cacheKeys = keys.where((k) => k.startsWith('cache_')).toList();

      int totalSize = 0;
      int validCache = 0;
      int expiredCache = 0;

      for (final key in cacheKeys) {
        if (key.endsWith('_expiry')) continue;

        final value = LocalStorage.getString(key);
        if (value != null) {
          totalSize += value.length;

          if (LocalStorage.getJsonWithExpiry(key) != null) {
            validCache++;
          } else {
            expiredCache++;
          }
        }
      }

      return {
        'total_entries': cacheKeys.length ~/ 2, // Divide by 2 (data + expiry)
        'valid_entries': validCache,
        'expired_entries': expiredCache,
        'total_size_bytes': totalSize,
        'total_size_kb': (totalSize / 1024).toStringAsFixed(2),
      };
    } catch (e) {
      AppLogger.error('Failed to get cache stats', tag: 'CACHE', error: e);
      return {};
    }
  }

  // ============================================================================
  // Private Helpers
  // ============================================================================

  static String _getCacheKey(String key) => 'cache_$key';

  static String _getApiCacheKey(String endpoint) {
    // Create a clean cache key from endpoint
    final cleanEndpoint = endpoint.replaceAll('/', '_').replaceAll('?', '_');
    return 'api_$cleanEndpoint';
  }

  static String _getImageCacheKey(String url) {
    // Create a clean cache key from image URL
    final cleanUrl = url.hashCode.toString();
    return 'img_$cleanUrl';
  }
}

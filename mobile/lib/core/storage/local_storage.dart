import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';

/// Local storage service using SharedPreferences
///
/// Provides a simple key-value storage with type-safe getters and setters
class LocalStorage {
  static SharedPreferences? _prefs;

  /// Initialize local storage
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    AppLogger.info('Local storage initialized', 'STORAGE');
  }

  /// Get SharedPreferences instance
  static SharedPreferences get instance {
    if (_prefs == null) {
      throw Exception('LocalStorage not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // ============================================================================
  // Basic Operations
  // ============================================================================

  /// Save string
  static Future<bool> setString(String key, String value) async {
    try {
      return await instance.setString(key, value);
    } catch (e) {
      AppLogger.error('Failed to save string', tag: 'STORAGE', error: e);
      return false;
    }
  }

  /// Get string
  static String? getString(String key, {String? defaultValue}) {
    try {
      return instance.getString(key) ?? defaultValue;
    } catch (e) {
      AppLogger.error('Failed to get string', tag: 'STORAGE', error: e);
      return defaultValue;
    }
  }

  /// Save int
  static Future<bool> setInt(String key, int value) async {
    try {
      return await instance.setInt(key, value);
    } catch (e) {
      AppLogger.error('Failed to save int', tag: 'STORAGE', error: e);
      return false;
    }
  }

  /// Get int
  static int? getInt(String key, {int? defaultValue}) {
    try {
      return instance.getInt(key) ?? defaultValue;
    } catch (e) {
      AppLogger.error('Failed to get int', tag: 'STORAGE', error: e);
      return defaultValue;
    }
  }

  /// Save double
  static Future<bool> setDouble(String key, double value) async {
    try {
      return await instance.setDouble(key, value);
    } catch (e) {
      AppLogger.error('Failed to save double', tag: 'STORAGE', error: e);
      return false;
    }
  }

  /// Get double
  static double? getDouble(String key, {double? defaultValue}) {
    try {
      return instance.getDouble(key) ?? defaultValue;
    } catch (e) {
      AppLogger.error('Failed to get double', tag: 'STORAGE', error: e);
      return defaultValue;
    }
  }

  /// Save bool
  static Future<bool> setBool(String key, bool value) async {
    try {
      return await instance.setBool(key, value);
    } catch (e) {
      AppLogger.error('Failed to save bool', tag: 'STORAGE', error: e);
      return false;
    }
  }

  /// Get bool
  static bool? getBool(String key, {bool? defaultValue}) {
    try {
      return instance.getBool(key) ?? defaultValue;
    } catch (e) {
      AppLogger.error('Failed to get bool', tag: 'STORAGE', error: e);
      return defaultValue;
    }
  }

  /// Save string list
  static Future<bool> setStringList(String key, List<String> value) async {
    try {
      return await instance.setStringList(key, value);
    } catch (e) {
      AppLogger.error('Failed to save string list', tag: 'STORAGE', error: e);
      return false;
    }
  }

  /// Get string list
  static List<String>? getStringList(String key, {List<String>? defaultValue}) {
    try {
      return instance.getStringList(key) ?? defaultValue;
    } catch (e) {
      AppLogger.error('Failed to get string list', tag: 'STORAGE', error: e);
      return defaultValue;
    }
  }

  // ============================================================================
  // JSON Operations
  // ============================================================================

  /// Save JSON object
  static Future<bool> setJson(String key, Map<String, dynamic> value) async {
    try {
      final jsonString = jsonEncode(value);
      return await setString(key, jsonString);
    } catch (e) {
      AppLogger.error('Failed to save JSON', tag: 'STORAGE', error: e);
      return false;
    }
  }

  /// Get JSON object
  static Map<String, dynamic>? getJson(String key) {
    try {
      final jsonString = getString(key);
      if (jsonString == null) return null;
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      AppLogger.error('Failed to get JSON', tag: 'STORAGE', error: e);
      return null;
    }
  }

  /// Save JSON list
  static Future<bool> setJsonList(String key, List<Map<String, dynamic>> value) async {
    try {
      final jsonString = jsonEncode(value);
      return await setString(key, jsonString);
    } catch (e) {
      AppLogger.error('Failed to save JSON list', tag: 'STORAGE', error: e);
      return false;
    }
  }

  /// Get JSON list
  static List<Map<String, dynamic>>? getJsonList(String key) {
    try {
      final jsonString = getString(key);
      if (jsonString == null) return null;
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      AppLogger.error('Failed to get JSON list', tag: 'STORAGE', error: e);
      return null;
    }
  }

  // ============================================================================
  // Cache Operations (with expiration)
  // ============================================================================

  /// Save with expiration time
  static Future<bool> setWithExpiry(
    String key,
    String value,
    Duration expiry,
  ) async {
    try {
      final expiryTime = DateTime.now().add(expiry).millisecondsSinceEpoch;
      await setString(key, value);
      await setInt('${key}_expiry', expiryTime);
      return true;
    } catch (e) {
      AppLogger.error('Failed to save with expiry', tag: 'STORAGE', error: e);
      return false;
    }
  }

  /// Get with expiration check
  static String? getWithExpiry(String key) {
    try {
      final expiryTime = getInt('${key}_expiry');
      if (expiryTime == null) return null;

      if (DateTime.now().millisecondsSinceEpoch > expiryTime) {
        // Expired, remove it
        remove(key);
        remove('${key}_expiry');
        return null;
      }

      return getString(key);
    } catch (e) {
      AppLogger.error('Failed to get with expiry', tag: 'STORAGE', error: e);
      return null;
    }
  }

  /// Save JSON with expiration
  static Future<bool> setJsonWithExpiry(
    String key,
    Map<String, dynamic> value,
    Duration expiry,
  ) async {
    try {
      final jsonString = jsonEncode(value);
      return await setWithExpiry(key, jsonString, expiry);
    } catch (e) {
      AppLogger.error('Failed to save JSON with expiry', tag: 'STORAGE', error: e);
      return false;
    }
  }

  /// Get JSON with expiration check
  static Map<String, dynamic>? getJsonWithExpiry(String key) {
    try {
      final jsonString = getWithExpiry(key);
      if (jsonString == null) return null;
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      AppLogger.error('Failed to get JSON with expiry', tag: 'STORAGE', error: e);
      return null;
    }
  }

  // ============================================================================
  // Utility Operations
  // ============================================================================

  /// Check if key exists
  static bool containsKey(String key) {
    try {
      return instance.containsKey(key);
    } catch (e) {
      AppLogger.error('Failed to check key', tag: 'STORAGE', error: e);
      return false;
    }
  }

  /// Remove key
  static Future<bool> remove(String key) async {
    try {
      return await instance.remove(key);
    } catch (e) {
      AppLogger.error('Failed to remove key', tag: 'STORAGE', error: e);
      return false;
    }
  }

  /// Clear all data
  static Future<bool> clear() async {
    try {
      return await instance.clear();
    } catch (e) {
      AppLogger.error('Failed to clear storage', tag: 'STORAGE', error: e);
      return false;
    }
  }

  /// Get all keys
  static Set<String> getKeys() {
    try {
      return instance.getKeys();
    } catch (e) {
      AppLogger.error('Failed to get keys', tag: 'STORAGE', error: e);
      return {};
    }
  }

  /// Reload data from disk
  static Future<void> reload() async {
    try {
      await instance.reload();
      AppLogger.info('Storage reloaded', 'STORAGE');
    } catch (e) {
      AppLogger.error('Failed to reload storage', tag: 'STORAGE', error: e);
    }
  }

  // ============================================================================
  // Predefined Keys (for type safety)
  // ============================================================================

  static const String keyFirstLaunch = 'first_launch';
  static const String keyThemeMode = 'theme_mode';
  static const String keyLanguage = 'language';
  static const String keyFontSize = 'font_size';
  static const String keyNotificationsEnabled = 'notifications_enabled';
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserData = 'user_data';
  static const String keyCachedIdols = 'cached_idols';
  static const String keyCachedCampaigns = 'cached_campaigns';
  static const String keyLastSync = 'last_sync';
}

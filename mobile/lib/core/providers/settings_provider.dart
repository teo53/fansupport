import 'package:state_notifier/state_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_settings.dart';
import '../storage/local_storage.dart';
import '../utils/logger.dart';

/// Settings state notifier
///
/// Manages app settings and persists to local storage
class SettingsNotifier extends StateNotifier<AppSettings> {
  static const String _settingsKey = 'app_settings';

  SettingsNotifier() : super(AppSettings.defaults) {
    _loadSettings();
  }

  /// Load settings from storage
  Future<void> _loadSettings() async {
    try {
      final json = LocalStorage.getJson(_settingsKey);
      if (json != null) {
        state = AppSettings.fromJson(json);
        AppLogger.info('Settings loaded', 'SETTINGS');
      }
    } catch (e) {
      AppLogger.error('Failed to load settings', tag: 'SETTINGS', error: e);
    }
  }

  /// Save settings to storage
  Future<void> _saveSettings() async {
    try {
      await LocalStorage.setJson(_settingsKey, state.toJson());
      AppLogger.info('Settings saved', 'SETTINGS');
    } catch (e) {
      AppLogger.error('Failed to save settings', tag: 'SETTINGS', error: e);
    }
  }

  /// Update language
  Future<void> setLanguage(String language) async {
    state = state.copyWith(language: language);
    await _saveSettings();
  }

  /// Update font size
  Future<void> setFontSize(double fontSize) async {
    state = state.copyWith(fontSize: fontSize);
    await _saveSettings();
  }

  /// Toggle notifications
  Future<void> toggleNotifications(bool enabled) async {
    state = state.copyWith(notificationsEnabled: enabled);
    await _saveSettings();
  }

  /// Toggle push notifications
  Future<void> togglePushNotifications(bool enabled) async {
    state = state.copyWith(pushNotificationsEnabled: enabled);
    await _saveSettings();
  }

  /// Toggle email notifications
  Future<void> toggleEmailNotifications(bool enabled) async {
    state = state.copyWith(emailNotificationsEnabled: enabled);
    await _saveSettings();
  }

  /// Toggle sound
  Future<void> toggleSound(bool enabled) async {
    state = state.copyWith(soundEnabled: enabled);
    await _saveSettings();
  }

  /// Toggle vibration
  Future<void> toggleVibration(bool enabled) async {
    state = state.copyWith(vibrationEnabled: enabled);
    await _saveSettings();
  }

  /// Toggle data saver mode
  Future<void> toggleDataSaver(bool enabled) async {
    state = state.copyWith(dataSaverMode: enabled);
    await _saveSettings();
  }

  /// Reset to default settings
  Future<void> resetToDefaults() async {
    state = AppSettings.defaults;
    await _saveSettings();
  }
}

/// Settings provider
final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>(
  (ref) => SettingsNotifier(),
);

/// Language provider (convenience)
final languageProvider = Provider<String>((ref) {
  return ref.watch(settingsProvider).language;
});

/// Font size provider (convenience)
final fontSizeProvider = Provider<double>((ref) {
  return ref.watch(settingsProvider).fontSize;
});

/// Notifications enabled provider (convenience)
final notificationsEnabledProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider).notificationsEnabled;
});

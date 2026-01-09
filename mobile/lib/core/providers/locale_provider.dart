import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Supported locales
const supportedLocales = [
  Locale('ko', 'KR'), // Korean
  Locale('en', 'US'), // English
  Locale('ja', 'JP'), // Japanese
];

/// Locale notifier state
class LocaleState {
  final Locale locale;
  final bool isLoading;

  const LocaleState({
    required this.locale,
    this.isLoading = false,
  });

  LocaleState copyWith({
    Locale? locale,
    bool? isLoading,
  }) {
    return LocaleState(
      locale: locale ?? this.locale,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Locale provider for managing app language (Riverpod 3.x Notifier pattern)
class LocaleNotifier extends Notifier<LocaleState> {
  static const _localeKey = 'app_locale';

  @override
  LocaleState build() {
    _loadSavedLocale();
    return const LocaleState(locale: Locale('ko', 'KR'));
  }

  /// Load saved locale from shared preferences
  Future<void> _loadSavedLocale() async {
    state = state.copyWith(isLoading: true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_localeKey);

      if (languageCode != null) {
        final savedLocale = supportedLocales.firstWhere(
          (locale) => locale.languageCode == languageCode,
          orElse: () => const Locale('ko', 'KR'),
        );
        state = LocaleState(locale: savedLocale);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Change app locale
  Future<void> setLocale(Locale locale) async {
    if (!supportedLocales.contains(locale)) return;

    state = state.copyWith(isLoading: true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, locale.languageCode);
      state = LocaleState(locale: locale);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Get locale by language code
  Locale? getLocaleByCode(String languageCode) {
    try {
      return supportedLocales.firstWhere(
        (locale) => locale.languageCode == languageCode,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get display name for locale
  static String getLocaleDisplayName(Locale locale) {
    switch (locale.languageCode) {
      case 'ko':
        return '한국어';
      case 'en':
        return 'English';
      case 'ja':
        return '日本語';
      default:
        return locale.languageCode;
    }
  }
}

/// Locale state provider
final localeProvider = NotifierProvider<LocaleNotifier, LocaleState>(() {
  return LocaleNotifier();
});

/// Current locale provider (convenience accessor)
final currentLocaleProvider = Provider<Locale>((ref) {
  return ref.watch(localeProvider).locale;
});

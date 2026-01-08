import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idol_support/core/providers/locale_provider.dart';

void main() {
  group('LocaleProvider', () {
    test('should have default locale as Korean', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(localeProvider);

      expect(state.locale.languageCode, 'ko');
    });

    test('supportedLocales should contain ko, en, ja', () {
      expect(supportedLocales.length, 3);
      expect(
        supportedLocales.any((l) => l.languageCode == 'ko'),
        isTrue,
      );
      expect(
        supportedLocales.any((l) => l.languageCode == 'en'),
        isTrue,
      );
      expect(
        supportedLocales.any((l) => l.languageCode == 'ja'),
        isTrue,
      );
    });

    test('getLocaleDisplayName should return correct names', () {
      expect(
        LocaleNotifier.getLocaleDisplayName(const Locale('ko', 'KR')),
        '한국어',
      );
      expect(
        LocaleNotifier.getLocaleDisplayName(const Locale('en', 'US')),
        'English',
      );
      expect(
        LocaleNotifier.getLocaleDisplayName(const Locale('ja', 'JP')),
        '日本語',
      );
    });

    test('currentLocaleProvider should return current locale', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final locale = container.read(currentLocaleProvider);

      expect(locale.languageCode, 'ko');
    });
  });
}

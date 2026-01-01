import 'package:flutter_test/flutter_test.dart';
import 'package:idol_support/core/utils/debouncer.dart';

void main() {
  group('Debouncer', () {
    test('지정된 딜레이 후 액션을 실행한다', () async {
      final debouncer = Debouncer(delay: const Duration(milliseconds: 50));
      var executed = false;

      debouncer.call(() => executed = true);

      expect(executed, false);
      await Future.delayed(const Duration(milliseconds: 60));
      expect(executed, true);

      debouncer.dispose();
    });

    test('연속 호출 시 마지막 액션만 실행한다', () async {
      final debouncer = Debouncer(delay: const Duration(milliseconds: 50));
      var counter = 0;

      debouncer.call(() => counter = 1);
      debouncer.call(() => counter = 2);
      debouncer.call(() => counter = 3);

      await Future.delayed(const Duration(milliseconds: 60));
      expect(counter, 3);

      debouncer.dispose();
    });

    test('cancel 호출 시 대기 중인 액션을 취소한다', () async {
      final debouncer = Debouncer(delay: const Duration(milliseconds: 50));
      var executed = false;

      debouncer.call(() => executed = true);
      debouncer.cancel();

      await Future.delayed(const Duration(milliseconds: 60));
      expect(executed, false);

      debouncer.dispose();
    });

    test('flush 호출 시 대기 중인 액션을 즉시 실행한다', () {
      final debouncer = Debouncer(delay: const Duration(milliseconds: 500));
      var executed = false;

      debouncer.call(() => executed = true);
      expect(executed, false);

      debouncer.flush();
      expect(executed, true);

      debouncer.dispose();
    });

    test('isPending이 대기 상태를 올바르게 반환한다', () async {
      final debouncer = Debouncer(delay: const Duration(milliseconds: 50));

      expect(debouncer.isPending, false);

      debouncer.call(() {});
      expect(debouncer.isPending, true);

      await Future.delayed(const Duration(milliseconds: 60));
      expect(debouncer.isPending, false);

      debouncer.dispose();
    });
  });

  group('Throttler', () {
    test('첫 번째 호출을 즉시 실행한다', () {
      final throttler = Throttler(interval: const Duration(milliseconds: 100));
      var executed = false;

      throttler.call(() => executed = true);
      expect(executed, true);

      throttler.dispose();
    });

    test('간격 내 연속 호출 시 첫 번째만 즉시 실행한다', () async {
      final throttler = Throttler(interval: const Duration(milliseconds: 100));
      var counter = 0;

      throttler.call(() => counter++);
      expect(counter, 1);

      throttler.call(() => counter++);
      expect(counter, 1); // 아직 간격 내라 실행 안됨

      await Future.delayed(const Duration(milliseconds: 110));
      expect(counter, 2); // 간격 후 실행됨

      throttler.dispose();
    });
  });

  group('SearchDebouncer', () {
    test('검색어 입력 시 디바운스된 검색을 수행한다', () async {
      String? lastQuery;
      final searchDebouncer = SearchDebouncer(
        delay: const Duration(milliseconds: 50),
        onSearch: (query) => lastQuery = query,
      );

      searchDebouncer.search('h');
      searchDebouncer.search('he');
      searchDebouncer.search('hel');
      searchDebouncer.search('hello');

      expect(lastQuery, null);

      await Future.delayed(const Duration(milliseconds: 60));
      expect(lastQuery, 'hello');

      searchDebouncer.dispose();
    });

    test('빈 검색어는 즉시 처리한다', () {
      String? lastQuery = 'initial';
      final searchDebouncer = SearchDebouncer(
        delay: const Duration(milliseconds: 50),
        onSearch: (query) => lastQuery = query,
      );

      searchDebouncer.search('');
      expect(lastQuery, '');

      searchDebouncer.dispose();
    });

    test('searchNow는 즉시 검색을 실행한다', () {
      String? lastQuery;
      final searchDebouncer = SearchDebouncer(
        delay: const Duration(milliseconds: 500),
        onSearch: (query) => lastQuery = query,
      );

      searchDebouncer.searchNow('immediate');
      expect(lastQuery, 'immediate');

      searchDebouncer.dispose();
    });
  });
}

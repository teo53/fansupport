# 성능 최적화 가이드

PIPO 앱의 성능 최적화를 위한 종합 가이드입니다.

## 목차

1. [메모리 관리](#메모리-관리)
2. [리스트 렌더링 최적화](#리스트-렌더링-최적화)
3. [이미지 최적화](#이미지-최적화)
4. [네트워크 최적화](#네트워크-최적화)
5. [빌드 최적화](#빌드-최적화)
6. [모니터링](#모니터링)

---

## 메모리 관리

### 1. 메모리 모니터링 시작

앱 시작 시 메모리 모니터링을 활성화합니다:

```dart
import 'package:idol_support/core/utils/memory_monitor.dart';

void main() {
  // Development 환경에서만 활성화
  if (kDebugMode) {
    MemoryMonitor.startMonitoring(interval: Duration(seconds: 10));
  }

  runApp(MyApp());
}
```

### 2. Widget 리빌드 추적

자주 리빌드되는 Widget을 추적합니다:

```dart
@override
Widget build(BuildContext context) {
  return RebuildTracker(
    name: 'IdolCard',
    enabled: kDebugMode,
    child: Card(
      // Widget content
    ),
  );
}
```

### 3. 메모리 누수 감지

```dart
class _MyWidgetState extends State<MyWidget> {
  late final StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();

    // Track object for leak detection
    MemoryLeakDetector.track('MyWidget_subscription', _subscription);

    _subscription = someStream.listen((data) {
      // Handle data
    });
  }

  @override
  void dispose() {
    _subscription.cancel(); // ⚠️ 중요: 반드시 취소해야 함
    super.dispose();
  }
}
```

### 4. 이미지 캐시 관리

```dart
// 앱 시작 시 이미지 캐시 설정
ImageCacheMonitor.configureCache(
  maximumSize: 100,           // 최대 100개 이미지
  maximumSizeBytes: 50 << 20, // 최대 50MB
);

// 메모리 부족 시 캐시 정리
void onLowMemory() {
  ImageCacheMonitor.clearCache();
}

// 캐시 상태 확인
void checkImageCache() {
  ImageCacheMonitor.printReport();
}
```

---

## 리스트 렌더링 최적화

### 1. RepaintBoundary 사용

각 리스트 아이템을 독립적으로 그리기:

```dart
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return OptimizedListItem(
      id: items[index].id,
      child: ItemCard(item: items[index]),
    );
  },
);
```

### 2. 무한 스크롤 구현

```dart
class _MyListState extends State<MyList> {
  final _scrollController = ScrollController();
  late final LazyLoadController _lazyLoadController;

  @override
  void initState() {
    super.initState();
    _lazyLoadController = LazyLoadController(
      scrollController: _scrollController,
      threshold: 0.8,
      onLoadMore: _loadMoreItems,
    );
  }

  Future<void> _loadMoreItems() async {
    // Load more data
    final newItems = await fetchMoreItems();

    setState(() {
      items.addAll(newItems);
    });

    _lazyLoadController.completeLoading();
  }

  @override
  void dispose() {
    _lazyLoadController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: items.length,
      itemBuilder: (context, index) => ItemCard(item: items[index]),
    );
  }
}
```

### 3. 페이지네이션 구현

```dart
class _PaginatedListState extends State<PaginatedList> {
  final _pagination = PaginationHelper<IdolModel>(pageSize: 20);

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final items = await fetchIdols();
    setState(() {
      _pagination.addItems(items);
    });
  }

  void _loadNextPage() {
    if (_pagination.loadNextPage()) {
      setState(() {});
    } else {
      // Load more from server
      _loadMoreFromServer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _pagination.getAllLoadedItems();

    return ListView.builder(
      itemCount: items.length + (_pagination.hasMorePages ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == items.length) {
          // Loading indicator
          return const Center(child: CircularProgressIndicator());
        }
        return ItemCard(item: items[index]);
      },
    );
  }
}
```

### 4. Sliver 사용하기

복잡한 스크롤 레이아웃에 Sliver 사용:

```dart
CustomScrollView(
  slivers: [
    SliverAppBar(
      // App bar content
    ),
    OptimizedSliverList(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return ItemCard(item: items[index]);
      },
    ),
  ],
);
```

---

## 이미지 최적화

### 1. 최적화된 이미지 로딩

```dart
// 자동 메모리 최적화를 위한 이미지 로딩
OptimizedCachedImage(
  imageUrl: idol.profileImageUrl,
  width: 100,
  height: 100,
  fit: BoxFit.cover,
  placeholder: (context, url) => const ShimmerCard(),
  errorWidget: (context, url, error) => const Icon(Icons.error),
);
```

### 2. 이미지 크기 제한

```dart
Image.network(
  imageUrl,
  cacheWidth: 400,  // 실제 표시 크기로 제한
  cacheHeight: 400,
  fit: BoxFit.cover,
);
```

### 3. Placeholder와 점진적 로딩

```dart
FadeInImage.memoryNetwork(
  placeholder: kTransparentImage,
  image: imageUrl,
  fit: BoxFit.cover,
  fadeInDuration: const Duration(milliseconds: 300),
);
```

---

## 네트워크 최적화

### 1. Debouncing 사용 (검색)

```dart
class _SearchScreenState extends State<SearchScreen> {
  final _debouncer = Debouncer(delay: Duration(milliseconds: 300));

  void _onSearchChanged(String query) {
    _debouncer.call(() {
      // API 호출은 300ms 후에만 실행
      _performSearch(query);
    });
  }

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }
}
```

### 2. Throttling 사용 (이벤트)

```dart
class _HomeScreenState extends State<HomeScreen> {
  final _throttler = Throttler(duration: Duration(milliseconds: 500));

  void _onRefresh() {
    _throttler.call(() {
      // 최대 0.5초에 한 번만 실행
      _fetchData();
    });
  }
}
```

### 3. 배치 처리

```dart
final _batchProcessor = BatchProcessor<AnalyticsEvent>(
  batchDuration: Duration(seconds: 5),
  onBatch: (events) {
    // 5초마다 모아서 한 번에 전송
    _sendAnalytics(events);
  },
);

void trackEvent(AnalyticsEvent event) {
  _batchProcessor.add(event);
}
```

### 4. Rate Limiting

```dart
final _rateLimiter = RateLimiter(
  maxCalls: 10,
  period: Duration(seconds: 60),
);

Future<void> _callAPI() async {
  final result = await _rateLimiter.execute(() => apiClient.getData());
  // 1분에 최대 10번만 호출
}
```

### 5. 결과 캐싱

```dart
final _cache = Memoizer<List<IdolModel>>(
  cacheDuration: Duration(minutes: 5),
);

Future<List<IdolModel>> getIdols() async {
  return _cache.call('idols', () => _fetchIdolsFromAPI());
}
```

---

## 빌드 최적화

### 1. const 생성자 사용

```dart
// ✅ Good - const로 재사용
const SizedBox(height: 16)
const Divider()
const Icon(Icons.star)

// ❌ Bad - 매번 새로 생성
SizedBox(height: 16)
Divider()
Icon(Icons.star)
```

### 2. Widget 분리

```dart
// ✅ Good - 독립적인 Widget
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) => /* ... */;
}

// ❌ Bad - 메서드로 분리
Widget _buildHeader() => /* ... */;
```

### 3. ListView.builder 사용

```dart
// ✅ Good - 필요한 아이템만 빌드
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemCard(item: items[index]),
);

// ❌ Bad - 모든 아이템을 한 번에 빌드
ListView(
  children: items.map((item) => ItemCard(item: item)).toList(),
);
```

### 4. Provider 범위 최소화

```dart
// ✅ Good - 필요한 부분만 watch
final idolName = ref.watch(idolProvider.select((idol) => idol.name));

// ❌ Bad - 전체 객체 watch
final idol = ref.watch(idolProvider);
final name = idol.name;
```

---

## 모니터링

### 1. 개발 중 모니터링

```dart
void main() {
  if (kDebugMode) {
    // 메모리 모니터링
    MemoryMonitor.startMonitoring();

    // 환경 설정 출력
    EnvironmentConfig.printConfig();
    SupabaseConfig.printConfig();

    // 이미지 캐시 설정
    ImageCacheMonitor.configureCache(
      maximumSize: 100,
      maximumSizeBytes: 50 << 20,
    );
  }

  runApp(MyApp());
}
```

### 2. 리포트 생성

```dart
// 메모리 리포트
MemoryMonitor.printReport();

// 이미지 캐시 리포트
ImageCacheMonitor.printReport();

// 스크롤 성능 리포트
final scrollMonitor = ScrollPerformanceMonitor('IdolList');
scrollMonitor.printReport();

// 메모리 누수 체크
MemoryLeakDetector.checkLeaks();
```

### 3. Performance Overlay

```dart
MaterialApp(
  showPerformanceOverlay: kDebugMode, // FPS 오버레이 표시
  // ...
);
```

---

## 체크리스트

### 개발 시

- [ ] 자주 사용되는 Widget에 `const` 적용
- [ ] 큰 리스트는 `.builder()` 사용
- [ ] 이미지 크기 제한 (`cacheWidth`, `cacheHeight`)
- [ ] 검색에 Debouncer 적용
- [ ] StreamSubscription 정리 (`dispose`)

### 최적화 시

- [ ] MemoryMonitor로 리빌드 횟수 확인
- [ ] RepaintBoundary로 리스트 아이템 분리
- [ ] ImageCacheMonitor로 캐시 사용량 확인
- [ ] 메모리 누수 체크
- [ ] 스크롤 성능 측정

### 배포 전

- [ ] Production 빌드 테스트
- [ ] 프로파일 모드에서 성능 측정
- [ ] 메모리 사용량 확인
- [ ] 앱 크기 확인 (APK/IPA)
- [ ] 이미지 최적화 확인

---

## 참고 자료

- [Flutter Performance Best Practices](https://docs.flutter.dev/perf/best-practices)
- [Flutter Performance Profiling](https://docs.flutter.dev/perf/ui-performance)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)

---

## 문제 해결

### 메모리 부족

1. `ImageCacheMonitor.clearCache()` 호출
2. 이미지 캐시 크기 줄이기
3. 리스트 페이지네이션 구현

### 느린 스크롤

1. `RepaintBoundary` 추가
2. `ListView.builder` 사용 확인
3. 복잡한 Widget 분리
4. ScrollPerformanceMonitor로 측정

### 잦은 리빌드

1. `RebuildTracker`로 원인 파악
2. Provider `select` 사용
3. `const` 생성자 적용
4. Widget 메모이제이션

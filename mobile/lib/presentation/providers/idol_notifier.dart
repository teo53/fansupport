import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/idol_entity.dart';
import '../../domain/repositories/idol_repository.dart';
import 'base_state.dart';
import 'di_providers.dart';

/// 아이돌 목록 상태 관리 Notifier
class IdolListNotifier extends StateNotifier<PaginatedState<IdolSummary>> {
  final IdolRepository _repository;
  IdolCategory? _currentCategory;
  String _searchQuery = '';

  IdolListNotifier(this._repository) : super(const PaginatedState()) {
    loadInitial();
  }

  Future<void> loadInitial({IdolCategory? category}) async {
    if (state.isLoading) return;

    _currentCategory = category;

    state = state.copyWith(
      isLoading: true,
      items: [],
      currentPage: 0,
      hasMore: true,
      error: null,
    );

    final result = await _repository.getIdols(
      category: _currentCategory,
      searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
      page: 1,
      limit: 20,
    );

    result.fold(
      onSuccess: (idols) {
        state = state.copyWith(
          items: idols,
          isLoading: false,
          currentPage: 1,
          hasMore: idols.length >= 20,
        );
      },
      onFailure: (failure) {
        state = state.setError(failure);
      },
    );
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.startLoading();

    final result = await _repository.getIdols(
      category: _currentCategory,
      searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
      page: state.currentPage + 1,
      limit: 20,
    );

    result.fold(
      onSuccess: (idols) {
        state = state.appendItems(idols, hasMore: idols.length >= 20);
      },
      onFailure: (failure) {
        state = state.setError(failure);
      },
    );
  }

  void setCategory(IdolCategory? category) {
    if (_currentCategory != category) {
      loadInitial(category: category);
    }
  }

  void search(String query) {
    _searchQuery = query;
    loadInitial(category: _currentCategory);
  }

  Future<void> refresh() async {
    state = state.reset();
    await loadInitial(category: _currentCategory);
  }
}

/// 아이돌 상세 상태
class IdolDetailNotifier extends StateNotifier<AsyncState<IdolEntity>> {
  final IdolRepository _repository;
  final String idolId;

  IdolDetailNotifier(this._repository, this.idolId)
      : super(const Initial()) {
    load();
  }

  Future<void> load() async {
    state = const Loading();

    final result = await _repository.getIdolById(idolId);

    result.fold(
      onSuccess: (idol) {
        state = Success(idol);
      },
      onFailure: (failure) {
        state = Error(failure);
      },
    );
  }

  Future<void> toggleFollow() async {
    final currentData = state.data;
    if (currentData == null) return;

    final isFollowing = currentData.isFollowing;

    // Optimistic update
    state = Success(currentData.copyWith(
      isFollowing: !isFollowing,
      followerCount: currentData.followerCount + (isFollowing ? -1 : 1),
    ));

    // API 호출
    final result = isFollowing
        ? await _repository.unfollowIdol(idolId)
        : await _repository.followIdol(idolId);

    result.fold(
      onSuccess: (updatedIdol) {
        state = Success(updatedIdol);
      },
      onFailure: (_) {
        // 실패 시 롤백
        state = Success(currentData);
      },
    );
  }
}

/// 아이돌 목록 Provider
final idolListProvider =
    StateNotifierProvider<IdolListNotifier, PaginatedState<IdolSummary>>((ref) {
  return IdolListNotifier(ref.read(idolRepositoryProvider));
});

/// 아이돌 상세 Provider
final idolDetailProvider = StateNotifierProvider.family<
    IdolDetailNotifier, AsyncState<IdolEntity>, String>((ref, idolId) {
  return IdolDetailNotifier(ref.read(idolRepositoryProvider), idolId);
});

/// 인기 아이돌 Provider
final popularIdolsProvider = FutureProvider<List<IdolSummary>>((ref) async {
  final result = await ref.read(idolRepositoryProvider).getPopularIdols();
  return result.data ?? [];
});

/// 아이돌 랭킹 Provider
final idolRankingProvider = FutureProvider.family<List<IdolRanking>, RankingType>(
  (ref, type) async {
    final result = await ref.read(idolRepositoryProvider).getIdolRanking(type: type);
    return result.data ?? [];
  },
);

/// 팔로잉 아이돌 Provider
final followingIdolsProvider = FutureProvider<List<IdolSummary>>((ref) async {
  final result = await ref.read(idolRepositoryProvider).getFollowingIdols();
  return result.data ?? [];
});

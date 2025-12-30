import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/repositories/post_repository.dart';
import 'base_state.dart';
import 'di_providers.dart';

/// 피드 상태 관리 Notifier
class FeedNotifier extends StateNotifier<PaginatedState<PostEntity>> {
  final PostRepository _repository;
  final FeedType _feedType;

  FeedNotifier(this._repository, this._feedType)
      : super(const PaginatedState()) {
    loadInitial();
  }

  Future<void> loadInitial() async {
    if (state.isLoading) return;

    state = state.copyWith(
      isLoading: true,
      items: [],
      currentPage: 0,
      hasMore: true,
      error: null,
    );

    final result = await _repository.getFeed(
      type: _feedType,
      page: 1,
      limit: 20,
    );

    result.fold(
      onSuccess: (posts) {
        state = state.copyWith(
          items: posts,
          isLoading: false,
          currentPage: 1,
          hasMore: posts.length >= 20,
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

    final result = await _repository.getFeed(
      type: _feedType,
      page: state.currentPage + 1,
      limit: 20,
    );

    result.fold(
      onSuccess: (posts) {
        state = state.appendItems(posts, hasMore: posts.length >= 20);
      },
      onFailure: (failure) {
        state = state.setError(failure);
      },
    );
  }

  Future<void> refresh() async {
    state = state.reset();
    await loadInitial();
  }

  Future<void> toggleLike(String postId) async {
    final index = state.items.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final post = state.items[index];
    final isLiked = post.isLiked;

    // Optimistic update
    final updatedItems = [...state.items];
    updatedItems[index] = post.toggleLike();
    state = state.copyWith(items: updatedItems);

    // API 호출
    final result = isLiked
        ? await _repository.unlikePost(postId)
        : await _repository.likePost(postId);

    result.fold(
      onSuccess: (updatedPost) {
        final newItems = [...state.items];
        newItems[index] = updatedPost;
        state = state.copyWith(items: newItems);
      },
      onFailure: (_) {
        // 실패 시 롤백
        final revertedItems = [...state.items];
        revertedItems[index] = post;
        state = state.copyWith(items: revertedItems);
      },
    );
  }

  Future<void> toggleBookmark(String postId) async {
    final index = state.items.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final post = state.items[index];
    final isBookmarked = post.isBookmarked;

    // Optimistic update
    final updatedItems = [...state.items];
    updatedItems[index] = post.toggleBookmark();
    state = state.copyWith(items: updatedItems);

    // API 호출
    final result = isBookmarked
        ? await _repository.unbookmarkPost(postId)
        : await _repository.bookmarkPost(postId);

    result.fold(
      onSuccess: (updatedPost) {
        final newItems = [...state.items];
        newItems[index] = updatedPost;
        state = state.copyWith(items: newItems);
      },
      onFailure: (_) {
        // 실패 시 롤백
        final revertedItems = [...state.items];
        revertedItems[index] = post;
        state = state.copyWith(items: revertedItems);
      },
    );
  }
}

/// 홈 피드 Provider
final homeFeedProvider =
    StateNotifierProvider<FeedNotifier, PaginatedState<PostEntity>>((ref) {
  return FeedNotifier(ref.read(postRepositoryProvider), FeedType.all);
});

/// 팔로잉 피드 Provider
final followingFeedProvider =
    StateNotifierProvider<FeedNotifier, PaginatedState<PostEntity>>((ref) {
  return FeedNotifier(ref.read(postRepositoryProvider), FeedType.following);
});

/// 인기 피드 Provider
final popularFeedProvider =
    StateNotifierProvider<FeedNotifier, PaginatedState<PostEntity>>((ref) {
  return FeedNotifier(ref.read(postRepositoryProvider), FeedType.popular);
});

/// 단일 게시물 Provider
final postDetailProvider =
    FutureProvider.family<PostEntity?, String>((ref, postId) async {
  final result = await ref.read(postRepositoryProvider).getPostById(postId);
  return result.data;
});

/// 댓글 목록 Provider
final commentsProvider =
    FutureProvider.family<List<CommentEntity>, String>((ref, postId) async {
  final result = await ref.read(postRepositoryProvider).getComments(postId: postId);
  return result.data ?? [];
});

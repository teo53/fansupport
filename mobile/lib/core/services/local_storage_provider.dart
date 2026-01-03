import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'local_storage_service.dart';

/// Provider for LocalStorageService
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  throw UnimplementedError('Must be overridden in main.dart');
});

/// Settings providers
final darkModeProvider = StateNotifierProvider<DarkModeNotifier, bool>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return DarkModeNotifier(storage);
});

class DarkModeNotifier extends StateNotifier<bool> {
  final LocalStorageService _storage;

  DarkModeNotifier(this._storage) : super(_storage.isDarkMode);

  void toggle() {
    state = !state;
    _storage.isDarkMode = state;
  }

  void set(bool value) {
    state = value;
    _storage.isDarkMode = value;
  }
}

/// Push notifications provider
final pushNotificationsProvider =
    StateNotifierProvider<PushNotificationsNotifier, bool>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return PushNotificationsNotifier(storage);
});

class PushNotificationsNotifier extends StateNotifier<bool> {
  final LocalStorageService _storage;

  PushNotificationsNotifier(this._storage)
      : super(_storage.pushNotificationsEnabled);

  void toggle() {
    state = !state;
    _storage.pushNotificationsEnabled = state;
  }
}

/// Followed idols provider
final followedIdolsProvider =
    StateNotifierProvider<FollowedIdolsNotifier, List<String>>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return FollowedIdolsNotifier(storage);
});

class FollowedIdolsNotifier extends StateNotifier<List<String>> {
  final LocalStorageService _storage;

  FollowedIdolsNotifier(this._storage) : super(_storage.followedIdols);

  bool isFollowing(String idolId) => state.contains(idolId);

  Future<void> toggle(String idolId) async {
    await _storage.toggleFollow(idolId);
    state = _storage.followedIdols;
  }
}

/// Bookmarked posts provider
final bookmarkedPostsProvider =
    StateNotifierProvider<BookmarkedPostsNotifier, List<String>>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return BookmarkedPostsNotifier(storage);
});

class BookmarkedPostsNotifier extends StateNotifier<List<String>> {
  final LocalStorageService _storage;

  BookmarkedPostsNotifier(this._storage) : super(_storage.bookmarkedPosts);

  bool isBookmarked(String postId) => state.contains(postId);

  Future<void> toggle(String postId) async {
    await _storage.toggleBookmark(postId);
    state = _storage.bookmarkedPosts;
  }
}

/// Liked posts provider
final likedPostsProvider =
    StateNotifierProvider<LikedPostsNotifier, List<String>>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return LikedPostsNotifier(storage);
});

class LikedPostsNotifier extends StateNotifier<List<String>> {
  final LocalStorageService _storage;

  LikedPostsNotifier(this._storage) : super(_storage.likedPosts);

  bool isLiked(String postId) => state.contains(postId);

  Future<void> toggle(String postId) async {
    await _storage.toggleLike(postId);
    state = _storage.likedPosts;
  }
}

/// Poll votes provider
final pollVotesProvider =
    StateNotifierProvider<PollVotesNotifier, Map<String, int>>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return PollVotesNotifier(storage);
});

class PollVotesNotifier extends StateNotifier<Map<String, int>> {
  final LocalStorageService _storage;

  PollVotesNotifier(this._storage) : super(_storage.pollVotes);

  int? getVotedOption(String postId) => state[postId];

  bool hasVoted(String postId) => state.containsKey(postId);

  Future<void> vote(String postId, int optionIndex) async {
    await _storage.vote(postId, optionIndex);
    state = Map.from(_storage.pollVotes);
  }
}

/// Search history provider
final searchHistoryProvider =
    StateNotifierProvider<SearchHistoryNotifier, List<String>>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return SearchHistoryNotifier(storage);
});

class SearchHistoryNotifier extends StateNotifier<List<String>> {
  final LocalStorageService _storage;

  SearchHistoryNotifier(this._storage) : super(_storage.searchHistory);

  Future<void> addQuery(String query) async {
    await _storage.addSearchQuery(query);
    state = _storage.searchHistory;
  }

  Future<void> removeQuery(String query) async {
    await _storage.removeSearchQuery(query);
    state = _storage.searchHistory;
  }

  Future<void> clear() async {
    await _storage.clearSearchHistory();
    state = [];
  }
}

/// Favorite campaigns provider
final favoriteCampaignsProvider =
    StateNotifierProvider<FavoriteCampaignsNotifier, List<String>>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return FavoriteCampaignsNotifier(storage);
});

class FavoriteCampaignsNotifier extends StateNotifier<List<String>> {
  final LocalStorageService _storage;

  FavoriteCampaignsNotifier(this._storage) : super(_storage.favoriteCampaigns);

  bool isFavorited(String campaignId) => state.contains(campaignId);

  Future<void> toggle(String campaignId) async {
    await _storage.toggleCampaignFavorite(campaignId);
    state = _storage.favoriteCampaigns;
  }
}

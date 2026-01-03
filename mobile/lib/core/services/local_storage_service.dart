import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Local storage service for persisting data without backend
class LocalStorageService {
  static LocalStorageService? _instance;
  static SharedPreferences? _prefs;

  LocalStorageService._();

  static Future<LocalStorageService> getInstance() async {
    _instance ??= LocalStorageService._();
    _prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  // ============================================
  // SETTINGS
  // ============================================

  static const String _keyDarkMode = 'settings_dark_mode';
  static const String _keyLanguage = 'settings_language';
  static const String _keyPushNotifications = 'settings_push_notifications';
  static const String _keyEmailNotifications = 'settings_email_notifications';

  bool get isDarkMode => _prefs?.getBool(_keyDarkMode) ?? false;
  set isDarkMode(bool value) => _prefs?.setBool(_keyDarkMode, value);

  String get language => _prefs?.getString(_keyLanguage) ?? 'ko';
  set language(String value) => _prefs?.setString(_keyLanguage, value);

  bool get pushNotificationsEnabled =>
      _prefs?.getBool(_keyPushNotifications) ?? true;
  set pushNotificationsEnabled(bool value) =>
      _prefs?.setBool(_keyPushNotifications, value);

  bool get emailNotificationsEnabled =>
      _prefs?.getBool(_keyEmailNotifications) ?? true;
  set emailNotificationsEnabled(bool value) =>
      _prefs?.setBool(_keyEmailNotifications, value);

  // ============================================
  // USER PROFILE
  // ============================================

  static const String _keyUserProfile = 'user_profile';

  Map<String, dynamic>? get userProfile {
    final json = _prefs?.getString(_keyUserProfile);
    if (json == null) return null;
    return jsonDecode(json) as Map<String, dynamic>;
  }

  set userProfile(Map<String, dynamic>? profile) {
    if (profile == null) {
      _prefs?.remove(_keyUserProfile);
    } else {
      _prefs?.setString(_keyUserProfile, jsonEncode(profile));
    }
  }

  Future<void> updateUserProfile({
    String? nickname,
    String? bio,
    String? profileImage,
  }) async {
    final current = userProfile ?? {};
    if (nickname != null) current['nickname'] = nickname;
    if (bio != null) current['bio'] = bio;
    if (profileImage != null) current['profileImage'] = profileImage;
    userProfile = current;
  }

  // ============================================
  // FOLLOWED IDOLS
  // ============================================

  static const String _keyFollowedIdols = 'followed_idols';

  List<String> get followedIdols {
    return _prefs?.getStringList(_keyFollowedIdols) ?? [];
  }

  bool isFollowing(String idolId) {
    return followedIdols.contains(idolId);
  }

  Future<void> followIdol(String idolId) async {
    final list = followedIdols;
    if (!list.contains(idolId)) {
      list.add(idolId);
      await _prefs?.setStringList(_keyFollowedIdols, list);
    }
  }

  Future<void> unfollowIdol(String idolId) async {
    final list = followedIdols;
    list.remove(idolId);
    await _prefs?.setStringList(_keyFollowedIdols, list);
  }

  Future<void> toggleFollow(String idolId) async {
    if (isFollowing(idolId)) {
      await unfollowIdol(idolId);
    } else {
      await followIdol(idolId);
    }
  }

  // ============================================
  // BOOKMARKED POSTS
  // ============================================

  static const String _keyBookmarkedPosts = 'bookmarked_posts';

  List<String> get bookmarkedPosts {
    return _prefs?.getStringList(_keyBookmarkedPosts) ?? [];
  }

  bool isBookmarked(String postId) {
    return bookmarkedPosts.contains(postId);
  }

  Future<void> toggleBookmark(String postId) async {
    final list = bookmarkedPosts;
    if (list.contains(postId)) {
      list.remove(postId);
    } else {
      list.add(postId);
    }
    await _prefs?.setStringList(_keyBookmarkedPosts, list);
  }

  // ============================================
  // LIKED POSTS
  // ============================================

  static const String _keyLikedPosts = 'liked_posts';

  List<String> get likedPosts {
    return _prefs?.getStringList(_keyLikedPosts) ?? [];
  }

  bool isLiked(String postId) {
    return likedPosts.contains(postId);
  }

  Future<void> toggleLike(String postId) async {
    final list = likedPosts;
    if (list.contains(postId)) {
      list.remove(postId);
    } else {
      list.add(postId);
    }
    await _prefs?.setStringList(_keyLikedPosts, list);
  }

  // ============================================
  // POLL VOTES
  // ============================================

  static const String _keyPollVotes = 'poll_votes';

  Map<String, int> get pollVotes {
    final json = _prefs?.getString(_keyPollVotes);
    if (json == null) return {};
    final decoded = jsonDecode(json) as Map<String, dynamic>;
    return decoded.map((key, value) => MapEntry(key, value as int));
  }

  int? getVotedOption(String postId) {
    return pollVotes[postId];
  }

  Future<void> vote(String postId, int optionIndex) async {
    final votes = pollVotes;
    votes[postId] = optionIndex;
    await _prefs?.setString(_keyPollVotes, jsonEncode(votes));
  }

  // ============================================
  // FAVORITE CAMPAIGNS
  // ============================================

  static const String _keyFavoriteCampaigns = 'favorite_campaigns';

  List<String> get favoriteCampaigns {
    return _prefs?.getStringList(_keyFavoriteCampaigns) ?? [];
  }

  bool isCampaignFavorited(String campaignId) {
    return favoriteCampaigns.contains(campaignId);
  }

  Future<void> toggleCampaignFavorite(String campaignId) async {
    final list = favoriteCampaigns;
    if (list.contains(campaignId)) {
      list.remove(campaignId);
    } else {
      list.add(campaignId);
    }
    await _prefs?.setStringList(_keyFavoriteCampaigns, list);
  }

  // ============================================
  // FAVORITE GENBA EVENTS
  // ============================================

  static const String _keyFavoriteGenbas = 'favorite_genbas';

  List<String> get favoriteGenbas {
    return _prefs?.getStringList(_keyFavoriteGenbas) ?? [];
  }

  bool isGenbaFavorited(String genbaId) {
    return favoriteGenbas.contains(genbaId);
  }

  Future<void> toggleGenbaFavorite(String genbaId) async {
    final list = favoriteGenbas;
    if (list.contains(genbaId)) {
      list.remove(genbaId);
    } else {
      list.add(genbaId);
    }
    await _prefs?.setStringList(_keyFavoriteGenbas, list);
  }

  // ============================================
  // SEARCH HISTORY
  // ============================================

  static const String _keySearchHistory = 'search_history';
  static const int _maxSearchHistory = 10;

  List<String> get searchHistory {
    return _prefs?.getStringList(_keySearchHistory) ?? [];
  }

  Future<void> addSearchQuery(String query) async {
    if (query.trim().isEmpty) return;
    final list = searchHistory;
    list.remove(query); // Remove if exists
    list.insert(0, query); // Add to front
    if (list.length > _maxSearchHistory) {
      list.removeLast();
    }
    await _prefs?.setStringList(_keySearchHistory, list);
  }

  Future<void> removeSearchQuery(String query) async {
    final list = searchHistory;
    list.remove(query);
    await _prefs?.setStringList(_keySearchHistory, list);
  }

  Future<void> clearSearchHistory() async {
    await _prefs?.remove(_keySearchHistory);
  }

  // ============================================
  // ONBOARDING
  // ============================================

  static const String _keyOnboardingComplete = 'onboarding_complete';

  bool get isOnboardingComplete =>
      _prefs?.getBool(_keyOnboardingComplete) ?? false;

  Future<void> setOnboardingComplete() async {
    await _prefs?.setBool(_keyOnboardingComplete, true);
  }

  // ============================================
  // RECENTLY VIEWED
  // ============================================

  static const String _keyRecentlyViewedIdols = 'recently_viewed_idols';
  static const int _maxRecentlyViewed = 20;

  List<String> get recentlyViewedIdols {
    return _prefs?.getStringList(_keyRecentlyViewedIdols) ?? [];
  }

  Future<void> addRecentlyViewedIdol(String idolId) async {
    final list = recentlyViewedIdols;
    list.remove(idolId);
    list.insert(0, idolId);
    if (list.length > _maxRecentlyViewed) {
      list.removeLast();
    }
    await _prefs?.setStringList(_keyRecentlyViewedIdols, list);
  }

  // ============================================
  // CLEAR ALL DATA
  // ============================================

  Future<void> clearAllData() async {
    await _prefs?.clear();
  }
}

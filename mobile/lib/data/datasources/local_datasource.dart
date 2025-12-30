import '../../core/mock/mock_data.dart';
import '../../domain/entities/entities.dart';

/// 로컬 데이터소스 (Mock 데이터 사용)
/// 추후 API 연동 시 RemoteDataSource로 교체
class LocalDataSource {
  // ============ 인증 ============

  AuthenticatedUser? _currentUser;

  Future<AuthenticatedUser?> getCurrentUser() async {
    await _simulateNetworkDelay();
    return _currentUser;
  }

  Future<AuthenticatedUser> login(String email, String password) async {
    await _simulateNetworkDelay();
    // 데모용 검증
    if (email == 'demo@test.com' || password == 'password') {
      _currentUser = _createDemoUser();
      return _currentUser!;
    }
    throw Exception('Invalid credentials');
  }

  Future<AuthenticatedUser> loginAsDemo() async {
    await _simulateNetworkDelay();
    _currentUser = _createDemoUser();
    return _currentUser!;
  }

  Future<void> logout() async {
    await _simulateNetworkDelay(ms: 200);
    _currentUser = null;
  }

  AuthenticatedUser _createDemoUser() {
    return AuthenticatedUser(
      id: 'demo_user_1',
      email: 'demo@fansupport.com',
      nickname: '열혈팬',
      profileImage: 'https://picsum.photos/200',
      bio: '아이돌을 사랑하는 팬입니다 💕',
      followersCount: 128,
      followingCount: 45,
      postsCount: 32,
      accessToken: 'demo_access_token',
      refreshToken: 'demo_refresh_token',
      createdAt: DateTime.now(),
    );
  }

  // ============ 아이돌 ============

  Future<List<IdolSummary>> getIdols({
    IdolCategory? category,
    String? searchQuery,
    int page = 1,
    int limit = 20,
  }) async {
    await _simulateNetworkDelay();

    var idols = MockData.idols.where((idol) {
      final matchesCategory = category == null ||
          idol['category'] == category.code;
      final matchesSearch = searchQuery == null ||
          searchQuery.isEmpty ||
          idol['stageName'].toString().toLowerCase()
              .contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    // 페이지네이션
    final start = (page - 1) * limit;
    final end = start + limit;
    if (start >= idols.length) return [];
    idols = idols.sublist(start, end.clamp(0, idols.length));

    return idols.map(_mapToIdolSummary).toList();
  }

  Future<IdolEntity> getIdolById(String id) async {
    await _simulateNetworkDelay();

    final idol = MockData.idols.firstWhere(
      (i) => i['id'] == id,
      orElse: () => throw Exception('Idol not found'),
    );

    return _mapToIdolEntity(idol);
  }

  Future<List<IdolRanking>> getIdolRanking({int limit = 100}) async {
    await _simulateNetworkDelay();

    final idols = MockData.idols.take(limit).toList();
    return idols.asMap().entries.map((entry) {
      final idol = entry.value;
      return IdolRanking(
        rank: entry.key + 1,
        previousRank: entry.key + 2,
        idol: _mapToIdolSummary(idol),
        score: (idol['followerCount'] ?? 0) * 10,
        supportAmount: idol['totalSupport'] ?? 0,
      );
    }).toList();
  }

  // ============ 게시물 ============

  final List<Map<String, dynamic>> _posts = List.from(MockData.posts);

  Future<List<PostEntity>> getPosts({
    int page = 1,
    int limit = 20,
  }) async {
    await _simulateNetworkDelay();

    final start = (page - 1) * limit;
    final end = start + limit;
    if (start >= _posts.length) return [];

    final paginated = _posts.sublist(start, end.clamp(0, _posts.length));
    return paginated.map(_mapToPostEntity).toList();
  }

  Future<PostEntity> getPostById(String id) async {
    await _simulateNetworkDelay();

    final post = _posts.firstWhere(
      (p) => p['id'] == id,
      orElse: () => throw Exception('Post not found'),
    );

    return _mapToPostEntity(post);
  }

  Future<PostEntity> toggleLikePost(String id) async {
    await _simulateNetworkDelay(ms: 200);

    final index = _posts.indexWhere((p) => p['id'] == id);
    if (index == -1) throw Exception('Post not found');

    final post = _posts[index];
    final isLiked = post['isLiked'] ?? false;
    _posts[index] = {
      ...post,
      'isLiked': !isLiked,
      'likeCount': (post['likeCount'] ?? 0) + (isLiked ? -1 : 1),
    };

    return _mapToPostEntity(_posts[index]);
  }

  Future<PostEntity> toggleBookmarkPost(String id) async {
    await _simulateNetworkDelay(ms: 200);

    final index = _posts.indexWhere((p) => p['id'] == id);
    if (index == -1) throw Exception('Post not found');

    final post = _posts[index];
    _posts[index] = {
      ...post,
      'isBookmarked': !(post['isBookmarked'] ?? false),
    };

    return _mapToPostEntity(_posts[index]);
  }

  // ============ 캠페인 ============

  Future<List<CampaignSummary>> getCampaigns({
    CampaignType? type,
    int page = 1,
    int limit = 20,
  }) async {
    await _simulateNetworkDelay();

    var campaigns = MockData.campaigns.where((c) {
      return type == null || c['type'] == type.code;
    }).toList();

    final start = (page - 1) * limit;
    final end = start + limit;
    if (start >= campaigns.length) return [];
    campaigns = campaigns.sublist(start, end.clamp(0, campaigns.length));

    return campaigns.map(_mapToCampaignSummary).toList();
  }

  Future<CampaignEntity> getCampaignById(String id) async {
    await _simulateNetworkDelay();

    final campaign = MockData.campaigns.firstWhere(
      (c) => c['id'] == id,
      orElse: () => throw Exception('Campaign not found'),
    );

    return _mapToCampaignEntity(campaign);
  }

  // ============ 이벤트 ============

  Future<List<EventEntity>> getEvents({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    await _simulateNetworkDelay();

    return MockData.events.where((e) {
      final date = DateTime.parse(e['date']);
      return !date.isBefore(startDate) && !date.isAfter(endDate);
    }).map(_mapToEventEntity).toList();
  }

  Future<List<EventEntity>> getEventsByDate(DateTime date) async {
    await _simulateNetworkDelay();

    return MockData.events.where((e) {
      final eventDate = DateTime.parse(e['date']);
      return eventDate.year == date.year &&
          eventDate.month == date.month &&
          eventDate.day == date.day;
    }).map(_mapToEventEntity).toList();
  }

  Future<Map<DateTime, List<EventEntity>>> getMonthlyEvents({
    required int year,
    required int month,
  }) async {
    await _simulateNetworkDelay();

    final Map<DateTime, List<EventEntity>> result = {};

    for (final e in MockData.events) {
      final date = DateTime.parse(e['date']);
      if (date.year == year && date.month == month) {
        final key = DateTime(date.year, date.month, date.day);
        result.putIfAbsent(key, () => []);
        result[key]!.add(_mapToEventEntity(e));
      }
    }

    return result;
  }

  // ============ Mappers ============

  IdolSummary _mapToIdolSummary(Map<String, dynamic> data) {
    return IdolSummary(
      id: data['id'] ?? '',
      stageName: data['stageName'] ?? '',
      category: IdolCategory.fromCode(data['category']),
      profileImage: data['profileImage'] ?? '',
      followerCount: data['followerCount'] ?? 0,
      isFollowing: data['isFollowing'] ?? false,
      isVerified: data['isVerified'] ?? false,
    );
  }

  IdolEntity _mapToIdolEntity(Map<String, dynamic> data) {
    return IdolEntity(
      id: data['id'] ?? '',
      stageName: data['stageName'] ?? '',
      realName: data['realName'],
      category: IdolCategory.fromCode(data['category']),
      profileImage: data['profileImage'] ?? '',
      coverImage: data['coverImage'],
      bio: data['bio'],
      agency: data['agency'],
      followerCount: data['followerCount'] ?? 0,
      supporterCount: data['supporterCount'] ?? 0,
      totalSupport: data['totalSupport'] ?? 0,
      isFollowing: data['isFollowing'] ?? false,
      isVerified: data['isVerified'] ?? false,
      gallery: List<String>.from(data['gallery'] ?? []),
    );
  }

  PostEntity _mapToPostEntity(Map<String, dynamic> data) {
    return PostEntity(
      id: data['id'] ?? '',
      author: PostAuthor(
        id: data['authorId'] ?? '',
        name: data['authorName'] ?? '',
        username: data['authorUsername'],
        profileImage: data['authorImage'],
        isVerified: data['isVerified'] ?? false,
        isIdol: data['isIdol'] ?? false,
      ),
      content: data['content'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      likeCount: data['likeCount'] ?? 0,
      commentCount: data['commentCount'] ?? 0,
      shareCount: data['shareCount'] ?? 0,
      viewCount: data['viewCount'] ?? 0,
      isLiked: data['isLiked'] ?? false,
      isBookmarked: data['isBookmarked'] ?? false,
      createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  CampaignSummary _mapToCampaignSummary(Map<String, dynamic> data) {
    final endDate = DateTime.tryParse(data['endDate'] ?? '');
    final daysLeft = endDate != null
        ? endDate.difference(DateTime.now()).inDays
        : 0;

    return CampaignSummary(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      type: CampaignType.fromCode(data['type']),
      thumbnailImage: data['thumbnailImage'],
      targetAmount: data['targetAmount'] ?? 0,
      currentAmount: data['currentAmount'] ?? 0,
      daysLeft: daysLeft.clamp(0, 999),
      isParticipating: data['isParticipating'] ?? false,
    );
  }

  CampaignEntity _mapToCampaignEntity(Map<String, dynamic> data) {
    return CampaignEntity(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      type: CampaignType.fromCode(data['type']),
      organizerId: data['organizerId'] ?? '',
      organizerName: data['organizerName'] ?? '',
      organizerImage: data['organizerImage'],
      thumbnailImage: data['thumbnailImage'],
      images: List<String>.from(data['images'] ?? []),
      targetAmount: data['targetAmount'] ?? 0,
      currentAmount: data['currentAmount'] ?? 0,
      participantCount: data['participantCount'] ?? 0,
      startDate: DateTime.parse(data['startDate'] ?? DateTime.now().toIso8601String()),
      endDate: DateTime.parse(data['endDate'] ?? DateTime.now().toIso8601String()),
      location: data['location'],
      isParticipating: data['isParticipating'] ?? false,
      createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  EventEntity _mapToEventEntity(Map<String, dynamic> data) {
    return EventEntity(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      description: data['description'],
      category: EventCategory.fromCode(data['category']),
      date: DateTime.parse(data['date']),
      endDate: data['endDate'] != null ? DateTime.parse(data['endDate']) : null,
      time: data['time'],
      location: data['location'],
      idolId: data['idolId'],
      idolName: data['idolName'],
      imageUrl: data['imageUrl'],
      price: data['price'],
      isAllDay: data['isAllDay'] ?? false,
      hasReminder: data['hasReminder'] ?? false,
      createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  // ============ Utilities ============

  Future<void> _simulateNetworkDelay({int ms = 300}) async {
    await Future.delayed(Duration(milliseconds: ms));
  }
}

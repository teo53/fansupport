import 'package:twitter_login/twitter_login.dart';
import 'package:dio/dio.dart';
import '../../shared/models/idol_model.dart';

/// 트위터 프로필 데이터
class TwitterProfileData {
  final String userId;
  final String username;
  final String name;
  final String bio;
  final String profileImageUrl;
  final String? headerImageUrl;
  final int followersCount;
  final int followingCount;
  final int tweetCount;
  final String? website;
  final String? location;
  final DateTime createdAt;
  final bool verified;

  TwitterProfileData({
    required this.userId,
    required this.username,
    required this.name,
    required this.bio,
    required this.profileImageUrl,
    this.headerImageUrl,
    required this.followersCount,
    required this.followingCount,
    required this.tweetCount,
    this.website,
    this.location,
    required this.createdAt,
    this.verified = false,
  });

  factory TwitterProfileData.fromJson(Map<String, dynamic> json) {
    return TwitterProfileData(
      userId: json['id'] as String,
      username: json['username'] as String,
      name: json['name'] as String,
      bio: json['description'] as String? ?? '',
      profileImageUrl: (json['profile_image_url'] as String?)
              ?.replaceAll('_normal', '_400x400') ??
          '',
      headerImageUrl: json['profile_banner_url'] as String?,
      followersCount: json['public_metrics']?['followers_count'] as int? ?? 0,
      followingCount: json['public_metrics']?['following_count'] as int? ?? 0,
      tweetCount: json['public_metrics']?['tweet_count'] as int? ?? 0,
      website: json['entities']?['url']?['urls']?[0]?['expanded_url'] as String?,
      location: json['location'] as String?,
      createdAt: DateTime.parse(
          json['created_at'] as String? ?? DateTime.now().toIso8601String()),
      verified: json['verified'] as bool? ?? false,
    );
  }
}

/// 트위터 트윗 데이터
class TwitterTweetData {
  final String id;
  final String text;
  final DateTime createdAt;
  final List<String> mediaUrls;
  final int likeCount;
  final int retweetCount;
  final int replyCount;

  TwitterTweetData({
    required this.id,
    required this.text,
    required this.createdAt,
    this.mediaUrls = const [],
    this.likeCount = 0,
    this.retweetCount = 0,
    this.replyCount = 0,
  });

  factory TwitterTweetData.fromJson(Map<String, dynamic> json) {
    final media = json['attachments']?['media_keys'] as List<dynamic>?;
    final mediaUrls = <String>[];

    // Extract media URLs if available
    if (json['includes']?['media'] != null) {
      for (var mediaItem in json['includes']['media']) {
        if (mediaItem['url'] != null) {
          mediaUrls.add(mediaItem['url'] as String);
        } else if (mediaItem['preview_image_url'] != null) {
          mediaUrls.add(mediaItem['preview_image_url'] as String);
        }
      }
    }

    return TwitterTweetData(
      id: json['id'] as String,
      text: json['text'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      mediaUrls: mediaUrls,
      likeCount: json['public_metrics']?['like_count'] as int? ?? 0,
      retweetCount: json['public_metrics']?['retweet_count'] as int? ?? 0,
      replyCount: json['public_metrics']?['reply_count'] as int? ?? 0,
    );
  }
}

/// 트위터 임포트 결과
class TwitterImportResult {
  final TwitterProfileData profile;
  final List<String> galleryImages;
  final List<TwitterTweetData> tweets;

  TwitterImportResult({
    required this.profile,
    this.galleryImages = const [],
    this.tweets = const [],
  });
}

/// 트위터 임포트 서비스
class TwitterImportService {
  final Dio _dio = Dio();

  // TODO: 환경 변수로 관리
  static const String _apiKey = 'YOUR_TWITTER_API_KEY';
  static const String _apiSecret = 'YOUR_TWITTER_API_SECRET';
  static const String _redirectUri = 'fansupport://twitter-callback';

  /// 트위터 OAuth 로그인
  Future<TwitterLoginResult?> login() async {
    try {
      final twitterLogin = TwitterLogin(
        apiKey: _apiKey,
        apiSecretKey: _apiSecret,
        redirectURI: _redirectUri,
      );

      final authResult = await twitterLogin.login();

      if (authResult.status == TwitterLoginStatus.loggedIn) {
        return authResult;
      }

      return null;
    } catch (e) {
      print('Twitter login error: $e');
      return null;
    }
  }

  /// 프로필 데이터 가져오기
  Future<TwitterProfileData?> getProfile(String userId, String accessToken) async {
    try {
      final response = await _dio.get(
        'https://api.twitter.com/2/users/$userId',
        queryParameters: {
          'user.fields':
              'created_at,description,entities,location,profile_image_url,public_metrics,url,verified',
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      return TwitterProfileData.fromJson(response.data['data']);
    } catch (e) {
      print('Error fetching Twitter profile: $e');
      return null;
    }
  }

  /// 최근 미디어 트윗 가져오기 (갤러리용)
  Future<List<String>> getRecentMedia(String userId, String accessToken, {int limit = 20}) async {
    try {
      final response = await _dio.get(
        'https://api.twitter.com/2/users/$userId/tweets',
        queryParameters: {
          'max_results': limit,
          'tweet.fields': 'attachments,created_at',
          'expansions': 'attachments.media_keys',
          'media.fields': 'url,preview_image_url',
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      final mediaUrls = <String>[];
      final tweets = response.data['data'] as List<dynamic>? ?? [];
      final mediaList = response.data['includes']?['media'] as List<dynamic>? ?? [];

      for (var media in mediaList) {
        if (media['type'] == 'photo' && media['url'] != null) {
          mediaUrls.add(media['url'] as String);
        } else if (media['type'] == 'video' && media['preview_image_url'] != null) {
          mediaUrls.add(media['preview_image_url'] as String);
        }
      }

      return mediaUrls.take(limit).toList();
    } catch (e) {
      print('Error fetching Twitter media: $e');
      return [];
    }
  }

  /// 최근 트윗 가져오기 (피드로 이식)
  Future<List<TwitterTweetData>> getRecentTweets(
      String userId, String accessToken, {int limit = 50}) async {
    try {
      final response = await _dio.get(
        'https://api.twitter.com/2/users/$userId/tweets',
        queryParameters: {
          'max_results': limit,
          'tweet.fields': 'created_at,public_metrics',
          'expansions': 'attachments.media_keys',
          'media.fields': 'url,preview_image_url',
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      final tweets = response.data['data'] as List<dynamic>? ?? [];
      return tweets.map((tweet) => TwitterTweetData.fromJson(tweet)).toList();
    } catch (e) {
      print('Error fetching Twitter tweets: $e');
      return [];
    }
  }

  /// 전체 임포트 프로세스
  Future<TwitterImportResult?> importFromTwitter() async {
    try {
      // 1. OAuth 로그인
      final authResult = await login();
      if (authResult == null || authResult.authToken == null) {
        return null;
      }

      final userId = authResult.user?.id ?? '';
      final accessToken = authResult.authToken!;

      // 2. 프로필 가져오기
      final profile = await getProfile(userId, accessToken);
      if (profile == null) {
        return null;
      }

      // 3. 미디어 가져오기
      final galleryImages = await getRecentMedia(userId, accessToken, limit: 20);

      // 4. 트윗 가져오기
      final tweets = await getRecentTweets(userId, accessToken, limit: 50);

      return TwitterImportResult(
        profile: profile,
        galleryImages: galleryImages,
        tweets: tweets,
      );
    } catch (e) {
      print('Error importing from Twitter: $e');
      return null;
    }
  }

  /// 트위터에 마이그레이션 공지 트윗 포스팅
  Future<bool> postMigrationAnnouncement(
    String accessToken,
    String idolName,
    String appDownloadUrl,
  ) async {
    try {
      final message = '''
안녕하세요! 이제 팬서포트 앱에서 활동합니다 🎉

✨ 앱에서만 제공하는 혜택
• 독점 사진/영상 콘텐츠
• 1:1 버블 메시지
• 직접 후원하기
• 특별 이벤트 참여

📱 앱 다운로드
$appDownloadUrl

앱에서 더 가까이 소통해요! 💕

#팬서포트 #$idolName
''';

      await _dio.post(
        'https://api.twitter.com/2/tweets',
        data: {'text': message},
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      return true;
    } catch (e) {
      print('Error posting migration announcement: $e');
      return false;
    }
  }
}

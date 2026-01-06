import 'package:equatable/equatable.dart';

/// 게시물 소스 유형
enum PostSource {
  native('NATIVE'), // 앱에서 직접 작성
  twitterImport('TWITTER_IMPORT'), // 트위터에서 이식
  instagramImport('INSTAGRAM_IMPORT'); // 인스타그램에서 이식

  final String code;
  const PostSource(this.code);

  static PostSource fromCode(String code) {
    return PostSource.values.firstWhere(
      (e) => e.code == code,
      orElse: () => PostSource.native,
    );
  }
}

/// 커뮤니티 게시물 모델
class PostModel extends Equatable {
  final String id;
  final String authorId;
  final String? authorName;
  final String? authorProfileImage;
  final bool? authorIsVerified;
  final String content;
  final List<String> images;
  final PostSource source;
  final String? originalPostUrl; // 원본 트윗/포스트 URL
  final DateTime originalCreatedAt; // 원본 게시물 작성 시간
  final bool isSubscriberOnly;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final bool isLiked;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const PostModel({
    required this.id,
    required this.authorId,
    this.authorName,
    this.authorProfileImage,
    this.authorIsVerified,
    required this.content,
    this.images = const [],
    this.source = PostSource.native,
    this.originalPostUrl,
    required this.originalCreatedAt,
    this.isSubscriberOnly = false,
    this.likeCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    this.isLiked = false,
    required this.createdAt,
    this.updatedAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String,
      authorId: json['authorId'] as String,
      authorName: json['author']?['nickname'] as String?,
      authorProfileImage: json['author']?['profileImage'] as String?,
      authorIsVerified: json['author']?['isVerified'] as bool?,
      content: json['content'] as String,
      images: List<String>.from(json['images'] ?? []),
      source: PostSource.fromCode(json['source'] as String? ?? 'NATIVE'),
      originalPostUrl: json['originalPostUrl'] as String?,
      originalCreatedAt: DateTime.parse(
        json['originalCreatedAt'] as String? ??
        json['createdAt'] as String? ??
        DateTime.now().toIso8601String()
      ),
      isSubscriberOnly: json['isSubscriberOnly'] as bool? ?? false,
      likeCount: json['likeCount'] as int? ?? 0,
      commentCount: json['commentCount'] as int? ?? 0,
      shareCount: json['shareCount'] as int? ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      createdAt: DateTime.parse(
        json['createdAt'] as String? ?? DateTime.now().toIso8601String()
      ),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorId': authorId,
      'content': content,
      'images': images,
      'source': source.code,
      'originalPostUrl': originalPostUrl,
      'originalCreatedAt': originalCreatedAt.toIso8601String(),
      'isSubscriberOnly': isSubscriberOnly,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'shareCount': shareCount,
      'isLiked': isLiked,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  PostModel copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? authorProfileImage,
    bool? authorIsVerified,
    String? content,
    List<String>? images,
    PostSource? source,
    String? originalPostUrl,
    DateTime? originalCreatedAt,
    bool? isSubscriberOnly,
    int? likeCount,
    int? commentCount,
    int? shareCount,
    bool? isLiked,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PostModel(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorProfileImage: authorProfileImage ?? this.authorProfileImage,
      authorIsVerified: authorIsVerified ?? this.authorIsVerified,
      content: content ?? this.content,
      images: images ?? this.images,
      source: source ?? this.source,
      originalPostUrl: originalPostUrl ?? this.originalPostUrl,
      originalCreatedAt: originalCreatedAt ?? this.originalCreatedAt,
      isSubscriberOnly: isSubscriberOnly ?? this.isSubscriberOnly,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      shareCount: shareCount ?? this.shareCount,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        authorId,
        content,
        source,
        originalCreatedAt,
        createdAt,
      ];
}

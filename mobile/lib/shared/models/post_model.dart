/// 📝 Post 모델
/// 지하돌 문화 게시글 시스템
library;

import 'package:flutter/foundation.dart';
import 'post_type.dart';

/// 게시글 작성자 정보
class PostAuthor {
  final String id;
  final String name;
  final String? profileImage;
  final bool isVerified;
  final bool isCreator; // 크리에이터(아이돌) 계정 여부

  const PostAuthor({
    required this.id,
    required this.name,
    this.profileImage,
    this.isVerified = false,
    this.isCreator = false,
  });

  factory PostAuthor.fromJson(Map<String, dynamic> json) {
    return PostAuthor(
      id: json['id'] as String,
      name: json['name'] as String,
      profileImage: json['profileImage'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
      isCreator: json['isCreator'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profileImage': profileImage,
      'isVerified': isVerified,
      'isCreator': isCreator,
    };
  }
}

/// 게시글 모델
class Post {
  final String id;
  final PostAuthor author;
  final PostType type;
  final String content;
  final List<String> images;

  /// 정산 관련
  final bool hasCreatorReply; // 아이돌 답글 여부
  final DateTime? creatorRepliedAt; // 답글 단 시간
  final DateTime? performanceDate; // 공연 날짜 (정산용)

  /// 구독 관련
  final bool isSubscriberOnly; // 구독자 전용 여부

  /// 통계
  final int likeCount;
  final int commentCount;
  final int viewCount;

  /// 상호작용
  final bool isLiked;
  final bool isBookmarked;

  /// 시간
  final DateTime createdAt;
  final DateTime? updatedAt;

  /// 태그
  final List<String> tags;

  const Post({
    required this.id,
    required this.author,
    required this.type,
    required this.content,
    this.images = const [],
    this.hasCreatorReply = false,
    this.creatorRepliedAt,
    this.performanceDate,
    this.isSubscriberOnly = false,
    this.likeCount = 0,
    this.commentCount = 0,
    this.viewCount = 0,
    this.isLiked = false,
    this.isBookmarked = false,
    required this.createdAt,
    this.updatedAt,
    this.tags = const [],
  });

  /// JSON에서 생성
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String,
      author: PostAuthor.fromJson(json['author'] as Map<String, dynamic>),
      type: PostTypeUtils.fromString(json['type'] as String?) ?? PostType.general,
      content: json['content'] as String,
      images: (json['images'] as List<dynamic>?)?.cast<String>() ?? [],
      hasCreatorReply: json['hasCreatorReply'] as bool? ?? false,
      creatorRepliedAt: json['creatorRepliedAt'] != null
          ? DateTime.parse(json['creatorRepliedAt'] as String)
          : null,
      performanceDate: json['performanceDate'] != null
          ? DateTime.parse(json['performanceDate'] as String)
          : null,
      isSubscriberOnly: json['isSubscriberOnly'] as bool? ?? false,
      likeCount: json['likeCount'] as int? ?? 0,
      commentCount: json['commentCount'] as int? ?? 0,
      viewCount: json['viewCount'] as int? ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      isBookmarked: json['isBookmarked'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author': author.toJson(),
      'type': PostTypeUtils.toJson(type),
      'content': content,
      'images': images,
      'hasCreatorReply': hasCreatorReply,
      'creatorRepliedAt': creatorRepliedAt?.toIso8601String(),
      'performanceDate': performanceDate?.toIso8601String(),
      'isSubscriberOnly': isSubscriberOnly,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'viewCount': viewCount,
      'isLiked': isLiked,
      'isBookmarked': isBookmarked,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'tags': tags,
    };
  }

  /// 복사 생성
  Post copyWith({
    String? id,
    PostAuthor? author,
    PostType? type,
    String? content,
    List<String>? images,
    bool? hasCreatorReply,
    DateTime? creatorRepliedAt,
    DateTime? performanceDate,
    bool? isSubscriberOnly,
    int? likeCount,
    int? commentCount,
    int? viewCount,
    bool? isLiked,
    bool? isBookmarked,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
  }) {
    return Post(
      id: id ?? this.id,
      author: author ?? this.author,
      type: type ?? this.type,
      content: content ?? this.content,
      images: images ?? this.images,
      hasCreatorReply: hasCreatorReply ?? this.hasCreatorReply,
      creatorRepliedAt: creatorRepliedAt ?? this.creatorRepliedAt,
      performanceDate: performanceDate ?? this.performanceDate,
      isSubscriberOnly: isSubscriberOnly ?? this.isSubscriberOnly,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      viewCount: viewCount ?? this.viewCount,
      isLiked: isLiked ?? this.isLiked,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
    );
  }

  /// 정산 타입인지
  bool get isCheki => type == PostType.cheki || type == PostType.hiddenCheki;

  /// 답글이 필요한지
  bool get needsCreatorReply => type.requiresCreatorReply && !hasCreatorReply;

  /// 정산이 지연되었는지 (24시간 이상)
  bool get isChekiOverdue {
    if (!isCheki || hasCreatorReply) return false;

    final diff = DateTime.now().difference(createdAt);
    return diff.inHours >= 24;
  }

  /// 정산이 긴급한지 (12시간 이상)
  bool get isChekiUrgent {
    if (!isCheki || hasCreatorReply) return false;

    final diff = DateTime.now().difference(createdAt);
    return diff.inHours >= 12;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Post && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Post(id: $id, type: ${type.displayName}, author: ${author.name}, hasReply: $hasCreatorReply)';
  }
}

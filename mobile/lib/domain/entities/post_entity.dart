import 'package:flutter/foundation.dart';

/// 게시물 타입
enum PostType {
  text,
  image,
  video,
  poll,
}

/// 게시물 엔티티
@immutable
class PostEntity {
  final String id;
  final PostAuthor author;
  final String content;
  final PostType type;
  final List<String> images;
  final String? videoUrl;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final int viewCount;
  final bool isLiked;
  final bool isBookmarked;
  final bool isReposted;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const PostEntity({
    required this.id,
    required this.author,
    required this.content,
    this.type = PostType.text,
    this.images = const [],
    this.videoUrl,
    this.likeCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    this.viewCount = 0,
    this.isLiked = false,
    this.isBookmarked = false,
    this.isReposted = false,
    required this.createdAt,
    this.updatedAt,
  });

  PostEntity copyWith({
    String? id,
    PostAuthor? author,
    String? content,
    PostType? type,
    List<String>? images,
    String? videoUrl,
    int? likeCount,
    int? commentCount,
    int? shareCount,
    int? viewCount,
    bool? isLiked,
    bool? isBookmarked,
    bool? isReposted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PostEntity(
      id: id ?? this.id,
      author: author ?? this.author,
      content: content ?? this.content,
      type: type ?? this.type,
      images: images ?? this.images,
      videoUrl: videoUrl ?? this.videoUrl,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      shareCount: shareCount ?? this.shareCount,
      viewCount: viewCount ?? this.viewCount,
      isLiked: isLiked ?? this.isLiked,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isReposted: isReposted ?? this.isReposted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 좋아요 토글
  PostEntity toggleLike() {
    return copyWith(
      isLiked: !isLiked,
      likeCount: isLiked ? likeCount - 1 : likeCount + 1,
    );
  }

  /// 북마크 토글
  PostEntity toggleBookmark() {
    return copyWith(isBookmarked: !isBookmarked);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'PostEntity(id: $id, author: ${author.name})';
}

/// 게시물 작성자
@immutable
class PostAuthor {
  final String id;
  final String name;
  final String? username;
  final String? profileImage;
  final bool isVerified;
  final bool isIdol;

  const PostAuthor({
    required this.id,
    required this.name,
    this.username,
    this.profileImage,
    this.isVerified = false,
    this.isIdol = false,
  });

  PostAuthor copyWith({
    String? id,
    String? name,
    String? username,
    String? profileImage,
    bool? isVerified,
    bool? isIdol,
  }) {
    return PostAuthor(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      profileImage: profileImage ?? this.profileImage,
      isVerified: isVerified ?? this.isVerified,
      isIdol: isIdol ?? this.isIdol,
    );
  }
}

/// 댓글 엔티티
@immutable
class CommentEntity {
  final String id;
  final String postId;
  final PostAuthor author;
  final String content;
  final int likeCount;
  final int replyCount;
  final bool isLiked;
  final String? parentId;
  final DateTime createdAt;

  const CommentEntity({
    required this.id,
    required this.postId,
    required this.author,
    required this.content,
    this.likeCount = 0,
    this.replyCount = 0,
    this.isLiked = false,
    this.parentId,
    required this.createdAt,
  });

  bool get isReply => parentId != null;

  CommentEntity copyWith({
    String? id,
    String? postId,
    PostAuthor? author,
    String? content,
    int? likeCount,
    int? replyCount,
    bool? isLiked,
    String? parentId,
    DateTime? createdAt,
  }) {
    return CommentEntity(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      author: author ?? this.author,
      content: content ?? this.content,
      likeCount: likeCount ?? this.likeCount,
      replyCount: replyCount ?? this.replyCount,
      isLiked: isLiked ?? this.isLiked,
      parentId: parentId ?? this.parentId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  CommentEntity toggleLike() {
    return copyWith(
      isLiked: !isLiked,
      likeCount: isLiked ? likeCount - 1 : likeCount + 1,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommentEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

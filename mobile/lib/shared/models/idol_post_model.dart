/// 아이돌 게시물 모델
/// 공감, 스크랩, 조회수 등 포함

enum PostType {
  text,
  image,
  video,
  voice,
  poll,
  story, // 24시간 후 사라지는 스토리
}

enum PostVisibility {
  public, // 모든 팬
  subscribers, // 구독자 전용
  premium, // 프리미엄 구독자 전용
  vip, // VIP 구독자 전용
}

class IdolPost {
  final String id;
  final String idolId;
  final String idolName;
  final String idolProfileImage;
  final bool isIdolVerified;
  final PostType type;
  final PostVisibility visibility;
  final String content;
  final List<String>? mediaUrls;
  final String? thumbnailUrl;
  final int? videoDuration; // seconds
  final int? voiceDuration; // seconds
  final DateTime createdAt;
  final DateTime? expiresAt; // for story

  // 통계
  final int viewCount;
  final int likeCount;
  final int commentCount;
  final int bookmarkCount;
  final int shareCount;

  // 사용자 상호작용 상태
  final bool isLiked;
  final bool isBookmarked;
  final bool isViewed;

  // 투표 관련
  final List<PollOption>? pollOptions;
  final DateTime? pollExpiresAt;
  final bool hasPollVoted;

  // 댓글 미리보기
  final List<PostComment>? previewComments;

  IdolPost({
    required this.id,
    required this.idolId,
    required this.idolName,
    required this.idolProfileImage,
    this.isIdolVerified = true,
    required this.type,
    this.visibility = PostVisibility.public,
    required this.content,
    this.mediaUrls,
    this.thumbnailUrl,
    this.videoDuration,
    this.voiceDuration,
    required this.createdAt,
    this.expiresAt,
    this.viewCount = 0,
    this.likeCount = 0,
    this.commentCount = 0,
    this.bookmarkCount = 0,
    this.shareCount = 0,
    this.isLiked = false,
    this.isBookmarked = false,
    this.isViewed = false,
    this.pollOptions,
    this.pollExpiresAt,
    this.hasPollVoted = false,
    this.previewComments,
  });

  bool get isStory => type == PostType.story;
  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
  bool get isPoll => type == PostType.poll;

  String get visibilityLabel {
    switch (visibility) {
      case PostVisibility.public:
        return '전체 공개';
      case PostVisibility.subscribers:
        return '구독자 전용';
      case PostVisibility.premium:
        return '프리미엄 전용';
      case PostVisibility.vip:
        return 'VIP 전용';
    }
  }

  String get visibilityIcon {
    switch (visibility) {
      case PostVisibility.public:
        return '🌍';
      case PostVisibility.subscribers:
        return '💎';
      case PostVisibility.premium:
        return '⭐';
      case PostVisibility.vip:
        return '👑';
    }
  }

  double get engagementRate {
    if (viewCount == 0) return 0;
    return (likeCount + commentCount + bookmarkCount + shareCount) / viewCount * 100;
  }

  IdolPost copyWith({
    String? id,
    String? idolId,
    String? idolName,
    String? idolProfileImage,
    bool? isIdolVerified,
    PostType? type,
    PostVisibility? visibility,
    String? content,
    List<String>? mediaUrls,
    String? thumbnailUrl,
    int? videoDuration,
    int? voiceDuration,
    DateTime? createdAt,
    DateTime? expiresAt,
    int? viewCount,
    int? likeCount,
    int? commentCount,
    int? bookmarkCount,
    int? shareCount,
    bool? isLiked,
    bool? isBookmarked,
    bool? isViewed,
    List<PollOption>? pollOptions,
    DateTime? pollExpiresAt,
    bool? hasPollVoted,
    List<PostComment>? previewComments,
  }) {
    return IdolPost(
      id: id ?? this.id,
      idolId: idolId ?? this.idolId,
      idolName: idolName ?? this.idolName,
      idolProfileImage: idolProfileImage ?? this.idolProfileImage,
      isIdolVerified: isIdolVerified ?? this.isIdolVerified,
      type: type ?? this.type,
      visibility: visibility ?? this.visibility,
      content: content ?? this.content,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      videoDuration: videoDuration ?? this.videoDuration,
      voiceDuration: voiceDuration ?? this.voiceDuration,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      bookmarkCount: bookmarkCount ?? this.bookmarkCount,
      shareCount: shareCount ?? this.shareCount,
      isLiked: isLiked ?? this.isLiked,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isViewed: isViewed ?? this.isViewed,
      pollOptions: pollOptions ?? this.pollOptions,
      pollExpiresAt: pollExpiresAt ?? this.pollExpiresAt,
      hasPollVoted: hasPollVoted ?? this.hasPollVoted,
      previewComments: previewComments ?? this.previewComments,
    );
  }
}

class PollOption {
  final String id;
  final String text;
  final int voteCount;
  final double votePercentage;
  final bool isSelected;

  PollOption({
    required this.id,
    required this.text,
    this.voteCount = 0,
    this.votePercentage = 0.0,
    this.isSelected = false,
  });
}

class PostComment {
  final String id;
  final String postId;
  final String userId;
  final String userName;
  final String? userProfileImage;
  final bool isIdolComment; // 아이돌이 작성한 댓글인지
  final String content;
  final DateTime createdAt;
  final int likeCount;
  final bool isLiked;
  final String? replyToId;
  final String? replyToUserName;

  PostComment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    this.userProfileImage,
    this.isIdolComment = false,
    required this.content,
    required this.createdAt,
    this.likeCount = 0,
    this.isLiked = false,
    this.replyToId,
    this.replyToUserName,
  });
}

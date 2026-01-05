/// 📰 활동 피드 모델
/// 아이돌의 최근 활동을 표시하기 위한 통합 피드
class ActivityFeedItem {
  final String id;
  final String idolId;
  final String idolName;
  final String? idolProfileImage;
  final ActivityType type;
  final String title;
  final String? content;
  final String? thumbnailUrl;
  final DateTime createdAt;
  final int likeCount;
  final int commentCount;
  final bool isLive;

  const ActivityFeedItem({
    required this.id,
    required this.idolId,
    required this.idolName,
    this.idolProfileImage,
    required this.type,
    required this.title,
    this.content,
    this.thumbnailUrl,
    required this.createdAt,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLive = false,
  });
}

/// 활동 타입
enum ActivityType {
  post, // 일반 게시글
  photo, // 사진 게시
  video, // 영상 업로드
  live, // 라이브 방송
  event, // 이벤트 등록
  bubble, // 버블 메시지
  announcement, // 공지사항
}

extension ActivityTypeExtension on ActivityType {
  String get displayName {
    switch (this) {
      case ActivityType.post:
        return '게시글';
      case ActivityType.photo:
        return '사진';
      case ActivityType.video:
        return '영상';
      case ActivityType.live:
        return '라이브';
      case ActivityType.event:
        return '이벤트';
      case ActivityType.bubble:
        return '버블';
      case ActivityType.announcement:
        return '공지';
    }
  }

  String get icon {
    switch (this) {
      case ActivityType.post:
        return '📝';
      case ActivityType.photo:
        return '📷';
      case ActivityType.video:
        return '🎬';
      case ActivityType.live:
        return '🔴';
      case ActivityType.event:
        return '🎉';
      case ActivityType.bubble:
        return '💬';
      case ActivityType.announcement:
        return '📢';
    }
  }

  String get actionText {
    switch (this) {
      case ActivityType.post:
        return '님이 새 글을 작성했어요';
      case ActivityType.photo:
        return '님이 사진을 올렸어요';
      case ActivityType.video:
        return '님이 영상을 업로드했어요';
      case ActivityType.live:
        return '님이 라이브 방송 중이에요';
      case ActivityType.event:
        return '님이 이벤트를 등록했어요';
      case ActivityType.bubble:
        return '님의 새로운 버블 메시지';
      case ActivityType.announcement:
        return '님의 중요 공지';
    }
  }
}

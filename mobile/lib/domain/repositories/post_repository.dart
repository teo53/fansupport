import '../../core/errors/result.dart';
import '../entities/post_entity.dart';

/// 게시물 Repository 인터페이스
abstract class PostRepository {
  /// 피드 조회
  Future<Result<List<PostEntity>>> getFeed({
    FeedType type = FeedType.all,
    int page = 1,
    int limit = 20,
  });

  /// 게시물 상세 조회
  Future<Result<PostEntity>> getPostById(String id);

  /// 사용자 게시물 조회
  Future<Result<List<PostEntity>>> getUserPosts({
    required String userId,
    int page = 1,
    int limit = 20,
  });

  /// 아이돌 게시물 조회
  Future<Result<List<PostEntity>>> getIdolPosts({
    required String idolId,
    int page = 1,
    int limit = 20,
  });

  /// 게시물 작성
  Future<Result<PostEntity>> createPost({
    required String content,
    List<String>? images,
    String? videoUrl,
  });

  /// 게시물 수정
  Future<Result<PostEntity>> updatePost({
    required String id,
    required String content,
    List<String>? images,
  });

  /// 게시물 삭제
  Future<Result<void>> deletePost(String id);

  /// 좋아요
  Future<Result<PostEntity>> likePost(String id);

  /// 좋아요 취소
  Future<Result<PostEntity>> unlikePost(String id);

  /// 북마크
  Future<Result<PostEntity>> bookmarkPost(String id);

  /// 북마크 취소
  Future<Result<PostEntity>> unbookmarkPost(String id);

  /// 북마크한 게시물 조회
  Future<Result<List<PostEntity>>> getBookmarkedPosts({
    int page = 1,
    int limit = 20,
  });

  /// 댓글 목록 조회
  Future<Result<List<CommentEntity>>> getComments({
    required String postId,
    int page = 1,
    int limit = 20,
  });

  /// 댓글 작성
  Future<Result<CommentEntity>> createComment({
    required String postId,
    required String content,
    String? parentId,
  });

  /// 댓글 삭제
  Future<Result<void>> deleteComment(String commentId);

  /// 댓글 좋아요
  Future<Result<CommentEntity>> likeComment(String commentId);

  /// 게시물 신고
  Future<Result<void>> reportPost({
    required String postId,
    required String reason,
  });
}

/// 피드 타입
enum FeedType {
  all,        // 전체 피드
  following,  // 팔로잉 피드
  popular,    // 인기 피드
}

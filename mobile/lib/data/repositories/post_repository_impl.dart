import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/result.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/repositories/post_repository.dart';
import '../datasources/local_datasource.dart';

/// PostRepository 구현체
class PostRepositoryImpl implements PostRepository {
  final LocalDataSource _dataSource;

  PostRepositoryImpl(this._dataSource);

  @override
  Future<Result<List<PostEntity>>> getFeed({
    FeedType type = FeedType.all,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final posts = await _dataSource.getPosts(page: page, limit: limit);
      return Success(posts);
    } catch (e) {
      return Fail(_mapException(e));
    }
  }

  @override
  Future<Result<PostEntity>> getPostById(String id) async {
    try {
      final post = await _dataSource.getPostById(id);
      return Success(post);
    } catch (e) {
      return Fail(_mapException(e, '게시물을 불러올 수 없습니다'));
    }
  }

  @override
  Future<Result<List<PostEntity>>> getUserPosts({
    required String userId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final allPosts = await _dataSource.getPosts(page: page, limit: limit);
      // 사용자 ID로 필터링
      final userPosts = allPosts.where((p) => p.author.id == userId).toList();
      return Success(userPosts);
    } catch (e) {
      return Fail(_mapException(e));
    }
  }

  @override
  Future<Result<List<PostEntity>>> getIdolPosts({
    required String idolId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final allPosts = await _dataSource.getPosts(page: page, limit: limit);
      // 아이돌 ID로 필터링 (isIdol이 true인 게시물)
      final idolPosts = allPosts.where((p) =>
        p.author.id == idolId || p.author.isIdol
      ).toList();
      return Success(idolPosts);
    } catch (e) {
      return Fail(_mapException(e));
    }
  }

  @override
  Future<Result<PostEntity>> createPost({
    required String content,
    List<String>? images,
    String? videoUrl,
  }) async {
    // Demo: 새 게시물 생성 시뮬레이션
    await Future.delayed(UIConstants.mockDelay);

    final newPost = PostEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      author: PostAuthor(
        id: DemoCredentials.userId,
        name: DemoCredentials.nickname,
        profileImage: AvatarUrls.generate('demouser'),
      ),
      content: content,
      images: images ?? [],
      createdAt: DateTime.now(),
    );

    return Success(newPost);
  }

  @override
  Future<Result<PostEntity>> updatePost({
    required String id,
    required String content,
    List<String>? images,
  }) async {
    try {
      final post = await _dataSource.getPostById(id);
      return Success(post.copyWith(
        content: content,
        images: images,
        updatedAt: DateTime.now(),
      ));
    } catch (e) {
      return Fail(_mapException(e, '게시물 수정에 실패했습니다'));
    }
  }

  @override
  Future<Result<void>> deletePost(String id) async {
    await Future.delayed(UIConstants.mockDelay);
    return const Success(null);
  }

  @override
  Future<Result<PostEntity>> likePost(String id) async {
    try {
      final post = await _dataSource.toggleLikePost(id);
      return Success(post);
    } catch (e) {
      return Fail(_mapException(e, '좋아요에 실패했습니다'));
    }
  }

  @override
  Future<Result<PostEntity>> unlikePost(String id) async {
    try {
      final post = await _dataSource.toggleLikePost(id);
      return Success(post);
    } catch (e) {
      return Fail(_mapException(e, '좋아요 취소에 실패했습니다'));
    }
  }

  @override
  Future<Result<PostEntity>> bookmarkPost(String id) async {
    try {
      final post = await _dataSource.toggleBookmarkPost(id);
      return Success(post);
    } catch (e) {
      return Fail(_mapException(e, '북마크에 실패했습니다'));
    }
  }

  @override
  Future<Result<PostEntity>> unbookmarkPost(String id) async {
    try {
      final post = await _dataSource.toggleBookmarkPost(id);
      return Success(post);
    } catch (e) {
      return Fail(_mapException(e, '북마크 취소에 실패했습니다'));
    }
  }

  @override
  Future<Result<List<PostEntity>>> getBookmarkedPosts({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final posts = await _dataSource.getPosts(page: 1, limit: 5);
      // 북마크된 게시물만 필터링
      final bookmarked = posts.where((p) => p.isBookmarked).toList();
      return Success(bookmarked);
    } catch (e) {
      return Fail(_mapException(e));
    }
  }

  @override
  Future<Result<List<CommentEntity>>> getComments({
    required String postId,
    int page = 1,
    int limit = 20,
  }) async {
    // Demo: 댓글 목록 시뮬레이션
    await Future.delayed(UIConstants.mockDelay);

    final comments = List.generate(5, (i) => CommentEntity(
      id: 'comment_$i',
      postId: postId,
      author: PostAuthor(
        id: 'user_$i',
        name: '사용자 ${i + 1}',
        profileImage: AvatarUrls.generate('user$i'),
      ),
      content: '멋진 게시물이네요! 😊',
      likeCount: i * 3,
      replyCount: i,
      createdAt: DateTime.now().subtract(Duration(hours: i)),
    ));

    return Success(comments);
  }

  @override
  Future<Result<CommentEntity>> createComment({
    required String postId,
    required String content,
    String? parentId,
  }) async {
    await Future.delayed(UIConstants.mockDelay);

    final comment = CommentEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      postId: postId,
      author: PostAuthor(
        id: DemoCredentials.userId,
        name: DemoCredentials.nickname,
        profileImage: AvatarUrls.generate('demouser'),
      ),
      content: content,
      parentId: parentId,
      createdAt: DateTime.now(),
    );

    return Success(comment);
  }

  @override
  Future<Result<void>> deleteComment(String commentId) async {
    await Future.delayed(UIConstants.mockDelay);
    return const Success(null);
  }

  @override
  Future<Result<CommentEntity>> likeComment(String commentId) async {
    await Future.delayed(UIConstants.shortMockDelay);

    final comment = CommentEntity(
      id: commentId,
      postId: 'post_1',
      author: PostAuthor(
        id: 'user',
        name: '사용자',
        profileImage: AvatarUrls.generate('user'),
      ),
      content: '댓글 내용',
      isLiked: true,
      likeCount: 1,
      createdAt: DateTime.now(),
    );

    return Success(comment);
  }

  @override
  Future<Result<void>> reportPost({
    required String postId,
    required String reason,
  }) async {
    await Future.delayed(UIConstants.mockDelay);
    return const Success(null);
  }

  /// 예외를 Failure로 변환
  Failure _mapException(dynamic e, [String? fallbackMessage]) {
    if (e is NetworkException) {
      return ServerFailure(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      );
    } else if (e is AuthException) {
      return AuthFailure(message: e.message, code: e.code);
    } else if (e is AppException) {
      return ServerFailure(message: e.message, code: e.code);
    }
    return ServerFailure(message: fallbackMessage ?? ErrorMessages.generic);
  }
}

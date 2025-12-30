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
      return Fail(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<PostEntity>> getPostById(String id) async {
    try {
      final post = await _dataSource.getPostById(id);
      return Success(post);
    } catch (e) {
      return Fail(ServerFailure(message: '게시물을 불러올 수 없습니다'));
    }
  }

  @override
  Future<Result<List<PostEntity>>> getUserPosts({
    required String userId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final posts = await _dataSource.getPosts(page: page, limit: limit);
      return Success(posts);
    } catch (e) {
      return Fail(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<List<PostEntity>>> getIdolPosts({
    required String idolId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final posts = await _dataSource.getPosts(page: page, limit: limit);
      return Success(posts);
    } catch (e) {
      return Fail(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<PostEntity>> createPost({
    required String content,
    List<String>? images,
    String? videoUrl,
  }) async {
    // Demo: 새 게시물 생성 시뮬레이션
    await Future.delayed(const Duration(milliseconds: 500));

    final newPost = PostEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      author: const PostAuthor(
        id: 'demo_user',
        name: '데모 유저',
        profileImage: 'https://picsum.photos/100',
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
      return Fail(ServerFailure(message: '게시물 수정에 실패했습니다'));
    }
  }

  @override
  Future<Result<void>> deletePost(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const Success(null);
  }

  @override
  Future<Result<PostEntity>> likePost(String id) async {
    try {
      final post = await _dataSource.toggleLikePost(id);
      return Success(post);
    } catch (e) {
      return Fail(ServerFailure(message: '좋아요에 실패했습니다'));
    }
  }

  @override
  Future<Result<PostEntity>> unlikePost(String id) async {
    try {
      final post = await _dataSource.toggleLikePost(id);
      return Success(post);
    } catch (e) {
      return Fail(ServerFailure(message: '좋아요 취소에 실패했습니다'));
    }
  }

  @override
  Future<Result<PostEntity>> bookmarkPost(String id) async {
    try {
      final post = await _dataSource.toggleBookmarkPost(id);
      return Success(post);
    } catch (e) {
      return Fail(ServerFailure(message: '북마크에 실패했습니다'));
    }
  }

  @override
  Future<Result<PostEntity>> unbookmarkPost(String id) async {
    try {
      final post = await _dataSource.toggleBookmarkPost(id);
      return Success(post);
    } catch (e) {
      return Fail(ServerFailure(message: '북마크 취소에 실패했습니다'));
    }
  }

  @override
  Future<Result<List<PostEntity>>> getBookmarkedPosts({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final posts = await _dataSource.getPosts(page: 1, limit: 5);
      return Success(posts);
    } catch (e) {
      return Fail(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<List<CommentEntity>>> getComments({
    required String postId,
    int page = 1,
    int limit = 20,
  }) async {
    // Demo: 댓글 목록 시뮬레이션
    await Future.delayed(const Duration(milliseconds: 300));

    final comments = List.generate(5, (i) => CommentEntity(
      id: 'comment_$i',
      postId: postId,
      author: PostAuthor(
        id: 'user_$i',
        name: '사용자 ${i + 1}',
        profileImage: 'https://picsum.photos/100?random=$i',
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
    await Future.delayed(const Duration(milliseconds: 300));

    final comment = CommentEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      postId: postId,
      author: const PostAuthor(
        id: 'demo_user',
        name: '데모 유저',
      ),
      content: content,
      parentId: parentId,
      createdAt: DateTime.now(),
    );

    return Success(comment);
  }

  @override
  Future<Result<void>> deleteComment(String commentId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const Success(null);
  }

  @override
  Future<Result<CommentEntity>> likeComment(String commentId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final comment = CommentEntity(
      id: commentId,
      postId: 'post_1',
      author: const PostAuthor(id: 'user', name: '사용자'),
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
    await Future.delayed(const Duration(milliseconds: 300));
    return const Success(null);
  }
}

import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/result.dart';
import '../../domain/entities/idol_entity.dart';
import '../../domain/repositories/idol_repository.dart';
import '../datasources/local_datasource.dart';

/// IdolRepository 구현체
class IdolRepositoryImpl implements IdolRepository {
  final LocalDataSource _dataSource;

  IdolRepositoryImpl(this._dataSource);

  @override
  Future<Result<List<IdolSummary>>> getIdols({
    IdolCategory? category,
    String? searchQuery,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final idols = await _dataSource.getIdols(
        category: category,
        searchQuery: searchQuery,
        page: page,
        limit: limit,
      );
      return Success(idols);
    } catch (e) {
      return Fail(_mapException(e));
    }
  }

  @override
  Future<Result<IdolEntity>> getIdolById(String id) async {
    try {
      final idol = await _dataSource.getIdolById(id);
      return Success(idol);
    } catch (e) {
      return Fail(_mapException(e, '아이돌 정보를 불러올 수 없습니다'));
    }
  }

  @override
  Future<Result<List<IdolSummary>>> getPopularIdols({int limit = 10}) async {
    try {
      final idols = await _dataSource.getIdols(limit: limit);
      return Success(idols);
    } catch (e) {
      return Fail(_mapException(e));
    }
  }

  @override
  Future<Result<IdolEntity>> followIdol(String id) async {
    try {
      final idol = await _dataSource.getIdolById(id);
      await Future.delayed(UIConstants.shortMockDelay);
      return Success(idol.copyWith(
        isFollowing: true,
        followerCount: idol.followerCount + 1,
      ));
    } catch (e) {
      return Fail(_mapException(e, '팔로우에 실패했습니다'));
    }
  }

  @override
  Future<Result<IdolEntity>> unfollowIdol(String id) async {
    try {
      final idol = await _dataSource.getIdolById(id);
      await Future.delayed(UIConstants.shortMockDelay);
      return Success(idol.copyWith(
        isFollowing: false,
        followerCount: (idol.followerCount - 1).clamp(0, idol.followerCount),
      ));
    } catch (e) {
      return Fail(_mapException(e, '언팔로우에 실패했습니다'));
    }
  }

  @override
  Future<Result<List<IdolSummary>>> getFollowingIdols({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      // Demo: 전체 아이돌 중 일부를 팔로잉으로 반환
      final allIdols = await _dataSource.getIdols(page: 1, limit: 5);
      return Success(allIdols);
    } catch (e) {
      return Fail(_mapException(e));
    }
  }

  @override
  Future<Result<List<IdolRanking>>> getIdolRanking({
    RankingType type = RankingType.weekly,
    IdolCategory? category,
    int limit = 100,
  }) async {
    try {
      final rankings = await _dataSource.getIdolRanking(limit: limit);
      return Success(rankings);
    } catch (e) {
      return Fail(_mapException(e));
    }
  }

  @override
  Future<Result<List<IdolSummary>>> searchIdols(String query) async {
    try {
      final idols = await _dataSource.getIdols(searchQuery: query);
      return Success(idols);
    } catch (e) {
      return Fail(_mapException(e));
    }
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

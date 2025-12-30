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
      return Fail(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<IdolEntity>> getIdolById(String id) async {
    try {
      final idol = await _dataSource.getIdolById(id);
      return Success(idol);
    } catch (e) {
      return Fail(ServerFailure(message: '아이돌 정보를 불러올 수 없습니다'));
    }
  }

  @override
  Future<Result<List<IdolSummary>>> getPopularIdols({int limit = 10}) async {
    try {
      final idols = await _dataSource.getIdols(limit: limit);
      return Success(idols);
    } catch (e) {
      return Fail(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<IdolEntity>> followIdol(String id) async {
    try {
      final idol = await _dataSource.getIdolById(id);
      return Success(idol.copyWith(
        isFollowing: true,
        followerCount: idol.followerCount + 1,
      ));
    } catch (e) {
      return Fail(ServerFailure(message: '팔로우에 실패했습니다'));
    }
  }

  @override
  Future<Result<IdolEntity>> unfollowIdol(String id) async {
    try {
      final idol = await _dataSource.getIdolById(id);
      return Success(idol.copyWith(
        isFollowing: false,
        followerCount: (idol.followerCount - 1).clamp(0, idol.followerCount),
      ));
    } catch (e) {
      return Fail(ServerFailure(message: '언팔로우에 실패했습니다'));
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
      return Fail(ServerFailure(message: e.toString()));
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
      return Fail(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<List<IdolSummary>>> searchIdols(String query) async {
    try {
      final idols = await _dataSource.getIdols(searchQuery: query);
      return Success(idols);
    } catch (e) {
      return Fail(ServerFailure(message: e.toString()));
    }
  }
}

import '../../core/errors/result.dart';
import '../entities/idol_entity.dart';

/// 아이돌 Repository 인터페이스
abstract class IdolRepository {
  /// 아이돌 목록 조회
  Future<Result<List<IdolSummary>>> getIdols({
    IdolCategory? category,
    String? searchQuery,
    int page = 1,
    int limit = 20,
  });

  /// 아이돌 상세 조회
  Future<Result<IdolEntity>> getIdolById(String id);

  /// 인기 아이돌 조회
  Future<Result<List<IdolSummary>>> getPopularIdols({int limit = 10});

  /// 팔로우
  Future<Result<IdolEntity>> followIdol(String id);

  /// 언팔로우
  Future<Result<IdolEntity>> unfollowIdol(String id);

  /// 팔로우 중인 아이돌 목록
  Future<Result<List<IdolSummary>>> getFollowingIdols({
    int page = 1,
    int limit = 20,
  });

  /// 아이돌 랭킹 조회
  Future<Result<List<IdolRanking>>> getIdolRanking({
    RankingType type = RankingType.weekly,
    IdolCategory? category,
    int limit = 100,
  });

  /// 아이돌 검색
  Future<Result<List<IdolSummary>>> searchIdols(String query);
}

/// 랭킹 타입
enum RankingType {
  daily,
  weekly,
  monthly,
  allTime,
}

/// 아이돌 랭킹 정보
class IdolRanking {
  final int rank;
  final int previousRank;
  final IdolSummary idol;
  final int score;
  final int supportAmount;

  const IdolRanking({
    required this.rank,
    required this.previousRank,
    required this.idol,
    required this.score,
    this.supportAmount = 0,
  });

  /// 순위 변동
  int get rankChange => previousRank - rank;

  /// 순위 상승
  bool get isUp => rankChange > 0;

  /// 순위 하락
  bool get isDown => rankChange < 0;

  /// 순위 유지
  bool get isSame => rankChange == 0;

  /// 신규 진입
  bool get isNew => previousRank == 0;
}

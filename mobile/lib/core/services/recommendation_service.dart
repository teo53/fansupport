import 'dart:math';
import '../../shared/models/idol_model.dart';
import '../../shared/models/user_model.dart';

/// 추천 점수 가중치
class RecommendationWeights {
  static const double categoryMatch = 0.3;
  static const double interactionHistory = 0.25;
  static const double popularity = 0.15;
  static const double newIdol = 0.1;
  static const double socialConnection = 0.1;
  static const double similarFans = 0.1;
}

/// 사용자 행동 데이터
class UserBehavior {
  final String userId;
  final List<String> viewedIdols;
  final List<String> likedPosts;
  final List<String> supportedIdols;
  final List<String> subscribedIdols;
  final Map<String, int> categoryViews; // 카테고리별 조회 수
  final DateTime lastActive;

  UserBehavior({
    required this.userId,
    this.viewedIdols = const [],
    this.likedPosts = const [],
    this.supportedIdols = const [],
    this.subscribedIdols = const [],
    this.categoryViews = const {},
    required this.lastActive,
  });
}

/// 추천 아이템
class RecommendedIdol {
  final IdolModel idol;
  final double score;
  final String reason; // 추천 이유

  RecommendedIdol({
    required this.idol,
    required this.score,
    required this.reason,
  });
}

/// AI 기반 아이돌 추천 서비스
class RecommendationService {
  /// 사용자 맞춤 아이돌 추천
  Future<List<RecommendedIdol>> recommendIdols(
    User user,
    List<IdolModel> allIdols,
    UserBehavior behavior, {
    int limit = 10,
  }) async {
    final recommendations = <RecommendedIdol>[];

    // 이미 구독/후원한 아이돌 제외
    final excludedIds = {
      ...behavior.subscribedIdols,
      ...behavior.supportedIdols,
    };

    for (var idol in allIdols) {
      if (excludedIds.contains(idol.id)) continue;

      final score = _calculateRecommendationScore(idol, user, behavior);
      final reason = _generateReason(idol, user, behavior);

      recommendations.add(
        RecommendedIdol(
          idol: idol,
          score: score,
          reason: reason,
        ),
      );
    }

    // 점수순 정렬 후 상위 N개 반환
    recommendations.sort((a, b) => b.score.compareTo(a.score));
    return recommendations.take(limit).toList();
  }

  /// 추천 점수 계산
  double _calculateRecommendationScore(
    IdolModel idol,
    User user,
    UserBehavior behavior,
  ) {
    double score = 0.0;

    // 1. 카테고리 선호도 매칭 (30%)
    score += _categoryMatchScore(idol, behavior) * RecommendationWeights.categoryMatch;

    // 2. 사용자 인터랙션 히스토리 (25%)
    score += _interactionScore(idol, behavior) * RecommendationWeights.interactionHistory;

    // 3. 아이돌 인기도 (15%)
    score += _popularityScore(idol) * RecommendationWeights.popularity;

    // 4. 신인 아이돌 부스트 (10%)
    score += _newIdolBoost(idol) * RecommendationWeights.newIdol;

    // 5. 소셜 연결 (10%)
    score += _socialConnectionScore(idol, behavior) * RecommendationWeights.socialConnection;

    // 6. 유사 팬 기반 추천 (10%)
    score += _collaborativeFilteringScore(idol, behavior) * RecommendationWeights.similarFans;

    return score;
  }

  /// 1. 카테고리 매칭 점수
  double _categoryMatchScore(IdolModel idol, UserBehavior behavior) {
    final categoryCode = idol.category.code;
    final viewCount = behavior.categoryViews[categoryCode] ?? 0;

    if (viewCount == 0) return 0.0;

    // 가장 많이 본 카테고리와 비교
    final maxViews = behavior.categoryViews.values.isEmpty
        ? 1
        : behavior.categoryViews.values.reduce(max);

    return viewCount / maxViews;
  }

  /// 2. 인터랙션 점수
  double _interactionScore(IdolModel idol, UserBehavior behavior) {
    double score = 0.0;

    // 조회한 적 있으면 +0.3
    if (behavior.viewedIdols.contains(idol.id)) {
      score += 0.3;
    }

    // 같은 그룹 아이돌을 좋아하면 +0.4
    if (idol.groupName != null) {
      final sameGroupInteracted = behavior.viewedIdols.any((viewedId) {
        // TODO: 실제로는 viewedId로 아이돌 정보를 가져와서 비교
        return false; // 임시
      });
      if (sameGroupInteracted) score += 0.4;
    }

    // 같은 소속사 아이돌을 후원한 적 있으면 +0.3
    if (idol.agencyId != null) {
      final sameAgencySupported = behavior.supportedIdols.any((supportedId) {
        return false; // TODO: 실제 구현
      });
      if (sameAgencySupported) score += 0.3;
    }

    return min(score, 1.0);
  }

  /// 3. 인기도 점수
  double _popularityScore(IdolModel idol) {
    // 팔로워, 후원자, 평점 등을 종합
    final followerScore = _normalizeScore(idol.supporterCount.toDouble(), 0, 10000);
    final subscriberScore = _normalizeScore(idol.subscriberCount.toDouble(), 0, 1000);
    final ratingScore = idol.rating / 5.0;

    return (followerScore * 0.4 + subscriberScore * 0.4 + ratingScore * 0.2);
  }

  /// 4. 신인 부스트
  double _newIdolBoost(IdolModel idol) {
    final now = DateTime.now();
    final accountAge = now.difference(idol.createdAt).inDays;

    // 30일 이내 신규 아이돌에게 높은 점수
    if (accountAge <= 30) {
      return 1.0 - (accountAge / 30);
    }

    return 0.0;
  }

  /// 5. 소셜 연결 점수
  double _socialConnectionScore(IdolModel idol, UserBehavior behavior) {
    double score = 0.0;

    // 트위터에서 마이그레이션한 아이돌 우대
    if (idol.importedFromTwitter) {
      score += 0.5;

      // 전환율이 높으면 추가 점수
      if (idol.twitterFollowersAtImport != null &&
          idol.twitterFollowersAtImport! > 0) {
        final conversionRate = idol.twitterFollowersConverted /
            idol.twitterFollowersAtImport!;
        score += conversionRate * 0.5;
      }
    }

    return min(score, 1.0);
  }

  /// 6. 협업 필터링 점수 (유사 팬 기반)
  double _collaborativeFilteringScore(IdolModel idol, UserBehavior behavior) {
    // TODO: 실제로는 유사한 취향의 다른 유저들이 좋아하는 아이돌 분석
    // 간단한 구현: 같은 카테고리의 인기 아이돌
    final categoryMatch = behavior.categoryViews[idol.category.code] ?? 0;
    if (categoryMatch > 0 && idol.subscriberCount > 50) {
      return 0.7;
    }
    return 0.3;
  }

  /// 추천 이유 생성
  String _generateReason(IdolModel idol, User user, UserBehavior behavior) {
    final reasons = <String>[];

    // 카테고리 매칭
    final categoryViewCount = behavior.categoryViews[idol.category.code] ?? 0;
    if (categoryViewCount > 5) {
      reasons.add('${idol.category.displayName}를 자주 보셨어요');
    }

    // 인기 아이돌
    if (idol.subscriberCount > 100) {
      reasons.add('구독자 ${idol.subscriberCount}명의 인기 아이돌');
    }

    // 신인
    final accountAge = DateTime.now().difference(idol.createdAt).inDays;
    if (accountAge <= 30) {
      reasons.add('신인 아이돌');
    }

    // 트위터 전환
    if (idol.importedFromTwitter && idol.twitterFollowersAtImport != null) {
      reasons.add('트위터 팔로워 ${_formatNumber(idol.twitterFollowersAtImport!)}명');
    }

    // 같은 그룹
    if (idol.groupName != null) {
      reasons.add('${idol.groupName} 소속');
    }

    // 기본 메시지
    if (reasons.isEmpty) {
      reasons.add('새로운 아이돌을 만나보세요');
    }

    return reasons.take(2).join(' • ');
  }

  /// 점수 정규화 (0-1 범위)
  double _normalizeScore(double value, double min, double max) {
    if (max == min) return 0.0;
    return ((value - min) / (max - min)).clamp(0.0, 1.0);
  }

  /// 숫자 포맷팅
  String _formatNumber(int number) {
    if (number >= 10000) {
      return '${(number / 10000).toStringAsFixed(1)}만';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}천';
    }
    return number.toString();
  }

  /// 유사 아이돌 찾기 (콘텐츠 기반 필터링)
  Future<List<IdolModel>> findSimilarIdols(
    IdolModel targetIdol,
    List<IdolModel> allIdols, {
    int limit = 5,
  }) async {
    final similarities = <MapEntry<IdolModel, double>>[];

    for (var idol in allIdols) {
      if (idol.id == targetIdol.id) continue;

      double similarity = 0.0;

      // 같은 카테고리 +0.4
      if (idol.category == targetIdol.category) {
        similarity += 0.4;
      }

      // 같은 그룹 +0.5
      if (idol.groupName != null && idol.groupName == targetIdol.groupName) {
        similarity += 0.5;
      }

      // 같은 소속사 +0.3
      if (idol.agencyId != null && idol.agencyId == targetIdol.agencyId) {
        similarity += 0.3;
      }

      // 특기가 겹치는 경우 +0.2
      final commonSpecialties = idol.specialties
          .where((s) => targetIdol.specialties.contains(s))
          .length;
      if (commonSpecialties > 0) {
        similarity += 0.2 * (commonSpecialties / max(idol.specialties.length, 1));
      }

      // 비슷한 구독자 수 범위 +0.1
      final subscriberDiff = (idol.subscriberCount - targetIdol.subscriberCount).abs();
      if (subscriberDiff < 100) {
        similarity += 0.1;
      }

      similarities.add(MapEntry(idol, similarity));
    }

    // 유사도순 정렬
    similarities.sort((a, b) => b.value.compareTo(a.value));

    return similarities.take(limit).map((e) => e.key).toList();
  }

  /// 트렌딩 아이돌 (최근 급상승)
  Future<List<IdolModel>> getTrendingIdols(
    List<IdolModel> allIdols, {
    int limit = 10,
  }) async {
    // TODO: 실제로는 시계열 데이터 분석 필요
    // 임시: 최근 생성 + 구독자 수 종합
    final scored = allIdols.map((idol) {
      final accountAge = DateTime.now().difference(idol.createdAt).inDays;
      final recencyScore = accountAge <= 90 ? (90 - accountAge) / 90 : 0.0;
      final popularityScore = _normalizeScore(
        idol.subscriberCount.toDouble(),
        0,
        1000,
      );

      final totalScore = recencyScore * 0.6 + popularityScore * 0.4;

      return MapEntry(idol, totalScore);
    }).toList();

    scored.sort((a, b) => b.value.compareTo(a.value));

    return scored.take(limit).map((e) => e.key).toList();
  }

  /// 카테고리별 인기 아이돌
  Future<Map<IdolCategory, List<IdolModel>>> getPopularByCategory(
    List<IdolModel> allIdols, {
    int limitPerCategory = 5,
  }) async {
    final result = <IdolCategory, List<IdolModel>>{};

    for (var category in IdolCategory.values) {
      final categoryIdols = allIdols
          .where((idol) => idol.category == category)
          .toList();

      categoryIdols.sort((a, b) => b.subscriberCount.compareTo(a.subscriberCount));

      result[category] = categoryIdols.take(limitPerCategory).toList();
    }

    return result;
  }
}

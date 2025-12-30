import '../../core/errors/result.dart';
import '../entities/campaign_entity.dart';

/// 캠페인 Repository 인터페이스
abstract class CampaignRepository {
  /// 캠페인 목록 조회
  Future<Result<List<CampaignSummary>>> getCampaigns({
    CampaignType? type,
    CampaignStatus? status,
    String? idolId,
    int page = 1,
    int limit = 20,
  });

  /// 캠페인 상세 조회
  Future<Result<CampaignEntity>> getCampaignById(String id);

  /// 인기 캠페인 조회
  Future<Result<List<CampaignSummary>>> getPopularCampaigns({int limit = 10});

  /// 마감 임박 캠페인 조회
  Future<Result<List<CampaignSummary>>> getEndingSoonCampaigns({int limit = 10});

  /// 캠페인 참여
  Future<Result<CampaignEntity>> participateCampaign({
    required String campaignId,
    required int amount,
    String? message,
  });

  /// 참여 취소
  Future<Result<void>> cancelParticipation(String campaignId);

  /// 참여한 캠페인 목록
  Future<Result<List<CampaignSummary>>> getParticipatedCampaigns({
    int page = 1,
    int limit = 20,
  });

  /// 캠페인 검색
  Future<Result<List<CampaignSummary>>> searchCampaigns(String query);

  /// 캠페인 생성 (주최자용)
  Future<Result<CampaignEntity>> createCampaign({
    required String title,
    required String description,
    required CampaignType type,
    required int targetAmount,
    required DateTime startDate,
    required DateTime endDate,
    String? idolId,
    String? thumbnailImage,
    List<String>? images,
    String? location,
  });
}

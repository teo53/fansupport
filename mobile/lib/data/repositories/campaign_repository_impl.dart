import '../../core/errors/failures.dart';
import '../../core/errors/result.dart';
import '../../domain/entities/campaign_entity.dart';
import '../../domain/repositories/campaign_repository.dart';
import '../datasources/local_datasource.dart';

/// CampaignRepository 구현체
class CampaignRepositoryImpl implements CampaignRepository {
  final LocalDataSource _dataSource;

  CampaignRepositoryImpl(this._dataSource);

  @override
  Future<Result<List<CampaignSummary>>> getCampaigns({
    CampaignType? type,
    CampaignStatus? status,
    String? idolId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final campaigns = await _dataSource.getCampaigns(
        type: type,
        page: page,
        limit: limit,
      );
      return Success(campaigns);
    } catch (e) {
      return Fail(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<CampaignEntity>> getCampaignById(String id) async {
    try {
      final campaign = await _dataSource.getCampaignById(id);
      return Success(campaign);
    } catch (e) {
      return Fail(ServerFailure(message: '캠페인 정보를 불러올 수 없습니다'));
    }
  }

  @override
  Future<Result<List<CampaignSummary>>> getPopularCampaigns({
    int limit = 10,
  }) async {
    try {
      final campaigns = await _dataSource.getCampaigns(limit: limit);
      return Success(campaigns);
    } catch (e) {
      return Fail(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<List<CampaignSummary>>> getEndingSoonCampaigns({
    int limit = 10,
  }) async {
    try {
      final campaigns = await _dataSource.getCampaigns(limit: limit);
      // 마감 임박 순으로 정렬된 것으로 가정
      return Success(campaigns);
    } catch (e) {
      return Fail(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<CampaignEntity>> participateCampaign({
    required String campaignId,
    required int amount,
    String? message,
  }) async {
    try {
      final campaign = await _dataSource.getCampaignById(campaignId);
      return Success(campaign.copyWith(
        currentAmount: campaign.currentAmount + amount,
        participantCount: campaign.participantCount + 1,
        isParticipating: true,
      ));
    } catch (e) {
      return Fail(ServerFailure(message: '참여에 실패했습니다'));
    }
  }

  @override
  Future<Result<void>> cancelParticipation(String campaignId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const Success(null);
  }

  @override
  Future<Result<List<CampaignSummary>>> getParticipatedCampaigns({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final campaigns = await _dataSource.getCampaigns(page: 1, limit: 5);
      return Success(campaigns);
    } catch (e) {
      return Fail(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<List<CampaignSummary>>> searchCampaigns(String query) async {
    try {
      final campaigns = await _dataSource.getCampaigns(limit: 20);
      final filtered = campaigns.where(
        (c) => c.title.toLowerCase().contains(query.toLowerCase()),
      ).toList();
      return Success(filtered);
    } catch (e) {
      return Fail(ServerFailure(message: e.toString()));
    }
  }

  @override
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
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final campaign = CampaignEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      type: type,
      organizerId: 'demo_user',
      organizerName: '데모 유저',
      thumbnailImage: thumbnailImage,
      images: images ?? [],
      targetAmount: targetAmount,
      startDate: startDate,
      endDate: endDate,
      location: location,
      createdAt: DateTime.now(),
    );

    return Success(campaign);
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/campaign_entity.dart';
import '../../domain/repositories/campaign_repository.dart';
import 'base_state.dart';
import 'di_providers.dart';

/// 캠페인 목록 상태 관리 Notifier
class CampaignListNotifier extends StateNotifier<PaginatedState<CampaignSummary>> {
  final CampaignRepository _repository;
  CampaignType? _currentType;

  CampaignListNotifier(this._repository) : super(const PaginatedState()) {
    loadInitial();
  }

  Future<void> loadInitial({CampaignType? type}) async {
    if (state.isLoading) return;

    _currentType = type;

    state = state.copyWith(
      isLoading: true,
      items: [],
      currentPage: 0,
      hasMore: true,
      error: null,
    );

    final result = await _repository.getCampaigns(
      type: _currentType,
      page: 1,
      limit: 20,
    );

    result.fold(
      onSuccess: (campaigns) {
        state = state.copyWith(
          items: campaigns,
          isLoading: false,
          currentPage: 1,
          hasMore: campaigns.length >= 20,
        );
      },
      onFailure: (failure) {
        state = state.setError(failure);
      },
    );
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.startLoading();

    final result = await _repository.getCampaigns(
      type: _currentType,
      page: state.currentPage + 1,
      limit: 20,
    );

    result.fold(
      onSuccess: (campaigns) {
        state = state.appendItems(campaigns, hasMore: campaigns.length >= 20);
      },
      onFailure: (failure) {
        state = state.setError(failure);
      },
    );
  }

  void setType(CampaignType? type) {
    if (_currentType != type) {
      loadInitial(type: type);
    }
  }

  Future<void> refresh() async {
    state = state.reset();
    await loadInitial(type: _currentType);
  }
}

/// 캠페인 상세 상태
class CampaignDetailNotifier extends StateNotifier<AsyncState<CampaignEntity>> {
  final CampaignRepository _repository;
  final String campaignId;

  CampaignDetailNotifier(this._repository, this.campaignId)
      : super(const Initial()) {
    load();
  }

  Future<void> load() async {
    state = const Loading();

    final result = await _repository.getCampaignById(campaignId);

    result.fold(
      onSuccess: (campaign) {
        state = Success(campaign);
      },
      onFailure: (failure) {
        state = Error(failure);
      },
    );
  }

  Future<bool> participate(int amount, {String? message}) async {
    final currentData = state.data;
    if (currentData == null) return false;

    final result = await _repository.participateCampaign(
      campaignId: campaignId,
      amount: amount,
      message: message,
    );

    return result.fold(
      onSuccess: (updatedCampaign) {
        state = Success(updatedCampaign);
        return true;
      },
      onFailure: (_) {
        return false;
      },
    );
  }
}

/// 캠페인 목록 Provider
final campaignListProvider =
    StateNotifierProvider<CampaignListNotifier, PaginatedState<CampaignSummary>>(
        (ref) {
  return CampaignListNotifier(ref.read(campaignRepositoryProvider));
});

/// 캠페인 상세 Provider
final campaignDetailProvider = StateNotifierProvider.family<
    CampaignDetailNotifier, AsyncState<CampaignEntity>, String>(
  (ref, campaignId) {
    return CampaignDetailNotifier(
      ref.read(campaignRepositoryProvider),
      campaignId,
    );
  },
);

/// 인기 캠페인 Provider
final popularCampaignsProvider =
    FutureProvider<List<CampaignSummary>>((ref) async {
  final result = await ref.read(campaignRepositoryProvider).getPopularCampaigns();
  return result.data ?? [];
});

/// 마감 임박 캠페인 Provider
final endingSoonCampaignsProvider =
    FutureProvider<List<CampaignSummary>>((ref) async {
  final result =
      await ref.read(campaignRepositoryProvider).getEndingSoonCampaigns();
  return result.data ?? [];
});

/// 참여한 캠페인 Provider
final participatedCampaignsProvider =
    FutureProvider<List<CampaignSummary>>((ref) async {
  final result =
      await ref.read(campaignRepositoryProvider).getParticipatedCampaigns();
  return result.data ?? [];
});

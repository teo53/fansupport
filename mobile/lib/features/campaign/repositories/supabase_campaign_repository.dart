import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/models/campaign_model.dart';

/// Supabase 캠페인/펀딩 Repository
class SupabaseCampaignRepository {
  final SupabaseClient _supabase;

  SupabaseCampaignRepository(this._supabase);

  /// 모든 캠페인 조회
  Future<List<CampaignModel>> getAllCampaigns({
    CampaignType? type,
    CampaignStatus? status,
    int limit = 20,
  }) async {
    try {
      var query = _supabase
          .from('campaigns')
          .select('''
            *,
            creator:creator_id(id, nickname, profile_image, is_verified)
          ''');

      if (type != null) {
        query = query.eq('type', type.toString().split('.').last.toUpperCase());
      }

      if (status != null) {
        query = query.eq('status', status.toString().split('.').last.toUpperCase());
      }

      query = query.order('created_at', ascending: false).limit(limit);

      final data = await query;
      return (data as List).map((json) => CampaignModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// 캠페인 상세 조회
  Future<CampaignModel?> getCampaignById(String campaignId) async {
    try {
      final data = await _supabase
          .from('campaigns')
          .select('''
            *,
            creator:creator_id(id, nickname, profile_image, is_verified)
          ''')
          .eq('id', campaignId)
          .single();

      return CampaignModel.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  /// 인기 캠페인 조회 (후원자 수 기준)
  Future<List<CampaignModel>> getPopularCampaigns({int limit = 10}) async {
    try {
      final data = await _supabase
          .from('campaigns')
          .select('''
            *,
            creator:creator_id(id, nickname, profile_image, is_verified)
          ''')
          .eq('status', 'ACTIVE')
          .order('supporter_count', ascending: false)
          .limit(limit);

      return (data as List).map((json) => CampaignModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// 마감 임박 캠페인 조회
  Future<List<CampaignModel>> getEndingSoonCampaigns({int limit = 10}) async {
    try {
      final now = DateTime.now();
      final threeDaysLater = now.add(const Duration(days: 3));

      final data = await _supabase
          .from('campaigns')
          .select('''
            *,
            creator:creator_id(id, nickname, profile_image, is_verified)
          ''')
          .eq('status', 'ACTIVE')
          .lt('end_date', threeDaysLater.toIso8601String())
          .gt('end_date', now.toIso8601String())
          .order('end_date', ascending: true)
          .limit(limit);

      return (data as List).map((json) => CampaignModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// 특정 크리에이터의 캠페인 조회
  Future<List<CampaignModel>> getCampaignsByCreator(String creatorId) async {
    try {
      final data = await _supabase
          .from('campaigns')
          .select('''
            *,
            creator:creator_id(id, nickname, profile_image, is_verified)
          ''')
          .eq('creator_id', creatorId)
          .order('created_at', ascending: false);

      return (data as List).map((json) => CampaignModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// 캠페인 후원하기
  Future<void> supportCampaign({
    required String campaignId,
    required String rewardId,
    required double amount,
    Map<String, dynamic>? deliveryInfo,
  }) async {
    try {
      await _supabase.rpc('support_campaign', params: {
        'p_campaign_id': campaignId,
        'p_reward_id': rewardId,
        'p_amount': amount,
        'p_delivery_info': deliveryInfo,
      });
    } catch (e) {
      throw Exception('캠페인 후원 실패: $e');
    }
  }

  /// 캠페인 검색
  Future<List<CampaignModel>> searchCampaigns(String query) async {
    try {
      final data = await _supabase
          .from('campaigns')
          .select('''
            *,
            creator:creator_id(id, nickname, profile_image, is_verified)
          ''')
          .or('title.ilike.%$query%,description.ilike.%$query%')
          .eq('status', 'ACTIVE')
          .limit(20);

      return (data as List).map((json) => CampaignModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// 캠페인 생성
  Future<String> createCampaign(Map<String, dynamic> campaignData) async {
    try {
      final data = await _supabase
          .from('campaigns')
          .insert(campaignData)
          .select('id')
          .single();

      return data['id'] as String;
    } catch (e) {
      throw Exception('캠페인 생성 실패: $e');
    }
  }

  /// 캠페인 업데이트
  Future<void> updateCampaign(String campaignId, Map<String, dynamic> updates) async {
    try {
      await _supabase
          .from('campaigns')
          .update(updates)
          .eq('id', campaignId);
    } catch (e) {
      throw Exception('캠페인 업데이트 실패: $e');
    }
  }

  /// 캠페인 진행률 계산
  double calculateProgress(CampaignModel campaign) {
    if (campaign.goalAmount <= 0) return 0.0;
    return (campaign.currentAmount / campaign.goalAmount * 100).clamp(0.0, 100.0);
  }

  /// 캠페인 종료일까지 남은 일수
  int getDaysRemaining(CampaignModel campaign) {
    final now = DateTime.now();
    final difference = campaign.endDate.difference(now);
    return difference.inDays.clamp(0, 999);
  }

  /// 캠페인 실시간 구독
  Stream<CampaignModel?> subscribeToCampaign(String campaignId) {
    return _supabase
        .from('campaigns')
        .stream(primaryKey: ['id'])
        .eq('id', campaignId)
        .map((data) {
          if (data.isEmpty) return null;
          return CampaignModel.fromJson(data.first);
        });
  }
}

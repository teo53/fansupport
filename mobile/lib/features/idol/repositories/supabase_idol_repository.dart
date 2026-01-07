import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/models/idol_model.dart';

/// Supabase 아이돌 Repository
class SupabaseIdolRepository {
  final SupabaseClient _supabase;

  SupabaseIdolRepository(this._supabase);

  /// 모든 아이돌 조회
  Future<List<IdolModel>> getAllIdols({
    IdolCategory? category,
    int limit = 50,
  }) async {
    try {
      dynamic query = _supabase
          .from('idol_profiles')
          .select('''
            *,
            user:user_id(id, email, nickname, profile_image, is_verified)
          ''');

      if (category != null) {
        query = query.eq('category', category.toString().split('.').last.toUpperCase());
      }

      query = query.order('total_support', ascending: false).limit(limit);

      final data = await query;
      return (data as List).map((json) => IdolModel.fromJson(json)).toList();
    } catch (e) {
      // Fallback to empty list on error
      return [];
    }
  }

  /// 아이돌 상세 조회
  Future<IdolModel?> getIdolById(String idolId) async {
    try {
      final data = await _supabase
          .from('idol_profiles')
          .select('''
            *,
            user:user_id(id, email, nickname, profile_image, is_verified)
          ''')
          .eq('user_id', idolId)
          .single();

      return IdolModel.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  /// 인기 아이돌 조회 (후원 기준)
  Future<List<IdolModel>> getPopularIdols({int limit = 10}) async {
    try {
      final data = await _supabase
          .from('idol_profiles')
          .select('''
            *,
            user:user_id(id, email, nickname, profile_image, is_verified)
          ''')
          .order('total_support', ascending: false)
          .limit(limit);

      return (data as List).map((json) => IdolModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// 신규 아이돌 조회 (데뷔일 기준)
  Future<List<IdolModel>> getNewIdols({int limit = 10}) async {
    try {
      final data = await _supabase
          .from('idol_profiles')
          .select('''
            *,
            user:user_id(id, email, nickname, profile_image, is_verified)
          ''')
          .order('debut_date', ascending: false)
          .limit(limit);

      return (data as List).map((json) => IdolModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// 아이돌 검색
  Future<List<IdolModel>> searchIdols(String query) async {
    try {
      final data = await _supabase
          .from('idol_profiles')
          .select('''
            *,
            user:user_id(id, email, nickname, profile_image, is_verified)
          ''')
          .or('stage_name.ilike.%$query%,bio.ilike.%$query%')
          .limit(20);

      return (data as List).map((json) => IdolModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// 랭킹 조회
  Future<List<IdolModel>> getRankings({
    required String period, // 'all', 'monthly', 'weekly'
    int limit = 50,
  }) async {
    try {
      var query = _supabase
          .from('idol_profiles')
          .select('''
            *,
            user:user_id(id, email, nickname, profile_image, is_verified)
          ''')
          .limit(limit);

      switch (period) {
        case 'monthly':
          query = query.order('monthly_ranking', ascending: true);
          break;
        case 'weekly':
          // TODO: Add weekly ranking column to database
          query = query.order('total_support', ascending: false);
          break;
        default:
          query = query.order('ranking', ascending: true);
      }

      final data = await query;
      return (data as List).map((json) => IdolModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// 카테고리별 아이돌 조회
  Future<List<IdolModel>> getIdolsByCategory(IdolCategory category, {int limit = 20}) async {
    try {
      final data = await _supabase
          .from('idol_profiles')
          .select('''
            *,
            user:user_id(id, email, nickname, profile_image, is_verified)
          ''')
          .eq('category', category.toString().split('.').last.toUpperCase())
          .order('total_support', ascending: false)
          .limit(limit);

      return (data as List).map((json) => IdolModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// 아이돌 프로필 업데이트
  Future<void> updateIdolProfile(String idolId, Map<String, dynamic> updates) async {
    try {
      await _supabase
          .from('idol_profiles')
          .update(updates)
          .eq('user_id', idolId);
    } catch (e) {
      throw Exception('프로필 업데이트 실패: $e');
    }
  }

  /// 아이돌 통계 업데이트 (후원 후 호출)
  Future<void> updateIdolStats(String idolId) async {
    try {
      // PostgreSQL function에서 자동으로 처리하므로 별도 호출 불필요
      // create_support 함수에서 통계 업데이트 수행
    } catch (e) {
      throw Exception('통계 업데이트 실패: $e');
    }
  }
}

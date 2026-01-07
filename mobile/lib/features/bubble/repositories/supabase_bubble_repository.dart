import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/models/bubble_message_model.dart';

/// Supabase 버블 메시지 Repository
class SupabaseBubbleRepository {
  final SupabaseClient _supabase;

  SupabaseBubbleRepository(this._supabase);

  /// 아이돌의 버블 메시지 조회
  Future<List<BubbleMessageModel>> getBubbleMessages({
    required String idolId,
    bool subscriberOnly = false,
    int limit = 20,
  }) async {
    try {
      var query = _supabase
          .from('bubble_messages')
          .select('''
            *,
            idol:idol_id(id, stage_name, profile_image)
          ''')
          .eq('idol_id', idolId)
          .order('created_at', ascending: false)
          .limit(limit);

      if (subscriberOnly) {
        query = query.eq('is_subscriber_only', true);
      }

      final data = await query;
      return (data as List).map((json) => BubbleMessageModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// 모든 버블 메시지 조회 (피드)
  Future<List<BubbleMessageModel>> getAllBubbleMessages({
    int limit = 50,
  }) async {
    try {
      final data = await _supabase
          .from('bubble_messages')
          .select('''
            *,
            idol:idol_id(id, stage_name, profile_image)
          ''')
          .order('created_at', ascending: false)
          .limit(limit);

      return (data as List).map((json) => BubbleMessageModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// 구독 중인 아이돌들의 버블 메시지 조회
  Future<List<BubbleMessageModel>> getSubscribedBubbleMessages({
    int limit = 50,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      // Get subscribed idol IDs
      final subscriptions = await _supabase
          .from('subscriptions')
          .select('idol_id')
          .eq('fan_id', userId)
          .eq('status', 'ACTIVE');

      if (subscriptions.isEmpty) return [];

      final idolIds = (subscriptions as List).map((s) => s['idol_id']).toList();

      // Get bubble messages from subscribed idols
      final data = await _supabase
          .from('bubble_messages')
          .select('''
            *,
            idol:idol_id(id, stage_name, profile_image)
          ''')
          .in_('idol_id', idolIds)
          .order('created_at', ascending: false)
          .limit(limit);

      return (data as List).map((json) => BubbleMessageModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// 버블 메시지 생성 (아이돌 전용)
  Future<String> createBubbleMessage({
    required BubbleMessageType type,
    required String content,
    String? mediaUrl,
    int? duration,
    bool isSubscriberOnly = false,
  }) async {
    try {
      final data = await _supabase
          .from('bubble_messages')
          .insert({
            'type': type.toString().split('.').last.toUpperCase(),
            'content': content,
            'media_url': mediaUrl,
            'duration': duration,
            'is_subscriber_only': isSubscriberOnly,
          })
          .select('id')
          .single();

      return data['id'] as String;
    } catch (e) {
      throw Exception('버블 메시지 생성 실패: $e');
    }
  }

  /// 버블 메시지 좋아요
  Future<void> likeBubbleMessage(String messageId) async {
    try {
      await _supabase.rpc('like_bubble_message', params: {
        'p_message_id': messageId,
      });
    } catch (e) {
      throw Exception('좋아요 실패: $e');
    }
  }

  /// 버블 메시지 실시간 구독
  Stream<List<BubbleMessageModel>> subscribeToBubbleMessages(String idolId) {
    return _supabase
        .from('bubble_messages')
        .stream(primaryKey: ['id'])
        .eq('idol_id', idolId)
        .order('created_at', ascending: false)
        .limit(50)
        .map((data) => data.map((json) => BubbleMessageModel.fromJson(json)).toList());
  }

  /// 모든 버블 메시지 실시간 구독 (피드)
  Stream<List<BubbleMessageModel>> subscribeToAllBubbleMessages() {
    return _supabase
        .from('bubble_messages')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .limit(50)
        .map((data) => data.map((json) => BubbleMessageModel.fromJson(json)).toList());
  }

  /// 버블 메시지 삭제 (아이돌 전용)
  Future<void> deleteBubbleMessage(String messageId) async {
    try {
      await _supabase
          .from('bubble_messages')
          .delete()
          .eq('id', messageId);
    } catch (e) {
      throw Exception('삭제 실패: $e');
    }
  }

  /// 버블 메시지 조회수 증가
  Future<void> incrementViewCount(String messageId) async {
    try {
      await _supabase.rpc('increment_bubble_view', params: {
        'p_message_id': messageId,
      });
    } catch (e) {
      // Silently fail - view count is not critical
    }
  }
}

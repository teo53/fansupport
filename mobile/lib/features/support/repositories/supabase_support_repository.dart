import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase 후원 Repository
class SupabaseSupportRepository {
  final SupabaseClient _supabase;

  SupabaseSupportRepository(this._supabase);

  /// 후원 생성 (트랜잭션 보장)
  Future<String> createSupport({
    required String receiverId,
    required double amount,
    String? message,
    bool isAnonymous = false,
  }) async {
    try {
      // Supabase Function 호출 (create_support)
      final response = await _supabase.rpc('create_support', params: {
        'p_receiver_id': receiverId,
        'p_amount': amount,
        'p_message': message,
        'p_is_anonymous': isAnonymous,
      });

      return response as String; // support_id 반환
    } catch (e) {
      throw Exception('후원 처리 중 오류가 발생했습니다: $e');
    }
  }

  /// 받은 후원 목록 조회
  Future<List<SupportModel>> getReceivedSupports({
    required String userId,
    int limit = 20,
  }) async {
    try {
      final data = await _supabase
          .from('supports')
          .select('*, supporter:supporter_id(nickname, profile_image)')
          .eq('receiver_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      return (data as List).map((json) => SupportModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('후원 내역을 불러오는데 실패했습니다: $e');
    }
  }

  /// 보낸 후원 목록 조회
  Future<List<SupportModel>> getSentSupports({
    required String userId,
    int limit = 20,
  }) async {
    try {
      final data = await _supabase
          .from('supports')
          .select('*, receiver:receiver_id(nickname, profile_image)')
          .eq('supporter_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      return (data as List).map((json) => SupportModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('후원 내역을 불러오는데 실패했습니다: $e');
    }
  }

  /// Top Supporters (상위 후원자)
  Future<List<SupportModel>> getTopSupporters({
    required String idolId,
    int limit = 10,
  }) async {
    try {
      final data = await _supabase
          .from('supports')
          .select('*, supporter:supporter_id(nickname, profile_image)')
          .eq('receiver_id', idolId)
          .order('amount', ascending: false)
          .limit(limit);

      return (data as List).map((json) => SupportModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Top 후원자를 불러오는데 실패했습니다: $e');
    }
  }

  /// 후원 실시간 구독
  Stream<List<SupportModel>> subscribeToSupports(String idolId) {
    return _supabase
        .from('supports')
        .stream(primaryKey: ['id'])
        .eq('receiver_id', idolId)
        .order('created_at', ascending: false)
        .limit(20)
        .map((data) => data.map((json) => SupportModel.fromJson(json)).toList())
        .handleError((error) {
          print('Support stream error: $error');
          return <SupportModel>[];
        });
  }
}

/// Support Model (간단 예시)
class SupportModel {
  final String id;
  final String supporterId;
  final String receiverId;
  final double amount;
  final String? message;
  final bool isAnonymous;
  final DateTime createdAt;

  SupportModel({
    required this.id,
    required this.supporterId,
    required this.receiverId,
    required this.amount,
    this.message,
    required this.isAnonymous,
    required this.createdAt,
  });

  factory SupportModel.fromJson(Map<String, dynamic> json) {
    return SupportModel(
      id: json['id'],
      supporterId: json['supporter_id'],
      receiverId: json['receiver_id'],
      amount: (json['amount'] as num).toDouble(),
      message: json['message'],
      isAnonymous: json['is_anonymous'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase 지갑 Repository
class SupabaseWalletRepository {
  final SupabaseClient _supabase;

  SupabaseWalletRepository(this._supabase);

  /// 지갑 잔액 조회
  Future<double> getBalance() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('로그인이 필요합니다');

      final data = await _supabase
          .from('wallets')
          .select('balance')
          .eq('user_id', userId)
          .maybeSingle();

      if (data == null) {
        throw Exception('지갑 정보를 찾을 수 없습니다');
      }

      return (data['balance'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      throw Exception('잔액 조회 실패: $e');
    }
  }

  /// 거래 내역 조회
  Future<List<Transaction>> getTransactions({int limit = 20}) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('로그인이 필요합니다');

      final walletData = await _supabase
          .from('wallets')
          .select('id')
          .eq('user_id', userId)
          .maybeSingle();

      if (walletData == null) {
        throw Exception('지갑 정보를 찾을 수 없습니다');
      }

      final data = await _supabase
          .from('transactions')
          .select()
          .eq('wallet_id', walletData['id'])
          .order('created_at', ascending: false)
          .limit(limit);

      if (data is! List) {
        return [];
      }

      return data.map((json) => Transaction.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('거래 내역 조회 실패: $e');
    }
  }

  /// 지갑 충전 (Stripe 결제 후 호출)
  Future<void> charge(double amount, String paymentId) async {
    try {
      await _supabase.rpc('charge_wallet', params: {
        'p_amount': amount,
        'p_payment_id': paymentId,
      });
    } catch (e) {
      throw Exception('충전 실패: $e');
    }
  }
}

/// Transaction Model
class Transaction {
  final String id;
  final String type;
  final double amount;
  final double balanceBefore;
  final double balanceAfter;
  final String? description;
  final DateTime createdAt;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.balanceBefore,
    required this.balanceAfter,
    this.description,
    required this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    try {
      return Transaction(
        id: json['id'] as String? ?? '',
        type: json['type'] as String? ?? 'UNKNOWN',
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
        balanceBefore: (json['balance_before'] as num?)?.toDouble() ?? 0.0,
        balanceAfter: (json['balance_after'] as num?)?.toDouble() ?? 0.0,
        description: json['description'] as String?,
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      );
    } catch (e) {
      // Return default transaction on error
      return Transaction(
        id: '',
        type: 'ERROR',
        amount: 0.0,
        balanceBefore: 0.0,
        balanceAfter: 0.0,
        description: 'Failed to parse transaction',
        createdAt: DateTime.now(),
      );
    }
  }
}

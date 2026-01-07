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
          .single();

      return (data['balance'] as num).toDouble();
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
          .single();

      final data = await _supabase
          .from('transactions')
          .select()
          .eq('wallet_id', walletData['id'])
          .order('created_at', ascending: false)
          .limit(limit);

      return (data as List).map((json) => Transaction.fromJson(json)).toList();
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
    return Transaction(
      id: json['id'],
      type: json['type'],
      amount: (json['amount'] as num).toDouble(),
      balanceBefore: (json['balance_before'] as num).toDouble(),
      balanceAfter: (json['balance_after'] as num).toDouble(),
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

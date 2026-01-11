import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../../../core/config/app_config.dart';

/// Payment result from backend
class PaymentResult {
  final bool success;
  final String? transactionId;
  final int? newBalance;
  final String? error;

  const PaymentResult({
    required this.success,
    this.transactionId,
    this.newBalance,
    this.error,
  });
}

/// Payment service for handling wallet transactions
class PaymentService {
  final sb.SupabaseClient _supabase;

  PaymentService() : _supabase = sb.Supabase.instance.client;

  /// Charge wallet with backend validation
  ///
  /// This method:
  /// 1. Creates a payment intent (Stripe or other provider)
  /// 2. Validates the payment on backend
  /// 3. Updates wallet balance via RPC
  /// 4. Creates transaction record
  Future<PaymentResult> chargeWallet({
    required String userId,
    required int amount,
    required String paymentMethod,
    String? paymentToken,
  }) async {
    try {
      // Validate amount
      if (amount <= 0) {
        return const PaymentResult(
          success: false,
          error: '충전 금액은 0보다 커야 합니다',
        );
      }

      if (amount > 10000000) {
        return const PaymentResult(
          success: false,
          error: '1회 최대 충전 금액은 1,000만원입니다',
        );
      }

      // Call Supabase RPC for secure wallet charging
      final result = await _supabase.rpc('charge_wallet', params: {
        'user_id': userId,
        'amount': amount,
        'payment_method': paymentMethod,
        'payment_token': paymentToken,
      });

      if (result != null && result['success'] == true) {
        return PaymentResult(
          success: true,
          transactionId: result['transaction_id']?.toString(),
          newBalance: result['new_balance']?.toInt(),
        );
      } else {
        return PaymentResult(
          success: false,
          error: result?['error'] ?? '결제 처리에 실패했습니다',
        );
      }
    } on sb.PostgrestException catch (e) {
      if (kDebugMode) {
        print('Payment RPC error: ${e.message}');
      }
      return PaymentResult(
        success: false,
        error: _handlePostgrestError(e),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Payment error: $e');
      }
      return PaymentResult(
        success: false,
        error: '결제 처리 중 오류가 발생했습니다',
      );
    }
  }

  /// Verify payment status
  Future<bool> verifyPayment(String transactionId) async {
    try {
      final result = await _supabase
          .from('transactions')
          .select('status')
          .eq('id', transactionId)
          .single();

      return result['status'] == 'COMPLETED';
    } catch (e) {
      if (kDebugMode) {
        print('Payment verification error: $e');
      }
      return false;
    }
  }

  /// Refund a payment
  Future<PaymentResult> refundPayment({
    required String transactionId,
    required String reason,
  }) async {
    try {
      final result = await _supabase.rpc('refund_payment', params: {
        'transaction_id': transactionId,
        'reason': reason,
      });

      if (result != null && result['success'] == true) {
        return PaymentResult(
          success: true,
          transactionId: result['refund_id']?.toString(),
          newBalance: result['new_balance']?.toInt(),
        );
      } else {
        return PaymentResult(
          success: false,
          error: result?['error'] ?? '환불 처리에 실패했습니다',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Refund error: $e');
      }
      return const PaymentResult(
        success: false,
        error: '환불 처리 중 오류가 발생했습니다',
      );
    }
  }

  /// Create Stripe payment intent (for production)
  Future<Map<String, dynamic>?> createPaymentIntent({
    required int amount,
    required String currency,
  }) async {
    if (!AppConfig.isProduction && AppConfig.useMockData) {
      // Return mock payment intent for development
      return {
        'client_secret': 'mock_secret_${DateTime.now().millisecondsSinceEpoch}',
        'payment_intent_id': 'pi_mock_${DateTime.now().millisecondsSinceEpoch}',
      };
    }

    try {
      // Call Edge Function to create Stripe PaymentIntent
      final response = await _supabase.functions.invoke(
        'create-payment-intent',
        body: {
          'amount': amount,
          'currency': currency,
        },
      );

      if (response.status == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Payment intent creation error: $e');
      }
      return null;
    }
  }

  String _handlePostgrestError(sb.PostgrestException error) {
    final code = error.code;

    switch (code) {
      case 'PGRST116':
        return '사용자를 찾을 수 없습니다';
      case '23514':
        return '잔액이 부족합니다';
      case '23505':
        return '중복된 거래가 감지되었습니다';
      default:
        return '결제 처리에 실패했습니다 (${error.code})';
    }
  }
}

/// Singleton instance
final paymentService = PaymentService();

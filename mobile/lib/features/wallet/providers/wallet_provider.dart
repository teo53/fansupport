import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/supabase_wallet_repository.dart';
import '../../auth/providers/auth_provider.dart';

// Wallet Repository Provider
final walletRepositoryProvider = Provider<SupabaseWalletRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return SupabaseWalletRepository(supabase);
});

// Wallet Balance Provider
final walletBalanceProviderSupabase = FutureProvider.autoDispose<double>((ref) async {
  final repository = ref.read(walletRepositoryProvider);
  return await repository.getBalance();
});

// Transactions Provider
final transactionsProvider = FutureProvider.autoDispose.family<List<Transaction>, int>((ref, limit) async {
  final repository = ref.read(walletRepositoryProvider);
  return await repository.getTransactions(limit: limit);
});

// Charge Wallet Provider
final chargeWalletProvider = FutureProvider.autoDispose.family<void, ChargeWalletParams>((ref, params) async {
  final repository = ref.read(walletRepositoryProvider);
  await repository.charge(params.amount, params.paymentId);
});

// Charge Wallet Parameters
class ChargeWalletParams {
  final double amount;
  final String paymentId;

  ChargeWalletParams({
    required this.amount,
    required this.paymentId,
  });
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/supabase_support_repository.dart';
import '../../auth/providers/auth_provider.dart';

// Support Repository Provider
final supportRepositoryProvider = Provider<SupabaseSupportRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return SupabaseSupportRepository(supabase);
});

// Create Support Provider
final createSupportProvider = FutureProvider.autoDispose.family<String, CreateSupportParams>((ref, params) async {
  final repository = ref.read(supportRepositoryProvider);
  return await repository.createSupport(
    receiverId: params.receiverId,
    amount: params.amount.toDouble(),
    message: params.message,
    isAnonymous: params.isAnonymous,
  );
});

// Support Parameters
class CreateSupportParams {
  final String receiverId;
  final int amount;
  final String? message;
  final bool isAnonymous;

  CreateSupportParams({
    required this.receiverId,
    required this.amount,
    this.message,
    this.isAnonymous = false,
  });
}

// Top Supporters Provider
final topSupportersProvider = FutureProvider.autoDispose.family<List<SupportModel>, String>((ref, idolId) async {
  final repository = ref.read(supportRepositoryProvider);
  return await repository.getTopSupporters(idolId: idolId, limit: 10);
});

// Support Stream Provider (Realtime)
final supportStreamProvider = StreamProvider.autoDispose.family<List<SupportModel>, String>((ref, idolId) {
  final repository = ref.read(supportRepositoryProvider);
  return repository.subscribeToSupports(idolId);
});

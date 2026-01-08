import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/supabase_idol_repository.dart';
import '../../../shared/models/idol_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/mock/mock_data.dart';

// Idol Repository Provider
final idolRepositoryProvider = Provider<SupabaseIdolRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return SupabaseIdolRepository(supabase);
});

// All Idols Provider (with fallback to mock data)
final allIdolsProvider = FutureProvider.autoDispose<List<IdolModel>>((ref) async {
  try {
    final repository = ref.read(idolRepositoryProvider);
    final idols = await repository.getAllIdols();

    // If Supabase returns empty and mock data is available, use mock data
    if (idols.isEmpty && MockData.idolModels.isNotEmpty) {
      return MockData.idolModels;
    }

    return idols;
  } catch (e) {
    // Fallback to mock data on error
    return MockData.idolModels;
  }
});

// Idol by ID Provider (with fallback to mock data)
final idolByIdProvider = FutureProvider.autoDispose.family<IdolModel?, String>((ref, idolId) async {
  try {
    final repository = ref.read(idolRepositoryProvider);
    final idol = await repository.getIdolById(idolId);

    // If not found in Supabase, try mock data
    if (idol == null) {
      try {
        return MockData.idolModels.firstWhere(
          (i) => i.id == idolId,
          orElse: () => IdolModel(
            id: '',
            userId: '',
            stageName: 'Unknown',
            realName: '',
            category: IdolCategory.UNDERGROUND_IDOL,
            bio: '',
            debutDate: DateTime.now(),
            totalSupport: 0,
            monthlySupport: 0,
            supporterCount: 0,
            isVerified: false,
            profileImage: '',
            coverImage: '',
            socialLinks: {},
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
      } catch (e) {
        return null;
      }
    }

    return idol;
  } catch (e) {
    return null;
  }
});

// Popular Idols Provider
final popularIdolsProvider = FutureProvider.autoDispose<List<IdolModel>>((ref) async {
  try {
    final repository = ref.read(idolRepositoryProvider);
    final idols = await repository.getPopularIdols(limit: 10);

    if (idols.isEmpty && MockData.idolModels.isNotEmpty) {
      return MockData.idolModels.take(10).toList();
    }

    return idols;
  } catch (e) {
    return MockData.idolModels.take(10).toList();
  }
});

// New Idols Provider
final newIdolsProvider = FutureProvider.autoDispose<List<IdolModel>>((ref) async {
  try {
    final repository = ref.read(idolRepositoryProvider);
    final idols = await repository.getNewIdols(limit: 10);

    if (idols.isEmpty && MockData.idolModels.isNotEmpty) {
      return MockData.idolModels.take(10).toList();
    }

    return idols;
  } catch (e) {
    return MockData.idolModels.take(10).toList();
  }
});

// Idols by Category Provider
final idolsByCategoryProvider = FutureProvider.autoDispose.family<List<IdolModel>, IdolCategory>((ref, category) async {
  try {
    final repository = ref.read(idolRepositoryProvider);
    final idols = await repository.getIdolsByCategory(category, limit: 20);

    if (idols.isEmpty && MockData.idolModels.isNotEmpty) {
      return MockData.idolModels.where((i) => i.category == category).toList();
    }

    return idols;
  } catch (e) {
    return MockData.idolModels.where((i) => i.category == category).toList();
  }
});

// Rankings Provider
final rankingsProvider = FutureProvider.autoDispose.family<List<IdolModel>, String>((ref, period) async {
  try {
    final repository = ref.read(idolRepositoryProvider);
    final idols = await repository.getRankings(period: period, limit: 50);

    if (idols.isEmpty && MockData.idolModels.isNotEmpty) {
      return MockData.idolModels;
    }

    return idols;
  } catch (e) {
    return MockData.idolModels;
  }
});

// Search Idols Provider
final searchIdolsProvider = FutureProvider.autoDispose.family<List<IdolModel>, String>((ref, query) async {
  if (query.trim().isEmpty) {
    return [];
  }

  try {
    final repository = ref.read(idolRepositoryProvider);
    final idols = await repository.searchIdols(query);

    if (idols.isEmpty && MockData.idolModels.isNotEmpty) {
      // Simple client-side search on mock data
      final lowerQuery = query.toLowerCase();
      return MockData.idolModels.where((idol) {
        return idol.stageName.toLowerCase().contains(lowerQuery) ||
               idol.bio?.toLowerCase().contains(lowerQuery) == true;
      }).toList();
    }

    return idols;
  } catch (e) {
    // Fallback to client-side search on mock data
    final lowerQuery = query.toLowerCase();
    return MockData.idolModels.where((idol) {
      return idol.stageName.toLowerCase().contains(lowerQuery) ||
             idol.bio?.toLowerCase().contains(lowerQuery) == true;
    }).toList();
  }
});

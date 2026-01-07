import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/supabase_campaign_repository.dart';
import '../../../shared/models/campaign_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/mock/mock_data.dart';

// Campaign Repository Provider
final campaignRepositoryProvider = Provider<SupabaseCampaignRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return SupabaseCampaignRepository(supabase);
});

// All Campaigns Provider (with fallback to mock data)
final allCampaignsProvider = FutureProvider.autoDispose<List<CampaignModel>>((ref) async {
  try {
    final repository = ref.read(campaignRepositoryProvider);
    final campaigns = await repository.getAllCampaigns();

    if (campaigns.isEmpty && MockData.campaignModels.isNotEmpty) {
      return MockData.campaignModels;
    }

    return campaigns;
  } catch (e) {
    return MockData.campaignModels;
  }
});

// Campaign by ID Provider (with fallback to mock data)
final campaignByIdProvider = FutureProvider.autoDispose.family<CampaignModel?, String>((ref, campaignId) async {
  try {
    final repository = ref.read(campaignRepositoryProvider);
    final campaign = await repository.getCampaignById(campaignId);

    if (campaign == null) {
      try {
        return MockData.campaignModels.firstWhere((c) => c.id == campaignId);
      } catch (e) {
        return null;
      }
    }

    return campaign;
  } catch (e) {
    try {
      return MockData.campaignModels.firstWhere((c) => c.id == campaignId);
    } catch (e) {
      return null;
    }
  }
});

// Popular Campaigns Provider
final popularCampaignsProvider = FutureProvider.autoDispose<List<CampaignModel>>((ref) async {
  try {
    final repository = ref.read(campaignRepositoryProvider);
    final campaigns = await repository.getPopularCampaigns(limit: 10);

    if (campaigns.isEmpty && MockData.campaignModels.isNotEmpty) {
      return MockData.campaignModels.take(10).toList();
    }

    return campaigns;
  } catch (e) {
    return MockData.campaignModels.take(10).toList();
  }
});

// Ending Soon Campaigns Provider
final endingSoonCampaignsProvider = FutureProvider.autoDispose<List<CampaignModel>>((ref) async {
  try {
    final repository = ref.read(campaignRepositoryProvider);
    final campaigns = await repository.getEndingSoonCampaigns(limit: 10);

    if (campaigns.isEmpty && MockData.campaignModels.isNotEmpty) {
      // Client-side filter for ending soon
      final now = DateTime.now();
      final threeDaysLater = now.add(const Duration(days: 3));

      return MockData.campaignModels
          .where((c) => c.endDate.isAfter(now) && c.endDate.isBefore(threeDaysLater))
          .toList();
    }

    return campaigns;
  } catch (e) {
    final now = DateTime.now();
    final threeDaysLater = now.add(const Duration(days: 3));

    return MockData.campaignModels
        .where((c) => c.endDate.isAfter(now) && c.endDate.isBefore(threeDaysLater))
        .toList();
  }
});

// Campaigns by Type Provider
final campaignsByTypeProvider = FutureProvider.autoDispose.family<List<CampaignModel>, CampaignType>((ref, type) async {
  try {
    final repository = ref.read(campaignRepositoryProvider);
    final campaigns = await repository.getAllCampaigns(type: type);

    if (campaigns.isEmpty && MockData.campaignModels.isNotEmpty) {
      return MockData.campaignModels.where((c) => c.type == type).toList();
    }

    return campaigns;
  } catch (e) {
    return MockData.campaignModels.where((c) => c.type == type).toList();
  }
});

// Campaigns by Creator Provider
final campaignsByCreatorProvider = FutureProvider.autoDispose.family<List<CampaignModel>, String>((ref, creatorId) async {
  try {
    final repository = ref.read(campaignRepositoryProvider);
    final campaigns = await repository.getCampaignsByCreator(creatorId);

    if (campaigns.isEmpty && MockData.campaignModels.isNotEmpty) {
      return MockData.campaignModels.where((c) => c.creatorId == creatorId).toList();
    }

    return campaigns;
  } catch (e) {
    return MockData.campaignModels.where((c) => c.creatorId == creatorId).toList();
  }
});

// Search Campaigns Provider
final searchCampaignsProvider = FutureProvider.autoDispose.family<List<CampaignModel>, String>((ref, query) async {
  if (query.trim().isEmpty) {
    return [];
  }

  try {
    final repository = ref.read(campaignRepositoryProvider);
    final campaigns = await repository.searchCampaigns(query);

    if (campaigns.isEmpty && MockData.campaignModels.isNotEmpty) {
      final lowerQuery = query.toLowerCase();
      return MockData.campaignModels.where((campaign) {
        return campaign.title.toLowerCase().contains(lowerQuery) ||
               campaign.description.toLowerCase().contains(lowerQuery);
      }).toList();
    }

    return campaigns;
  } catch (e) {
    final lowerQuery = query.toLowerCase();
    return MockData.campaignModels.where((campaign) {
      return campaign.title.toLowerCase().contains(lowerQuery) ||
             campaign.description.toLowerCase().contains(lowerQuery);
    }).toList();
  }
});

// Campaign Progress Provider
final campaignProgressProvider = Provider.family<double, CampaignModel>((ref, campaign) {
  final repository = ref.read(campaignRepositoryProvider);
  return repository.calculateProgress(campaign);
});

// Days Remaining Provider
final daysRemainingProvider = Provider.family<int, CampaignModel>((ref, campaign) {
  final repository = ref.read(campaignRepositoryProvider);
  return repository.getDaysRemaining(campaign);
});

// Campaign Stream Provider (Realtime)
final campaignStreamProvider = StreamProvider.autoDispose.family<CampaignModel?, String>((ref, campaignId) {
  final repository = ref.read(campaignRepositoryProvider);
  return repository.subscribeToCampaign(campaignId);
});

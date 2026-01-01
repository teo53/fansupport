import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local_datasource.dart';
import '../../data/repositories/repositories.dart';
import '../../domain/repositories/repositories.dart';

/// ============ DataSources ============

final localDataSourceProvider = Provider<LocalDataSource>((ref) {
  return LocalDataSource();
});

/// ============ Repositories ============

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.read(localDataSourceProvider));
});

final idolRepositoryProvider = Provider<IdolRepository>((ref) {
  return IdolRepositoryImpl(ref.read(localDataSourceProvider));
});

final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepositoryImpl(ref.read(localDataSourceProvider));
});

final campaignRepositoryProvider = Provider<CampaignRepository>((ref) {
  return CampaignRepositoryImpl(ref.read(localDataSourceProvider));
});

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepositoryImpl(ref.read(localDataSourceProvider));
});

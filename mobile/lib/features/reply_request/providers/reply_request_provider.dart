import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../models/reply_request_model.dart';
import '../repositories/reply_request_repository.dart';

/// Repository provider
final replyRequestRepositoryProvider = Provider<ReplyRequestRepository>((ref) {
  return ReplyRequestRepository();
});

/// Inbox requests provider - fetches user's reply requests
final inboxRequestsProvider = FutureProvider.autoDispose
    .family<PaginatedResponse<ReplyRequest>, InboxFilter>((ref, filter) async {
  final repo = ref.watch(replyRequestRepositoryProvider);
  final authState = ref.watch(authStateProvider).value;

  if (authState == null || !authState.isLoggedIn) {
    throw Exception('Not authenticated');
  }

  return repo.getMyRequests(
    token: authState.token!,
    status: filter.status,
    page: filter.page,
    limit: filter.limit,
  );
});

/// Single request detail provider
final replyRequestDetailProvider = FutureProvider.autoDispose
    .family<ReplyRequest, String>((ref, requestId) async {
  final repo = ref.watch(replyRequestRepositoryProvider);
  final authState = ref.watch(authStateProvider).value;

  if (authState == null || !authState.isLoggedIn) {
    throw Exception('Not authenticated');
  }

  return repo.getRequestById(requestId, authState.token!);
});

/// Creator queue provider
final creatorQueueProvider = FutureProvider.autoDispose
    .family<CreatorQueueResponse, QueueFilter>((ref, filter) async {
  final repo = ref.watch(replyRequestRepositoryProvider);
  final authState = ref.watch(authStateProvider).value;

  if (authState == null || !authState.isLoggedIn) {
    throw Exception('Not authenticated');
  }

  return repo.getCreatorQueue(
    token: authState.token!,
    page: filter.page,
    limit: filter.limit,
  );
});

/// Creator products provider
final creatorProductsProvider = FutureProvider.autoDispose
    .family<CreatorProductsResponse, String>((ref, creatorId) async {
  final repo = ref.watch(replyRequestRepositoryProvider);
  return repo.getCreatorProducts(creatorId);
});

/// Create request state notifier using StateProvider pattern (simpler for Riverpod 3.x)
final createRequestStateProvider = StateProvider.autoDispose<AsyncValue<ReplyRequest?>>((ref) {
  return const AsyncValue.data(null);
});

/// Create request action provider
Future<ReplyRequest?> createRequest(WidgetRef ref, CreateReplyRequestDto dto) async {
  final repo = ref.read(replyRequestRepositoryProvider);
  final token = ref.read(authStateProvider).value?.token;

  if (token == null) {
    ref.read(createRequestStateProvider.notifier).state =
        AsyncValue.error(Exception('Not authenticated'), StackTrace.current);
    return null;
  }

  ref.read(createRequestStateProvider.notifier).state = const AsyncValue.loading();

  try {
    final request = await repo.createRequest(dto, token);
    ref.read(createRequestStateProvider.notifier).state = AsyncValue.data(request);
    return request;
  } catch (e, st) {
    ref.read(createRequestStateProvider.notifier).state = AsyncValue.error(e, st);
    return null;
  }
}

/// Deliver reply state provider
final deliverReplyStateProvider = StateProvider.autoDispose<AsyncValue<ReplyRequest?>>((ref) {
  return const AsyncValue.data(null);
});

/// Deliver reply action
Future<ReplyRequest?> deliverReply(WidgetRef ref, String requestId, DeliverReplyDto dto) async {
  final repo = ref.read(replyRequestRepositoryProvider);
  final token = ref.read(authStateProvider).value?.token;

  if (token == null) {
    ref.read(deliverReplyStateProvider.notifier).state =
        AsyncValue.error(Exception('Not authenticated'), StackTrace.current);
    return null;
  }

  ref.read(deliverReplyStateProvider.notifier).state = const AsyncValue.loading();

  try {
    final request = await repo.deliverReply(requestId, dto, token);
    ref.read(deliverReplyStateProvider.notifier).state = AsyncValue.data(request);
    return request;
  } catch (e, st) {
    ref.read(deliverReplyStateProvider.notifier).state = AsyncValue.error(e, st);
    return null;
  }
}

/// Reject request action
Future<ReplyRequest?> rejectRequest(WidgetRef ref, String requestId, String reason) async {
  final repo = ref.read(replyRequestRepositoryProvider);
  final token = ref.read(authStateProvider).value?.token;

  if (token == null) {
    ref.read(deliverReplyStateProvider.notifier).state =
        AsyncValue.error(Exception('Not authenticated'), StackTrace.current);
    return null;
  }

  ref.read(deliverReplyStateProvider.notifier).state = const AsyncValue.loading();

  try {
    final request = await repo.rejectRequest(requestId, reason, token);
    ref.read(deliverReplyStateProvider.notifier).state = AsyncValue.data(request);
    return request;
  } catch (e, st) {
    ref.read(deliverReplyStateProvider.notifier).state = AsyncValue.error(e, st);
    return null;
  }
}

/// Start request action
Future<ReplyRequest?> startRequest(WidgetRef ref, String requestId) async {
  final repo = ref.read(replyRequestRepositoryProvider);
  final token = ref.read(authStateProvider).value?.token;

  if (token == null) {
    ref.read(deliverReplyStateProvider.notifier).state =
        AsyncValue.error(Exception('Not authenticated'), StackTrace.current);
    return null;
  }

  ref.read(deliverReplyStateProvider.notifier).state = const AsyncValue.loading();

  try {
    final request = await repo.startRequest(requestId, token);
    ref.read(deliverReplyStateProvider.notifier).state = AsyncValue.data(request);
    return request;
  } catch (e, st) {
    ref.read(deliverReplyStateProvider.notifier).state = AsyncValue.error(e, st);
    return null;
  }
}

/// Fan feedback state provider
final fanFeedbackStateProvider = StateProvider.autoDispose<AsyncValue<ReplyDelivery?>>((ref) {
  return const AsyncValue.data(null);
});

/// Submit feedback action
Future<ReplyDelivery?> submitFeedback(WidgetRef ref, String requestId, FanFeedbackDto dto) async {
  final repo = ref.read(replyRequestRepositoryProvider);
  final token = ref.read(authStateProvider).value?.token;

  if (token == null) {
    ref.read(fanFeedbackStateProvider.notifier).state =
        AsyncValue.error(Exception('Not authenticated'), StackTrace.current);
    return null;
  }

  ref.read(fanFeedbackStateProvider.notifier).state = const AsyncValue.loading();

  try {
    final delivery = await repo.submitFeedback(requestId, dto, token);
    ref.read(fanFeedbackStateProvider.notifier).state = AsyncValue.data(delivery);
    return delivery;
  } catch (e, st) {
    ref.read(fanFeedbackStateProvider.notifier).state = AsyncValue.error(e, st);
    return null;
  }
}

/// Filter classes
class InboxFilter {
  final ReplyRequestStatus? status;
  final int page;
  final int limit;

  const InboxFilter({
    this.status,
    this.page = 1,
    this.limit = 20,
  });

  InboxFilter copyWith({
    ReplyRequestStatus? status,
    int? page,
    int? limit,
  }) {
    return InboxFilter(
      status: status ?? this.status,
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InboxFilter &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          page == other.page &&
          limit == other.limit;

  @override
  int get hashCode => status.hashCode ^ page.hashCode ^ limit.hashCode;
}

class QueueFilter {
  final int page;
  final int limit;

  const QueueFilter({
    this.page = 1,
    this.limit = 20,
  });

  QueueFilter copyWith({
    int? page,
    int? limit,
  }) {
    return QueueFilter(
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QueueFilter &&
          runtimeType == other.runtimeType &&
          page == other.page &&
          limit == other.limit;

  @override
  int get hashCode => page.hashCode ^ limit.hashCode;
}

/// Request composer state
class RequestComposerState {
  final String? creatorId;
  final String? selectedProductId;
  final String? selectedSlaId;
  final String requestMessage;
  final bool isAnonymous;
  final double? calculatedPrice;

  const RequestComposerState({
    this.creatorId,
    this.selectedProductId,
    this.selectedSlaId,
    this.requestMessage = '',
    this.isAnonymous = false,
    this.calculatedPrice,
  });

  RequestComposerState copyWith({
    String? creatorId,
    String? selectedProductId,
    String? selectedSlaId,
    String? requestMessage,
    bool? isAnonymous,
    double? calculatedPrice,
  }) {
    return RequestComposerState(
      creatorId: creatorId ?? this.creatorId,
      selectedProductId: selectedProductId ?? this.selectedProductId,
      selectedSlaId: selectedSlaId ?? this.selectedSlaId,
      requestMessage: requestMessage ?? this.requestMessage,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      calculatedPrice: calculatedPrice ?? this.calculatedPrice,
    );
  }

  bool get isValid =>
      creatorId != null &&
      selectedProductId != null &&
      selectedSlaId != null &&
      requestMessage.isNotEmpty;
}

/// Request composer notifier using Notifier pattern
class RequestComposerNotifier extends Notifier<RequestComposerState> {
  @override
  RequestComposerState build() {
    return const RequestComposerState();
  }

  void setCreatorId(String creatorId) {
    state = state.copyWith(creatorId: creatorId);
  }

  void setProduct(String productId) {
    state = RequestComposerState(
      creatorId: state.creatorId,
      selectedProductId: productId,
      selectedSlaId: null, // Reset SLA when product changes
      requestMessage: state.requestMessage,
      isAnonymous: state.isAnonymous,
    );
  }

  void setSla(String slaId) {
    state = state.copyWith(selectedSlaId: slaId);
  }

  void setMessage(String message) {
    state = state.copyWith(requestMessage: message);
  }

  void setAnonymous(bool isAnonymous) {
    state = state.copyWith(isAnonymous: isAnonymous);
  }

  void setCalculatedPrice(double price) {
    state = state.copyWith(calculatedPrice: price);
  }

  void reset() {
    state = const RequestComposerState();
  }
}

final requestComposerProvider =
    NotifierProvider<RequestComposerNotifier, RequestComposerState>(() {
  return RequestComposerNotifier();
});

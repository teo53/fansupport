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

/// Create request notifier
class CreateRequestNotifier extends StateNotifier<AsyncValue<ReplyRequest?>> {
  final ReplyRequestRepository _repo;
  final String _token;

  CreateRequestNotifier(this._repo, this._token)
      : super(const AsyncValue.data(null));

  Future<ReplyRequest?> createRequest(CreateReplyRequestDto dto) async {
    state = const AsyncValue.loading();

    try {
      final request = await _repo.createRequest(dto, _token);
      state = AsyncValue.data(request);
      return request;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

final createRequestProvider = StateNotifierProvider.autoDispose<
    CreateRequestNotifier, AsyncValue<ReplyRequest?>>((ref) {
  final repo = ref.watch(replyRequestRepositoryProvider);
  final authState = ref.watch(authStateProvider).value;

  if (authState == null || !authState.isLoggedIn) {
    throw Exception('Not authenticated');
  }

  return CreateRequestNotifier(repo, authState.token!);
});

/// Deliver reply notifier (for creators)
class DeliverReplyNotifier extends StateNotifier<AsyncValue<ReplyRequest?>> {
  final ReplyRequestRepository _repo;
  final String _token;

  DeliverReplyNotifier(this._repo, this._token)
      : super(const AsyncValue.data(null));

  Future<ReplyRequest?> deliver(String requestId, DeliverReplyDto dto) async {
    state = const AsyncValue.loading();

    try {
      final request = await _repo.deliverReply(requestId, dto, _token);
      state = AsyncValue.data(request);
      return request;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<ReplyRequest?> reject(String requestId, String reason) async {
    state = const AsyncValue.loading();

    try {
      final request = await _repo.rejectRequest(requestId, reason, _token);
      state = AsyncValue.data(request);
      return request;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<ReplyRequest?> start(String requestId) async {
    state = const AsyncValue.loading();

    try {
      final request = await _repo.startRequest(requestId, _token);
      state = AsyncValue.data(request);
      return request;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

final deliverReplyProvider = StateNotifierProvider.autoDispose<
    DeliverReplyNotifier, AsyncValue<ReplyRequest?>>((ref) {
  final repo = ref.watch(replyRequestRepositoryProvider);
  final authState = ref.watch(authStateProvider).value;

  if (authState == null || !authState.isLoggedIn) {
    throw Exception('Not authenticated');
  }

  return DeliverReplyNotifier(repo, authState.token!);
});

/// Fan feedback notifier
class FanFeedbackNotifier extends StateNotifier<AsyncValue<ReplyDelivery?>> {
  final ReplyRequestRepository _repo;
  final String _token;

  FanFeedbackNotifier(this._repo, this._token)
      : super(const AsyncValue.data(null));

  Future<ReplyDelivery?> submitFeedback(
      String requestId, FanFeedbackDto dto) async {
    state = const AsyncValue.loading();

    try {
      final delivery = await _repo.submitFeedback(requestId, dto, _token);
      state = AsyncValue.data(delivery);
      return delivery;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

final fanFeedbackProvider = StateNotifierProvider.autoDispose<FanFeedbackNotifier,
    AsyncValue<ReplyDelivery?>>((ref) {
  final repo = ref.watch(replyRequestRepositoryProvider);
  final authState = ref.watch(authStateProvider).value;

  if (authState == null || !authState.isLoggedIn) {
    throw Exception('Not authenticated');
  }

  return FanFeedbackNotifier(repo, authState.token!);
});

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

/// Request composer state notifier
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

class RequestComposerNotifier extends StateNotifier<RequestComposerState> {
  RequestComposerNotifier([String? initialCreatorId])
      : super(RequestComposerState(creatorId: initialCreatorId));

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
    StateNotifierProvider.autoDispose<RequestComposerNotifier, RequestComposerState>(
        (ref) {
  return RequestComposerNotifier();
});

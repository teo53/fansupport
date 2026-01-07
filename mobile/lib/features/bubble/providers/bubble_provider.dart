import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/supabase_bubble_repository.dart';
import '../../../shared/models/bubble_message_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/mock/mock_data.dart';

// Bubble Repository Provider
final bubbleRepositoryProvider = Provider<SupabaseBubbleRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return SupabaseBubbleRepository(supabase);
});

// Bubble Messages by Idol Provider (with fallback to mock data)
final bubbleMessagesByIdolProvider = FutureProvider.autoDispose.family<List<BubbleMessageModel>, String>((ref, idolId) async {
  try {
    final repository = ref.read(bubbleRepositoryProvider);
    final messages = await repository.getBubbleMessages(idolId: idolId);

    if (messages.isEmpty && MockData.bubbleMessages.isNotEmpty) {
      return MockData.bubbleMessages.where((m) => m.idolId == idolId).toList();
    }

    return messages;
  } catch (e) {
    return MockData.bubbleMessages.where((m) => m.idolId == idolId).toList();
  }
});

// All Bubble Messages Provider (Feed)
final allBubbleMessagesProvider = FutureProvider.autoDispose<List<BubbleMessageModel>>((ref) async {
  try {
    final repository = ref.read(bubbleRepositoryProvider);
    final messages = await repository.getAllBubbleMessages();

    if (messages.isEmpty && MockData.bubbleMessages.isNotEmpty) {
      return MockData.bubbleMessages;
    }

    return messages;
  } catch (e) {
    return MockData.bubbleMessages;
  }
});

// Subscribed Bubble Messages Provider
final subscribedBubbleMessagesProvider = FutureProvider.autoDispose<List<BubbleMessageModel>>((ref) async {
  try {
    final repository = ref.read(bubbleRepositoryProvider);
    final messages = await repository.getSubscribedBubbleMessages();

    if (messages.isEmpty && MockData.bubbleMessages.isNotEmpty) {
      // Client-side filter for demo
      return MockData.bubbleMessages;
    }

    return messages;
  } catch (e) {
    return MockData.bubbleMessages;
  }
});

// Bubble Messages Stream Provider (Realtime)
final bubbleMessagesStreamProvider = StreamProvider.autoDispose.family<List<BubbleMessageModel>, String>((ref, idolId) {
  final repository = ref.read(bubbleRepositoryProvider);
  return repository.subscribeToBubbleMessages(idolId);
});

// All Bubble Messages Stream Provider (Feed Realtime)
final allBubbleMessagesStreamProvider = StreamProvider.autoDispose<List<BubbleMessageModel>>((ref) {
  final repository = ref.read(bubbleRepositoryProvider);
  return repository.subscribeToAllBubbleMessages();
});

// Like Bubble Message Provider
final likeBubbleMessageProvider = FutureProvider.autoDispose.family<void, String>((ref, messageId) async {
  final repository = ref.read(bubbleRepositoryProvider);
  await repository.likeBubbleMessage(messageId);
});

// Create Bubble Message Provider (for Idol users)
final createBubbleMessageProvider = FutureProvider.autoDispose.family<String, CreateBubbleMessageParams>((ref, params) async {
  final repository = ref.read(bubbleRepositoryProvider);
  return await repository.createBubbleMessage(
    type: params.type,
    content: params.content,
    mediaUrl: params.mediaUrl,
    duration: params.duration,
    isSubscriberOnly: params.isSubscriberOnly,
  );
});

// Create Bubble Message Parameters
class CreateBubbleMessageParams {
  final BubbleMessageType type;
  final String content;
  final String? mediaUrl;
  final int? duration;
  final bool isSubscriberOnly;

  CreateBubbleMessageParams({
    required this.type,
    required this.content,
    this.mediaUrl,
    this.duration,
    this.isSubscriberOnly = false,
  });
}

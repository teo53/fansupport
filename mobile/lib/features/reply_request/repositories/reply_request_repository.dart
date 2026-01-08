import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config/app_config.dart';
import '../models/reply_request_model.dart';

/// Repository for reply request API calls
class ReplyRequestRepository {
  final http.Client _client;
  final String _baseUrl;

  ReplyRequestRepository({
    http.Client? client,
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? AppConfig.apiBaseUrl;

  /// Get auth headers
  Map<String, String> _headers(String? token) {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Create a new reply request
  Future<ReplyRequest> createRequest(
    CreateReplyRequestDto dto,
    String token,
  ) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/reply-requests'),
      headers: _headers(token),
      body: jsonEncode(dto.toJson()),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body)['data'];
      return ReplyRequest.fromJson(data);
    } else {
      throw Exception('Failed to create request: ${response.body}');
    }
  }

  /// Get user's reply requests (inbox)
  Future<PaginatedResponse<ReplyRequest>> getMyRequests({
    required String token,
    ReplyRequestStatus? status,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      if (status != null) 'status': status.value,
    };

    final uri = Uri.parse('$_baseUrl/reply-requests')
        .replace(queryParameters: queryParams);

    final response = await _client.get(uri, headers: _headers(token));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body)['data'];
      return PaginatedResponse.fromJson(
        json,
        (item) => ReplyRequest.fromJson(item as Map<String, dynamic>),
      );
    } else {
      throw Exception('Failed to get requests: ${response.body}');
    }
  }

  /// Get single request by ID
  Future<ReplyRequest> getRequestById(String id, String token) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/reply-requests/$id'),
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      return ReplyRequest.fromJson(data);
    } else {
      throw Exception('Failed to get request: ${response.body}');
    }
  }

  /// Get creator's queue
  Future<CreatorQueueResponse> getCreatorQueue({
    required String token,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };

    final uri = Uri.parse('$_baseUrl/reply-requests/creator/queue')
        .replace(queryParameters: queryParams);

    final response = await _client.get(uri, headers: _headers(token));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body)['data'];
      return CreatorQueueResponse.fromJson(json);
    } else {
      throw Exception('Failed to get queue: ${response.body}');
    }
  }

  /// Get creator's products
  Future<CreatorProductsResponse> getCreatorProducts(String creatorId) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/creators/$creatorId/products'),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body)['data'];
      return CreatorProductsResponse.fromJson(json);
    } else {
      throw Exception('Failed to get products: ${response.body}');
    }
  }

  /// Start working on a request (creator)
  Future<ReplyRequest> startRequest(String requestId, String token) async {
    final response = await _client.patch(
      Uri.parse('$_baseUrl/reply-requests/$requestId/start'),
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      return ReplyRequest.fromJson(data);
    } else {
      throw Exception('Failed to start request: ${response.body}');
    }
  }

  /// Deliver reply (creator)
  Future<ReplyRequest> deliverReply(
    String requestId,
    DeliverReplyDto dto,
    String token,
  ) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/reply-requests/$requestId/deliver'),
      headers: _headers(token),
      body: jsonEncode(dto.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body)['data'];
      return ReplyRequest.fromJson(data);
    } else {
      throw Exception('Failed to deliver reply: ${response.body}');
    }
  }

  /// Reject request (creator)
  Future<ReplyRequest> rejectRequest(
    String requestId,
    String reason,
    String token,
  ) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/reply-requests/$requestId/reject'),
      headers: _headers(token),
      body: jsonEncode({'reason': reason}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body)['data'];
      return ReplyRequest.fromJson(data);
    } else {
      throw Exception('Failed to reject request: ${response.body}');
    }
  }

  /// Submit fan feedback
  Future<ReplyDelivery> submitFeedback(
    String requestId,
    FanFeedbackDto dto,
    String token,
  ) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/reply-requests/$requestId/feedback'),
      headers: _headers(token),
      body: jsonEncode(dto.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body)['data'];
      return ReplyDelivery.fromJson(data);
    } else {
      throw Exception('Failed to submit feedback: ${response.body}');
    }
  }
}

/// Paginated response wrapper
class PaginatedResponse<T> {
  final List<T> data;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const PaginatedResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    final meta = json['meta'] as Map<String, dynamic>;
    return PaginatedResponse(
      data: (json['data'] as List<dynamic>).map(fromJsonT).toList(),
      total: meta['total'] as int,
      page: meta['page'] as int,
      limit: meta['limit'] as int,
      totalPages: meta['totalPages'] as int,
    );
  }

  bool get hasMore => page < totalPages;
}

/// Creator queue response
class CreatorQueueResponse {
  final List<ReplyRequest> data;
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final QueueStats stats;

  const CreatorQueueResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.stats,
  });

  factory CreatorQueueResponse.fromJson(Map<String, dynamic> json) {
    final meta = json['meta'] as Map<String, dynamic>;
    return CreatorQueueResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => ReplyRequest.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: meta['total'] as int,
      page: meta['page'] as int,
      limit: meta['limit'] as int,
      totalPages: meta['totalPages'] as int,
      stats: QueueStats.fromJson(json['stats'] as Map<String, dynamic>),
    );
  }
}

/// Queue statistics
class QueueStats {
  final int queueCount;
  final int todayDelivered;
  final int totalDelivered;
  final int dailySlotLimit;
  final int remainingSlots;

  const QueueStats({
    required this.queueCount,
    required this.todayDelivered,
    required this.totalDelivered,
    required this.dailySlotLimit,
    required this.remainingSlots,
  });

  factory QueueStats.fromJson(Map<String, dynamic> json) {
    return QueueStats(
      queueCount: json['queueCount'] as int,
      todayDelivered: json['todayDelivered'] as int,
      totalDelivered: json['totalDelivered'] as int,
      dailySlotLimit: json['dailySlotLimit'] as int,
      remainingSlots: json['remainingSlots'] as int,
    );
  }
}

/// Creator products response
class CreatorProductsResponse {
  final List<ReplyProduct> products;
  final SlotPolicy slotPolicy;
  final TodayStats todayStats;

  const CreatorProductsResponse({
    required this.products,
    required this.slotPolicy,
    required this.todayStats,
  });

  factory CreatorProductsResponse.fromJson(Map<String, dynamic> json) {
    return CreatorProductsResponse(
      products: (json['products'] as List<dynamic>)
          .map((e) => ReplyProduct.fromJson(e as Map<String, dynamic>))
          .toList(),
      slotPolicy: SlotPolicy.fromJson(json['slotPolicy'] as Map<String, dynamic>),
      todayStats: TodayStats.fromJson(json['todayStats'] as Map<String, dynamic>),
    );
  }
}

/// Slot policy
class SlotPolicy {
  final int dailySlotLimit;
  final bool isAutoClose;

  const SlotPolicy({
    required this.dailySlotLimit,
    required this.isAutoClose,
  });

  factory SlotPolicy.fromJson(Map<String, dynamic> json) {
    return SlotPolicy(
      dailySlotLimit: json['dailySlotLimit'] as int? ?? 10,
      isAutoClose: json['isAutoClose'] as bool? ?? true,
    );
  }
}

/// Today's statistics
class TodayStats {
  final int requestCount;
  final int remainingSlots;

  const TodayStats({
    required this.requestCount,
    required this.remainingSlots,
  });

  factory TodayStats.fromJson(Map<String, dynamic> json) {
    return TodayStats(
      requestCount: json['requestCount'] as int,
      remainingSlots: json['remainingSlots'] as int,
    );
  }
}

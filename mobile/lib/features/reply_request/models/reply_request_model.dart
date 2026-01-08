import 'package:flutter/foundation.dart';

/// Reply request status enum matching backend
enum ReplyRequestStatus {
  pendingPayment,
  queued,
  inProgress,
  delivered,
  expired,
  refunded,
  rejected,
  cancelled,
}

extension ReplyRequestStatusExtension on ReplyRequestStatus {
  String get value {
    switch (this) {
      case ReplyRequestStatus.pendingPayment:
        return 'PENDING_PAYMENT';
      case ReplyRequestStatus.queued:
        return 'QUEUED';
      case ReplyRequestStatus.inProgress:
        return 'IN_PROGRESS';
      case ReplyRequestStatus.delivered:
        return 'DELIVERED';
      case ReplyRequestStatus.expired:
        return 'EXPIRED';
      case ReplyRequestStatus.refunded:
        return 'REFUNDED';
      case ReplyRequestStatus.rejected:
        return 'REJECTED';
      case ReplyRequestStatus.cancelled:
        return 'CANCELLED';
    }
  }

  String get displayName {
    switch (this) {
      case ReplyRequestStatus.pendingPayment:
        return '결제 대기';
      case ReplyRequestStatus.queued:
        return '대기중';
      case ReplyRequestStatus.inProgress:
        return '작업중';
      case ReplyRequestStatus.delivered:
        return '완료';
      case ReplyRequestStatus.expired:
        return '만료';
      case ReplyRequestStatus.refunded:
        return '환불됨';
      case ReplyRequestStatus.rejected:
        return '거절됨';
      case ReplyRequestStatus.cancelled:
        return '취소됨';
    }
  }

  bool get isActive =>
      this == ReplyRequestStatus.queued || this == ReplyRequestStatus.inProgress;

  bool get isCompleted => this == ReplyRequestStatus.delivered;

  bool get isTerminal =>
      this == ReplyRequestStatus.delivered ||
      this == ReplyRequestStatus.expired ||
      this == ReplyRequestStatus.refunded ||
      this == ReplyRequestStatus.rejected ||
      this == ReplyRequestStatus.cancelled;

  static ReplyRequestStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'PENDING_PAYMENT':
        return ReplyRequestStatus.pendingPayment;
      case 'QUEUED':
        return ReplyRequestStatus.queued;
      case 'IN_PROGRESS':
        return ReplyRequestStatus.inProgress;
      case 'DELIVERED':
        return ReplyRequestStatus.delivered;
      case 'EXPIRED':
        return ReplyRequestStatus.expired;
      case 'REFUNDED':
        return ReplyRequestStatus.refunded;
      case 'REJECTED':
        return ReplyRequestStatus.rejected;
      case 'CANCELLED':
        return ReplyRequestStatus.cancelled;
      default:
        return ReplyRequestStatus.pendingPayment;
    }
  }
}

/// Reply content type enum
enum ReplyContentType {
  text,
  voice,
  photo,
  video,
}

extension ReplyContentTypeExtension on ReplyContentType {
  String get value {
    switch (this) {
      case ReplyContentType.text:
        return 'TEXT';
      case ReplyContentType.voice:
        return 'VOICE';
      case ReplyContentType.photo:
        return 'PHOTO';
      case ReplyContentType.video:
        return 'VIDEO';
    }
  }

  String get displayName {
    switch (this) {
      case ReplyContentType.text:
        return '텍스트 메시지';
      case ReplyContentType.voice:
        return '보이스 메시지';
      case ReplyContentType.photo:
        return '사진';
      case ReplyContentType.video:
        return '영상';
    }
  }

  static ReplyContentType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'TEXT':
        return ReplyContentType.text;
      case 'VOICE':
        return ReplyContentType.voice;
      case 'PHOTO':
        return ReplyContentType.photo;
      case 'VIDEO':
        return ReplyContentType.video;
      default:
        return ReplyContentType.text;
    }
  }
}

/// Reply product model
@immutable
class ReplyProduct {
  final String id;
  final String idolProfileId;
  final String name;
  final String? description;
  final ReplyContentType contentType;
  final double basePrice;
  final bool isActive;
  final int sortOrder;
  final List<ReplySLA> slaOptions;

  const ReplyProduct({
    required this.id,
    required this.idolProfileId,
    required this.name,
    this.description,
    required this.contentType,
    required this.basePrice,
    this.isActive = true,
    this.sortOrder = 0,
    this.slaOptions = const [],
  });

  factory ReplyProduct.fromJson(Map<String, dynamic> json) {
    return ReplyProduct(
      id: json['id'] as String,
      idolProfileId: json['idolProfileId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      contentType: ReplyContentTypeExtension.fromString(json['contentType'] as String),
      basePrice: (json['basePrice'] as num).toDouble(),
      isActive: json['isActive'] as bool? ?? true,
      sortOrder: json['sortOrder'] as int? ?? 0,
      slaOptions: (json['slaOptions'] as List<dynamic>?)
              ?.map((e) => ReplySLA.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idolProfileId': idolProfileId,
      'name': name,
      'description': description,
      'contentType': contentType.value,
      'basePrice': basePrice,
      'isActive': isActive,
      'sortOrder': sortOrder,
      'slaOptions': slaOptions.map((e) => e.toJson()).toList(),
    };
  }
}

/// SLA option model
@immutable
class ReplySLA {
  final String id;
  final String replyProductId;
  final String name;
  final int deadlineHours;
  final double priceMultiplier;
  final bool isActive;
  final int sortOrder;

  const ReplySLA({
    required this.id,
    required this.replyProductId,
    required this.name,
    required this.deadlineHours,
    this.priceMultiplier = 1.0,
    this.isActive = true,
    this.sortOrder = 0,
  });

  factory ReplySLA.fromJson(Map<String, dynamic> json) {
    return ReplySLA(
      id: json['id'] as String,
      replyProductId: json['replyProductId'] as String,
      name: json['name'] as String,
      deadlineHours: json['deadlineHours'] as int,
      priceMultiplier: (json['priceMultiplier'] as num?)?.toDouble() ?? 1.0,
      isActive: json['isActive'] as bool? ?? true,
      sortOrder: json['sortOrder'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'replyProductId': replyProductId,
      'name': name,
      'deadlineHours': deadlineHours,
      'priceMultiplier': priceMultiplier,
      'isActive': isActive,
      'sortOrder': sortOrder,
    };
  }

  String get deadlineDisplay {
    if (deadlineHours >= 24) {
      return '${deadlineHours ~/ 24}일';
    }
    return '$deadlineHours시간';
  }
}

/// Simple user info for display
@immutable
class UserInfo {
  final String id;
  final String nickname;
  final String? profileImage;

  const UserInfo({
    required this.id,
    required this.nickname,
    this.profileImage,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'] as String,
      nickname: json['nickname'] as String,
      profileImage: json['profileImage'] as String?,
    );
  }

  factory UserInfo.anonymous() {
    return const UserInfo(
      id: 'anonymous',
      nickname: 'Anonymous',
      profileImage: null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'profileImage': profileImage,
    };
  }

  bool get isAnonymous => id == 'anonymous';
}

/// Reply delivery model
@immutable
class ReplyDelivery {
  final String id;
  final String replyRequestId;
  final String? textContent;
  final String? voiceUrl;
  final List<String> photoUrls;
  final String? videoUrl;
  final int? duration;
  final String? creatorNote;
  final int? fanRating;
  final String? fanFeedback;
  final bool isPublicAllowed;
  final DateTime createdAt;

  const ReplyDelivery({
    required this.id,
    required this.replyRequestId,
    this.textContent,
    this.voiceUrl,
    this.photoUrls = const [],
    this.videoUrl,
    this.duration,
    this.creatorNote,
    this.fanRating,
    this.fanFeedback,
    this.isPublicAllowed = false,
    required this.createdAt,
  });

  factory ReplyDelivery.fromJson(Map<String, dynamic> json) {
    return ReplyDelivery(
      id: json['id'] as String,
      replyRequestId: json['replyRequestId'] as String,
      textContent: json['textContent'] as String?,
      voiceUrl: json['voiceUrl'] as String?,
      photoUrls: (json['photoUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      videoUrl: json['videoUrl'] as String?,
      duration: json['duration'] as int?,
      creatorNote: json['creatorNote'] as String?,
      fanRating: json['fanRating'] as int?,
      fanFeedback: json['fanFeedback'] as String?,
      isPublicAllowed: json['isPublicAllowed'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'replyRequestId': replyRequestId,
      'textContent': textContent,
      'voiceUrl': voiceUrl,
      'photoUrls': photoUrls,
      'videoUrl': videoUrl,
      'duration': duration,
      'creatorNote': creatorNote,
      'fanRating': fanRating,
      'fanFeedback': fanFeedback,
      'isPublicAllowed': isPublicAllowed,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  bool get hasRating => fanRating != null;
}

/// Reply request model
@immutable
class ReplyRequest {
  final String id;
  final String requesterId;
  final String creatorId;
  final String productId;
  final String slaId;
  final UserInfo? requester;
  final UserInfo? creator;
  final ReplyProduct? product;
  final ReplySLA? sla;
  final String requestMessage;
  final bool isAnonymous;
  final double basePrice;
  final double slaPrice;
  final double totalPrice;
  final double escrowAmount;
  final ReplyRequestStatus status;
  final int? queuePosition;
  final DateTime? paidAt;
  final DateTime? queuedAt;
  final DateTime? startedAt;
  final DateTime? deadlineAt;
  final DateTime? deliveredAt;
  final DateTime? expiredAt;
  final DateTime? refundedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ReplyDelivery? delivery;

  const ReplyRequest({
    required this.id,
    required this.requesterId,
    required this.creatorId,
    required this.productId,
    required this.slaId,
    this.requester,
    this.creator,
    this.product,
    this.sla,
    required this.requestMessage,
    this.isAnonymous = false,
    required this.basePrice,
    required this.slaPrice,
    required this.totalPrice,
    required this.escrowAmount,
    required this.status,
    this.queuePosition,
    this.paidAt,
    this.queuedAt,
    this.startedAt,
    this.deadlineAt,
    this.deliveredAt,
    this.expiredAt,
    this.refundedAt,
    required this.createdAt,
    required this.updatedAt,
    this.delivery,
  });

  factory ReplyRequest.fromJson(Map<String, dynamic> json) {
    return ReplyRequest(
      id: json['id'] as String,
      requesterId: json['requesterId'] as String,
      creatorId: json['creatorId'] as String,
      productId: json['productId'] as String,
      slaId: json['slaId'] as String,
      requester: json['requester'] != null
          ? UserInfo.fromJson(json['requester'] as Map<String, dynamic>)
          : null,
      creator: json['creator'] != null
          ? UserInfo.fromJson(json['creator'] as Map<String, dynamic>)
          : null,
      product: json['product'] != null
          ? ReplyProduct.fromJson(json['product'] as Map<String, dynamic>)
          : null,
      sla: json['sla'] != null
          ? ReplySLA.fromJson(json['sla'] as Map<String, dynamic>)
          : null,
      requestMessage: json['requestMessage'] as String,
      isAnonymous: json['isAnonymous'] as bool? ?? false,
      basePrice: (json['basePrice'] as num).toDouble(),
      slaPrice: (json['slaPrice'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      escrowAmount: (json['escrowAmount'] as num).toDouble(),
      status: ReplyRequestStatusExtension.fromString(json['status'] as String),
      queuePosition: json['queuePosition'] as int?,
      paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt'] as String) : null,
      queuedAt: json['queuedAt'] != null ? DateTime.parse(json['queuedAt'] as String) : null,
      startedAt: json['startedAt'] != null ? DateTime.parse(json['startedAt'] as String) : null,
      deadlineAt: json['deadlineAt'] != null ? DateTime.parse(json['deadlineAt'] as String) : null,
      deliveredAt: json['deliveredAt'] != null ? DateTime.parse(json['deliveredAt'] as String) : null,
      expiredAt: json['expiredAt'] != null ? DateTime.parse(json['expiredAt'] as String) : null,
      refundedAt: json['refundedAt'] != null ? DateTime.parse(json['refundedAt'] as String) : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      delivery: json['delivery'] != null
          ? ReplyDelivery.fromJson(json['delivery'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'requesterId': requesterId,
      'creatorId': creatorId,
      'productId': productId,
      'slaId': slaId,
      'requester': requester?.toJson(),
      'creator': creator?.toJson(),
      'product': product?.toJson(),
      'sla': sla?.toJson(),
      'requestMessage': requestMessage,
      'isAnonymous': isAnonymous,
      'basePrice': basePrice,
      'slaPrice': slaPrice,
      'totalPrice': totalPrice,
      'escrowAmount': escrowAmount,
      'status': status.value,
      'queuePosition': queuePosition,
      'paidAt': paidAt?.toIso8601String(),
      'queuedAt': queuedAt?.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'deadlineAt': deadlineAt?.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'expiredAt': expiredAt?.toIso8601String(),
      'refundedAt': refundedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'delivery': delivery?.toJson(),
    };
  }

  /// Get remaining time until deadline
  Duration? get remainingTime {
    if (deadlineAt == null) return null;
    final now = DateTime.now();
    if (deadlineAt!.isBefore(now)) return Duration.zero;
    return deadlineAt!.difference(now);
  }

  /// Get remaining time as display string
  String? get remainingTimeDisplay {
    final remaining = remainingTime;
    if (remaining == null) return null;
    if (remaining == Duration.zero) return '만료됨';

    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;

    if (hours > 24) {
      final days = hours ~/ 24;
      return '$days일 ${hours % 24}시간';
    }
    if (hours > 0) {
      return '$hours시간 $minutes분';
    }
    return '$minutes분';
  }

  /// Check if deadline is urgent (less than 6 hours)
  bool get isUrgent {
    final remaining = remainingTime;
    if (remaining == null) return false;
    return remaining.inHours < 6 && !status.isTerminal;
  }
}

/// Create reply request DTO
@immutable
class CreateReplyRequestDto {
  final String creatorId;
  final String productId;
  final String slaId;
  final String requestMessage;
  final bool isAnonymous;

  const CreateReplyRequestDto({
    required this.creatorId,
    required this.productId,
    required this.slaId,
    required this.requestMessage,
    this.isAnonymous = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'creatorId': creatorId,
      'productId': productId,
      'slaId': slaId,
      'requestMessage': requestMessage,
      'isAnonymous': isAnonymous,
    };
  }
}

/// Deliver reply DTO
@immutable
class DeliverReplyDto {
  final String? textContent;
  final String? voiceUrl;
  final List<String>? photoUrls;
  final String? videoUrl;
  final int? duration;
  final String? creatorNote;

  const DeliverReplyDto({
    this.textContent,
    this.voiceUrl,
    this.photoUrls,
    this.videoUrl,
    this.duration,
    this.creatorNote,
  });

  Map<String, dynamic> toJson() {
    return {
      if (textContent != null) 'textContent': textContent,
      if (voiceUrl != null) 'voiceUrl': voiceUrl,
      if (photoUrls != null) 'photoUrls': photoUrls,
      if (videoUrl != null) 'videoUrl': videoUrl,
      if (duration != null) 'duration': duration,
      if (creatorNote != null) 'creatorNote': creatorNote,
    };
  }
}

/// Fan feedback DTO
@immutable
class FanFeedbackDto {
  final int rating;
  final String? feedback;
  final bool isPublicAllowed;

  const FanFeedbackDto({
    required this.rating,
    this.feedback,
    this.isPublicAllowed = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      if (feedback != null) 'feedback': feedback,
      'isPublicAllowed': isPublicAllowed,
    };
  }
}

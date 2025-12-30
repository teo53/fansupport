import 'package:equatable/equatable.dart';

/// 캠페인/펀딩 타입
enum CampaignType {
  album('앨범 제작', 'ALBUM'),
  concert('콘서트/공연', 'CONCERT'),
  merchandise('굿즈 제작', 'MERCHANDISE'),
  mv('뮤직비디오', 'MV'),
  photobook('화보/포토북', 'PHOTOBOOK'),
  event('이벤트/팬미팅', 'EVENT'),
  debut('데뷔 지원', 'DEBUT'),
  advertisement('광고/전광판', 'ADVERTISEMENT'),
  other('기타', 'OTHER');

  final String displayName;
  final String code;
  const CampaignType(this.displayName, this.code);

  static CampaignType fromCode(String code) {
    return CampaignType.values.firstWhere(
      (e) => e.code == code,
      orElse: () => CampaignType.other,
    );
  }
}

/// 캠페인 상태
enum CampaignStatus {
  draft('준비중', 'DRAFT'),
  active('진행중', 'ACTIVE'),
  funded('펀딩성공', 'FUNDED'),
  completed('완료', 'COMPLETED'),
  failed('미달성', 'FAILED'),
  cancelled('취소', 'CANCELLED');

  final String displayName;
  final String code;
  const CampaignStatus(this.displayName, this.code);

  static CampaignStatus fromCode(String code) {
    return CampaignStatus.values.firstWhere(
      (e) => e.code == code,
      orElse: () => CampaignStatus.draft,
    );
  }
}

/// 펀딩 캠페인 모델
class CampaignModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final String? detailContent; // 상세 설명 (HTML 또는 마크다운)
  final CampaignType type;
  final CampaignStatus status;
  final String coverImage;
  final List<String> images;

  // 크리에이터 정보
  final String creatorId;
  final String creatorName;
  final String creatorImage;
  final bool isVerifiedCreator;

  // 금액 정보
  final int goalAmount;
  final int currentAmount;
  final int supporterCount;

  // 기간
  final DateTime startDate;
  final DateTime endDate;

  // 리워드
  final List<CampaignReward> rewards;

  // 업데이트/소식
  final List<CampaignUpdate> updates;

  // 태그
  final List<String> tags;

  // 통계
  final int viewCount;
  final int likeCount;
  final int shareCount;
  final bool isLiked;

  final DateTime createdAt;
  final DateTime? updatedAt;

  const CampaignModel({
    required this.id,
    required this.title,
    required this.description,
    this.detailContent,
    required this.type,
    this.status = CampaignStatus.active,
    required this.coverImage,
    this.images = const [],
    required this.creatorId,
    required this.creatorName,
    required this.creatorImage,
    this.isVerifiedCreator = false,
    required this.goalAmount,
    this.currentAmount = 0,
    this.supporterCount = 0,
    required this.startDate,
    required this.endDate,
    this.rewards = const [],
    this.updates = const [],
    this.tags = const [],
    this.viewCount = 0,
    this.likeCount = 0,
    this.shareCount = 0,
    this.isLiked = false,
    required this.createdAt,
    this.updatedAt,
  });

  /// 펀딩 달성률 (%)
  double get progressPercentage {
    if (goalAmount == 0) return 0;
    return (currentAmount / goalAmount * 100).clamp(0, 100);
  }

  /// 남은 일수
  int get daysLeft {
    final now = DateTime.now();
    if (now.isAfter(endDate)) return 0;
    return endDate.difference(now).inDays;
  }

  /// 펀딩 성공 여부
  bool get isFunded => currentAmount >= goalAmount;

  /// 진행 중 여부
  bool get isActive => status == CampaignStatus.active && DateTime.now().isBefore(endDate);

  factory CampaignModel.fromJson(Map<String, dynamic> json) {
    return CampaignModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      detailContent: json['detailContent'] as String?,
      type: CampaignType.fromCode(json['type'] as String? ?? 'OTHER'),
      status: CampaignStatus.fromCode(json['status'] as String? ?? 'ACTIVE'),
      coverImage: json['coverImage'] as String? ?? '',
      images: List<String>.from(json['images'] ?? []),
      creatorId: json['creatorId'] as String,
      creatorName: json['creatorName'] as String,
      creatorImage: json['creatorImage'] as String? ?? '',
      isVerifiedCreator: json['isVerifiedCreator'] as bool? ?? false,
      goalAmount: json['goalAmount'] as int,
      currentAmount: json['currentAmount'] as int? ?? 0,
      supporterCount: json['supporterCount'] as int? ?? 0,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      rewards: (json['rewards'] as List<dynamic>?)
              ?.map((e) => CampaignReward.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      updates: (json['updates'] as List<dynamic>?)
              ?.map((e) => CampaignUpdate.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      tags: List<String>.from(json['tags'] ?? []),
      viewCount: json['viewCount'] as int? ?? 0,
      likeCount: json['likeCount'] as int? ?? 0,
      shareCount: json['shareCount'] as int? ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String? ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'detailContent': detailContent,
      'type': type.code,
      'status': status.code,
      'coverImage': coverImage,
      'images': images,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'creatorImage': creatorImage,
      'isVerifiedCreator': isVerifiedCreator,
      'goalAmount': goalAmount,
      'currentAmount': currentAmount,
      'supporterCount': supporterCount,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'rewards': rewards.map((e) => e.toJson()).toList(),
      'updates': updates.map((e) => e.toJson()).toList(),
      'tags': tags,
      'viewCount': viewCount,
      'likeCount': likeCount,
      'shareCount': shareCount,
      'isLiked': isLiked,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, title, status, currentAmount, goalAmount];
}

/// 펀딩 리워드 모델
class CampaignReward extends Equatable {
  final String id;
  final String title;
  final String description;
  final int amount;
  final int supporterCount;
  final int? limit; // null이면 무제한
  final bool isPopular;
  final List<String> items; // 포함되는 아이템 목록
  final String? deliveryInfo;
  final DateTime? expectedDelivery;

  const CampaignReward({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    this.supporterCount = 0,
    this.limit,
    this.isPopular = false,
    this.items = const [],
    this.deliveryInfo,
    this.expectedDelivery,
  });

  bool get isSoldOut => limit != null && supporterCount >= limit!;
  int? get remaining => limit != null ? limit! - supporterCount : null;

  factory CampaignReward.fromJson(Map<String, dynamic> json) {
    return CampaignReward(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      amount: json['amount'] as int,
      supporterCount: json['supporterCount'] as int? ?? 0,
      limit: json['limit'] as int?,
      isPopular: json['isPopular'] as bool? ?? false,
      items: List<String>.from(json['items'] ?? []),
      deliveryInfo: json['deliveryInfo'] as String?,
      expectedDelivery: json['expectedDelivery'] != null
          ? DateTime.parse(json['expectedDelivery'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'amount': amount,
      'supporterCount': supporterCount,
      'limit': limit,
      'isPopular': isPopular,
      'items': items,
      'deliveryInfo': deliveryInfo,
      'expectedDelivery': expectedDelivery?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, title, amount];
}

/// 캠페인 업데이트/소식
class CampaignUpdate extends Equatable {
  final String id;
  final String title;
  final String content;
  final List<String> images;
  final DateTime createdAt;

  const CampaignUpdate({
    required this.id,
    required this.title,
    required this.content,
    this.images = const [],
    required this.createdAt,
  });

  factory CampaignUpdate.fromJson(Map<String, dynamic> json) {
    return CampaignUpdate(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      images: List<String>.from(json['images'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'images': images,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, title, createdAt];
}

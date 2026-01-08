import 'package:equatable/equatable.dart';

/// 광고 상품 타입
enum AdProductType {
  appBanner('앱 배너', 'APP_BANNER', 100000), // 10만원/주
  appPopup('앱 팝업', 'APP_POPUP', 200000), // 20만원/주
  homeFeature('홈 추천', 'HOME_FEATURE', 300000), // 30만원/주
  searchTop('검색 상단', 'SEARCH_TOP', 150000), // 15만원/주
  subwayAd('지하철 광고', 'SUBWAY_AD', 5000000), // 500만원/주
  busAd('버스 광고', 'BUS_AD', 3000000), // 300만원/주
  billboardSmall('전광판 소형', 'BILLBOARD_SMALL', 2000000), // 200만원/주
  billboardLarge('전광판 대형 (강남역 등)', 'BILLBOARD_LARGE', 10000000), // 1000만원/주
  cafeAd('카페 광고', 'CAFE_AD', 500000), // 50만원/주
  youtubeAd('유튜브 광고', 'YOUTUBE_AD', 1000000); // 100만원/주

  final String displayName;
  final String code;
  final int basePrice;
  const AdProductType(this.displayName, this.code, this.basePrice);

  static AdProductType fromCode(String code) {
    return AdProductType.values.firstWhere(
      (e) => e.code == code,
      orElse: () => AdProductType.appBanner,
    );
  }
}

/// 광고 상태
enum AdStatus {
  draft('준비중', 'DRAFT'),
  pending('검수중', 'PENDING'),
  approved('승인됨', 'APPROVED'),
  active('게재중', 'ACTIVE'),
  paused('일시정지', 'PAUSED'),
  completed('완료', 'COMPLETED'),
  rejected('반려', 'REJECTED');

  final String displayName;
  final String code;
  const AdStatus(this.displayName, this.code);

  static AdStatus fromCode(String code) {
    return AdStatus.values.firstWhere(
      (e) => e.code == code,
      orElse: () => AdStatus.draft,
    );
  }
}

/// 광고 상품 모델 (구매 가능한 광고 상품)
class AdProduct extends Equatable {
  final String id;
  final AdProductType type;
  final String name;
  final String description;
  final int price;
  final int durationDays; // 게재 기간 (일)
  final String? location; // 위치 정보 (전광판 등)
  final String? sizeInfo; // 사이즈 정보
  final int? impressions; // 예상 노출수
  final List<String> sampleImages;
  final List<String> requirements; // 광고 소재 요구사항
  final bool isPopular;
  final bool isAvailable;
  final int soldCount;

  const AdProduct({
    required this.id,
    required this.type,
    required this.name,
    required this.description,
    required this.price,
    this.durationDays = 7,
    this.location,
    this.sizeInfo,
    this.impressions,
    this.sampleImages = const [],
    this.requirements = const [],
    this.isPopular = false,
    this.isAvailable = true,
    this.soldCount = 0,
  });

  factory AdProduct.fromJson(Map<String, dynamic> json) {
    return AdProduct(
      id: json['id'] as String,
      type: AdProductType.fromCode(json['type'] as String),
      name: json['name'] as String,
      description: json['description'] as String,
      price: json['price'] as int,
      durationDays: json['durationDays'] as int? ?? 7,
      location: json['location'] as String?,
      sizeInfo: json['sizeInfo'] as String?,
      impressions: json['impressions'] as int?,
      sampleImages: List<String>.from(json['sampleImages'] ?? []),
      requirements: List<String>.from(json['requirements'] ?? []),
      isPopular: json['isPopular'] as bool? ?? false,
      isAvailable: json['isAvailable'] as bool? ?? true,
      soldCount: json['soldCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.code,
      'name': name,
      'description': description,
      'price': price,
      'durationDays': durationDays,
      'location': location,
      'sizeInfo': sizeInfo,
      'impressions': impressions,
      'sampleImages': sampleImages,
      'requirements': requirements,
      'isPopular': isPopular,
      'isAvailable': isAvailable,
      'soldCount': soldCount,
    };
  }

  @override
  List<Object?> get props => [id, type, name, price];
}

/// 광고 주문 모델 (팬/소속사가 구매한 광고)
class AdOrder extends Equatable {
  final String id;
  final String productId;
  final AdProductType productType;
  final String productName;
  final String buyerId;
  final String buyerName;
  final String? targetIdolId; // 광고 대상 아이돌
  final String? targetIdolName;
  final int price;
  final AdStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> adImages; // 광고 소재 이미지
  final String? adText; // 광고 문구
  final String? rejectionReason;
  final int? impressions; // 실제 노출수
  final int? clicks; // 클릭수
  final DateTime orderedAt;
  final DateTime? approvedAt;
  final DateTime? completedAt;

  const AdOrder({
    required this.id,
    required this.productId,
    required this.productType,
    required this.productName,
    required this.buyerId,
    required this.buyerName,
    this.targetIdolId,
    this.targetIdolName,
    required this.price,
    required this.status,
    required this.startDate,
    required this.endDate,
    this.adImages = const [],
    this.adText,
    this.rejectionReason,
    this.impressions,
    this.clicks,
    required this.orderedAt,
    this.approvedAt,
    this.completedAt,
  });

  int get durationDays => endDate.difference(startDate).inDays;
  double get ctr => impressions != null && impressions! > 0 && clicks != null
      ? (clicks! / impressions! * 100)
      : 0;

  factory AdOrder.fromJson(Map<String, dynamic> json) {
    return AdOrder(
      id: json['id'] as String,
      productId: json['productId'] as String,
      productType: AdProductType.fromCode(json['productType'] as String),
      productName: json['productName'] as String,
      buyerId: json['buyerId'] as String,
      buyerName: json['buyerName'] as String,
      targetIdolId: json['targetIdolId'] as String?,
      targetIdolName: json['targetIdolName'] as String?,
      price: json['price'] as int,
      status: AdStatus.fromCode(json['status'] as String),
      startDate: DateTime.tryParse(json['startDate'] as String? ?? '' ?? DateTime.now(),
      endDate: DateTime.tryParse(json['endDate'] as String? ?? '' ?? DateTime.now(),
      adImages: List<String>.from(json['adImages'] ?? []),
      adText: json['adText'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
      impressions: json['impressions'] as int?,
      clicks: json['clicks'] as int?,
      orderedAt: DateTime.tryParse(json['orderedAt'] as String? ?? '' ?? DateTime.now(),
      approvedAt: json['approvedAt'] != null
          ? DateTime.tryParse(json['approvedAt'] as String? ?? '' ?? DateTime.now()
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'] as String? ?? '' ?? DateTime.now()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productType': productType.code,
      'productName': productName,
      'buyerId': buyerId,
      'buyerName': buyerName,
      'targetIdolId': targetIdolId,
      'targetIdolName': targetIdolName,
      'price': price,
      'status': status.code,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'adImages': adImages,
      'adText': adText,
      'rejectionReason': rejectionReason,
      'impressions': impressions,
      'clicks': clicks,
      'orderedAt': orderedAt.toIso8601String(),
      'approvedAt': approvedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, productId, buyerId, status];
}

/// 팬덤 광고 펀딩 (팬들이 모아서 광고하기)
class AdFunding extends Equatable {
  final String id;
  final String title;
  final String description;
  final String targetIdolId;
  final String targetIdolName;
  final String targetIdolImage;
  final AdProductType adType;
  final String? adLocation;
  final int goalAmount;
  final int currentAmount;
  final int supporterCount;
  final DateTime startDate;
  final DateTime endDate;
  final String organizerId;
  final String organizerName;
  final String? adDesignImage; // 광고 시안
  final bool isCompleted;
  final DateTime createdAt;

  const AdFunding({
    required this.id,
    required this.title,
    required this.description,
    required this.targetIdolId,
    required this.targetIdolName,
    required this.targetIdolImage,
    required this.adType,
    this.adLocation,
    required this.goalAmount,
    this.currentAmount = 0,
    this.supporterCount = 0,
    required this.startDate,
    required this.endDate,
    required this.organizerId,
    required this.organizerName,
    this.adDesignImage,
    this.isCompleted = false,
    required this.createdAt,
  });

  double get progressPercentage {
    if (goalAmount == 0) return 0;
    return (currentAmount / goalAmount * 100).clamp(0, 100);
  }

  int get daysLeft {
    final now = DateTime.now();
    if (now.isAfter(endDate)) return 0;
    return endDate.difference(now).inDays;
  }

  bool get isFunded => currentAmount >= goalAmount;

  factory AdFunding.fromJson(Map<String, dynamic> json) {
    return AdFunding(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      targetIdolId: json['targetIdolId'] as String,
      targetIdolName: json['targetIdolName'] as String,
      targetIdolImage: json['targetIdolImage'] as String? ?? '',
      adType: AdProductType.fromCode(json['adType'] as String),
      adLocation: json['adLocation'] as String?,
      goalAmount: json['goalAmount'] as int,
      currentAmount: json['currentAmount'] as int? ?? 0,
      supporterCount: json['supporterCount'] as int? ?? 0,
      startDate: DateTime.tryParse(json['startDate'] as String? ?? '' ?? DateTime.now(),
      endDate: DateTime.tryParse(json['endDate'] as String? ?? '' ?? DateTime.now(),
      organizerId: json['organizerId'] as String,
      organizerName: json['organizerName'] as String,
      adDesignImage: json['adDesignImage'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '' ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'targetIdolId': targetIdolId,
      'targetIdolName': targetIdolName,
      'targetIdolImage': targetIdolImage,
      'adType': adType.code,
      'adLocation': adLocation,
      'goalAmount': goalAmount,
      'currentAmount': currentAmount,
      'supporterCount': supporterCount,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'organizerId': organizerId,
      'organizerName': organizerName,
      'adDesignImage': adDesignImage,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, targetIdolId, adType, goalAmount, currentAmount];
}

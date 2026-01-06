import 'package:equatable/equatable.dart';

/// 굿즈 카테고리
enum MerchandiseCategory {
  photocard('포토카드', 'PHOTOCARD'),
  poster('포스터', 'POSTER'),
  album('앨범', 'ALBUM'),
  lightstick('응원봉', 'LIGHTSTICK'),
  clothing('의류', 'CLOTHING'),
  accessory('액세서리', 'ACCESSORY'),
  stationery('문구', 'STATIONERY'),
  digital('디지털', 'DIGITAL'),
  other('기타', 'OTHER');

  final String displayName;
  final String code;
  const MerchandiseCategory(this.displayName, this.code);

  static MerchandiseCategory fromCode(String code) {
    return MerchandiseCategory.values.firstWhere(
      (e) => e.code == code,
      orElse: () => MerchandiseCategory.other,
    );
  }
}

/// 굿즈 타입 (개인/그룹)
enum MerchandiseType {
  individual('개인', 'INDIVIDUAL'),
  group('그룹', 'GROUP'),
  collaboration('콜라보', 'COLLABORATION');

  final String displayName;
  final String code;
  const MerchandiseType(this.displayName, this.code);

  static MerchandiseType fromCode(String code) {
    return MerchandiseType.values.firstWhere(
      (e) => e.code == code,
      orElse: () => MerchandiseType.individual,
    );
  }
}

/// 굿즈 상태
enum MerchandiseStatus {
  preorder('사전주문', 'PREORDER'),
  available('판매중', 'AVAILABLE'),
  soldout('품절', 'SOLDOUT'),
  discontinued('단종', 'DISCONTINUED');

  final String displayName;
  final String code;
  const MerchandiseStatus(this.displayName, this.code);

  static MerchandiseStatus fromCode(String code) {
    return MerchandiseStatus.values.firstWhere(
      (e) => e.code == code,
      orElse: () => MerchandiseStatus.available,
    );
  }
}

/// 굿즈 모델
class MerchandiseModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final MerchandiseCategory category;
  final MerchandiseType type;
  final MerchandiseStatus status;

  // 판매자 정보
  final String? idolId; // 개인 굿즈인 경우
  final String? groupId; // 그룹 굿즈인 경우
  final String? idolName;
  final String? groupName;

  // 가격 정보
  final int price;
  final int? originalPrice; // 할인 전 가격
  final int? discountRate; // 할인율 (%)

  // 재고
  final int? stock;
  final bool isLimitedEdition;
  final int? limitedQuantity;

  // 이미지
  final List<String> images;
  final String thumbnailImage;

  // 상세 정보
  final Map<String, String>? specifications; // 사이즈, 재질 등
  final List<String>? colors;
  final List<String>? sizes;

  // 배송
  final bool requiresShipping;
  final int? shippingCost;
  final String? estimatedDelivery;

  // 통계
  final int salesCount;
  final int viewCount;
  final int likeCount;
  final double rating;
  final int reviewCount;

  // 사전주문
  final DateTime? preorderStartDate;
  final DateTime? preorderEndDate;

  // 메타
  final List<String> tags;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const MerchandiseModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.type = MerchandiseType.individual,
    this.status = MerchandiseStatus.available,
    this.idolId,
    this.groupId,
    this.idolName,
    this.groupName,
    required this.price,
    this.originalPrice,
    this.discountRate,
    this.stock,
    this.isLimitedEdition = false,
    this.limitedQuantity,
    this.images = const [],
    required this.thumbnailImage,
    this.specifications,
    this.colors,
    this.sizes,
    this.requiresShipping = true,
    this.shippingCost,
    this.estimatedDelivery,
    this.salesCount = 0,
    this.viewCount = 0,
    this.likeCount = 0,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.preorderStartDate,
    this.preorderEndDate,
    this.tags = const [],
    required this.createdAt,
    this.updatedAt,
  });

  bool get isOnSale => originalPrice != null && originalPrice! > price;

  bool get isPreorder =>
      status == MerchandiseStatus.preorder ||
      (preorderStartDate != null &&
          preorderEndDate != null &&
          DateTime.now().isAfter(preorderStartDate!) &&
          DateTime.now().isBefore(preorderEndDate!));

  bool get isAvailable =>
      status == MerchandiseStatus.available &&
      (stock == null || stock! > 0);

  bool get isSoldOut =>
      status == MerchandiseStatus.soldout ||
      (stock != null && stock! <= 0);

  factory MerchandiseModel.fromJson(Map<String, dynamic> json) {
    return MerchandiseModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      category: MerchandiseCategory.fromCode(
        json['category'] as String? ?? 'OTHER',
      ),
      type: MerchandiseType.fromCode(
        json['type'] as String? ?? 'INDIVIDUAL',
      ),
      status: MerchandiseStatus.fromCode(
        json['status'] as String? ?? 'AVAILABLE',
      ),
      idolId: json['idolId'] as String?,
      groupId: json['groupId'] as String?,
      idolName: json['idolName'] as String?,
      groupName: json['groupName'] as String?,
      price: json['price'] as int,
      originalPrice: json['originalPrice'] as int?,
      discountRate: json['discountRate'] as int?,
      stock: json['stock'] as int?,
      isLimitedEdition: json['isLimitedEdition'] as bool? ?? false,
      limitedQuantity: json['limitedQuantity'] as int?,
      images: List<String>.from(json['images'] ?? []),
      thumbnailImage: json['thumbnailImage'] as String,
      specifications: json['specifications'] != null
          ? Map<String, String>.from(json['specifications'])
          : null,
      colors: json['colors'] != null
          ? List<String>.from(json['colors'])
          : null,
      sizes: json['sizes'] != null ? List<String>.from(json['sizes']) : null,
      requiresShipping: json['requiresShipping'] as bool? ?? true,
      shippingCost: json['shippingCost'] as int?,
      estimatedDelivery: json['estimatedDelivery'] as String?,
      salesCount: json['salesCount'] as int? ?? 0,
      viewCount: json['viewCount'] as int? ?? 0,
      likeCount: json['likeCount'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      preorderStartDate: json['preorderStartDate'] != null
          ? DateTime.parse(json['preorderStartDate'] as String)
          : null,
      preorderEndDate: json['preorderEndDate'] != null
          ? DateTime.parse(json['preorderEndDate'] as String)
          : null,
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: DateTime.parse(
        json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category.code,
      'type': type.code,
      'status': status.code,
      'idolId': idolId,
      'groupId': groupId,
      'idolName': idolName,
      'groupName': groupName,
      'price': price,
      'originalPrice': originalPrice,
      'discountRate': discountRate,
      'stock': stock,
      'isLimitedEdition': isLimitedEdition,
      'limitedQuantity': limitedQuantity,
      'images': images,
      'thumbnailImage': thumbnailImage,
      'specifications': specifications,
      'colors': colors,
      'sizes': sizes,
      'requiresShipping': requiresShipping,
      'shippingCost': shippingCost,
      'estimatedDelivery': estimatedDelivery,
      'salesCount': salesCount,
      'viewCount': viewCount,
      'likeCount': likeCount,
      'rating': rating,
      'reviewCount': reviewCount,
      'preorderStartDate': preorderStartDate?.toIso8601String(),
      'preorderEndDate': preorderEndDate?.toIso8601String(),
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, name, price, status];
}

/// 그룹 모델
class IdolGroupModel extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? logoImage;
  final String? coverImage;
  final List<String> memberIds; // 아이돌 ID 리스트
  final String? agencyId;
  final String? agencyName;
  final DateTime? debutDate;
  final String? officialColor; // Hex string
  final Map<String, String>? socialLinks;
  final int followerCount;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const IdolGroupModel({
    required this.id,
    required this.name,
    this.description,
    this.logoImage,
    this.coverImage,
    this.memberIds = const [],
    this.agencyId,
    this.agencyName,
    this.debutDate,
    this.officialColor,
    this.socialLinks,
    this.followerCount = 0,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory IdolGroupModel.fromJson(Map<String, dynamic> json) {
    return IdolGroupModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      logoImage: json['logoImage'] as String?,
      coverImage: json['coverImage'] as String?,
      memberIds: List<String>.from(json['memberIds'] ?? []),
      agencyId: json['agencyId'] as String?,
      agencyName: json['agencyName'] as String?,
      debutDate: json['debutDate'] != null
          ? DateTime.parse(json['debutDate'] as String)
          : null,
      officialColor: json['officialColor'] as String?,
      socialLinks: json['socialLinks'] != null
          ? Map<String, String>.from(json['socialLinks'])
          : null,
      followerCount: json['followerCount'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(
        json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'logoImage': logoImage,
      'coverImage': coverImage,
      'memberIds': memberIds,
      'agencyId': agencyId,
      'agencyName': agencyName,
      'debutDate': debutDate?.toIso8601String(),
      'officialColor': officialColor,
      'socialLinks': socialLinks,
      'followerCount': followerCount,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, name, isActive];
}

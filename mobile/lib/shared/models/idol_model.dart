import 'package:equatable/equatable.dart';

/// 아이돌 카테고리
enum IdolCategory {
  undergroundIdol('지하아이돌', 'UNDERGROUND_IDOL'),
  maidCafe('메이드카페', 'MAID_CAFE'),
  cosplayer('코스플레이어', 'COSPLAYER'),
  vtuber('버튜버', 'VTUBER'),
  streamer('스트리머', 'STREAMER');

  final String displayName;
  final String code;
  const IdolCategory(this.displayName, this.code);

  static IdolCategory fromCode(String code) {
    return IdolCategory.values.firstWhere(
      (e) => e.code == code,
      orElse: () => IdolCategory.undergroundIdol,
    );
  }
}

/// 아이돌 프로필 모델
class IdolModel extends Equatable {
  final String id;
  final String stageName;
  final String? realName;
  final IdolCategory category;
  final String? agencyId;
  final String? agencyName;
  final String? groupName;
  final String? imageColor; // Hex string e.g. "0xFFFF0000"
  final String profileImage;
  final String? coverImage;
  final String bio;
  final String? description;
  final bool isVerified;
  final bool isActive;

  // 지하돌 관련 정보
  final String? debutDate;
  final String? birthDate;
  final String? height;
  final String? bloodType;
  final List<String> specialties; // 특기: 노래, 춤, MC, 연기 등
  final List<String> hobbies;

  // SNS 링크
  final String? twitterUrl;
  final String? instagramUrl;
  final String? youtubeUrl;
  final String? tiktokUrl;
  final String? fanCafeUrl;

  // 통계
  final int totalSupport;
  final int supporterCount;
  final int subscriberCount;
  final int ranking;
  final int monthlyRanking;
  final double rating;

  // 갤러리
  final List<String> galleryImages;

  // 데이트권 관련
  final bool offersMealDate;
  final bool offersCafeDate;
  final int? mealDatePrice; // 기본 150만원
  final int? cafeDatePrice; // 기본 100만원
  final bool dateAvailable;

  // 버블 (팬 메시지) 관련
  final bool hasBubble;
  final int? bubblePrice; // 월 구독료

  // 구독 티어
  final List<SubscriptionTier> subscriptionTiers;

  // 트위터 마이그레이션 관련
  final bool importedFromTwitter;
  final DateTime? twitterImportedAt;
  final String? twitterUserId; // 트위터 사용자 ID
  final String? twitterHandle; // @username
  final int? twitterFollowersAtImport; // 이주 당시 팔로워 수
  final bool twitterAnnouncementSent; // 공지 트윗 발송 여부
  final int twitterFollowersConverted; // 앱에 가입한 팔로워 수

  final DateTime createdAt;
  final DateTime? updatedAt;

  const IdolModel({
    required this.id,
    required this.stageName,
    this.realName,
    required this.category,
    this.agencyId,
    this.agencyName,
    this.groupName,
    this.imageColor,
    required this.profileImage,
    this.coverImage,
    required this.bio,
    this.description,
    this.isVerified = false,
    this.isActive = true,
    this.debutDate,
    this.birthDate,
    this.height,
    this.bloodType,
    this.specialties = const [],
    this.hobbies = const [],
    this.twitterUrl,
    this.instagramUrl,
    this.youtubeUrl,
    this.tiktokUrl,
    this.fanCafeUrl,
    this.totalSupport = 0,
    this.supporterCount = 0,
    this.subscriberCount = 0,
    this.ranking = 0,
    this.monthlyRanking = 0,
    this.rating = 0.0,
    this.galleryImages = const [],
    this.offersMealDate = false,
    this.offersCafeDate = false,
    this.mealDatePrice,
    this.cafeDatePrice,
    this.dateAvailable = false,
    this.hasBubble = false,
    this.bubblePrice,
    this.subscriptionTiers = const [],
    this.importedFromTwitter = false,
    this.twitterImportedAt,
    this.twitterUserId,
    this.twitterHandle,
    this.twitterFollowersAtImport,
    this.twitterAnnouncementSent = false,
    this.twitterFollowersConverted = 0,
    required this.createdAt,
    this.updatedAt,
  });

  factory IdolModel.fromJson(Map<String, dynamic> json) {
    return IdolModel(
      id: json['id'] as String,
      stageName: json['stageName'] as String,
      realName: json['realName'] as String?,
      category: IdolCategory.fromCode(
          json['category'] as String? ?? 'UNDERGROUND_IDOL'),
      agencyId: json['agencyId'] as String?,
      agencyName: json['agencyName'] as String?,
      groupName: json['groupName'] as String?,
      imageColor: json['imageColor'] as String?,
      profileImage: json['profileImage'] as String? ?? '',
      coverImage: json['coverImage'] as String?,
      bio: json['bio'] as String? ?? '',
      description: json['description'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      debutDate: json['debutDate'] as String?,
      birthDate: json['birthDate'] as String?,
      height: json['height'] as String?,
      bloodType: json['bloodType'] as String?,
      specialties: List<String>.from(json['specialties'] ?? []),
      hobbies: List<String>.from(json['hobbies'] ?? []),
      twitterUrl: json['twitterUrl'] as String?,
      instagramUrl: json['instagramUrl'] as String?,
      youtubeUrl: json['youtubeUrl'] as String?,
      tiktokUrl: json['tiktokUrl'] as String?,
      fanCafeUrl: json['fanCafeUrl'] as String?,
      totalSupport: json['totalSupport'] as int? ?? 0,
      supporterCount: json['supporterCount'] as int? ?? 0,
      subscriberCount: json['subscriberCount'] as int? ?? 0,
      ranking: json['ranking'] as int? ?? 0,
      monthlyRanking: json['monthlyRanking'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      galleryImages: List<String>.from(json['galleryImages'] ?? []),
      offersMealDate: json['offersMealDate'] as bool? ?? false,
      offersCafeDate: json['offersCafeDate'] as bool? ?? false,
      mealDatePrice: json['mealDatePrice'] as int?,
      cafeDatePrice: json['cafeDatePrice'] as int?,
      dateAvailable: json['dateAvailable'] as bool? ?? false,
      hasBubble: json['hasBubble'] as bool? ?? false,
      bubblePrice: json['bubblePrice'] as int?,
      subscriptionTiers: (json['subscriptionTiers'] as List<dynamic>?)
              ?.map((e) => SubscriptionTier.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      importedFromTwitter: json['importedFromTwitter'] as bool? ?? false,
      twitterImportedAt: json['twitterImportedAt'] != null
          ? DateTime.parse(json['twitterImportedAt'] as String)
          : null,
      twitterUserId: json['twitterUserId'] as String?,
      twitterHandle: json['twitterHandle'] as String?,
      twitterFollowersAtImport: json['twitterFollowersAtImport'] as int?,
      twitterAnnouncementSent: json['twitterAnnouncementSent'] as bool? ?? false,
      twitterFollowersConverted: json['twitterFollowersConverted'] as int? ?? 0,
      createdAt: DateTime.parse(
          json['createdAt'] as String? ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stageName': stageName,
      'realName': realName,
      'category': category.code,
      'agencyId': agencyId,
      'agencyName': agencyName,
      'groupName': groupName,
      'imageColor': imageColor,
      'profileImage': profileImage,
      'coverImage': coverImage,
      'bio': bio,
      'description': description,
      'isVerified': isVerified,
      'isActive': isActive,
      'debutDate': debutDate,
      'birthDate': birthDate,
      'height': height,
      'bloodType': bloodType,
      'specialties': specialties,
      'hobbies': hobbies,
      'twitterUrl': twitterUrl,
      'instagramUrl': instagramUrl,
      'youtubeUrl': youtubeUrl,
      'tiktokUrl': tiktokUrl,
      'fanCafeUrl': fanCafeUrl,
      'totalSupport': totalSupport,
      'supporterCount': supporterCount,
      'subscriberCount': subscriberCount,
      'ranking': ranking,
      'monthlyRanking': monthlyRanking,
      'rating': rating,
      'galleryImages': galleryImages,
      'offersMealDate': offersMealDate,
      'offersCafeDate': offersCafeDate,
      'mealDatePrice': mealDatePrice,
      'cafeDatePrice': cafeDatePrice,
      'dateAvailable': dateAvailable,
      'hasBubble': hasBubble,
      'bubblePrice': bubblePrice,
      'subscriptionTiers': subscriptionTiers.map((e) => e.toJson()).toList(),
      'importedFromTwitter': importedFromTwitter,
      'twitterImportedAt': twitterImportedAt?.toIso8601String(),
      'twitterUserId': twitterUserId,
      'twitterHandle': twitterHandle,
      'twitterFollowersAtImport': twitterFollowersAtImport,
      'twitterAnnouncementSent': twitterAnnouncementSent,
      'twitterFollowersConverted': twitterFollowersConverted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  IdolModel copyWith({
    String? id,
    String? stageName,
    String? realName,
    IdolCategory? category,
    String? agencyId,
    String? agencyName,
    String? profileImage,
    String? coverImage,
    String? bio,
    String? description,
    bool? isVerified,
    bool? isActive,
    String? debutDate,
    String? birthDate,
    String? height,
    String? bloodType,
    List<String>? specialties,
    List<String>? hobbies,
    String? twitterUrl,
    String? instagramUrl,
    String? youtubeUrl,
    String? tiktokUrl,
    String? fanCafeUrl,
    int? totalSupport,
    int? supporterCount,
    int? subscriberCount,
    int? ranking,
    int? monthlyRanking,
    double? rating,
    List<String>? galleryImages,
    bool? offersMealDate,
    bool? offersCafeDate,
    int? mealDatePrice,
    int? cafeDatePrice,
    bool? dateAvailable,
    bool? hasBubble,
    int? bubblePrice,
    List<SubscriptionTier>? subscriptionTiers,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return IdolModel(
      id: id ?? this.id,
      stageName: stageName ?? this.stageName,
      realName: realName ?? this.realName,
      category: category ?? this.category,
      agencyId: agencyId ?? this.agencyId,
      agencyName: agencyName ?? this.agencyName,
      profileImage: profileImage ?? this.profileImage,
      coverImage: coverImage ?? this.coverImage,
      bio: bio ?? this.bio,
      description: description ?? this.description,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      debutDate: debutDate ?? this.debutDate,
      birthDate: birthDate ?? this.birthDate,
      height: height ?? this.height,
      bloodType: bloodType ?? this.bloodType,
      specialties: specialties ?? this.specialties,
      hobbies: hobbies ?? this.hobbies,
      twitterUrl: twitterUrl ?? this.twitterUrl,
      instagramUrl: instagramUrl ?? this.instagramUrl,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
      tiktokUrl: tiktokUrl ?? this.tiktokUrl,
      fanCafeUrl: fanCafeUrl ?? this.fanCafeUrl,
      totalSupport: totalSupport ?? this.totalSupport,
      supporterCount: supporterCount ?? this.supporterCount,
      subscriberCount: subscriberCount ?? this.subscriberCount,
      ranking: ranking ?? this.ranking,
      monthlyRanking: monthlyRanking ?? this.monthlyRanking,
      rating: rating ?? this.rating,
      galleryImages: galleryImages ?? this.galleryImages,
      offersMealDate: offersMealDate ?? this.offersMealDate,
      offersCafeDate: offersCafeDate ?? this.offersCafeDate,
      mealDatePrice: mealDatePrice ?? this.mealDatePrice,
      cafeDatePrice: cafeDatePrice ?? this.cafeDatePrice,
      dateAvailable: dateAvailable ?? this.dateAvailable,
      hasBubble: hasBubble ?? this.hasBubble,
      bubblePrice: bubblePrice ?? this.bubblePrice,
      subscriptionTiers: subscriptionTiers ?? this.subscriptionTiers,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        stageName,
        realName,
        category,
        agencyId,
        profileImage,
        isVerified,
        isActive,
        ranking,
      ];
}

/// 구독 티어 모델
class SubscriptionTier extends Equatable {
  final String id;
  final String name;
  final int price;
  final String description;
  final List<String> benefits;
  final bool isPopular;

  const SubscriptionTier({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    this.benefits = const [],
    this.isPopular = false,
  });

  factory SubscriptionTier.fromJson(Map<String, dynamic> json) {
    return SubscriptionTier(
      id: json['id'] as String,
      name: json['name'] as String,
      price: json['price'] as int,
      description: json['description'] as String,
      benefits: List<String>.from(json['benefits'] ?? []),
      isPopular: json['isPopular'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'benefits': benefits,
      'isPopular': isPopular,
    };
  }

  @override
  List<Object?> get props => [id, name, price];
}

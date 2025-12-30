import 'package:equatable/equatable.dart';
import 'user_model.dart';

enum IdolCategory { undergroundIdol, maidCafe, cosplayer, vtuber, other }

class IdolProfile extends Equatable {
  final String id;
  final String userId;
  final String stageName;
  final String? introduction;
  final IdolCategory category;
  final String? cafeName;
  final String? cafeAddress;
  final String? headerImage;
  final List<String> galleryImages;
  final Map<String, String>? socialLinks;
  final bool isVerified;
  final double totalSupport;
  final int supporterCount;
  final int? ranking;
  final User? user;

  const IdolProfile({
    required this.id,
    required this.userId,
    required this.stageName,
    this.introduction,
    required this.category,
    this.cafeName,
    this.cafeAddress,
    this.headerImage,
    this.galleryImages = const [],
    this.socialLinks,
    required this.isVerified,
    required this.totalSupport,
    required this.supporterCount,
    this.ranking,
    this.user,
  });

  factory IdolProfile.fromJson(Map<String, dynamic> json) {
    return IdolProfile(
      id: json['id'] as String,
      userId: json['userId'] as String,
      stageName: json['stageName'] as String,
      introduction: json['introduction'] as String?,
      category: _parseCategory(json['category'] as String),
      cafeName: json['cafeName'] as String?,
      cafeAddress: json['cafeAddress'] as String?,
      headerImage: json['headerImage'] as String?,
      galleryImages: (json['galleryImages'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      socialLinks: (json['socialLinks'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(k, v as String),
      ),
      isVerified: json['isVerified'] as bool? ?? false,
      totalSupport: (json['totalSupport'] as num?)?.toDouble() ?? 0,
      supporterCount: json['supporterCount'] as int? ?? 0,
      ranking: json['ranking'] as int?,
      user: json['user'] != null
          ? User.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }

  static IdolCategory _parseCategory(String category) {
    switch (category.toUpperCase()) {
      case 'UNDERGROUND_IDOL':
        return IdolCategory.undergroundIdol;
      case 'MAID_CAFE':
        return IdolCategory.maidCafe;
      case 'COSPLAYER':
        return IdolCategory.cosplayer;
      case 'VTUBER':
        return IdolCategory.vtuber;
      default:
        return IdolCategory.other;
    }
  }

  String get categoryDisplayName {
    switch (category) {
      case IdolCategory.undergroundIdol:
        return '지하 아이돌';
      case IdolCategory.maidCafe:
        return '메이드 카페';
      case IdolCategory.cosplayer:
        return '코스플레이어';
      case IdolCategory.vtuber:
        return 'VTuber';
      case IdolCategory.other:
        return '기타';
    }
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        stageName,
        introduction,
        category,
        cafeName,
        cafeAddress,
        headerImage,
        galleryImages,
        socialLinks,
        isVerified,
        totalSupport,
        supporterCount,
        ranking,
        user,
      ];
}

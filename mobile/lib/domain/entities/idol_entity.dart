import 'package:flutter/foundation.dart';

/// 아이돌 카테고리
enum IdolCategory {
  undergroundIdol('UNDERGROUND_IDOL', '지하 아이돌'),
  maidCafe('MAID_CAFE', '메이드카페'),
  cosplayer('COSPLAYER', '코스플레이어'),
  vtuber('VTuber', 'VTuber');

  final String code;
  final String displayName;

  const IdolCategory(this.code, this.displayName);

  static IdolCategory fromCode(String? code) {
    return IdolCategory.values.firstWhere(
      (e) => e.code == code,
      orElse: () => IdolCategory.undergroundIdol,
    );
  }
}

/// 아이돌 엔티티
@immutable
class IdolEntity {
  final String id;
  final String stageName;
  final String? realName;
  final IdolCategory category;
  final String profileImage;
  final String? coverImage;
  final String? bio;
  final String? agency;
  final int followerCount;
  final int supporterCount;
  final int totalSupport;
  final bool isFollowing;
  final bool isVerified;
  final List<String> gallery;
  final List<SocialLink> socialLinks;
  final DateTime? debutDate;
  final DateTime? createdAt;

  const IdolEntity({
    required this.id,
    required this.stageName,
    this.realName,
    required this.category,
    required this.profileImage,
    this.coverImage,
    this.bio,
    this.agency,
    this.followerCount = 0,
    this.supporterCount = 0,
    this.totalSupport = 0,
    this.isFollowing = false,
    this.isVerified = false,
    this.gallery = const [],
    this.socialLinks = const [],
    this.debutDate,
    this.createdAt,
  });

  IdolEntity copyWith({
    String? id,
    String? stageName,
    String? realName,
    IdolCategory? category,
    String? profileImage,
    String? coverImage,
    String? bio,
    String? agency,
    int? followerCount,
    int? supporterCount,
    int? totalSupport,
    bool? isFollowing,
    bool? isVerified,
    List<String>? gallery,
    List<SocialLink>? socialLinks,
    DateTime? debutDate,
    DateTime? createdAt,
  }) {
    return IdolEntity(
      id: id ?? this.id,
      stageName: stageName ?? this.stageName,
      realName: realName ?? this.realName,
      category: category ?? this.category,
      profileImage: profileImage ?? this.profileImage,
      coverImage: coverImage ?? this.coverImage,
      bio: bio ?? this.bio,
      agency: agency ?? this.agency,
      followerCount: followerCount ?? this.followerCount,
      supporterCount: supporterCount ?? this.supporterCount,
      totalSupport: totalSupport ?? this.totalSupport,
      isFollowing: isFollowing ?? this.isFollowing,
      isVerified: isVerified ?? this.isVerified,
      gallery: gallery ?? this.gallery,
      socialLinks: socialLinks ?? this.socialLinks,
      debutDate: debutDate ?? this.debutDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IdolEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'IdolEntity(id: $id, stageName: $stageName)';
}

/// 소셜 링크
@immutable
class SocialLink {
  final String platform;
  final String url;
  final String? username;

  const SocialLink({
    required this.platform,
    required this.url,
    this.username,
  });

  SocialLink copyWith({
    String? platform,
    String? url,
    String? username,
  }) {
    return SocialLink(
      platform: platform ?? this.platform,
      url: url ?? this.url,
      username: username ?? this.username,
    );
  }
}

/// 아이돌 간략 정보 (리스트용)
@immutable
class IdolSummary {
  final String id;
  final String stageName;
  final IdolCategory category;
  final String profileImage;
  final int followerCount;
  final bool isFollowing;
  final bool isVerified;

  const IdolSummary({
    required this.id,
    required this.stageName,
    required this.category,
    required this.profileImage,
    this.followerCount = 0,
    this.isFollowing = false,
    this.isVerified = false,
  });

  factory IdolSummary.fromEntity(IdolEntity entity) {
    return IdolSummary(
      id: entity.id,
      stageName: entity.stageName,
      category: entity.category,
      profileImage: entity.profileImage,
      followerCount: entity.followerCount,
      isFollowing: entity.isFollowing,
      isVerified: entity.isVerified,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IdolSummary &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

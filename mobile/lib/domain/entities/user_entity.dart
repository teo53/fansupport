import 'package:flutter/foundation.dart';

/// 사용자 엔티티
@immutable
class UserEntity {
  final String id;
  final String email;
  final String nickname;
  final String? profileImage;
  final String? bio;
  final int followersCount;
  final int followingCount;
  final int postsCount;
  final DateTime? createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.nickname,
    this.profileImage,
    this.bio,
    this.followersCount = 0,
    this.followingCount = 0,
    this.postsCount = 0,
    this.createdAt,
  });

  UserEntity copyWith({
    String? id,
    String? email,
    String? nickname,
    String? profileImage,
    String? bio,
    int? followersCount,
    int? followingCount,
    int? postsCount,
    DateTime? createdAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      profileImage: profileImage ?? this.profileImage,
      bio: bio ?? this.bio,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      postsCount: postsCount ?? this.postsCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'UserEntity(id: $id, nickname: $nickname)';
}

/// 인증된 사용자 (토큰 포함)
@immutable
class AuthenticatedUser extends UserEntity {
  final String accessToken;
  final String? refreshToken;
  final DateTime? tokenExpiresAt;

  const AuthenticatedUser({
    required super.id,
    required super.email,
    required super.nickname,
    super.profileImage,
    super.bio,
    super.followersCount,
    super.followingCount,
    super.postsCount,
    super.createdAt,
    required this.accessToken,
    this.refreshToken,
    this.tokenExpiresAt,
  });

  bool get isTokenExpired =>
      tokenExpiresAt != null && DateTime.now().isAfter(tokenExpiresAt!);

  @override
  AuthenticatedUser copyWith({
    String? id,
    String? email,
    String? nickname,
    String? profileImage,
    String? bio,
    int? followersCount,
    int? followingCount,
    int? postsCount,
    DateTime? createdAt,
    String? accessToken,
    String? refreshToken,
    DateTime? tokenExpiresAt,
  }) {
    return AuthenticatedUser(
      id: id ?? this.id,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      profileImage: profileImage ?? this.profileImage,
      bio: bio ?? this.bio,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      postsCount: postsCount ?? this.postsCount,
      createdAt: createdAt ?? this.createdAt,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      tokenExpiresAt: tokenExpiresAt ?? this.tokenExpiresAt,
    );
  }
}

import 'package:equatable/equatable.dart';

enum UserRole { fan, idol, maid, agency, admin }

class User extends Equatable {
  final String id;
  final String email;
  final String nickname;
  final String? profileImage;
  final String role;
  final bool isVerified;
  final int walletBalance;
  final String? bio;

  const User({
    required this.id,
    required this.email,
    required this.nickname,
    this.profileImage,
    required this.role,
    required this.isVerified,
    this.walletBalance = 0,
    this.bio,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      nickname: json['nickname'] as String,
      profileImage: json['profileImage'] as String?,
      role: json['role'] as String? ?? 'FAN',
      isVerified: json['isVerified'] as bool? ?? false,
      walletBalance: json['wallet']?['balance'] as int? ?? 0,
      bio: json['bio'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nickname': nickname,
      'profileImage': profileImage,
      'role': role,
      'isVerified': isVerified,
      'wallet': {'balance': walletBalance},
      'bio': bio,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? nickname,
    String? profileImage,
    String? role,
    bool? isVerified,
    int? walletBalance,
    String? bio,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      profileImage: profileImage ?? this.profileImage,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      walletBalance: walletBalance ?? this.walletBalance,
      bio: bio ?? this.bio,
    );
  }

  @override
  List<Object?> get props => [id, email, nickname, profileImage, role, isVerified, walletBalance, bio];
}

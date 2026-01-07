import 'package:equatable/equatable.dart';

/// Support transaction model
class SupportModel extends Equatable {
  final String id;
  final String supporterId;
  final String receiverId;
  final double amount;
  final String? message;
  final bool isAnonymous;
  final DateTime createdAt;

  // Related data (from joins)
  final String? supporterNickname;
  final String? supporterProfileImage;
  final String? receiverNickname;
  final String? receiverProfileImage;

  const SupportModel({
    required this.id,
    required this.supporterId,
    required this.receiverId,
    required this.amount,
    this.message,
    this.isAnonymous = false,
    required this.createdAt,
    this.supporterNickname,
    this.supporterProfileImage,
    this.receiverNickname,
    this.receiverProfileImage,
  });

  factory SupportModel.fromJson(Map<String, dynamic> json) {
    return SupportModel(
      id: json['id'] as String,
      supporterId: json['supporter_id'] as String,
      receiverId: json['receiver_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      message: json['message'] as String?,
      isAnonymous: json['is_anonymous'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      supporterNickname: json['supporter']?['nickname'] as String?,
      supporterProfileImage: json['supporter']?['profile_image'] as String?,
      receiverNickname: json['receiver']?['nickname'] as String?,
      receiverProfileImage: json['receiver']?['profile_image'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'supporter_id': supporterId,
      'receiver_id': receiverId,
      'amount': amount,
      'message': message,
      'is_anonymous': isAnonymous,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        supporterId,
        receiverId,
        amount,
        message,
        isAnonymous,
        createdAt,
      ];
}

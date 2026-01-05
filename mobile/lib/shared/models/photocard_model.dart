import 'package:flutter/material.dart';

/// Type of photocard issued to fans
enum PhotocardType {
  support('후원 기념'),
  subscription('구독 멤버십'),
  event('이벤트 한정'),
  birthday('생일 축하'),
  firstMeet('첫 만남');

  final String displayName;
  const PhotocardType(this.displayName);
}

/// Rarity level of the photocard
enum PhotocardRarity {
  common('일반', Color(0xFF9CA3AF), '★'),
  rare('레어', Color(0xFF3B82F6), '★★'),
  superRare('슈퍼레어', Color(0xFF8B5CF6), '★★★'),
  legendary('레전더리', Color(0xFFFFD700), '★★★★');

  final String displayName;
  final Color color;
  final String stars;
  const PhotocardRarity(this.displayName, this.color, this.stars);
}

/// Digital photocard model for fan collection
class PhotocardModel {
  final String id;
  final String idolId;
  final String idolName;
  final String idolGroup;
  final String imageUrl;
  final String? backImageUrl;
  final DateTime issuedAt;
  final PhotocardType type;
  final PhotocardRarity rarity;
  final int serialNumber;
  final int totalIssued;
  final String? message;
  final String? eventName;
  final bool isHolographic;

  const PhotocardModel({
    required this.id,
    required this.idolId,
    required this.idolName,
    required this.idolGroup,
    required this.imageUrl,
    this.backImageUrl,
    required this.issuedAt,
    required this.type,
    this.rarity = PhotocardRarity.common,
    required this.serialNumber,
    required this.totalIssued,
    this.message,
    this.eventName,
    this.isHolographic = false,
  });

  /// Unique serial display (e.g., "#0042/1000")
  String get serialDisplay =>
      '#${serialNumber.toString().padLeft(4, '0')}/${totalIssued}';

  /// Formatted issue date
  String get issuedDateDisplay {
    final d = issuedAt;
    return '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';
  }

  /// Create from JSON
  factory PhotocardModel.fromJson(Map<String, dynamic> json) {
    return PhotocardModel(
      id: json['id'] as String,
      idolId: json['idolId'] as String,
      idolName: json['idolName'] as String,
      idolGroup: json['idolGroup'] as String? ?? '',
      imageUrl: json['imageUrl'] as String,
      backImageUrl: json['backImageUrl'] as String?,
      issuedAt: DateTime.parse(json['issuedAt'] as String),
      type: PhotocardType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PhotocardType.support,
      ),
      rarity: PhotocardRarity.values.firstWhere(
        (e) => e.name == json['rarity'],
        orElse: () => PhotocardRarity.common,
      ),
      serialNumber: json['serialNumber'] as int,
      totalIssued: json['totalIssued'] as int,
      message: json['message'] as String?,
      eventName: json['eventName'] as String?,
      isHolographic: json['isHolographic'] as bool? ?? false,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idolId': idolId,
      'idolName': idolName,
      'idolGroup': idolGroup,
      'imageUrl': imageUrl,
      'backImageUrl': backImageUrl,
      'issuedAt': issuedAt.toIso8601String(),
      'type': type.name,
      'rarity': rarity.name,
      'serialNumber': serialNumber,
      'totalIssued': totalIssued,
      'message': message,
      'eventName': eventName,
      'isHolographic': isHolographic,
    };
  }

  /// Copy with modifications
  PhotocardModel copyWith({
    String? id,
    String? idolId,
    String? idolName,
    String? idolGroup,
    String? imageUrl,
    String? backImageUrl,
    DateTime? issuedAt,
    PhotocardType? type,
    PhotocardRarity? rarity,
    int? serialNumber,
    int? totalIssued,
    String? message,
    String? eventName,
    bool? isHolographic,
  }) {
    return PhotocardModel(
      id: id ?? this.id,
      idolId: idolId ?? this.idolId,
      idolName: idolName ?? this.idolName,
      idolGroup: idolGroup ?? this.idolGroup,
      imageUrl: imageUrl ?? this.imageUrl,
      backImageUrl: backImageUrl ?? this.backImageUrl,
      issuedAt: issuedAt ?? this.issuedAt,
      type: type ?? this.type,
      rarity: rarity ?? this.rarity,
      serialNumber: serialNumber ?? this.serialNumber,
      totalIssued: totalIssued ?? this.totalIssued,
      message: message ?? this.message,
      eventName: eventName ?? this.eventName,
      isHolographic: isHolographic ?? this.isHolographic,
    );
  }
}

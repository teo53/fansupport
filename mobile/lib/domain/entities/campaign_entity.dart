import 'package:flutter/foundation.dart';
import 'idol_entity.dart';

/// 캠페인 타입
enum CampaignType {
  birthday('BIRTHDAY', '생일'),
  debut('DEBUT', '데뷔'),
  album('ALBUM', '앨범'),
  concert('CONCERT', '콘서트'),
  event('EVENT', '이벤트'),
  support('SUPPORT', '서포트'),
  other('OTHER', '기타');

  final String code;
  final String displayName;

  const CampaignType(this.code, this.displayName);

  static CampaignType fromCode(String? code) {
    return CampaignType.values.firstWhere(
      (e) => e.code == code,
      orElse: () => CampaignType.other,
    );
  }
}

/// 캠페인 상태
enum CampaignStatus {
  upcoming('UPCOMING', '예정'),
  active('ACTIVE', '진행중'),
  completed('COMPLETED', '완료'),
  cancelled('CANCELLED', '취소');

  final String code;
  final String displayName;

  const CampaignStatus(this.code, this.displayName);

  static CampaignStatus fromCode(String? code) {
    return CampaignStatus.values.firstWhere(
      (e) => e.code == code,
      orElse: () => CampaignStatus.active,
    );
  }
}

/// 캠페인 엔티티
@immutable
class CampaignEntity {
  final String id;
  final String title;
  final String description;
  final CampaignType type;
  final CampaignStatus status;
  final IdolSummary? idol;
  final String organizerId;
  final String organizerName;
  final String? organizerImage;
  final String? thumbnailImage;
  final List<String> images;
  final int targetAmount;
  final int currentAmount;
  final int participantCount;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime? eventDate;
  final String? location;
  final bool isParticipating;
  final DateTime createdAt;

  const CampaignEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.status = CampaignStatus.active,
    this.idol,
    required this.organizerId,
    required this.organizerName,
    this.organizerImage,
    this.thumbnailImage,
    this.images = const [],
    required this.targetAmount,
    this.currentAmount = 0,
    this.participantCount = 0,
    required this.startDate,
    required this.endDate,
    this.eventDate,
    this.location,
    this.isParticipating = false,
    required this.createdAt,
  });

  /// 진행률 (0.0 ~ 1.0)
  double get progressPercent {
    if (targetAmount <= 0) return 0.0;
    return (currentAmount / targetAmount).clamp(0.0, 1.0);
  }

  /// 진행률 퍼센트
  int get progressPercentInt => (progressPercent * 100).round();

  /// 목표 달성 여부
  bool get isGoalReached => currentAmount >= targetAmount;

  /// 남은 일수
  int get daysLeft {
    final now = DateTime.now();
    if (now.isAfter(endDate)) return 0;
    return endDate.difference(now).inDays;
  }

  /// 종료 여부
  bool get isEnded => DateTime.now().isAfter(endDate);

  /// 시작 전 여부
  bool get isUpcoming => DateTime.now().isBefore(startDate);

  /// 진행중 여부
  bool get isActive => !isUpcoming && !isEnded;

  CampaignEntity copyWith({
    String? id,
    String? title,
    String? description,
    CampaignType? type,
    CampaignStatus? status,
    IdolSummary? idol,
    String? organizerId,
    String? organizerName,
    String? organizerImage,
    String? thumbnailImage,
    List<String>? images,
    int? targetAmount,
    int? currentAmount,
    int? participantCount,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? eventDate,
    String? location,
    bool? isParticipating,
    DateTime? createdAt,
  }) {
    return CampaignEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      idol: idol ?? this.idol,
      organizerId: organizerId ?? this.organizerId,
      organizerName: organizerName ?? this.organizerName,
      organizerImage: organizerImage ?? this.organizerImage,
      thumbnailImage: thumbnailImage ?? this.thumbnailImage,
      images: images ?? this.images,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      participantCount: participantCount ?? this.participantCount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      eventDate: eventDate ?? this.eventDate,
      location: location ?? this.location,
      isParticipating: isParticipating ?? this.isParticipating,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CampaignEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'CampaignEntity(id: $id, title: $title)';
}

/// 캠페인 간략 정보 (리스트용)
@immutable
class CampaignSummary {
  final String id;
  final String title;
  final CampaignType type;
  final String? thumbnailImage;
  final int targetAmount;
  final int currentAmount;
  final int daysLeft;
  final bool isParticipating;

  const CampaignSummary({
    required this.id,
    required this.title,
    required this.type,
    this.thumbnailImage,
    required this.targetAmount,
    this.currentAmount = 0,
    this.daysLeft = 0,
    this.isParticipating = false,
  });

  double get progressPercent {
    if (targetAmount <= 0) return 0.0;
    return (currentAmount / targetAmount).clamp(0.0, 1.0);
  }

  factory CampaignSummary.fromEntity(CampaignEntity entity) {
    return CampaignSummary(
      id: entity.id,
      title: entity.title,
      type: entity.type,
      thumbnailImage: entity.thumbnailImage,
      targetAmount: entity.targetAmount,
      currentAmount: entity.currentAmount,
      daysLeft: entity.daysLeft,
      isParticipating: entity.isParticipating,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CampaignSummary &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

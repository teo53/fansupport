import 'package:equatable/equatable.dart';

/// 오프회 타입
enum DateTicketType {
  meal('식사 오프회', 'MEAL', 1500000), // 150만원
  cafe('카페 오프회', 'CAFE', 1000000); // 100만원

  final String displayName;
  final String code;
  final int defaultPrice;
  const DateTicketType(this.displayName, this.code, this.defaultPrice);

  static DateTicketType fromCode(String code) {
    return DateTicketType.values.firstWhere(
      (e) => e.code == code,
      orElse: () => DateTicketType.cafe,
    );
  }
}

/// 오프회 상태
enum DateTicketStatus {
  available('구매가능', 'AVAILABLE'),
  pending('승인대기', 'PENDING'),
  confirmed('확정', 'CONFIRMED'),
  completed('완료', 'COMPLETED'),
  cancelled('취소', 'CANCELLED'),
  refunded('환불', 'REFUNDED');

  final String displayName;
  final String code;
  const DateTicketStatus(this.displayName, this.code);

  static DateTicketStatus fromCode(String code) {
    return DateTicketStatus.values.firstWhere(
      (e) => e.code == code,
      orElse: () => DateTicketStatus.available,
    );
  }
}

/// 특별 만남 상품 모델 (아이돌이 등록하는 상품)
class DateTicketProduct extends Equatable {
  final String id;
  final String idolId;
  final String idolName;
  final String idolProfileImage;
  final DateTicketType type;
  final int price;
  final String description;
  final int duration; // 분 단위
  final String location; // 지역 (예: 서울, 부산 등)
  final List<String> availableDays; // 가능한 요일
  final String? availableTimeStart;
  final String? availableTimeEnd;
  final int maxMonthlyCount; // 월 최대 예약 가능 수
  final int currentMonthCount; // 현재 월 예약 수
  final bool isActive;
  final List<String> includeItems; // 포함 사항
  final List<String> excludeItems; // 불포함 사항
  final String? notice; // 주의사항
  final DateTime createdAt;

  const DateTicketProduct({
    required this.id,
    required this.idolId,
    required this.idolName,
    required this.idolProfileImage,
    required this.type,
    required this.price,
    required this.description,
    this.duration = 120, // 기본 2시간
    required this.location,
    this.availableDays = const ['토', '일'],
    this.availableTimeStart,
    this.availableTimeEnd,
    this.maxMonthlyCount = 4,
    this.currentMonthCount = 0,
    this.isActive = true,
    this.includeItems = const [],
    this.excludeItems = const [],
    this.notice,
    required this.createdAt,
  });

  bool get isAvailable => isActive && currentMonthCount < maxMonthlyCount;
  int get remainingSlots => maxMonthlyCount - currentMonthCount;

  factory DateTicketProduct.fromJson(Map<String, dynamic> json) {
    return DateTicketProduct(
      id: json['id'] as String,
      idolId: json['idolId'] as String,
      idolName: json['idolName'] as String,
      idolProfileImage: json['idolProfileImage'] as String? ?? '',
      type: DateTicketType.fromCode(json['type'] as String),
      price: json['price'] as int,
      description: json['description'] as String,
      duration: json['duration'] as int? ?? 120,
      location: json['location'] as String,
      availableDays: List<String>.from(json['availableDays'] ?? ['토', '일']),
      availableTimeStart: json['availableTimeStart'] as String?,
      availableTimeEnd: json['availableTimeEnd'] as String?,
      maxMonthlyCount: json['maxMonthlyCount'] as int? ?? 4,
      currentMonthCount: json['currentMonthCount'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      includeItems: List<String>.from(json['includeItems'] ?? []),
      excludeItems: List<String>.from(json['excludeItems'] ?? []),
      notice: json['notice'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idolId': idolId,
      'idolName': idolName,
      'idolProfileImage': idolProfileImage,
      'type': type.code,
      'price': price,
      'description': description,
      'duration': duration,
      'location': location,
      'availableDays': availableDays,
      'availableTimeStart': availableTimeStart,
      'availableTimeEnd': availableTimeEnd,
      'maxMonthlyCount': maxMonthlyCount,
      'currentMonthCount': currentMonthCount,
      'isActive': isActive,
      'includeItems': includeItems,
      'excludeItems': excludeItems,
      'notice': notice,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, idolId, type, price, isActive];
}

/// 특별 만남 예약 모델 (오타가 구매한 특별 만남)
class DateTicketReservation extends Equatable {
  final String id;
  final String ticketProductId;
  final String userId;
  final String userName;
  final String idolId;
  final String idolName;
  final String idolProfileImage;
  final DateTicketType type;
  final int price;
  final DateTicketStatus status;
  final DateTime? scheduledDate;
  final String? scheduledTime;
  final String? location;
  final String? userMessage; // 팬의 요청사항
  final String? idolMessage; // 아이돌의 메시지
  final String? cancelReason;
  final DateTime purchasedAt;
  final DateTime? confirmedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;

  const DateTicketReservation({
    required this.id,
    required this.ticketProductId,
    required this.userId,
    required this.userName,
    required this.idolId,
    required this.idolName,
    required this.idolProfileImage,
    required this.type,
    required this.price,
    required this.status,
    this.scheduledDate,
    this.scheduledTime,
    this.location,
    this.userMessage,
    this.idolMessage,
    this.cancelReason,
    required this.purchasedAt,
    this.confirmedAt,
    this.completedAt,
    this.cancelledAt,
  });

  factory DateTicketReservation.fromJson(Map<String, dynamic> json) {
    return DateTicketReservation(
      id: json['id'] as String,
      ticketProductId: json['ticketProductId'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      idolId: json['idolId'] as String,
      idolName: json['idolName'] as String,
      idolProfileImage: json['idolProfileImage'] as String? ?? '',
      type: DateTicketType.fromCode(json['type'] as String),
      price: json['price'] as int,
      status: DateTicketStatus.fromCode(json['status'] as String),
      scheduledDate: json['scheduledDate'] != null
          ? DateTime.parse(json['scheduledDate'] as String)
          : null,
      scheduledTime: json['scheduledTime'] as String?,
      location: json['location'] as String?,
      userMessage: json['userMessage'] as String?,
      idolMessage: json['idolMessage'] as String?,
      cancelReason: json['cancelReason'] as String?,
      purchasedAt: DateTime.parse(json['purchasedAt'] as String),
      confirmedAt: json['confirmedAt'] != null
          ? DateTime.parse(json['confirmedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      cancelledAt: json['cancelledAt'] != null
          ? DateTime.parse(json['cancelledAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticketProductId': ticketProductId,
      'userId': userId,
      'userName': userName,
      'idolId': idolId,
      'idolName': idolName,
      'idolProfileImage': idolProfileImage,
      'type': type.code,
      'price': price,
      'status': status.code,
      'scheduledDate': scheduledDate?.toIso8601String(),
      'scheduledTime': scheduledTime,
      'location': location,
      'userMessage': userMessage,
      'idolMessage': idolMessage,
      'cancelReason': cancelReason,
      'purchasedAt': purchasedAt.toIso8601String(),
      'confirmedAt': confirmedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, ticketProductId, userId, idolId, status];
}

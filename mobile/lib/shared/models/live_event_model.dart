import 'package:equatable/equatable.dart';

/// 라이브 이벤트 카테고리
enum LiveEventCategory {
  general('일반', 'GENERAL'),
  debut('데뷔', 'OHIROME'), // お披露目
  birthday('생일', 'BIRTHDAY'),
  last('마지막', 'LAST'), // 졸업/탈퇴
  free('무료', 'FREE'),
  special('스페셜', 'SPECIAL');

  final String displayName;
  final String code;
  const LiveEventCategory(this.displayName, this.code);

  static LiveEventCategory fromCode(String code) {
    return LiveEventCategory.values.firstWhere(
      (e) => e.code == code,
      orElse: () => LiveEventCategory.general,
    );
  }
}

/// 라이브 이벤트 상태
enum LiveEventStatus {
  upcoming('예정', 'UPCOMING'),
  open('오픈', 'OPEN'), // 티켓 판매중
  soldout('매진', 'SOLDOUT'),
  ongoing('진행중', 'ONGOING'),
  ended('종료', 'ENDED'),
  cancelled('취소', 'CANCELLED');

  final String displayName;
  final String code;
  const LiveEventStatus(this.displayName, this.code);

  static LiveEventStatus fromCode(String code) {
    return LiveEventStatus.values.firstWhere(
      (e) => e.code == code,
      orElse: () => LiveEventStatus.upcoming,
    );
  }
}

/// 공연장 정보
class VenueInfo extends Equatable {
  final String id;
  final String name;
  final String address;
  final String? addressDetail;
  final double? latitude;
  final double? longitude;
  final int? capacity;
  final String? phoneNumber;
  final String? website;

  const VenueInfo({
    required this.id,
    required this.name,
    required this.address,
    this.addressDetail,
    this.latitude,
    this.longitude,
    this.capacity,
    this.phoneNumber,
    this.website,
  });

  factory VenueInfo.fromJson(Map<String, dynamic> json) {
    return VenueInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      addressDetail: json['addressDetail'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      capacity: json['capacity'] as int?,
      phoneNumber: json['phoneNumber'] as String?,
      website: json['website'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'addressDetail': addressDetail,
      'latitude': latitude,
      'longitude': longitude,
      'capacity': capacity,
      'phoneNumber': phoneNumber,
      'website': website,
    };
  }

  @override
  List<Object?> get props => [id, name, address];
}

/// 출연진 정보
class CastInfo extends Equatable {
  final String idolId;
  final String idolName;
  final String? idolImage;
  final bool isMain; // 메인 출연자 여부

  const CastInfo({
    required this.idolId,
    required this.idolName,
    this.idolImage,
    this.isMain = false,
  });

  factory CastInfo.fromJson(Map<String, dynamic> json) {
    return CastInfo(
      idolId: json['idolId'] as String,
      idolName: json['idolName'] as String,
      idolImage: json['idolImage'] as String?,
      isMain: json['isMain'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idolId': idolId,
      'idolName': idolName,
      'idolImage': idolImage,
      'isMain': isMain,
    };
  }

  @override
  List<Object?> get props => [idolId, idolName];
}

/// 티켓 정보
class TicketInfo extends Equatable {
  final String id;
  final String name;
  final int price;
  final String? description;
  final int? quantity;
  final int sold;
  final bool isAvailable;

  const TicketInfo({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    this.quantity,
    this.sold = 0,
    this.isAvailable = true,
  });

  bool get isSoldOut => quantity != null && sold >= quantity!;

  factory TicketInfo.fromJson(Map<String, dynamic> json) {
    return TicketInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      price: json['price'] as int,
      description: json['description'] as String?,
      quantity: json['quantity'] as int?,
      sold: json['sold'] as int? ?? 0,
      isAvailable: json['isAvailable'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'quantity': quantity,
      'sold': sold,
      'isAvailable': isAvailable,
    };
  }

  @override
  List<Object?> get props => [id, name, price];
}

/// 라이브 이벤트 모델
class LiveEventModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final LiveEventCategory category;
  final LiveEventStatus status;

  // 주최자 정보
  final String? hostId;
  final String? hostName;
  final String? groupId;
  final String? groupName;

  // 포스터/이미지
  final String posterImage;
  final List<String> galleryImages;

  // 공연장 정보
  final VenueInfo venue;

  // 일정
  final DateTime doorOpenTime; // 개장 시간
  final DateTime startTime; // 공연 시작
  final DateTime? endTime; // 공연 종료
  final int? durationMinutes; // 소요 시간 (분)

  // 출연진
  final List<CastInfo> castList;

  // 티켓 정보
  final List<TicketInfo> tickets;
  final bool isOnSiteAvailable; // 현장 구매 가능 여부
  final DateTime? ticketOpenDate; // 티켓 판매 시작
  final DateTime? ticketCloseDate; // 티켓 판매 종료

  // 추가 정보
  final String? notes; // 주의사항
  final List<String> tags;
  final String? livestreamUrl; // 온라인 스트리밍 URL

  // 통계
  final int viewCount;
  final int interestedCount; // 관심있음
  final int attendeeCount; // 참석자 수

  final DateTime createdAt;
  final DateTime? updatedAt;

  const LiveEventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    this.hostId,
    this.hostName,
    this.groupId,
    this.groupName,
    required this.posterImage,
    this.galleryImages = const [],
    required this.venue,
    required this.doorOpenTime,
    required this.startTime,
    this.endTime,
    this.durationMinutes,
    this.castList = const [],
    this.tickets = const [],
    this.isOnSiteAvailable = false,
    this.ticketOpenDate,
    this.ticketCloseDate,
    this.notes,
    this.tags = const [],
    this.livestreamUrl,
    this.viewCount = 0,
    this.interestedCount = 0,
    this.attendeeCount = 0,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isToday {
    final now = DateTime.now();
    return startTime.year == now.year &&
        startTime.month == now.month &&
        startTime.day == now.day;
  }

  bool get isFree => category == LiveEventCategory.free;

  bool get isSoldOut => status == LiveEventStatus.soldout;

  bool get isOngoing {
    final now = DateTime.now();
    return now.isAfter(doorOpenTime) &&
        (endTime == null || now.isBefore(endTime!));
  }

  bool get isUpcoming => DateTime.now().isBefore(doorOpenTime);

  factory LiveEventModel.fromJson(Map<String, dynamic> json) {
    return LiveEventModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      category: LiveEventCategory.fromCode(
        json['category'] as String? ?? 'GENERAL',
      ),
      status: LiveEventStatus.fromCode(
        json['status'] as String? ?? 'UPCOMING',
      ),
      hostId: json['hostId'] as String?,
      hostName: json['hostName'] as String?,
      groupId: json['groupId'] as String?,
      groupName: json['groupName'] as String?,
      posterImage: json['posterImage'] as String,
      galleryImages: List<String>.from(json['galleryImages'] ?? []),
      venue: VenueInfo.fromJson(json['venue'] as Map<String, dynamic>),
      doorOpenTime: DateTime.parse(json['doorOpenTime'] as String),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      durationMinutes: json['durationMinutes'] as int?,
      castList: (json['castList'] as List<dynamic>?)
              ?.map((e) => CastInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      tickets: (json['tickets'] as List<dynamic>?)
              ?.map((e) => TicketInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      isOnSiteAvailable: json['isOnSiteAvailable'] as bool? ?? false,
      ticketOpenDate: json['ticketOpenDate'] != null
          ? DateTime.parse(json['ticketOpenDate'] as String)
          : null,
      ticketCloseDate: json['ticketCloseDate'] != null
          ? DateTime.parse(json['ticketCloseDate'] as String)
          : null,
      notes: json['notes'] as String?,
      tags: List<String>.from(json['tags'] ?? []),
      livestreamUrl: json['livestreamUrl'] as String?,
      viewCount: json['viewCount'] as int? ?? 0,
      interestedCount: json['interestedCount'] as int? ?? 0,
      attendeeCount: json['attendeeCount'] as int? ?? 0,
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
      'title': title,
      'description': description,
      'category': category.code,
      'status': status.code,
      'hostId': hostId,
      'hostName': hostName,
      'groupId': groupId,
      'groupName': groupName,
      'posterImage': posterImage,
      'galleryImages': galleryImages,
      'venue': venue.toJson(),
      'doorOpenTime': doorOpenTime.toIso8601String(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'durationMinutes': durationMinutes,
      'castList': castList.map((e) => e.toJson()).toList(),
      'tickets': tickets.map((e) => e.toJson()).toList(),
      'isOnSiteAvailable': isOnSiteAvailable,
      'ticketOpenDate': ticketOpenDate?.toIso8601String(),
      'ticketCloseDate': ticketCloseDate?.toIso8601String(),
      'notes': notes,
      'tags': tags,
      'livestreamUrl': livestreamUrl,
      'viewCount': viewCount,
      'interestedCount': interestedCount,
      'attendeeCount': attendeeCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, title, startTime];
}

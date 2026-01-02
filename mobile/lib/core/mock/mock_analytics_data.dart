import '../../shared/models/analytics_model.dart';
import '../../shared/models/live_chat_model.dart';
import '../../shared/models/idol_post_model.dart';

/// CRM 분석 및 라이브 채팅용 Mock 데이터
class MockAnalyticsData {
  // ============ 소속사 매출 요약 ============
  static final AgencyRevenueSummary agencyRevenue = AgencyRevenueSummary(
    agencyId: 'agency-001',
    agencyName: '스타라이트 엔터테인먼트',
    totalRevenue: 1245000000, // 12억 4500만원
    monthlyRevenue: 156000000, // 1억 5600만원
    weeklyRevenue: 42000000, // 4200만원
    todayRevenue: 8500000, // 850만원
    totalSubscribers: 3248,
    totalIdols: 6,
    activeIdols: 5,
    revenueGrowthRate: 15.2,
    subscriberGrowthRate: 8.7,
    peakHour: 21, // 오후 9시
    peakDay: '토요일',
    subscriptionRevenueRatio: 35.0,
    giftRevenueRatio: 28.0,
    dateTicketRevenueRatio: 18.0,
    campaignRevenueRatio: 12.0,
    advertisementRevenueRatio: 7.0,
    idolSummaries: [
      IdolRevenueSummary(
        idolId: 'idol-001',
        idolName: '하늘별',
        idolProfileImage: 'https://i.pravatar.cc/100?img=5',
        groupName: null,
        totalRevenue: 450000000,
        monthlyRevenue: 52000000,
        weeklyRevenue: 14500000,
        todayRevenue: 3200000,
        subscriberCount: 856,
        newSubscribersToday: 12,
        giftCount: 1245,
        bubbleMessageCount: 156,
        revenueGrowthRate: 18.5,
        subscriberGrowthRate: 12.3,
        peakHour: 21,
        peakDay: '토요일',
      ),
      IdolRevenueSummary(
        idolId: 'idol-002',
        idolName: '미유',
        idolProfileImage: 'https://i.pravatar.cc/100?img=9',
        groupName: 'StarLight Cafe',
        totalRevenue: 320000000,
        monthlyRevenue: 38000000,
        weeklyRevenue: 9800000,
        todayRevenue: 1800000,
        subscriberCount: 523,
        newSubscribersToday: 8,
        giftCount: 892,
        bubbleMessageCount: 89,
        revenueGrowthRate: 12.1,
        subscriberGrowthRate: 9.5,
        peakHour: 20,
        peakDay: '금요일',
      ),
      IdolRevenueSummary(
        idolId: 'idol-003',
        idolName: '루나',
        idolProfileImage: 'https://i.pravatar.cc/100?img=10',
        groupName: 'MoonLight',
        totalRevenue: 285000000,
        monthlyRevenue: 35000000,
        weeklyRevenue: 9200000,
        todayRevenue: 1650000,
        subscriberCount: 412,
        newSubscribersToday: 6,
        giftCount: 756,
        bubbleMessageCount: 112,
        revenueGrowthRate: 22.4,
        subscriberGrowthRate: 15.2,
        peakHour: 22,
        peakDay: '토요일',
      ),
      IdolRevenueSummary(
        idolId: 'idol-004',
        idolName: '사쿠라',
        idolProfileImage: 'https://i.pravatar.cc/100?img=20',
        groupName: null,
        totalRevenue: 120000000,
        monthlyRevenue: 18000000,
        weeklyRevenue: 4800000,
        todayRevenue: 950000,
        subscriberCount: 289,
        newSubscribersToday: 4,
        giftCount: 456,
        bubbleMessageCount: 67,
        revenueGrowthRate: 8.3,
        subscriberGrowthRate: 5.1,
        peakHour: 19,
        peakDay: '일요일',
      ),
      IdolRevenueSummary(
        idolId: 'idol-005',
        idolName: '유키',
        idolProfileImage: 'https://i.pravatar.cc/100?img=25',
        groupName: 'VirtuaLive',
        totalRevenue: 70000000,
        monthlyRevenue: 13000000,
        weeklyRevenue: 3700000,
        todayRevenue: 900000,
        subscriberCount: 523,
        newSubscribersToday: 15,
        giftCount: 623,
        bubbleMessageCount: 245,
        revenueGrowthRate: 35.2,
        subscriberGrowthRate: 28.5,
        peakHour: 22,
        peakDay: '금요일',
      ),
    ],
    recentDailyRevenue: _generateDailyRevenue(),
  );

  // 최근 7일간 일별 매출 생성
  static List<DailyRevenue> _generateDailyRevenue() {
    final List<DailyRevenue> revenues = [];
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final baseRevenue = 20000000 + (i % 3) * 5000000; // 변동성
      revenues.add(DailyRevenue(
        date: date,
        revenue: baseRevenue,
        subscriptionRevenue: (baseRevenue * 0.35).toInt(),
        giftRevenue: (baseRevenue * 0.28).toInt(),
        dateTicketRevenue: (baseRevenue * 0.18).toInt(),
        campaignRevenue: (baseRevenue * 0.12).toInt(),
        advertisementRevenue: (baseRevenue * 0.07).toInt(),
        bubbleRevenue: (baseRevenue * 0.08).toInt(),
        newSubscribers: 20 + (i % 5) * 3,
        churnedSubscribers: 3 + (i % 2),
        transactionCount: 150 + (i % 3) * 30,
      ));
    }
    return revenues;
  }

  // 시간대별 매출 (24시간)
  static List<HourlyRevenue> get hourlyRevenue {
    final List<HourlyRevenue> hourly = [];
    for (int i = 0; i < 24; i++) {
      int multiplier;
      if (i >= 20 && i <= 23) {
        multiplier = 5; // 피크 시간
      } else if (i >= 18 && i < 20) {
        multiplier = 4;
      } else if (i >= 12 && i < 18) {
        multiplier = 2;
      } else if (i >= 9 && i < 12) {
        multiplier = 1;
      } else {
        multiplier = 0;
      }
      hourly.add(HourlyRevenue(
        hour: i,
        revenue: 100000 * multiplier + 50000,
        transactionCount: 10 * multiplier + 5,
        subscriptionCount: 2 * multiplier,
      ));
    }
    return hourly;
  }

  // ============ 실시간 매출 알림 ============
  static List<RevenueNotification> get recentNotifications => [
    RevenueNotification(
      id: 'notif-001',
      idolId: 'idol-001',
      idolName: '하늘별',
      type: TransactionType.subscription,
      amount: 15000,
      fanName: '별빛팬1',
      message: '프리미엄 구독',
      createdAt: DateTime.now().subtract(const Duration(seconds: 30)),
    ),
    RevenueNotification(
      id: 'notif-002',
      idolId: 'idol-001',
      idolName: '하늘별',
      type: TransactionType.gift,
      amount: 50000,
      fanName: '스카이러버',
      message: '🎁 케이크 선물',
      createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
    RevenueNotification(
      id: 'notif-003',
      idolId: 'idol-003',
      idolName: '루나',
      type: TransactionType.campaign,
      amount: 55000,
      fanName: '문라이터',
      message: '생일 펀딩 참여',
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    RevenueNotification(
      id: 'notif-004',
      idolId: 'idol-002',
      idolName: '미유',
      type: TransactionType.dateTicket,
      amount: 800000,
      fanName: '주인님123',
      message: '카페 데이트권 구매',
      createdAt: DateTime.now().subtract(const Duration(minutes: 8)),
    ),
    RevenueNotification(
      id: 'notif-005',
      idolId: 'idol-001',
      idolName: '하늘별',
      type: TransactionType.bubble,
      amount: 4900,
      fanName: '새로운팬',
      message: '버블 구독 시작',
      createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
    ),
    RevenueNotification(
      id: 'notif-006',
      idolId: 'idol-005',
      idolName: '유키',
      type: TransactionType.gift,
      amount: 10000,
      fanName: '게이머유키',
      message: '🎮 게임 아이템 선물',
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
  ];

  // ============ 버블 라이브 채팅 Mock 데이터 ============
  static BubbleLiveRoom getLiveRoom(String idolId) {
    return BubbleLiveRoom(
      id: 'live-room-$idolId',
      idolId: idolId,
      idolName: _getIdolName(idolId),
      idolProfileImage: _getIdolImage(idolId),
      isLive: true,
      liveStartedAt: DateTime.now().subtract(const Duration(minutes: 45)),
      viewerCount: 1234,
      totalMessages: 567,
      totalGifts: 89,
      totalGiftAmount: 2450000,
    );
  }

  static String _getIdolName(String idolId) {
    switch (idolId) {
      case 'idol-001':
        return '하늘별';
      case 'idol-002':
        return '미유';
      case 'idol-003':
        return '루나';
      default:
        return '아이돌';
    }
  }

  static String _getIdolImage(String idolId) {
    switch (idolId) {
      case 'idol-001':
        return 'https://i.pravatar.cc/100?img=5';
      case 'idol-002':
        return 'https://i.pravatar.cc/100?img=9';
      case 'idol-003':
        return 'https://i.pravatar.cc/100?img=10';
      default:
        return 'https://i.pravatar.cc/100?img=1';
    }
  }

  // 버블 라이브 메시지 (1:1 느낌 구현용)
  static List<LiveChatMessage> getLiveChatMessages(String roomId, String myUserId) {
    final now = DateTime.now();
    return [
      // 아이돌 메시지 (모든 팬에게 보임)
      LiveChatMessage(
        id: 'msg-001',
        roomId: roomId,
        senderId: 'idol-001',
        senderName: '하늘별',
        senderProfileImage: 'https://i.pravatar.cc/100?img=5',
        senderType: SenderType.idol,
        messageType: LiveChatMessageType.text,
        content: '안녕하세요~ 오늘도 와주셨네요! 💕',
        createdAt: now.subtract(const Duration(minutes: 10)),
      ),

      // 내 메시지 (나만 보임)
      LiveChatMessage(
        id: 'msg-002',
        roomId: roomId,
        senderId: myUserId,
        senderName: '별빛팬',
        senderType: SenderType.fan,
        messageType: LiveChatMessageType.text,
        content: '하늘별 안녕하세요!! 오늘도 예뻐요 🥰',
        createdAt: now.subtract(const Duration(minutes: 9)),
      ),

      // 다른 팬 메시지 (아이돌이 태그하지 않으면 안보임)
      LiveChatMessage(
        id: 'msg-003',
        roomId: roomId,
        senderId: 'fan-002',
        senderName: '스카이러버',
        senderType: SenderType.fan,
        messageType: LiveChatMessageType.text,
        content: '오늘 방송 너무 기다렸어요!',
        createdAt: now.subtract(const Duration(minutes: 8)),
        isTaggedByIdol: false, // 태그 안됨 -> 다른 팬들에게 안보임
      ),

      // 아이돌이 특정 팬을 태그해서 답장 (모든 팬에게 보임)
      LiveChatMessage(
        id: 'msg-004',
        roomId: roomId,
        senderId: 'idol-001',
        senderName: '하늘별',
        senderProfileImage: 'https://i.pravatar.cc/100?img=5',
        senderType: SenderType.idol,
        messageType: LiveChatMessageType.text,
        content: '고마워요~ 오늘 컨디션 진짜 좋아요! ㅎㅎ',
        createdAt: now.subtract(const Duration(minutes: 7)),
        isTaggedByIdol: true,
        taggedMessageId: 'msg-003',
        taggedFanName: '스카이러버',
        taggedContent: '오늘 방송 너무 기다렸어요!',
      ),

      // 시스템 메시지
      LiveChatMessage(
        id: 'msg-005',
        roomId: roomId,
        senderId: 'system',
        senderName: '시스템',
        senderType: SenderType.system,
        messageType: LiveChatMessageType.gift,
        content: '🎁 새로운팬님이 케이크를 선물했습니다!',
        createdAt: now.subtract(const Duration(minutes: 6)),
        giftType: 'cake',
        giftAmount: 50000,
      ),

      // 아이돌 메시지
      LiveChatMessage(
        id: 'msg-006',
        roomId: roomId,
        senderId: 'idol-001',
        senderName: '하늘별',
        senderProfileImage: 'https://i.pravatar.cc/100?img=5',
        senderType: SenderType.idol,
        messageType: LiveChatMessageType.text,
        content: '새로운팬님 케이크 감사해요!! 🎂💕',
        createdAt: now.subtract(const Duration(minutes: 5)),
      ),

      // 다른 팬 메시지 (안보임)
      LiveChatMessage(
        id: 'msg-007',
        roomId: roomId,
        senderId: 'fan-003',
        senderName: '달빛소녀',
        senderType: SenderType.fan,
        messageType: LiveChatMessageType.text,
        content: '하늘별 너무 귀여워요 ㅠㅠ',
        createdAt: now.subtract(const Duration(minutes: 4)),
        isTaggedByIdol: false,
      ),

      // 내 메시지
      LiveChatMessage(
        id: 'msg-008',
        roomId: roomId,
        senderId: myUserId,
        senderName: '별빛팬',
        senderType: SenderType.fan,
        messageType: LiveChatMessageType.text,
        content: '오늘 노래 불러주세요~!',
        createdAt: now.subtract(const Duration(minutes: 3)),
      ),

      // 아이돌이 내 메시지에 답장! (태그됨)
      LiveChatMessage(
        id: 'msg-009',
        roomId: roomId,
        senderId: 'idol-001',
        senderName: '하늘별',
        senderProfileImage: 'https://i.pravatar.cc/100?img=5',
        senderType: SenderType.idol,
        messageType: LiveChatMessageType.text,
        content: '그럼 제 신곡 살짝 들려드릴까요? 🎤✨',
        createdAt: now.subtract(const Duration(minutes: 2)),
        isTaggedByIdol: true,
        taggedMessageId: 'msg-008',
        taggedFanName: '별빛팬',
        taggedContent: '오늘 노래 불러주세요~!',
      ),

      // 아이돌 보이스 메시지
      LiveChatMessage(
        id: 'msg-010',
        roomId: roomId,
        senderId: 'idol-001',
        senderName: '하늘별',
        senderProfileImage: 'https://i.pravatar.cc/100?img=5',
        senderType: SenderType.idol,
        messageType: LiveChatMessageType.voice,
        content: '🎵 미공개곡 일부분이에요~',
        duration: 30,
        createdAt: now.subtract(const Duration(minutes: 1)),
      ),
    ];
  }

  // ============ 아이돌 게시물 Mock 데이터 ============
  static List<IdolPost> get idolPosts => [
    IdolPost(
      id: 'post-001',
      idolId: 'idol-001',
      idolName: '하늘별',
      idolProfileImage: 'https://i.pravatar.cc/100?img=5',
      isIdolVerified: true,
      type: PostType.image,
      visibility: PostVisibility.public,
      content: '오늘 연습 끝! 다음 주 공연 준비 열심히 하고 있어요 💪\n\n팬분들 많이 와주실 거죠? 🥺\n\n#하늘별 #지하돌 #연습',
      mediaUrls: ['https://picsum.photos/seed/practice/800/800'],
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      viewCount: 4523,
      likeCount: 1234,
      commentCount: 89,
      bookmarkCount: 156,
      shareCount: 45,
      isLiked: true,
      isBookmarked: false,
    ),
    IdolPost(
      id: 'post-002',
      idolId: 'idol-001',
      idolName: '하늘별',
      idolProfileImage: 'https://i.pravatar.cc/100?img=5',
      isIdolVerified: true,
      type: PostType.text,
      visibility: PostVisibility.subscribers,
      content: '🎉 구독자 전용 공지 🎉\n\n다음 주 팬미팅 장소가 확정됐어요!\n서울 강남 XX홀에서 만나요 💕\n\n자세한 내용은 추후 공지할게요!',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      viewCount: 856,
      likeCount: 423,
      commentCount: 67,
      bookmarkCount: 234,
      shareCount: 12,
      isLiked: false,
      isBookmarked: true,
    ),
    IdolPost(
      id: 'post-003',
      idolId: 'idol-001',
      idolName: '하늘별',
      idolProfileImage: 'https://i.pravatar.cc/100?img=5',
      isIdolVerified: true,
      type: PostType.poll,
      visibility: PostVisibility.public,
      content: '다음 커버곡 투표해주세요! 🎵\n어떤 노래가 듣고 싶으세요?',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      viewCount: 6789,
      likeCount: 890,
      commentCount: 234,
      bookmarkCount: 67,
      shareCount: 89,
      pollOptions: [
        PollOption(id: 'opt-1', text: 'NewJeans - Hype Boy', voteCount: 423, votePercentage: 42.0, isSelected: true),
        PollOption(id: 'opt-2', text: 'IVE - Love Dive', voteCount: 312, votePercentage: 31.0),
        PollOption(id: 'opt-3', text: 'aespa - Supernova', voteCount: 178, votePercentage: 18.0),
        PollOption(id: 'opt-4', text: '직접 입력 (댓글)', voteCount: 89, votePercentage: 9.0),
      ],
      pollExpiresAt: DateTime.now().add(const Duration(days: 2)),
      hasPollVoted: true,
    ),
    IdolPost(
      id: 'post-004',
      idolId: 'idol-001',
      idolName: '하늘별',
      idolProfileImage: 'https://i.pravatar.cc/100?img=5',
      isIdolVerified: true,
      type: PostType.video,
      visibility: PostVisibility.premium,
      content: '🎬 VIP 전용 비하인드 영상 🎬\n\n앨범 녹음 현장 브이로그예요!\n열심히 녹음하는 모습 봐주세요 💕',
      mediaUrls: ['https://picsum.photos/seed/vlog/800/450'],
      thumbnailUrl: 'https://picsum.photos/seed/vlog/400/225',
      videoDuration: 325,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      viewCount: 234,
      likeCount: 189,
      commentCount: 56,
      bookmarkCount: 123,
      shareCount: 8,
      isLiked: true,
      isBookmarked: true,
    ),
    IdolPost(
      id: 'post-005',
      idolId: 'idol-003',
      idolName: '루나',
      idolProfileImage: 'https://i.pravatar.cc/100?img=10',
      isIdolVerified: true,
      type: PostType.image,
      visibility: PostVisibility.public,
      content: '생일 펀딩 78% 달성!! 🎂\n\n정말 감사해요 여러분... 😢💕\n강남역 전광판 기대해주세요!!\n\n#루나 #생일 #감사',
      mediaUrls: [
        'https://picsum.photos/seed/luna_bday/800/800',
        'https://picsum.photos/seed/luna_bday2/800/800',
      ],
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      viewCount: 8923,
      likeCount: 2341,
      commentCount: 456,
      bookmarkCount: 289,
      shareCount: 178,
      isLiked: true,
      isBookmarked: false,
    ),
  ];

  // 게시물 상세 통계
  static PostEngagement getPostEngagement(String postId) {
    return PostEngagement(
      postId: postId,
      viewCount: 4523,
      likeCount: 1234,
      commentCount: 89,
      bookmarkCount: 156,
      shareCount: 45,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      hourlyEngagement: List.generate(
        24,
        (i) => HourlyEngagement(
          hour: i,
          views: 100 + (i > 18 && i < 23 ? 300 : 0),
          likes: 20 + (i > 18 && i < 23 ? 80 : 0),
          comments: 2 + (i > 18 && i < 23 ? 8 : 0),
        ),
      ),
    );
  }
}

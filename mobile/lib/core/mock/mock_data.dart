import '../../shared/models/user_model.dart';
import '../../shared/models/idol_model.dart';
import '../../shared/models/campaign_model.dart';
import '../../shared/models/bubble_message_model.dart';
import '../../shared/models/date_ticket_model.dart';
import '../../shared/models/advertisement_model.dart';
import '../../shared/models/event_model.dart';
import '../../shared/models/activity_stats.dart';

class MockData {
  // ============ 데모 유저 ============
  static final User demoUser = User(
    id: 'demo-user-001',
    email: 'demo@example.com',
    nickname: '별빛팬',
    profileImage: 'https://ui-avatars.com/api/?name=Fan&background=FF4D8D&color=fff&size=150',
    role: 'FAN',
    isVerified: true,
    walletBalance: 500000, // 50만원
  );

  // ============ 아이돌 상세 데이터 ============
  static final List<IdolModel> idolModels = [
    IdolModel(
      id: 'idol-001',
      stageName: '하늘별',
      realName: '김서연',
      category: IdolCategory.undergroundIdol,
      agencyName: '스타라이트 엔터테인먼트',
      groupName: null,
      imageColor: '0xFFE91E63', // Pink
      profileImage: 'https://ui-avatars.com/api/?name=하늘별&background=E91E63&color=fff&size=300',
      coverImage: 'https://placehold.co/800x400/E91E63/ffffff?text=하늘별',
      bio: '데뷔 2년차 솔로 아이돌\n좋아하는 것: 노래, 춤, 팬분들\n꿈: 더 많은 분들께 행복을 전하기',
      description: '신나는 무대와 함께하는 지하돌 하늘별입니다! 항상 응원해주셔서 감사해요 💕',
      isVerified: true,
      debutDate: '2023-03-15',
      birthDate: '2002-08-12',
      height: '163cm',
      bloodType: 'A',
      specialties: ['보컬', '작사', '피아노'],
      hobbies: ['영화 감상', '카페 탐방', '팬레터 읽기'],
      twitterUrl: 'https://twitter.com/skystar_idol',
      instagramUrl: 'https://instagram.com/skystar_official',
      youtubeUrl: 'https://youtube.com/@skystar',
      totalSupport: 25000000,
      supporterCount: 1342,
      subscriberCount: 856,
      ranking: 1,
      monthlyRanking: 1,
      rating: 4.9,
      activityStats: ActivityStats.withCalculatedScore(
        totalPosts: 156,
        postsThisWeek: 8,
        postsThisMonth: 32,
        totalBubbleMessages: 423,
        bubbleMessagesThisWeek: 15,
        totalEvents: 12,
        upcomingEvents: 2,
        totalActiveDays: 245,
        consecutiveActiveDays: 28,
        lastActiveDate: DateTime.now(),
        totalComments: 892,
        commentsThisWeek: 34,
        fanResponseRate: 0.92,
        totalLiveHours: 48,
        liveHoursThisWeek: 3,
        badges: ['streak_7', 'streak_30', 'posts_100', 'fan_favorite'],
      ),
      galleryImages: [
        'https://placehold.co/400x400/E91E63/ffffff?text=Photo+1',
        'https://placehold.co/400x400/E91E63/ffffff?text=Photo+2',
        'https://placehold.co/400x400/E91E63/ffffff?text=Photo+3',
        'https://placehold.co/400x400/E91E63/ffffff?text=Photo+4',
        'https://placehold.co/400x400/E91E63/ffffff?text=Photo+5',
        'https://placehold.co/400x400/E91E63/ffffff?text=Photo+6',
      ],
      offersMealDate: true,
      offersCafeDate: true,
      mealDatePrice: 1500000,
      cafeDatePrice: 1000000,
      dateAvailable: true,
      hasBubble: true,
      bubblePrice: 4900,
      subscriptionTiers: [
        const SubscriptionTier(
          id: 'tier-1',
          name: '라이트',
          price: 5000,
          description: '기본 구독',
          benefits: ['전용 피드 열람', '월간 포토카드 1장'],
        ),
        const SubscriptionTier(
          id: 'tier-2',
          name: '프리미엄',
          price: 15000,
          description: '인기 구독',
          benefits: ['전용 피드 열람', '월간 포토카드 3장', '비하인드 영상', '생일 축하 영상'],
          isPopular: true,
        ),
        const SubscriptionTier(
          id: 'tier-3',
          name: 'VIP',
          price: 50000,
          description: '최고 혜택',
          benefits: ['모든 프리미엄 혜택', '월 1회 영상통화 5분', '연간 팬미팅 초대', '친필 편지'],
        ),
      ],
      createdAt: DateTime(2023, 3, 15),
    ),
    IdolModel(
      id: 'idol-002',
      stageName: '미유',
      category: IdolCategory.maidCafe,
      agencyName: 'StarLight Cafe',
      groupName: 'StarLight Cafe',
      imageColor: '0xFFFFD54F', // Yellow
      profileImage: 'https://ui-avatars.com/api/?name=미유&background=FFD54F&color=333&size=300',
      coverImage: 'https://placehold.co/800x400/FFD54F/333333?text=미유',
      bio: '메이드 카페 근무 3년차\n취미: 코스프레, 게임\n특기: 라떼아트, 오믈렛 라이스',
      description: '아키하바라 ☆StarLight Cafe☆ 소속 미유입니다! 오늘도 주인님을 기다리고 있어요~',
      isVerified: true,
      birthDate: '2001-04-22',
      height: '158cm',
      bloodType: 'O',
      specialties: ['라떼아트', '오믈렛 라이스', '마술'],
      hobbies: ['게임', '코스프레', '요리'],
      twitterUrl: 'https://twitter.com/miyu_maid',
      instagramUrl: 'https://instagram.com/miyu_starlight',
      totalSupport: 18000000,
      supporterCount: 756,
      subscriberCount: 523,
      ranking: 2,
      monthlyRanking: 3,
      rating: 4.8,
      activityStats: ActivityStats.withCalculatedScore(
        totalPosts: 89,
        postsThisWeek: 12,
        postsThisMonth: 45,
        totalBubbleMessages: 567,
        bubbleMessagesThisWeek: 28,
        totalEvents: 8,
        upcomingEvents: 1,
        totalActiveDays: 187,
        consecutiveActiveDays: 15,
        lastActiveDate: DateTime.now(),
        totalComments: 1234,
        commentsThisWeek: 56,
        fanResponseRate: 0.95,
        totalLiveHours: 32,
        liveHoursThisWeek: 5,
        badges: ['streak_7', 'posts_50', 'fan_favorite'],
      ),
      galleryImages: [
        'https://placehold.co/400x400/FFD54F/333333?text=Photo+1',
        'https://placehold.co/400x400/FFD54F/333333?text=Photo+2',
        'https://placehold.co/400x400/FFD54F/333333?text=Photo+3',
        'https://placehold.co/400x400/FFD54F/333333?text=Photo+4',
      ],
      offersMealDate: false,
      offersCafeDate: true,
      cafeDatePrice: 800000, // 메이드카페는 카페데이트만
      dateAvailable: true,
      hasBubble: true,
      bubblePrice: 3900,
      subscriptionTiers: [
        const SubscriptionTier(
          id: 'tier-1',
          name: '일반',
          price: 3000,
          description: '기본 구독',
          benefits: ['전용 피드 열람'],
        ),
        const SubscriptionTier(
          id: 'tier-2',
          name: '단골손님',
          price: 10000,
          description: '단골 혜택',
          benefits: ['전용 피드 열람', '코스프레 사진', '카페 할인쿠폰'],
          isPopular: true,
        ),
      ],
      createdAt: DateTime(2022, 6, 1),
    ),
    IdolModel(
      id: 'idol-003',
      stageName: '루나',
      category: IdolCategory.undergroundIdol,
      agencyName: 'MoonLight Entertainment',
      groupName: 'MoonLight',
      imageColor: '0xFF5C6BC0', // Indigo
      profileImage: 'https://ui-avatars.com/api/?name=루나&background=5C6BC0&color=fff&size=300',
      coverImage: 'https://placehold.co/800x400/5C6BC0/ffffff?text=루나',
      bio: '그룹 MoonLight 멤버\n포지션: 메인보컬\n좋아하는 음식: 마카롱',
      description: '달빛처럼 빛나는 아이돌 루나예요 🌙 함께 꿈을 이뤄가요!',
      isVerified: true,
      debutDate: '2022-09-01',
      birthDate: '2003-01-15',
      height: '165cm',
      bloodType: 'B',
      specialties: ['고음', '작곡', '기타'],
      hobbies: ['작곡', '독서', '별 관측'],
      twitterUrl: 'https://twitter.com/luna_moonlight',
      instagramUrl: 'https://instagram.com/luna_ml',
      youtubeUrl: 'https://youtube.com/@lunamoonlight',
      tiktokUrl: 'https://tiktok.com/@luna_ml',
      totalSupport: 15000000,
      supporterCount: 598,
      subscriberCount: 412,
      ranking: 3,
      monthlyRanking: 2,
      rating: 4.9,
      activityStats: ActivityStats.withCalculatedScore(
        totalPosts: 134,
        postsThisWeek: 6,
        postsThisMonth: 28,
        totalBubbleMessages: 312,
        bubbleMessagesThisWeek: 18,
        totalEvents: 6,
        upcomingEvents: 2,
        totalActiveDays: 156,
        consecutiveActiveDays: 22,
        lastActiveDate: DateTime.now(),
        totalComments: 678,
        commentsThisWeek: 29,
        fanResponseRate: 0.88,
        totalLiveHours: 28,
        liveHoursThisWeek: 2,
        badges: ['streak_7', 'posts_100'],
      ),
      galleryImages: [
        'https://placehold.co/400x400/5C6BC0/ffffff?text=Photo+1',
        'https://placehold.co/400x400/5C6BC0/ffffff?text=Photo+2',
        'https://placehold.co/400x400/5C6BC0/ffffff?text=Photo+3',
      ],
      offersMealDate: true,
      offersCafeDate: true,
      mealDatePrice: 1500000,
      cafeDatePrice: 1000000,
      dateAvailable: true,
      hasBubble: true,
      bubblePrice: 4900,
      subscriptionTiers: [
        const SubscriptionTier(
          id: 'tier-1',
          name: '문라이트',
          price: 5000,
          description: '기본 구독',
          benefits: ['전용 피드', '월간 배경화면'],
        ),
        const SubscriptionTier(
          id: 'tier-2',
          name: '풀문',
          price: 20000,
          description: 'VIP 혜택',
          benefits: ['전용 피드', '비하인드', '미공개 음원', '팬미팅 우선예약'],
          isPopular: true,
        ),
      ],
      createdAt: DateTime(2022, 9, 1),
    ),
    IdolModel(
      id: 'idol-004',
      stageName: '사쿠라',
      category: IdolCategory.cosplayer,
      groupName: null,
      imageColor: '0xFFF48FB1', // Sakura Pink
      profileImage: 'https://ui-avatars.com/api/?name=사쿠라&background=F48FB1&color=fff&size=300',
      coverImage: 'https://placehold.co/800x400/F48FB1/ffffff?text=사쿠라',
      bio: '코스프레 경력 5년\n최애 작품: 마법소녀\n다음 코스프레: 비밀!',
      description: '애니메이션 코스프레를 사랑하는 사쿠라입니다! 🌸',
      isVerified: true,
      birthDate: '2000-03-27',
      height: '160cm',
      bloodType: 'AB',
      specialties: ['의상 제작', '메이크업', '가발 스타일링'],
      hobbies: ['애니메이션', '재봉', '게임'],
      twitterUrl: 'https://twitter.com/sakura_cos',
      instagramUrl: 'https://instagram.com/sakura_cosplay',
      totalSupport: 12000000,
      supporterCount: 467,
      subscriberCount: 289,
      ranking: 4,
      monthlyRanking: 5,
      rating: 4.7,
      activityStats: ActivityStats.withCalculatedScore(
        totalPosts: 198,
        postsThisWeek: 15,
        postsThisMonth: 62,
        totalBubbleMessages: 145,
        bubbleMessagesThisWeek: 8,
        totalEvents: 15,
        upcomingEvents: 3,
        totalActiveDays: 312,
        consecutiveActiveDays: 42,
        lastActiveDate: DateTime.now(),
        totalComments: 456,
        commentsThisWeek: 18,
        fanResponseRate: 0.85,
        totalLiveHours: 12,
        liveHoursThisWeek: 1,
        badges: ['streak_7', 'streak_30', 'posts_100', 'event_10'],
      ),
      galleryImages: [
        'https://placehold.co/400x400/F48FB1/ffffff?text=Photo+1',
        'https://placehold.co/400x400/F48FB1/ffffff?text=Photo+2',
        'https://placehold.co/400x400/F48FB1/ffffff?text=Photo+3',
        'https://placehold.co/400x400/F48FB1/ffffff?text=Photo+4',
        'https://placehold.co/400x400/F48FB1/ffffff?text=Photo+5',
      ],
      offersMealDate: false,
      offersCafeDate: true,
      cafeDatePrice: 1000000,
      dateAvailable: true,
      hasBubble: true,
      bubblePrice: 3900,
      subscriptionTiers: [
        const SubscriptionTier(
          id: 'tier-1',
          name: '팬',
          price: 5000,
          description: '기본 구독',
          benefits: ['고화질 코스프레 사진', '제작 비하인드'],
          isPopular: true,
        ),
      ],
      createdAt: DateTime(2021, 1, 10),
    ),
    IdolModel(
      id: 'idol-005',
      stageName: '유키',
      category: IdolCategory.vtuber,
      groupName: 'VirtuaLive',
      imageColor: '0xFF00E5FF', // Cyan
      profileImage: 'https://ui-avatars.com/api/?name=유키&background=00E5FF&color=333&size=300',
      coverImage: 'https://placehold.co/800x400/00E5FF/333333?text=유키',
      bio: '데뷔 1년차 VTuber\n주 콘텐츠: 게임, 노래\n구독자 수: 50,000+',
      description: '버츄얼 유튜버 유키입니다! 게임 방송 많이 시청해주세요 🎮',
      isVerified: true,
      debutDate: '2024-01-01',
      height: '설정상 160cm',
      specialties: ['게임', '노래', '성대모사'],
      hobbies: ['게임', 'ASMR', '애니메이션'],
      twitterUrl: 'https://twitter.com/yuki_vtuber',
      youtubeUrl: 'https://youtube.com/@yukivtuber',
      tiktokUrl: 'https://tiktok.com/@yuki_vt',
      totalSupport: 9800000,
      supporterCount: 345,
      subscriberCount: 523,
      ranking: 5,
      monthlyRanking: 4,
      rating: 4.8,
      activityStats: ActivityStats.withCalculatedScore(
        totalPosts: 67,
        postsThisWeek: 18,
        postsThisMonth: 72,
        totalBubbleMessages: 234,
        bubbleMessagesThisWeek: 42,
        totalEvents: 4,
        upcomingEvents: 1,
        totalActiveDays: 89,
        consecutiveActiveDays: 35,
        lastActiveDate: DateTime.now(),
        totalComments: 345,
        commentsThisWeek: 67,
        fanResponseRate: 0.91,
        totalLiveHours: 156,
        liveHoursThisWeek: 18,
        badges: ['streak_7', 'streak_30', 'posts_50'],
      ),
      galleryImages: [
        'https://placehold.co/400x400/00E5FF/333333?text=Photo+1',
        'https://placehold.co/400x400/00E5FF/333333?text=Photo+2',
        'https://placehold.co/400x400/00E5FF/333333?text=Photo+3',
      ],
      offersMealDate: false,
      offersCafeDate: false,
      dateAvailable: false,
      hasBubble: true,
      bubblePrice: 2900,
      subscriptionTiers: [
        const SubscriptionTier(
          id: 'tier-1',
          name: '멤버십',
          price: 4900,
          description: '유튜브 멤버십 연동',
          benefits: ['멤버십 전용 방송', '이모티콘', '커뮤니티 접근'],
          isPopular: true,
        ),
      ],
      createdAt: DateTime(2024, 1, 1),
    ),
    IdolModel(
      id: 'idol-006',
      stageName: '아리',
      category: IdolCategory.undergroundIdol,
      groupName: 'NewStar',
      imageColor: '0xFF69F0AE', // Mint
      profileImage: 'https://ui-avatars.com/api/?name=아리&background=69F0AE&color=333&size=300',
      bio: '데뷔 6개월차\n연습생 기간: 1년\n목표: 첫 단독 콘서트',
      description: '꿈을 향해 달려가는 신인 아이돌 아리예요! ⭐',
      isVerified: false,
      debutDate: '2024-06-15',
      birthDate: '2004-11-03',
      height: '157cm',
      bloodType: 'A',
      specialties: ['댄스', '랩'],
      hobbies: ['춤 연습', 'SNS', '먹방'],
      instagramUrl: 'https://instagram.com/ari_newstar',
      totalSupport: 3500000,
      supporterCount: 189,
      subscriberCount: 87,
      ranking: 12,
      monthlyRanking: 8,
      rating: 4.5,
      activityStats: ActivityStats.withCalculatedScore(
        totalPosts: 23,
        postsThisWeek: 4,
        postsThisMonth: 18,
        totalBubbleMessages: 45,
        bubbleMessagesThisWeek: 6,
        totalEvents: 2,
        upcomingEvents: 0,
        totalActiveDays: 34,
        consecutiveActiveDays: 7,
        lastActiveDate: DateTime.now(),
        totalComments: 156,
        commentsThisWeek: 12,
        fanResponseRate: 0.78,
        totalLiveHours: 8,
        liveHoursThisWeek: 1,
        badges: ['streak_7', 'early_bird'],
      ),
      galleryImages: [
        'https://placehold.co/400x400/69F0AE/333333?text=Photo+1',
        'https://placehold.co/400x400/69F0AE/333333?text=Photo+2',
      ],
      offersMealDate: false,
      offersCafeDate: true,
      cafeDatePrice: 500000, // 신인은 저렴
      dateAvailable: true,
      hasBubble: false,
      subscriptionTiers: [
        const SubscriptionTier(
          id: 'tier-1',
          name: '응원단',
          price: 3000,
          description: '신인 응원',
          benefits: ['전용 피드', '연습 영상'],
        ),
      ],
      createdAt: DateTime(2024, 6, 15),
    ),
  ];

  // 기존 호환을 위한 idols Map 형태
  static final List<Map<String, dynamic>> idols =
      idolModels.map((idol) => idol.toJson()).toList();

  // ============ 캠페인/펀딩 데이터 ============
  static final List<CampaignModel> campaignModels = [
    CampaignModel(
      id: 'campaign-001',
      title: '하늘별 첫 번째 미니앨범 [Starlight] 발매',
      description: '팬 여러분과 함께 만들어가는 첫 미니앨범! 2년간의 지하돌 활동을 담은 5곡 수록 예정.',
      detailContent: '''
## 프로젝트 소개

안녕하세요, 하늘별입니다! 🌟

드디어 첫 미니앨범을 준비하게 되었어요. 지난 2년간 여러분과 함께한 추억을 담아 5곡의 자작곡을 준비했습니다.

### 수록곡 (예정)
1. **Starlight** - 타이틀곡
2. **첫 만남** - 데뷔 때의 설렘을 담은 곡
3. **약속** - 팬분들께 드리는 약속
4. **새벽** - 밤새 연습하던 날들
5. **함께** - 응원해주신 분들께

### 앨범 구성
- 포토북 80p
- CD 1장
- 포토카드 랜덤 2종
- 포스터 1종

여러분의 응원이 이 꿈을 현실로 만들어줄 거예요! 💕
      ''',
      type: CampaignType.album,
      status: CampaignStatus.active,
      coverImage: 'https://placehold.co/800x400/E91E63/ffffff?text=Starlight+Album',
      images: [
        'https://placehold.co/600x600/E91E63/ffffff?text=Album+Preview+1',
        'https://placehold.co/600x600/E91E63/ffffff?text=Album+Preview+2',
        'https://placehold.co/600x600/E91E63/ffffff?text=Album+Preview+3',
      ],
      creatorId: 'idol-001',
      creatorName: '하늘별',
      creatorImage: 'https://ui-avatars.com/api/?name=하늘별&background=E91E63&color=fff&size=100',
      isVerifiedCreator: true,
      goalAmount: 15000000,
      currentAmount: 11250000,
      supporterCount: 287,
      startDate: DateTime(2024, 12, 1),
      endDate: DateTime(2025, 1, 31),
      rewards: [
        const CampaignReward(
          id: 'reward-1',
          title: '감사 메시지',
          description: '진심 담은 감사 메시지 카드를 보내드려요',
          amount: 10000,
          supporterCount: 45,
          items: ['감사 메시지 카드'],
        ),
        const CampaignReward(
          id: 'reward-2',
          title: '디지털 앨범',
          description: '미니앨범 디지털 버전 + 감사 메시지 + 디지털 포토카드',
          amount: 30000,
          supporterCount: 89,
          items: ['디지털 앨범', '감사 메시지', '디지털 포토카드 3종'],
        ),
        const CampaignReward(
          id: 'reward-3',
          title: '사인 앨범',
          description: '친필 사인이 담긴 실물 앨범 + 랜덤 포토카드 추가 2장',
          amount: 55000,
          supporterCount: 112,
          isPopular: true,
          items: ['사인 앨범', '포토카드 추가 2종', '디지털 앨범'],
          deliveryInfo: '2025년 3월 발송 예정',
        ),
        const CampaignReward(
          id: 'reward-4',
          title: '팬미팅 초대권',
          description: '발매 기념 팬미팅 초대 + 사인 앨범 + 단체 사진 촬영',
          amount: 150000,
          supporterCount: 41,
          limit: 50,
          items: ['팬미팅 초대권', '사인 앨범', '단체 사진', '디지털 앨범'],
          deliveryInfo: '팬미팅: 2025년 3월 서울 예정',
        ),
      ],
      updates: [
        CampaignUpdate(
          id: 'update-1',
          title: '1차 목표 달성! 🎉',
          content:
              '여러분 덕분에 1차 목표인 1000만원을 달성했어요! 정말 감사합니다. 추가 목표로 뮤직비디오 제작을 추진할 예정이에요!',
          createdAt: DateTime(2024, 12, 20),
        ),
        CampaignUpdate(
          id: 'update-2',
          title: '녹음 시작했어요!',
          content: '드디어 스튜디오에서 녹음을 시작했습니다. 최고의 퀄리티로 보답할게요!',
          images: ['https://placehold.co/600x400/E91E63/ffffff?text=Recording'],
          createdAt: DateTime(2024, 12, 25),
        ),
      ],
      tags: ['미니앨범', '지하돌', '자작곡', '첫앨범'],
      viewCount: 5420,
      likeCount: 342,
      createdAt: DateTime(2024, 12, 1),
    ),
    CampaignModel(
      id: 'campaign-002',
      title: '루나 생일 서포트 - 강남역 전광판 광고',
      description: '루나의 생일을 강남역 전광판에서 축하해주세요! 팬들이 모아 만드는 특별한 생일 선물.',
      detailContent: '''
## 루나 생일 광고 프로젝트 🎂

### 광고 개요
- **위치**: 강남역 10번 출구 앞 대형 전광판
- **기간**: 2025년 1월 13일 ~ 1월 17일 (5일간)
- **시간**: 07:00 ~ 24:00 (17시간/일)
- **노출**: 1시간당 약 12회 (1회 15초)

### 광고 시안
루나의 베스트 사진과 함께 "Happy Birthday Luna 🌙 팬들이 전하는 사랑" 메시지 예정

### 달성 시 추가 혜택
- 150% 달성: 신논현역 추가 게재
- 200% 달성: 버스 랩핑 광고 추가

루나에게 잊지 못할 생일을 선물해주세요! 💜
      ''',
      type: CampaignType.advertisement,
      status: CampaignStatus.active,
      coverImage: 'https://placehold.co/800x400/5C6BC0/ffffff?text=Luna+Birthday+Ad',
      images: [
        'https://placehold.co/600x400/5C6BC0/ffffff?text=Billboard+Design',
      ],
      creatorId: 'user-organizer-001',
      creatorName: '루나 팬클럽 대표',
      creatorImage: 'https://ui-avatars.com/api/?name=Fan+Club&background=5C6BC0&color=fff&size=100',
      isVerifiedCreator: false,
      goalAmount: 10000000,
      currentAmount: 7800000,
      supporterCount: 456,
      startDate: DateTime(2024, 12, 15),
      endDate: DateTime(2025, 1, 10),
      rewards: [
        const CampaignReward(
          id: 'reward-1',
          title: '참여 인증',
          description: '광고 사진과 함께 참여 인증서를 보내드려요',
          amount: 5000,
          supporterCount: 234,
          items: ['디지털 인증서', '광고 사진'],
        ),
        const CampaignReward(
          id: 'reward-2',
          title: '이름 게재',
          description: '광고 마지막에 후원자 이름이 표시됩니다',
          amount: 30000,
          supporterCount: 156,
          isPopular: true,
          items: ['이름 게재', '디지털 인증서', '광고 영상'],
        ),
        const CampaignReward(
          id: 'reward-3',
          title: '굿즈 세트',
          description: '이름 게재 + 루나 생일 기념 팬메이드 굿즈',
          amount: 80000,
          supporterCount: 66,
          items: ['이름 게재', '아크릴 스탠드', '포토카드 세트', '슬로건'],
          deliveryInfo: '생일 이후 순차 발송',
        ),
      ],
      tags: ['생일광고', '전광판', '루나', '강남역'],
      viewCount: 8920,
      likeCount: 678,
      createdAt: DateTime(2024, 12, 15),
    ),
    CampaignModel(
      id: 'campaign-003',
      title: '사쿠라 코스프레 화보집 [BLOSSOM] 제작',
      description: '5년간의 베스트 코스프레를 담은 100페이지 풀컬러 화보집! 미공개 사진 다수 수록.',
      type: CampaignType.photobook,
      status: CampaignStatus.active,
      coverImage: 'https://placehold.co/800x400/F48FB1/ffffff?text=Sakura+Photobook',
      creatorId: 'idol-004',
      creatorName: '사쿠라',
      creatorImage: 'https://ui-avatars.com/api/?name=사쿠라&background=F48FB1&color=fff&size=100',
      isVerifiedCreator: true,
      goalAmount: 8000000,
      currentAmount: 3200000,
      supporterCount: 89,
      startDate: DateTime(2024, 12, 20),
      endDate: DateTime(2025, 2, 28),
      rewards: [
        const CampaignReward(
          id: 'reward-1',
          title: '디지털 화보',
          description: '고화질 디지털 화보 15장',
          amount: 15000,
          supporterCount: 34,
          items: ['디지털 화보 15장'],
        ),
        const CampaignReward(
          id: 'reward-2',
          title: '실물 화보집',
          description: '100페이지 풀컬러 화보집',
          amount: 45000,
          supporterCount: 38,
          isPopular: true,
          items: ['실물 화보집', '디지털 화보'],
          deliveryInfo: '2025년 4월 발송 예정',
        ),
        const CampaignReward(
          id: 'reward-3',
          title: '사인 화보집 + 포카',
          description: '사인 화보집 + 미공개 포토카드 5종',
          amount: 85000,
          supporterCount: 17,
          items: ['사인 화보집', '미공개 포토카드 5종', '디지털 화보'],
        ),
      ],
      tags: ['화보집', '코스프레', '사쿠라'],
      viewCount: 2340,
      likeCount: 156,
      createdAt: DateTime(2024, 12, 20),
    ),
    CampaignModel(
      id: 'campaign-004',
      title: 'MoonLight 첫 단독 콘서트 [Under the Moon]',
      description: '그룹 MoonLight의 첫 단독 콘서트를 함께 만들어주세요! 서울 홍대 라이브클럽에서 개최 예정.',
      type: CampaignType.concert,
      status: CampaignStatus.active,
      coverImage: 'https://placehold.co/800x400/5C6BC0/ffffff?text=Under+The+Moon+Concert',
      creatorId: 'idol-003',
      creatorName: '루나 (MoonLight)',
      creatorImage: 'https://ui-avatars.com/api/?name=루나&background=5C6BC0&color=fff&size=100',
      isVerifiedCreator: true,
      goalAmount: 20000000,
      currentAmount: 8500000,
      supporterCount: 134,
      startDate: DateTime(2024, 12, 25),
      endDate: DateTime(2025, 2, 15),
      rewards: [
        const CampaignReward(
          id: 'reward-1',
          title: '응원 메시지',
          description: '콘서트장에 응원 메시지가 전시됩니다',
          amount: 10000,
          supporterCount: 56,
          items: ['응원 메시지 전시'],
        ),
        const CampaignReward(
          id: 'reward-2',
          title: '일반석',
          description: '콘서트 일반석 티켓',
          amount: 66000,
          supporterCount: 45,
          items: ['일반석 티켓', '응원봉'],
          limit: 80,
        ),
        const CampaignReward(
          id: 'reward-3',
          title: 'VIP석',
          description: '최앞줄 VIP석 + 포토타임 + 하이터치',
          amount: 150000,
          supporterCount: 28,
          isPopular: true,
          items: ['VIP석 티켓', '포토타임', '하이터치', '굿즈 패키지'],
          limit: 30,
        ),
        const CampaignReward(
          id: 'reward-4',
          title: 'VVIP 패키지',
          description: 'VIP석 + 리허설 관람 + 단독 사진촬영',
          amount: 300000,
          supporterCount: 5,
          items: ['VVIP석', '리허설 관람', '단독 사진촬영', '사인 포스터'],
          limit: 10,
        ),
      ],
      tags: ['콘서트', 'MoonLight', '루나', '홍대'],
      viewCount: 4560,
      likeCount: 289,
      createdAt: DateTime(2024, 12, 25),
    ),
  ];

  // 기존 호환을 위한 campaigns Map 형태
  static final List<Map<String, dynamic>> campaigns =
      campaignModels.map((campaign) => campaign.toJson()).toList();

  // ============ 버블 메시지 데이터 ============
  static final List<BubbleMessageModel> bubbleMessages = [
    BubbleMessageModel(
      id: 'bubble-001',
      idolId: 'idol-001',
      idolName: '하늘별',
      idolProfileImage: 'https://ui-avatars.com/api/?name=하늘별&background=E91E63&color=fff&size=100',
      type: BubbleMessageType.text,
      content: '오늘 연습 끝났어요! 너무 힘들었지만 팬분들 생각하니까 힘이 나요 💕 다들 뭐해요?',
      isSubscriberOnly: false,
      viewCount: 1234,
      likeCount: 456,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    BubbleMessageModel(
      id: 'bubble-002',
      idolId: 'idol-001',
      idolName: '하늘별',
      idolProfileImage: 'https://ui-avatars.com/api/?name=하늘별&background=E91E63&color=fff&size=100',
      type: BubbleMessageType.image,
      content: '오늘 먹은 거 자랑! 🍰 카페 다녀왔어요~',
      mediaUrl: 'https://placehold.co/400x400/E91E63/ffffff?text=Cafe+Photo',
      isSubscriberOnly: true,
      viewCount: 567,
      likeCount: 234,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    BubbleMessageModel(
      id: 'bubble-003',
      idolId: 'idol-001',
      idolName: '하늘별',
      idolProfileImage: 'https://ui-avatars.com/api/?name=하늘별&background=E91E63&color=fff&size=100',
      type: BubbleMessageType.voice,
      content: '잠들기 전 인사 드려요~ 오늘도 수고했어요 🌙',
      mediaUrl: 'https://example.com/voice/goodnight.mp3',
      duration: 15,
      isSubscriberOnly: true,
      viewCount: 890,
      likeCount: 345,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    BubbleMessageModel(
      id: 'bubble-004',
      idolId: 'idol-003',
      idolName: '루나',
      idolProfileImage: 'https://ui-avatars.com/api/?name=루나&background=5C6BC0&color=fff&size=100',
      type: BubbleMessageType.text,
      content: '생일 펀딩 70% 달성이래요!! 😭💕 정말 감사해요 여러분... 사랑해요!!',
      isSubscriberOnly: false,
      viewCount: 2345,
      likeCount: 890,
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    BubbleMessageModel(
      id: 'bubble-005',
      idolId: 'idol-002',
      idolName: '미유',
      idolProfileImage: 'https://ui-avatars.com/api/?name=미유&background=FFD54F&color=333&size=100',
      type: BubbleMessageType.image,
      content: '오늘 새 의상이에요! 주인님들 어떠세요? 🎀',
      mediaUrl: 'https://placehold.co/400x500/FFD54F/333333?text=New+Outfit',
      isSubscriberOnly: false,
      viewCount: 1567,
      likeCount: 567,
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
  ];

  // ============ 데이트권 상품 데이터 ============
  static final List<DateTicketProduct> dateTicketProducts = [
    DateTicketProduct(
      id: 'date-001',
      idolId: 'idol-001',
      idolName: '하늘별',
      idolProfileImage: 'https://ui-avatars.com/api/?name=하늘별&background=E91E63&color=fff&size=100',
      type: DateTicketType.meal,
      price: 1500000, // 150만원
      description: '하늘별과 함께하는 특별한 식사 시간! 고급 레스토랑에서 2시간 동안 대화를 나눠요.',
      duration: 120,
      location: '서울',
      availableDays: ['토', '일'],
      availableTimeStart: '12:00',
      availableTimeEnd: '20:00',
      maxMonthlyCount: 2,
      currentMonthCount: 1,
      isActive: true,
      includeItems: ['고급 레스토랑 식사', '기념 폴라로이드 사진 2장', '친필 사인'],
      excludeItems: ['교통비', '추가 음료'],
      notice: '촬영/녹음 금지, 매니저 동행, 신분증 지참 필수',
      createdAt: DateTime(2024, 12, 1),
    ),
    DateTicketProduct(
      id: 'date-002',
      idolId: 'idol-001',
      idolName: '하늘별',
      idolProfileImage: 'https://ui-avatars.com/api/?name=하늘별&background=E91E63&color=fff&size=100',
      type: DateTicketType.cafe,
      price: 1000000, // 100만원
      description: '하늘별과 카페에서 티타임! 음료와 디저트를 함께하며 이야기 나눠요.',
      duration: 90,
      location: '서울',
      availableDays: ['토', '일'],
      availableTimeStart: '14:00',
      availableTimeEnd: '18:00',
      maxMonthlyCount: 4,
      currentMonthCount: 2,
      isActive: true,
      includeItems: ['음료 및 디저트', '기념 폴라로이드 사진 1장'],
      excludeItems: ['교통비'],
      notice: '촬영/녹음 금지, 매니저 동행',
      createdAt: DateTime(2024, 12, 1),
    ),
    DateTicketProduct(
      id: 'date-003',
      idolId: 'idol-003',
      idolName: '루나',
      idolProfileImage: 'https://ui-avatars.com/api/?name=루나&background=5C6BC0&color=fff&size=100',
      type: DateTicketType.meal,
      price: 1500000,
      description: '루나와 함께하는 저녁 식사! 분위기 좋은 레스토랑에서 특별한 시간을 보내세요.',
      duration: 120,
      location: '서울',
      availableDays: ['토'],
      availableTimeStart: '18:00',
      availableTimeEnd: '21:00',
      maxMonthlyCount: 2,
      currentMonthCount: 0,
      isActive: true,
      includeItems: ['코스 요리', '폴라로이드 사진 2장', '사인 CD'],
      excludeItems: ['주류', '교통비'],
      notice: '촬영/녹음 금지, 매니저 동행',
      createdAt: DateTime(2024, 12, 10),
    ),
    DateTicketProduct(
      id: 'date-004',
      idolId: 'idol-002',
      idolName: '미유',
      idolProfileImage: 'https://ui-avatars.com/api/?name=미유&background=FFD54F&color=333&size=100',
      type: DateTicketType.cafe,
      price: 800000, // 메이드카페 스페셜
      description: '미유가 직접 서빙하는 특별 카페 타임! 라떼아트와 오믈렛 라이스를 만들어드려요.',
      duration: 60,
      location: '도쿄 아키하바라',
      availableDays: ['금', '토', '일'],
      availableTimeStart: '15:00',
      availableTimeEnd: '19:00',
      maxMonthlyCount: 6,
      currentMonthCount: 3,
      isActive: true,
      includeItems: ['라떼아트 음료', '오믈렛 라이스', '폴라로이드 사진', '마법 주문'],
      excludeItems: ['교통비', '추가 메뉴'],
      notice: '카페 내 촬영 가능 (SNS 업로드 허용)',
      createdAt: DateTime(2024, 11, 15),
    ),
  ];

  // ============ 광고 상품 데이터 ============
  static final List<AdProduct> adProducts = [
    AdProduct(
      id: 'ad-001',
      type: AdProductType.billboardLarge,
      name: '강남역 대형 전광판',
      description: '강남역 10번 출구 앞 대형 LED 전광판. 하루 유동인구 약 50만명!',
      price: 10000000, // 1000만원/주
      durationDays: 7,
      location: '서울 강남역 10번 출구',
      sizeInfo: '가로 20m x 세로 8m',
      impressions: 3500000,
      sampleImages: ['https://placehold.co/600x300/FF4D8D/ffffff?text=Billboard+Sample'],
      requirements: ['1920x768 해상도', 'MP4 형식', '15초 이내'],
      isPopular: true,
      soldCount: 23,
    ),
    AdProduct(
      id: 'ad-002',
      type: AdProductType.subwayAd,
      name: '2호선 스크린도어 광고',
      description: '2호선 주요역 스크린도어 광고. 10개역 동시 게재.',
      price: 5000000,
      durationDays: 14,
      location: '2호선 강남/홍대/신촌 등 10개역',
      sizeInfo: '스크린도어 사이즈',
      impressions: 2000000,
      requirements: ['지정 사이즈', '정적 이미지'],
      isPopular: true,
      soldCount: 45,
    ),
    AdProduct(
      id: 'ad-003',
      type: AdProductType.busAd,
      name: '서울 버스 랩핑',
      description: '서울 시내버스 외부 랩핑 광고. 강남-홍대 노선.',
      price: 3000000,
      durationDays: 30,
      location: '서울 시내 (강남-홍대 노선)',
      impressions: 1500000,
      requirements: ['버스 랩핑 규격', '시인쇄 가능 이미지'],
      soldCount: 12,
    ),
    AdProduct(
      id: 'ad-004',
      type: AdProductType.appBanner,
      name: '앱 메인 배너',
      description: '앱 홈 화면 최상단 배너 광고. 모든 사용자에게 노출.',
      price: 100000,
      durationDays: 7,
      impressions: 50000,
      requirements: ['720x200 해상도', 'PNG/JPG'],
      isAvailable: true,
      soldCount: 156,
    ),
    AdProduct(
      id: 'ad-005',
      type: AdProductType.homeFeature,
      name: '홈 추천 아이돌',
      description: '홈 화면 "HOT 아이돌" 섹션 첫 번째 노출.',
      price: 300000,
      durationDays: 7,
      impressions: 80000,
      requirements: ['프로필 이미지 필수'],
      isPopular: true,
      soldCount: 89,
    ),
    AdProduct(
      id: 'ad-006',
      type: AdProductType.cafeAd,
      name: '아이돌 카페 포스터',
      description: '서울/부산 주요 아이돌 카페 10곳에 포스터 게시.',
      price: 500000,
      durationDays: 14,
      location: '서울/부산 아이돌 카페',
      requirements: ['A2 사이즈', '고해상도'],
      soldCount: 34,
    ),
  ];

  // ============ 광고 펀딩 데이터 ============
  static final List<AdFunding> adFundings = [
    AdFunding(
      id: 'adfund-001',
      title: '루나 생일 강남역 전광판',
      description: '루나의 생일을 강남역 대형 전광판으로 축하해요!',
      targetIdolId: 'idol-003',
      targetIdolName: '루나',
      targetIdolImage: 'https://ui-avatars.com/api/?name=루나&background=5C6BC0&color=fff&size=100',
      adType: AdProductType.billboardLarge,
      adLocation: '강남역 10번 출구',
      goalAmount: 10000000,
      currentAmount: 7800000,
      supporterCount: 456,
      startDate: DateTime(2024, 12, 15),
      endDate: DateTime(2025, 1, 10),
      organizerId: 'user-001',
      organizerName: '루나 팬클럽',
      adDesignImage: 'https://placehold.co/600x300/5C6BC0/ffffff?text=Luna+Birthday+Ad',
      createdAt: DateTime(2024, 12, 15),
    ),
    AdFunding(
      id: 'adfund-002',
      title: '하늘별 데뷔 2주년 지하철 광고',
      description: '하늘별 데뷔 2주년을 2호선 광고로 축하해주세요!',
      targetIdolId: 'idol-001',
      targetIdolName: '하늘별',
      targetIdolImage: 'https://ui-avatars.com/api/?name=하늘별&background=E91E63&color=fff&size=100',
      adType: AdProductType.subwayAd,
      adLocation: '2호선 10개역',
      goalAmount: 5000000,
      currentAmount: 2300000,
      supporterCount: 189,
      startDate: DateTime(2025, 1, 1),
      endDate: DateTime(2025, 3, 1),
      organizerId: 'user-002',
      organizerName: '별빛 서포터즈',
      createdAt: DateTime(2025, 1, 1),
    ),
  ];

  // ============ 거래 내역 데이터 ============
  static final List<Map<String, dynamic>> transactions = [
    {
      'id': 'tx-001',
      'type': 'DEPOSIT',
      'amount': 100000,
      'balanceBefore': 400000,
      'balanceAfter': 500000,
      'description': '코인 충전',
      'createdAt': '2024-12-28T10:30:00Z',
    },
    {
      'id': 'tx-002',
      'type': 'SUPPORT',
      'amount': -10000,
      'balanceBefore': 500000,
      'balanceAfter': 490000,
      'description': '하늘별님께 후원',
      'createdAt': '2024-12-27T15:20:00Z',
    },
    {
      'id': 'tx-003',
      'type': 'SUBSCRIPTION',
      'amount': -15000,
      'balanceBefore': 490000,
      'balanceAfter': 475000,
      'description': '하늘별 프리미엄 구독',
      'createdAt': '2024-12-25T09:00:00Z',
    },
    {
      'id': 'tx-004',
      'type': 'BUBBLE',
      'amount': -4900,
      'balanceBefore': 475000,
      'balanceAfter': 470100,
      'description': '하늘별 버블 구독',
      'createdAt': '2024-12-25T09:01:00Z',
    },
    {
      'id': 'tx-005',
      'type': 'CAMPAIGN',
      'amount': -55000,
      'balanceBefore': 470100,
      'balanceAfter': 415100,
      'description': '하늘별 미니앨범 펀딩 (사인 앨범)',
      'createdAt': '2024-12-20T14:45:00Z',
    },
    {
      'id': 'tx-006',
      'type': 'AD_FUNDING',
      'amount': -30000,
      'balanceBefore': 415100,
      'balanceAfter': 385100,
      'description': '루나 생일 전광판 광고 후원',
      'createdAt': '2024-12-18T11:00:00Z',
    },
  ];

  // ============ 커뮤니티 포스트 데이터 ============
  static final List<Map<String, dynamic>> posts = [
    {
      'id': 'post-001',
      'author': {
        'id': 'idol-001',
        'nickname': '하늘별',
        'profileImage': 'https://ui-avatars.com/api/?name=하늘별&background=E91E63&color=fff&size=100',
        'isVerified': true,
        'category': 'UNDERGROUND_IDOL',
      },
      'content':
          '오늘 연습 끝! 다음 주 공연 준비 열심히 하고 있어요 💪 팬분들 많이 와주실 거죠? 🥺\n\n#하늘별 #지하돌 #연습',
      'images': ['https://placehold.co/400x400/E91E63/ffffff?text=Practice'],
      'likeCount': 234,
      'commentCount': 45,
      'createdAt': '2024-12-28T18:30:00Z',
      'isLiked': true,
      'isSubscriberOnly': false,
    },
    {
      'id': 'post-002',
      'author': {
        'id': 'idol-002',
        'nickname': '미유',
        'profileImage': 'https://ui-avatars.com/api/?name=미유&background=FFD54F&color=333&size=100',
        'isVerified': true,
        'category': 'MAID_CAFE',
      },
      'content':
          '새로운 메이드 의상이 도착했어요! 🎀 어떤가요? 주인님들 의견 궁금해요~\n\n오늘 출근하니까 카페에서 만나요! 💕',
      'images': ['https://placehold.co/400x500/FFD54F/333333?text=Maid+Outfit'],
      'likeCount': 189,
      'commentCount': 67,
      'createdAt': '2024-12-28T14:00:00Z',
      'isLiked': false,
      'isSubscriberOnly': false,
    },
    {
      'id': 'post-003',
      'author': {
        'id': 'idol-003',
        'nickname': '루나',
        'profileImage': 'https://ui-avatars.com/api/?name=루나&background=5C6BC0&color=fff&size=100',
        'isVerified': true,
        'category': 'UNDERGROUND_IDOL',
      },
      'content':
          '생일 이벤트 펀딩 78% 달성! 🎂\n\n정말 감사해요 여러분... 울컥 😢💕\n\n남은 기간도 열심히 할게요! 강남역 전광판 기대해주세요!!',
      'images': [],
      'likeCount': 312,
      'commentCount': 89,
      'createdAt': '2024-12-27T20:15:00Z',
      'isLiked': true,
      'isSubscriberOnly': false,
    },
    {
      'id': 'post-004',
      'author': {
        'id': 'idol-005',
        'nickname': '유키',
        'profileImage': 'https://ui-avatars.com/api/?name=유키&background=00E5FF&color=333&size=100',
        'isVerified': true,
        'category': 'VTUBER',
      },
      'content':
          '오늘 밤 10시 게임 방송 있어요! 🎮\n\n같이 게임하고 싶은 분 댓글로 신청해주세요~\n\n오늘은 발로란트 가요!',
      'images': ['https://placehold.co/400x300/00E5FF/333333?text=Gaming'],
      'likeCount': 156,
      'commentCount': 123,
      'createdAt': '2024-12-27T16:00:00Z',
      'isLiked': false,
      'isSubscriberOnly': false,
    },
    {
      'id': 'post-005',
      'author': {
        'id': 'idol-001',
        'nickname': '하늘별',
        'profileImage': 'https://ui-avatars.com/api/?name=하늘별&background=E91E63&color=fff&size=100',
        'isVerified': true,
        'category': 'UNDERGROUND_IDOL',
      },
      'content':
          '🎉 구독자 전용 비하인드! 🎉\n\n앨범 녹음 현장 사진이에요~ 프리미엄 구독자분들만 볼 수 있어요! 💕',
      'images': [
        'https://placehold.co/400x400/E91E63/ffffff?text=Behind+1',
        'https://placehold.co/400x400/E91E63/ffffff?text=Behind+2',
      ],
      'likeCount': 89,
      'commentCount': 23,
      'createdAt': '2024-12-26T12:00:00Z',
      'isLiked': true,
      'isSubscriberOnly': true,
    },
  ];

  // ============ 메이드카페 데이터 ============
  static final List<Map<String, dynamic>> maidCafes = [
    {
      'id': 'cafe-001',
      'name': 'StarLight Cafe',
      'address': '도쿄 아키하바라 1-2-3',
      'image': 'https://placehold.co/400x200/FFD54F/333333?text=Cafe',
      'rating': 4.8,
      'reviewCount': 256,
      'maids': ['idol-002'],
      'description': '아키하바라 최고의 메이드 카페! 미유를 만나보세요.',
    },
    {
      'id': 'cafe-002',
      'name': 'Melty Kiss',
      'address': '도쿄 아키하바라 4-5-6',
      'image': 'https://placehold.co/400x200/FFD54F/333333?text=Melty+Kiss',
      'rating': 4.6,
      'reviewCount': 189,
      'maids': [],
      'description': '달콤한 디저트와 함께하는 특별한 시간',
    },
    {
      'id': 'cafe-003',
      'name': 'Dream Paradise',
      'address': '오사카 닛폰바시 7-8-9',
      'image': 'https://placehold.co/400x200/FFD54F/333333?text=Dream+Paradise',
      'rating': 4.7,
      'reviewCount': 134,
      'maids': [],
      'description': '꿈같은 메이드들이 기다리는 파라다이스',
    },
  ];

  // ============ 이벤트/일정 데이터 ============
  static final List<EventModel> events = [
    // 지하돌 이벤트
    EventModel(
      id: 'event-001',
      title: '하늘별 신곡 쇼케이스',
      description: '신곡 Starlight 첫 공개! 소규모 팬미팅과 함께 진행됩니다.',
      date: DateTime(2026, 1, 15, 19, 0),
      type: EventType.performance,
      idolId: 'idol-001',
      category: IdolCategory.undergroundIdol,
      location: '홍대 라이브홀',
      price: 25000,
      maxParticipants: 50,
      currentParticipants: 32,
      imageUrl: 'https://placehold.co/600x400/E91E63/ffffff?text=하늘별+쇼케이스',
      isOnline: false,
    ),
    EventModel(
      id: 'event-002',
      title: '하늘별 생일 팬미팅',
      description: '하늘별과 함께하는 특별한 생일 파티! 케이크 & 선물 증정',
      date: DateTime(2026, 8, 12, 15, 0),
      type: EventType.birthday,
      idolId: 'idol-001',
      category: IdolCategory.undergroundIdol,
      location: '강남 팬미팅홀',
      price: 35000,
      maxParticipants: 80,
      currentParticipants: 45,
      imageUrl: 'https://placehold.co/600x400/E91E63/ffffff?text=생일+파티',
      isOnline: false,
    ),
    EventModel(
      id: 'event-003',
      title: '루나 버스킹 공연',
      description: '거리에서 만나는 루나! 자유롭게 참여 가능합니다.',
      date: DateTime(2026, 1, 18, 14, 0),
      type: EventType.performance,
      idolId: 'idol-003',
      category: IdolCategory.undergroundIdol,
      location: '신촌 거리',
      price: 0,
      maxParticipants: null,
      currentParticipants: 0,
      imageUrl: 'https://placehold.co/600x400/9C27B0/ffffff?text=루나+버스킹',
      isOnline: false,
    ),
    EventModel(
      id: 'event-004',
      title: '루나 포토카드 교환회',
      description: '팬들과 함께하는 포토카드 교환 & 사인회',
      date: DateTime(2026, 1, 25, 13, 0),
      type: EventType.photocard,
      idolId: 'idol-003',
      category: IdolCategory.undergroundIdol,
      location: '홍대 카페 루나',
      price: 10000,
      maxParticipants: 30,
      currentParticipants: 18,
      imageUrl: 'https://placehold.co/600x400/9C27B0/ffffff?text=포토카드+교환회',
      isOnline: false,
    ),
    EventModel(
      id: 'event-005',
      title: '세라 아카펠라 라이브',
      description: '세라의 청아한 목소리로 듣는 아카펠라 무대',
      date: DateTime(2026, 2, 2, 19, 30),
      type: EventType.performance,
      idolId: 'idol-005',
      category: IdolCategory.undergroundIdol,
      location: '대학로 소극장',
      price: 20000,
      maxParticipants: 40,
      currentParticipants: 28,
      imageUrl: 'https://placehold.co/600x400/00BCD4/ffffff?text=세라+아카펠라',
      isOnline: false,
    ),

    // 메이드카페 이벤트
    EventModel(
      id: 'event-006',
      title: '미유 메이드 생일 카페 이벤트',
      description: '미유의 생일을 축하하는 특별 메뉴 & 포토타임',
      date: DateTime(2026, 4, 22, 14, 0),
      endDate: DateTime(2026, 4, 22, 18, 0),
      type: EventType.birthday,
      idolId: 'idol-002',
      category: IdolCategory.maidCafe,
      location: 'StarLight Cafe 아키하바라',
      price: 15000,
      maxParticipants: 20,
      currentParticipants: 15,
      imageUrl: 'https://placehold.co/600x400/FFD54F/333333?text=미유+생일+이벤트',
      isOnline: false,
    ),
    EventModel(
      id: 'event-007',
      title: '발렌타인 초콜릿 만들기 클래스',
      description: '미유와 함께 초콜릿을 만들어요! (선착순)',
      date: DateTime(2026, 2, 14, 11, 0),
      endDate: DateTime(2026, 2, 14, 16, 0),
      type: EventType.cafeEvent,
      idolId: 'idol-002',
      category: IdolCategory.maidCafe,
      location: 'StarLight Cafe',
      price: 30000,
      maxParticipants: 10,
      currentParticipants: 10,
      imageUrl: 'https://placehold.co/600x400/FFD54F/333333?text=초콜릿+클래스',
      isOnline: false,
    ),

    // 코스프레이어 이벤트
    EventModel(
      id: 'event-008',
      title: '사쿠라 코믹마켓 부스',
      description: '코믹마켓에서 만나는 사쿠라! 한정판 포토북 판매',
      date: DateTime(2026, 1, 20, 10, 0),
      endDate: DateTime(2026, 1, 20, 18, 0),
      type: EventType.cosplayEvent,
      idolId: 'idol-004',
      category: IdolCategory.cosplayer,
      location: '코엑스 전시장',
      price: 0,
      maxParticipants: null,
      currentParticipants: 0,
      imageUrl: 'https://placehold.co/600x400/FF5722/ffffff?text=코믹마켓',
      isOnline: false,
    ),
    EventModel(
      id: 'event-009',
      title: '사쿠라 코스프레 촬영회',
      description: '새 코스프레 의상 공개! 1:1 촬영 기회',
      date: DateTime(2026, 1, 28, 13, 0),
      type: EventType.fanmeeting,
      idolId: 'idol-004',
      category: IdolCategory.cosplayer,
      location: '강남 스튜디오',
      price: 50000,
      maxParticipants: 15,
      currentParticipants: 12,
      imageUrl: 'https://placehold.co/600x400/FF5722/ffffff?text=촬영회',
      isOnline: false,
    ),
    EventModel(
      id: 'event-010',
      title: '사쿠라 코스프레 워크샵',
      description: '코스프레 제작 노하우를 배워보세요!',
      date: DateTime(2026, 2, 10, 15, 0),
      type: EventType.other,
      idolId: 'idol-004',
      category: IdolCategory.cosplayer,
      location: '홍대 작업실',
      price: 40000,
      maxParticipants: 12,
      currentParticipants: 7,
      imageUrl: 'https://placehold.co/600x400/FF5722/ffffff?text=워크샵',
      isOnline: false,
    ),

    // 온라인 이벤트
    EventModel(
      id: 'event-011',
      title: '세라 온라인 팬미팅',
      description: '언제 어디서나 세라와 함께! 온라인 영상통화 팬미팅',
      date: DateTime(2026, 1, 22, 20, 0),
      type: EventType.fanmeeting,
      idolId: 'idol-005',
      category: IdolCategory.undergroundIdol,
      location: null,
      price: 15000,
      maxParticipants: 50,
      currentParticipants: 35,
      imageUrl: 'https://placehold.co/600x400/00BCD4/ffffff?text=온라인+팬미팅',
      isOnline: true,
      meetingLink: 'https://meet.pipo.com/sera-fanmeeting',
    ),
  ];

  /// 특정 날짜의 이벤트 가져오기
  static List<EventModel> getEventsForDate(DateTime date) {
    return events.where((event) {
      final eventDate = DateTime(event.date.year, event.date.month, event.date.day);
      final targetDate = DateTime(date.year, date.month, date.day);

      if (event.endDate != null) {
        // 여러 날짜에 걸친 이벤트
        final endDate = DateTime(event.endDate!.year, event.endDate!.month, event.endDate!.day);
        return targetDate.isAtSameMomentAs(eventDate) ||
               targetDate.isAtSameMomentAs(endDate) ||
               (targetDate.isAfter(eventDate) && targetDate.isBefore(endDate));
      } else {
        return eventDate.isAtSameMomentAs(targetDate);
      }
    }).toList();
  }

  /// 특정 카테고리의 이벤트 가져오기
  static List<EventModel> getEventsByCategory(Set<IdolCategory> categories) {
    return events.where((event) => categories.contains(event.category)).toList();
  }

  /// 특정 날짜 & 카테고리의 이벤트 가져오기
  static List<EventModel> getEventsForDateAndCategory(
    DateTime date,
    Set<IdolCategory> categories,
  ) {
    return getEventsForDate(date)
        .where((event) => categories.contains(event.category))
        .toList();
  }

  /// 이벤트가 있는 날짜 목록 가져오기 (특정 카테고리)
  static List<DateTime> getEventDates(Set<IdolCategory> categories) {
    final dates = <DateTime>{};

    for (final event in events) {
      if (categories.contains(event.category)) {
        final eventDate = DateTime(event.date.year, event.date.month, event.date.day);
        dates.add(eventDate);

        if (event.endDate != null) {
          var current = eventDate;
          final end = DateTime(event.endDate!.year, event.endDate!.month, event.endDate!.day);
          while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
            dates.add(current);
            current = current.add(const Duration(days: 1));
          }
        }
      }
    }

    return dates.toList()..sort();
  }

  // ============ 서포터 랭킹 데이터 ============

  /// 하늘별 서포터 랭킹
  static final List<SupporterModel> skystarSupporters = [
    SupporterModel(
      id: 'supporter-001',
      userId: 'user-001',
      nickname: 'Kpop으로영어공부하기',
      profileImage: 'https://ui-avatars.com/api/?name=Kpop&background=4CAF50&color=fff&size=100',
      isVerified: true,
      totalSupport: 3500000, // 후원 350만원
      totalFunding: 1500000, // 펀딩 150만원
      totalAmount: 5000000, // 총 500만원
      supportCount: 24,
      fundingCount: 3,
      firstSupportDate: DateTime(2023, 5, 1),
      lastSupportDate: DateTime.now(),
      isSubscriber: true,
      subscriptionTier: 'VIP',
      subscriptionStartDate: DateTime(2023, 5, 1),
      badges: ['first_supporter', 'vip_supporter', 'loyal_supporter'],
    ),
    SupporterModel(
      id: 'supporter-002',
      userId: 'user-002',
      nickname: '박철호',
      profileImage: 'https://ui-avatars.com/api/?name=박철호&background=2196F3&color=fff&size=100',
      isVerified: false,
      totalSupport: 2000000,
      totalFunding: 800000,
      totalAmount: 2800000,
      supportCount: 18,
      fundingCount: 2,
      firstSupportDate: DateTime(2023, 6, 15),
      lastSupportDate: DateTime.now(),
      isSubscriber: true,
      subscriptionTier: '프리미엄',
      subscriptionStartDate: DateTime(2023, 7, 1),
      badges: ['subscriber_supporter'],
    ),
    SupporterModel(
      id: 'supporter-003',
      userId: 'user-003',
      nickname: '광복간',
      profileImage: 'https://ui-avatars.com/api/?name=광복간&background=FF9800&color=fff&size=100',
      isVerified: false,
      totalSupport: 1200000,
      totalFunding: 500000,
      totalAmount: 1700000,
      supportCount: 12,
      fundingCount: 1,
      firstSupportDate: DateTime(2023, 8, 1),
      lastSupportDate: DateTime.now(),
      isSubscriber: true,
      subscriptionTier: '프리미엄',
      badges: [],
    ),
    SupporterModel(
      id: 'supporter-004',
      userId: 'user-004',
      nickname: '느어버린전주역',
      profileImage: null,
      isVerified: false,
      totalSupport: 800000,
      totalFunding: 200000,
      totalAmount: 1000000,
      supportCount: 8,
      fundingCount: 1,
      firstSupportDate: DateTime(2024, 1, 1),
      lastSupportDate: DateTime(2025, 12, 15),
      isSubscriber: false,
      badges: [],
    ),
    SupporterModel(
      id: 'supporter-005',
      userId: 'user-005',
      nickname: 'lllSTONElll',
      profileImage: null,
      isVerified: false,
      totalSupport: 650000,
      totalFunding: 150000,
      totalAmount: 800000,
      supportCount: 6,
      fundingCount: 1,
      firstSupportDate: DateTime(2024, 3, 1),
      lastSupportDate: DateTime(2025, 11, 20),
      isSubscriber: true,
      subscriptionTier: '라이트',
      badges: [],
    ),
    SupporterModel(
      id: 'supporter-006',
      userId: 'user-006',
      nickname: '유튜브식인한TV',
      profileImage: null,
      isVerified: false,
      totalSupport: 450000,
      totalFunding: 100000,
      totalAmount: 550000,
      supportCount: 5,
      fundingCount: 1,
      firstSupportDate: DateTime(2024, 4, 1),
      lastSupportDate: DateTime(2025, 10, 10),
      isSubscriber: false,
      badges: [],
    ),
    SupporterModel(
      id: 'supporter-007',
      userId: 'user-007',
      nickname: 'parkha',
      profileImage: null,
      isVerified: false,
      totalSupport: 350000,
      totalFunding: 50000,
      totalAmount: 400000,
      supportCount: 4,
      fundingCount: 1,
      firstSupportDate: DateTime(2024, 6, 1),
      lastSupportDate: DateTime(2025, 9, 5),
      isSubscriber: false,
      badges: [],
    ),
    SupporterModel(
      id: 'supporter-008',
      userId: 'user-008',
      nickname: '하나애',
      profileImage: null,
      isVerified: false,
      totalSupport: 250000,
      totalFunding: 0,
      totalAmount: 250000,
      supportCount: 3,
      fundingCount: 0,
      firstSupportDate: DateTime(2024, 7, 1),
      lastSupportDate: DateTime(2025, 8, 15),
      isSubscriber: true,
      subscriptionTier: '라이트',
      badges: [],
    ),
  ];

  /// 아이돌별 서포터 랭킹 조회
  static List<SupporterModel> getSupportersForIdol(String idolId) {
    // 실제로는 idolId별로 다른 데이터를 반환해야 하지만
    // 데모에서는 하늘별의 데이터를 반환
    return skystarSupporters;
  }

  /// TOP 3 서포터 조회
  static List<SupporterModel> getTop3Supporters(String idolId) {
    final supporters = getSupportersForIdol(idolId);
    supporters.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
    return supporters.take(3).toList();
  }
}

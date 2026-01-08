import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/design_system.dart';
import '../../../shared/widgets/glass_card.dart';

/// Feed Screen - Public highlights and community posts
class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PipoColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildHighlightsFeed(),
                  _buildCommunityFeed(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(PipoSpacing.md),
      child: Row(
        children: [
          Text(
            '피드',
            style: PipoTypography.heading1.copyWith(
              color: PipoColors.textPrimary,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              // TODO: Notifications
            },
            icon: const Icon(Icons.notifications_outlined),
            color: PipoColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: PipoSpacing.md),
      decoration: BoxDecoration(
        color: PipoColors.surfaceVariant,
        borderRadius: BorderRadius.circular(PipoRadius.lg),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: PipoColors.primary,
          borderRadius: BorderRadius.circular(PipoRadius.md),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: PipoColors.textSecondary,
        labelStyle: PipoTypography.labelMedium.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: PipoTypography.labelMedium,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: '하이라이트'),
          Tab(text: '커뮤니티'),
        ],
      ),
    );
  }

  Widget _buildHighlightsFeed() {
    final highlights = _getMockHighlights();

    if (highlights.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome_rounded,
              size: 64,
              color: PipoColors.textTertiary,
            ),
            const SizedBox(height: PipoSpacing.md),
            Text(
              '아직 공개된 리프가 없습니다',
              style: PipoTypography.bodyLarge.copyWith(
                color: PipoColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(PipoSpacing.md),
      itemCount: highlights.length,
      itemBuilder: (context, index) => _buildHighlightCard(highlights[index]),
    );
  }

  Widget _buildHighlightCard(Map<String, dynamic> highlight) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: PipoSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Creator info
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: PipoColors.surfaceVariant,
                child: const Icon(Icons.person, size: 20, color: PipoColors.textTertiary),
              ),
              const SizedBox(width: PipoSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          highlight['creatorName'] ?? '',
                          style: PipoTypography.titleSmall.copyWith(
                            color: PipoColors.textPrimary,
                          ),
                        ),
                        if (highlight['isVerified'] == true) ...[
                          const SizedBox(width: PipoSpacing.xs),
                          const Icon(
                            Icons.verified_rounded,
                            size: 14,
                            color: PipoColors.primary,
                          ),
                        ],
                      ],
                    ),
                    Text(
                      highlight['productName'] ?? '',
                      style: PipoTypography.labelSmall.copyWith(
                        color: PipoColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: PipoSpacing.sm,
                  vertical: PipoSpacing.xs,
                ),
                decoration: BoxDecoration(
                  gradient: PipoColors.primaryGradient,
                  borderRadius: BorderRadius.circular(PipoRadius.sm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome, size: 12, color: Colors.white),
                    const SizedBox(width: PipoSpacing.xs),
                    Text(
                      '하이라이트',
                      style: PipoTypography.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: PipoSpacing.md),

          // Content
          if (highlight['textContent'] != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(PipoSpacing.md),
              decoration: BoxDecoration(
                color: PipoColors.surfaceVariant,
                borderRadius: BorderRadius.circular(PipoRadius.md),
              ),
              child: Text(
                highlight['textContent'],
                style: PipoTypography.bodyMedium.copyWith(
                  color: PipoColors.textPrimary,
                ),
              ),
            ),

          const SizedBox(height: PipoSpacing.md),

          // Fan info
          Row(
            children: [
              Icon(
                Icons.favorite_rounded,
                size: 16,
                color: PipoColors.error,
              ),
              const SizedBox(width: PipoSpacing.xs),
              Text(
                '${highlight['likeCount'] ?? 0}',
                style: PipoTypography.labelMedium.copyWith(
                  color: PipoColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                highlight['fanName'] != null ? 'by ${highlight['fanName']}' : '',
                style: PipoTypography.labelSmall.copyWith(
                  color: PipoColors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityFeed() {
    final posts = _getMockPosts();

    return ListView.builder(
      padding: const EdgeInsets.all(PipoSpacing.md),
      itemCount: posts.length,
      itemBuilder: (context, index) => _buildPostCard(posts[index]),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: PipoSpacing.md),
      onTap: () {
        // TODO: Navigate to post detail
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: PipoColors.surfaceVariant,
                child: const Icon(Icons.person, size: 20, color: PipoColors.textTertiary),
              ),
              const SizedBox(width: PipoSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post['authorName'] ?? '',
                      style: PipoTypography.titleSmall.copyWith(
                        color: PipoColors.textPrimary,
                      ),
                    ),
                    Text(
                      post['timestamp'] ?? '',
                      style: PipoTypography.labelSmall.copyWith(
                        color: PipoColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              if (post['visibility'] == 'SUBSCRIBERS_ONLY')
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: PipoSpacing.sm,
                    vertical: PipoSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: PipoColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(PipoRadius.sm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lock_rounded,
                        size: 12,
                        color: PipoColors.warning,
                      ),
                      const SizedBox(width: PipoSpacing.xs),
                      Text(
                        '구독자',
                        style: PipoTypography.labelSmall.copyWith(
                          color: PipoColors.warning,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: PipoSpacing.md),
          Text(
            post['content'] ?? '',
            style: PipoTypography.bodyMedium.copyWith(
              color: PipoColors.textPrimary,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: PipoSpacing.md),
          Row(
            children: [
              Icon(
                Icons.favorite_border_rounded,
                size: 20,
                color: PipoColors.textTertiary,
              ),
              const SizedBox(width: PipoSpacing.xs),
              Text(
                '${post['likeCount'] ?? 0}',
                style: PipoTypography.labelMedium.copyWith(
                  color: PipoColors.textSecondary,
                ),
              ),
              const SizedBox(width: PipoSpacing.md),
              Icon(
                Icons.chat_bubble_outline_rounded,
                size: 20,
                color: PipoColors.textTertiary,
              ),
              const SizedBox(width: PipoSpacing.xs),
              Text(
                '${post['commentCount'] ?? 0}',
                style: PipoTypography.labelMedium.copyWith(
                  color: PipoColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getMockHighlights() {
    return [
      {
        'id': '1',
        'creatorName': 'Sakura',
        'isVerified': true,
        'productName': '텍스트 메시지',
        'textContent': '팬 여러분 항상 응원해주셔서 감사합니다! 이번 공연도 최선을 다할게요. 사랑해요! 💕',
        'fanName': 'Fan123',
        'likeCount': 42,
      },
      {
        'id': '2',
        'creatorName': 'Yuki',
        'isVerified': true,
        'productName': '보이스 메시지',
        'textContent': null,
        'fanName': null,
        'likeCount': 28,
      },
    ];
  }

  List<Map<String, dynamic>> _getMockPosts() {
    return [
      {
        'id': '1',
        'authorName': 'Sakura',
        'timestamp': '2시간 전',
        'content': '오늘 연습 열심히 했어요! 다음 주 공연 기대해주세요 🎤',
        'visibility': 'PUBLIC',
        'likeCount': 156,
        'commentCount': 23,
      },
      {
        'id': '2',
        'authorName': 'Mina',
        'timestamp': '5시간 전',
        'content': '새로운 코스프레 의상 준비 중! 힌트: 빨간색이에요 ❤️',
        'visibility': 'SUBSCRIBERS_ONLY',
        'likeCount': 89,
        'commentCount': 12,
      },
      {
        'id': '3',
        'authorName': 'Hana',
        'timestamp': '어제',
        'content': '스트림 일정 공지! 이번 주 토요일 저녁 8시에 만나요~',
        'visibility': 'PUBLIC',
        'likeCount': 234,
        'commentCount': 45,
      },
    ];
  }
}

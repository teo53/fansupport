import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/mock/mock_data.dart';
import '../../../shared/widgets/comment_sheet.dart';
import '../../auth/providers/auth_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late TabController _tabController;
  final List<Map<String, dynamic>> _posts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _tabController = TabController(length: 3, vsync: this);
    _loadPosts();
  }

  void _loadPosts() {
    // Mock 데이터에서 포스트 로드
    _posts.clear();
    _posts.addAll(MockData.posts);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  String _formatTimeAgo(String dateStr) {
    return TimeFormatter.formatRelative(DateTime.parse(dateStr));
  }

  String _formatNumber(int number) {
    return NumberFormatter.formatKorean(number);
  }

  Future<void> _onRefresh() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    _loadPosts();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final user = ref.watch(currentUserProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            // App Bar
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: Colors.white,
              elevation: 0,
              toolbarHeight: Responsive.hp(7),
              title: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.go('/profile'),
                    child: CircleAvatar(
                      radius: Responsive.wp(5),
                      backgroundColor: AppColors.primarySoft,
                      backgroundImage: user?.profileImage != null
                          ? CachedNetworkImageProvider(user!.profileImage!)
                          : null,
                      child: user?.profileImage == null
                          ? Icon(Icons.person, color: AppColors.primary, size: Responsive.sp(20))
                          : null,
                    ),
                  ),
                  SizedBox(width: Responsive.wp(3)),
                  Expanded(
                    child: Text(
                      'FanSupport',
                      style: TextStyle(
                        fontSize: Responsive.sp(22),
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                _buildAppBarButton(
                  icon: Icons.search_rounded,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('검색 기능은 준비 중입니다')),
                    );
                  },
                ),
                _buildAppBarButton(
                  icon: Icons.notifications_none_rounded,
                  badge: 3,
                  onTap: () => context.push('/notifications'),
                ),
                SizedBox(width: Responsive.wp(2)),
              ],
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(Responsive.hp(5.5)),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.divider,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: AppColors.textPrimary,
                    unselectedLabelColor: AppColors.textSecondary,
                    labelStyle: TextStyle(
                      fontSize: Responsive.sp(14),
                      fontWeight: FontWeight.w700,
                    ),
                    unselectedLabelStyle: TextStyle(
                      fontSize: Responsive.sp(14),
                      fontWeight: FontWeight.w500,
                    ),
                    indicatorColor: AppColors.primary,
                    indicatorWeight: 3,
                    tabs: const [
                      Tab(text: '추천'),
                      Tab(text: '팔로잉'),
                      Tab(text: '인기'),
                    ],
                  ),
                ),
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildFeedTab(),
              _buildFeedTab(followingOnly: true),
              _buildFeedTab(sortByPopular: true),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            _showCreatePostSheet(context);
          },
          backgroundColor: AppColors.primary,
          child: Icon(Icons.edit, color: Colors.white, size: Responsive.sp(24)),
        ),
      ),
    );
  }

  Widget _buildAppBarButton({
    required IconData icon,
    int? badge,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: Responsive.wp(10),
        height: Responsive.wp(10),
        margin: EdgeInsets.symmetric(horizontal: Responsive.wp(1)),
        decoration: BoxDecoration(
          color: AppColors.background,
          shape: BoxShape.circle,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, size: Responsive.sp(22), color: AppColors.textPrimary),
            if (badge != null)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$badge',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: Responsive.sp(9),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedTab({bool followingOnly = false, bool sortByPopular = false}) {
    List<Map<String, dynamic>> filteredPosts = List.from(_posts);

    if (sortByPopular) {
      filteredPosts.sort((a, b) => (b['likeCount'] as int).compareTo(a['likeCount'] as int));
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppColors.primary,
      child: CustomScrollView(
        slivers: [
          // 스토리/하이라이트 섹션
          SliverToBoxAdapter(
            child: _buildStoriesSection(),
          ),

          // 구분선
          SliverToBoxAdapter(
            child: Container(
              height: Responsive.hp(1),
              color: AppColors.background,
            ),
          ),

          // 피드 게시물
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index >= filteredPosts.length) return null;
                return _buildPostCard(filteredPosts[index]);
              },
              childCount: filteredPosts.length,
            ),
          ),

          // 하단 여백
          SliverToBoxAdapter(
            child: SizedBox(height: Responsive.hp(10)),
          ),
        ],
      ),
    );
  }

  Widget _buildStoriesSection() {
    final idols = MockData.idols.take(8).toList();

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: Responsive.hp(1.5)),
      child: SizedBox(
        height: Responsive.hp(12),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: Responsive.wp(3)),
          itemCount: idols.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              // 내 스토리 추가 버튼
              return Container(
                width: Responsive.wp(18),
                margin: EdgeInsets.only(right: Responsive.wp(2)),
                child: Column(
                  children: [
                    Container(
                      width: Responsive.wp(15),
                      height: Responsive.wp(15),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.divider, width: 1),
                      ),
                      child: Icon(
                        Icons.add,
                        color: AppColors.textSecondary,
                        size: Responsive.sp(24),
                      ),
                    ),
                    SizedBox(height: Responsive.hp(0.8)),
                    Text(
                      '내 스토리',
                      style: TextStyle(
                        fontSize: Responsive.sp(11),
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            }

            final idol = idols[index - 1];
            final hasNewStory = index % 2 == 0; // 데모용 랜덤

            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                context.go('/idols/${idol['id']}');
              },
              child: Container(
                width: Responsive.wp(18),
                margin: EdgeInsets.only(right: Responsive.wp(2)),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: hasNewStory
                            ? AppColors.primaryGradient
                            : null,
                        border: hasNewStory
                            ? null
                            : Border.all(color: AppColors.divider, width: 2),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: Responsive.wp(6.5),
                          backgroundColor: AppColors.primarySoft,
                          backgroundImage: idol['profileImage'] != null
                              ? CachedNetworkImageProvider(idol['profileImage'])
                              : null,
                        ),
                      ),
                    ),
                    SizedBox(height: Responsive.hp(0.8)),
                    Text(
                      idol['stageName'] ?? '',
                      style: TextStyle(
                        fontSize: Responsive.sp(11),
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    final author = post['author'] as Map<String, dynamic>?;
    final images = post['images'] as List? ?? [];
    final isSubscriberOnly = post['isSubscriberOnly'] ?? false;
    final isLiked = post['isLiked'] ?? false;

    return Container(
      color: Colors.white,
      margin: EdgeInsets.only(bottom: Responsive.hp(1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더: 프로필, 이름, 시간
          Padding(
            padding: EdgeInsets.all(Responsive.wp(4)),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (author?['id'] != null) {
                      context.go('/idols/${author!['id']}');
                    }
                  },
                  child: CircleAvatar(
                    radius: Responsive.wp(6),
                    backgroundColor: AppColors.primarySoft,
                    backgroundImage: author?['profileImage'] != null
                        ? CachedNetworkImageProvider(author!['profileImage'])
                        : null,
                    child: author?['profileImage'] == null
                        ? Icon(Icons.person, color: AppColors.primary, size: Responsive.sp(24))
                        : null,
                  ),
                ),
                SizedBox(width: Responsive.wp(3)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              author?['nickname'] ?? '익명',
                              style: TextStyle(
                                fontSize: Responsive.sp(15),
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (author?['isVerified'] == true) ...[
                            SizedBox(width: Responsive.wp(1)),
                            Icon(
                              Icons.verified,
                              color: AppColors.primary,
                              size: Responsive.sp(16),
                            ),
                          ],
                          if (isSubscriberOnly) ...[
                            SizedBox(width: Responsive.wp(2)),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: Responsive.wp(2),
                                vertical: Responsive.hp(0.3),
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '구독자 전용',
                                style: TextStyle(
                                  color: AppColors.secondary,
                                  fontSize: Responsive.sp(10),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: Responsive.hp(0.3)),
                      Row(
                        children: [
                          Text(
                            _getCategoryLabel(author?['category']),
                            style: TextStyle(
                              fontSize: Responsive.sp(12),
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            ' · ${_formatTimeAgo(post['createdAt'])}',
                            style: TextStyle(
                              fontSize: Responsive.sp(12),
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.more_horiz,
                    color: AppColors.textSecondary,
                    size: Responsive.sp(20),
                  ),
                  onPressed: () => _showPostOptions(context, post),
                ),
              ],
            ),
          ),

          // 게시물 내용
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Responsive.wp(4)),
            child: Text(
              post['content'] ?? '',
              style: TextStyle(
                fontSize: Responsive.sp(15),
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ),

          // 이미지
          if (images.isNotEmpty) ...[
            SizedBox(height: Responsive.hp(1.5)),
            _buildImageGrid(images),
          ],

          // 액션 버튼들
          Padding(
            padding: EdgeInsets.all(Responsive.wp(4)),
            child: Row(
              children: [
                _buildActionButton(
                  icon: isLiked ? Icons.favorite : Icons.favorite_border,
                  label: _formatNumber(post['likeCount'] ?? 0),
                  color: isLiked ? AppColors.error : null,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      post['isLiked'] = !isLiked;
                      post['likeCount'] = (post['likeCount'] ?? 0) + (isLiked ? -1 : 1);
                    });
                  },
                ),
                SizedBox(width: Responsive.wp(6)),
                _buildActionButton(
                  icon: Icons.chat_bubble_outline,
                  label: _formatNumber(post['commentCount'] ?? 0),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    CommentSheet.show(
                      context,
                      postId: post['id'] ?? '',
                    );
                  },
                ),
                SizedBox(width: Responsive.wp(6)),
                _buildActionButton(
                  icon: Icons.repeat,
                  label: '',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('리트윗 기능은 준비 중입니다')),
                    );
                  },
                ),
                SizedBox(width: Responsive.wp(6)),
                _buildActionButton(
                  icon: Icons.share_outlined,
                  label: '',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('공유 기능은 준비 중입니다')),
                    );
                  },
                ),
                const Spacer(),
                _buildActionButton(
                  icon: post['isBookmarked'] == true ? Icons.bookmark : Icons.bookmark_border,
                  label: '',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      post['isBookmarked'] = !(post['isBookmarked'] ?? false);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(post['isBookmarked'] == true ? '북마크에 추가되었습니다' : '북마크가 해제되었습니다'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGrid(List images) {
    if (images.isEmpty) return const SizedBox.shrink();

    if (images.length == 1) {
      return GestureDetector(
        onTap: () => _showImageViewer(context, images, 0),
        child: CachedNetworkImage(
          imageUrl: images[0],
          width: double.infinity,
          height: Responsive.hp(30),
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            height: Responsive.hp(30),
            color: AppColors.background,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            height: Responsive.hp(30),
            color: AppColors.background,
            child: Icon(Icons.image, color: AppColors.textHint, size: Responsive.sp(40)),
          ),
        ),
      );
    }

    // 2개 이상의 이미지
    return SizedBox(
      height: Responsive.hp(25),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _showImageViewer(context, images, 0),
              child: CachedNetworkImage(
                imageUrl: images[0],
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          if (images.length > 1) ...[
            SizedBox(width: Responsive.wp(0.5)),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _showImageViewer(context, images, 1),
                      child: CachedNetworkImage(
                        imageUrl: images[1],
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  if (images.length > 2) ...[
                    SizedBox(height: Responsive.wp(0.5)),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _showImageViewer(context, images, 2),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CachedNetworkImage(
                              imageUrl: images[2],
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            if (images.length > 3)
                              Container(
                                color: Colors.black.withValues(alpha: 0.5),
                                child: Center(
                                  child: Text(
                                    '+${images.length - 3}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: Responsive.sp(20),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    Color? color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            size: Responsive.sp(20),
            color: color ?? AppColors.textSecondary,
          ),
          if (label.isNotEmpty) ...[
            SizedBox(width: Responsive.wp(1.5)),
            Text(
              label,
              style: TextStyle(
                fontSize: Responsive.sp(13),
                color: color ?? AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getCategoryLabel(String? category) {
    if (category == null) return '';
    return CategoryMapper.getCategoryName(category);
  }

  void _showPostOptions(BuildContext context, Map<String, dynamic> post) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: Responsive.wp(10),
                height: 4,
                margin: EdgeInsets.symmetric(vertical: Responsive.hp(1.5)),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              _buildOptionItem(Icons.person_add, '팔로우', () => Navigator.pop(context)),
              _buildOptionItem(Icons.bookmark_border, '저장', () => Navigator.pop(context)),
              _buildOptionItem(Icons.link, '링크 복사', () => Navigator.pop(context)),
              _buildOptionItem(Icons.report_outlined, '신고', () => Navigator.pop(context), isDestructive: true),
              SizedBox(height: Responsive.hp(2)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionItem(IconData icon, String label, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? AppColors.error : AppColors.textPrimary,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isDestructive ? AppColors.error : AppColors.textPrimary,
          fontSize: Responsive.sp(15),
        ),
      ),
      onTap: onTap,
    );
  }

  void _showImageViewer(BuildContext context, List images, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: PageView.builder(
            controller: PageController(initialPage: initialIndex),
            itemCount: images.length,
            itemBuilder: (context, index) => InteractiveViewer(
              child: Center(
                child: CachedNetworkImage(
                  imageUrl: images[index],
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showCreatePostSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: Responsive.hp(70),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: Responsive.wp(10),
              height: 4,
              margin: EdgeInsets.symmetric(vertical: Responsive.hp(1.5)),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Responsive.wp(4)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      '취소',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: Responsive.sp(15),
                      ),
                    ),
                  ),
                  Text(
                    '새 게시물',
                    style: TextStyle(
                      fontSize: Responsive.sp(17),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('게시물이 작성되었습니다 (데모)')),
                      );
                    },
                    child: Text(
                      '게시',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: Responsive.sp(15),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: AppColors.divider, height: 1),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(Responsive.wp(4)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: Responsive.wp(6),
                      backgroundColor: AppColors.primarySoft,
                      child: Icon(Icons.person, color: AppColors.primary),
                    ),
                    SizedBox(width: Responsive.wp(3)),
                    Expanded(
                      child: TextField(
                        maxLines: null,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: '무슨 일이 있나요?',
                          hintStyle: TextStyle(
                            color: AppColors.textHint,
                            fontSize: Responsive.sp(16),
                          ),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(
                          fontSize: Responsive.sp(16),
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(Responsive.wp(4)),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.divider)),
              ),
              child: Row(
                children: [
                  _buildMediaButton(Icons.image_outlined, '사진'),
                  SizedBox(width: Responsive.wp(4)),
                  _buildMediaButton(Icons.gif_box_outlined, 'GIF'),
                  SizedBox(width: Responsive.wp(4)),
                  _buildMediaButton(Icons.poll_outlined, '투표'),
                  SizedBox(width: Responsive.wp(4)),
                  _buildMediaButton(Icons.location_on_outlined, '위치'),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaButton(IconData icon, String label) {
    return GestureDetector(
      onTap: () => HapticFeedback.lightImpact(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary, size: Responsive.sp(24)),
          SizedBox(height: Responsive.hp(0.3)),
          Text(
            label,
            style: TextStyle(
              color: AppColors.primary,
              fontSize: Responsive.sp(10),
            ),
          ),
        ],
      ),
    );
  }
}

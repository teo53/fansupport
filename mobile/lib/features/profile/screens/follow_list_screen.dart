import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/widgets/empty_state.dart';

enum FollowListType { followers, following }

class FollowUser {
  final String id;
  final String name;
  final String username;
  final String profileImage;
  final bool isVerified;
  final bool isFollowing;
  final String? bio;

  FollowUser({
    required this.id,
    required this.name,
    required this.username,
    required this.profileImage,
    this.isVerified = false,
    this.isFollowing = false,
    this.bio,
  });
}

class FollowListScreen extends ConsumerStatefulWidget {
  final FollowListType initialType;
  final String userId;
  final String userName;

  const FollowListScreen({
    super.key,
    this.initialType = FollowListType.followers,
    required this.userId,
    required this.userName,
  });

  @override
  ConsumerState<FollowListScreen> createState() => _FollowListScreenState();
}

class _FollowListScreenState extends ConsumerState<FollowListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  bool _isSearching = false;

  final List<FollowUser> _followers = [
    FollowUser(
      id: 'u1',
      name: '하늘별',
      username: '@skystar_idol',
      profileImage: 'https://i.pravatar.cc/100?img=5',
      isVerified: true,
      isFollowing: true,
      bio: '지하 아이돌 2년차 💕',
    ),
    FollowUser(
      id: 'u2',
      name: '미유',
      username: '@miyu_maid',
      profileImage: 'https://i.pravatar.cc/100?img=9',
      isVerified: true,
      isFollowing: true,
      bio: '메이드카페 ☆StarLight☆',
    ),
    FollowUser(
      id: 'u3',
      name: '루나',
      username: '@luna_cos',
      profileImage: 'https://i.pravatar.cc/100?img=10',
      isVerified: true,
      bio: '코스플레이어 | DM 환영',
    ),
    FollowUser(
      id: 'u4',
      name: '별빛서포터',
      username: '@starlight_fan',
      profileImage: 'https://i.pravatar.cc/100?img=12',
      isFollowing: true,
    ),
    FollowUser(
      id: 'u5',
      name: '아이돌덕후',
      username: '@idol_lover99',
      profileImage: 'https://i.pravatar.cc/100?img=15',
    ),
  ];

  final List<FollowUser> _following = [
    FollowUser(
      id: 'u1',
      name: '하늘별',
      username: '@skystar_idol',
      profileImage: 'https://i.pravatar.cc/100?img=5',
      isVerified: true,
      isFollowing: true,
      bio: '지하 아이돌 2년차 💕',
    ),
    FollowUser(
      id: 'u2',
      name: '미유',
      username: '@miyu_maid',
      profileImage: 'https://i.pravatar.cc/100?img=9',
      isVerified: true,
      isFollowing: true,
      bio: '메이드카페 ☆StarLight☆',
    ),
    FollowUser(
      id: 'u6',
      name: '유키',
      username: '@yuki_vtuber',
      profileImage: 'https://i.pravatar.cc/100?img=20',
      isVerified: true,
      isFollowing: true,
      bio: 'VTuber | 매일 방송 중!',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialType == FollowListType.followers ? 0 : 1,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<FollowUser> _getFilteredList(List<FollowUser> list) {
    if (_searchController.text.isEmpty) return list;
    final query = _searchController.text.toLowerCase();
    return list.where((user) =>
      user.name.toLowerCase().contains(query) ||
      user.username.toLowerCase().contains(query)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: _isSearching
            ? _buildSearchField()
            : Text(widget.userName, style: TextStyle(fontSize: Responsive.sp(18))),
        leading: IconButton(
          icon: Icon(_isSearching ? Icons.arrow_back : Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            if (_isSearching) {
              setState(() {
                _isSearching = false;
                _searchController.clear();
              });
            } else {
              context.pop();
            }
          },
        ),
        actions: [
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => setState(() => _isSearching = true),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: TextStyle(
            fontSize: Responsive.sp(15),
            fontWeight: FontWeight.w600,
          ),
          tabs: [
            Tab(text: '팔로워 ${_followers.length}'),
            Tab(text: '팔로잉 ${_following.length}'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUserList(_getFilteredList(_followers), isFollowers: true),
          _buildUserList(_getFilteredList(_following), isFollowers: false),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      style: TextStyle(fontSize: Responsive.sp(16)),
      decoration: InputDecoration(
        hintText: '검색...',
        hintStyle: TextStyle(color: AppColors.textHint),
        border: InputBorder.none,
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                },
              )
            : null,
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildUserList(List<FollowUser> users, {required bool isFollowers}) {
    if (users.isEmpty) {
      return EmptyState(
        type: EmptyStateType.noFollower,
        title: _searchController.text.isNotEmpty
            ? '검색 결과가 없습니다'
            : isFollowers ? '팔로워가 없습니다' : '팔로잉이 없습니다',
        message: _searchController.text.isNotEmpty
            ? '다른 검색어로 시도해보세요'
            : isFollowers
                ? '아직 팔로워가 없습니다'
                : '다른 사용자를 팔로우해보세요',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: Responsive.hp(1)),
        itemCount: users.length,
        itemBuilder: (context, index) => _buildUserTile(users[index]),
      ),
    );
  }

  Widget _buildUserTile(FollowUser user) {
    return InkWell(
      onTap: () {
        // Navigate to user profile
        if (user.isVerified) {
          context.push('/idols/${user.id}');
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.wp(4),
          vertical: Responsive.hp(1.5),
        ),
        child: Row(
          children: [
            // Profile Image
            Stack(
              children: [
                CircleAvatar(
                  radius: Responsive.wp(7),
                  backgroundImage: CachedNetworkImageProvider(user.profileImage),
                ),
                if (user.isVerified)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: Responsive.wp(5),
                      height: Responsive.wp(5),
                      decoration: BoxDecoration(
                        color: AppColors.info,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(
                        Icons.check,
                        size: Responsive.sp(10),
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: Responsive.wp(3)),

            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        user.name,
                        style: TextStyle(
                          fontSize: Responsive.sp(15),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (user.isVerified) ...[
                        SizedBox(width: Responsive.wp(1)),
                        Icon(
                          Icons.verified,
                          size: Responsive.sp(16),
                          color: AppColors.info,
                        ),
                      ],
                    ],
                  ),
                  Text(
                    user.username,
                    style: TextStyle(
                      fontSize: Responsive.sp(13),
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (user.bio != null) ...[
                    SizedBox(height: Responsive.hp(0.3)),
                    Text(
                      user.bio!,
                      style: TextStyle(
                        fontSize: Responsive.sp(13),
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Follow Button
            _buildFollowButton(user),
          ],
        ),
      ),
    );
  }

  Widget _buildFollowButton(FollowUser user) {
    if (user.isFollowing) {
      return OutlinedButton(
        onPressed: () => _toggleFollow(user),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.wp(4),
            vertical: Responsive.hp(0.8),
          ),
          side: BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          '팔로잉',
          style: TextStyle(
            fontSize: Responsive.sp(13),
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return ElevatedButton(
      onPressed: () => _toggleFollow(user),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.wp(4),
          vertical: Responsive.hp(0.8),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
      child: Text(
        '팔로우',
        style: TextStyle(
          fontSize: Responsive.sp(13),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _toggleFollow(FollowUser user) {
    HapticFeedback.lightImpact();

    // Show confirmation dialog for unfollow
    if (user.isFollowing) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('${user.name}님을 언팔로우 하시겠습니까?'),
          content: Text('${user.name}님의 게시물이 더 이상 피드에 표시되지 않습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                '취소',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  // Toggle follow state
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${user.name}님을 언팔로우했습니다')),
                );
              },
              child: Text(
                '언팔로우',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        ),
      );
    } else {
      setState(() {
        // Toggle follow state
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${user.name}님을 팔로우합니다')),
      );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/demo_feedback.dart';
import '../../../core/mock/mock_data.dart';
import '../../../shared/models/bubble_message_model.dart';

class BubbleListScreen extends ConsumerStatefulWidget {
  const BubbleListScreen({super.key});

  @override
  ConsumerState<BubbleListScreen> createState() => _BubbleListScreenState();
}

class _BubbleListScreenState extends ConsumerState<BubbleListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedIdolId = 'all';

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

  List<BubbleMessageModel> get _filteredMessages {
    if (_selectedIdolId == 'all') {
      return MockData.bubbleMessages;
    }
    return MockData.bubbleMessages
        .where((m) => m.idolId == _selectedIdolId)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildIdolFilter(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMessageList(),
                  _buildSubscriptionList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.wp(4),
        vertical: Responsive.hp(1.5),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.backgroundAlt,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            ),
          ),
          SizedBox(width: Responsive.wp(3)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '버블',
                  style: TextStyle(
                    fontSize: Responsive.sp(22),
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Pretendard',
                  ),
                ),
                Text(
                  '아이돌의 일상을 함께해요',
                  style: TextStyle(
                    fontSize: Responsive.sp(13),
                    color: AppColors.textSecondary,
                    fontFamily: 'Pretendard',
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.add_circle_outline, size: 16, color: Colors.white),
                const SizedBox(width: 4),
                Text(
                  '구독하기',
                  style: TextStyle(
                    fontSize: Responsive.sp(12),
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontFamily: 'Pretendard',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdolFilter() {
    final subscribedIdols = MockData.idolModels
        .where((idol) => idol.hasBubble)
        .take(5)
        .toList();

    return Container(
      height: 80,
      padding: EdgeInsets.symmetric(vertical: Responsive.hp(1)),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: Responsive.wp(4)),
        itemCount: subscribedIdols.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildIdolFilterItem(
              id: 'all',
              name: '전체',
              imageUrl: null,
              isSelected: _selectedIdolId == 'all',
            );
          }
          final idol = subscribedIdols[index - 1];
          return _buildIdolFilterItem(
            id: idol.id,
            name: idol.stageName,
            imageUrl: idol.profileImage,
            isSelected: _selectedIdolId == idol.id,
            hasNew: index == 1 || index == 2,
          );
        },
      ),
    );
  }

  Widget _buildIdolFilterItem({
    required String id,
    required String name,
    String? imageUrl,
    required bool isSelected,
    bool hasNew = false,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _selectedIdolId = id;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: isSelected ? 2 : 1,
                    ),
                    gradient: isSelected ? AppColors.primaryGradient : null,
                  ),
                  padding: const EdgeInsets.all(2),
                  child: CircleAvatar(
                    backgroundImage: imageUrl != null
                        ? CachedNetworkImageProvider(imageUrl)
                        : null,
                    backgroundColor: AppColors.backgroundAlt,
                    child: imageUrl == null
                        ? const Icon(Icons.all_inclusive, size: 20)
                        : null,
                  ),
                ),
                if (hasNew)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.neonPink,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              name.length > 4 ? '${name.substring(0, 4)}...' : name,
              style: TextStyle(
                fontSize: Responsive.sp(11),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontFamily: 'Pretendard',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: Responsive.wp(4),
        vertical: Responsive.hp(1),
      ),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.backgroundAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: AppColors.softShadow(),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: AppColors.textPrimary,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: TextStyle(
          fontSize: Responsive.sp(14),
          fontWeight: FontWeight.w600,
          fontFamily: 'Pretendard',
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: Responsive.sp(14),
          fontWeight: FontWeight.w500,
          fontFamily: 'Pretendard',
        ),
        tabs: const [
          Tab(text: '메시지'),
          Tab(text: '구독 관리'),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    final messages = _filteredMessages;

    if (messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mail_outline_rounded,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              '아직 메시지가 없어요',
              style: TextStyle(
                fontSize: Responsive.sp(16),
                color: AppColors.textSecondary,
                fontFamily: 'Pretendard',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '아이돌을 구독하고 메시지를 받아보세요!',
              style: TextStyle(
                fontSize: Responsive.sp(14),
                color: AppColors.textTertiary,
                fontFamily: 'Pretendard',
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.wp(4),
        vertical: Responsive.hp(1),
      ),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return _buildMessageCard(message);
      },
    );
  }

  Widget _buildMessageCard(BubbleMessageModel message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.softShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundImage: CachedNetworkImageProvider(message.idolProfileImage),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            message.idolName,
                            style: TextStyle(
                              fontSize: Responsive.sp(15),
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Pretendard',
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.verified,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          if (message.isSubscriberOnly) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '구독자 전용',
                                style: TextStyle(
                                  fontSize: Responsive.sp(10),
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  fontFamily: 'Pretendard',
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        _formatTime(message.createdAt),
                        style: TextStyle(
                          fontSize: Responsive.sp(12),
                          color: AppColors.textTertiary,
                          fontFamily: 'Pretendard',
                        ),
                      ),
                    ],
                  ),
                ),
                _buildMessageTypeIcon(message.type),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              message.content,
              style: TextStyle(
                fontSize: Responsive.sp(14),
                height: 1.5,
                fontFamily: 'Pretendard',
              ),
            ),
          ),

          // Media
          if (message.mediaUrl != null && message.type == BubbleMessageType.image)
            Padding(
              padding: const EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: message.mediaUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 200,
                    color: AppColors.backgroundAlt,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ),
              ),
            ),

          // Voice message
          if (message.type == BubbleMessageType.voice)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: FractionallySizedBox(
                              widthFactor: 0.0,
                              alignment: Alignment.centerLeft,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '0:00 / 0:${message.duration?.toString().padLeft(2, '0') ?? '00'}',
                            style: TextStyle(
                              fontSize: Responsive.sp(11),
                              color: AppColors.textSecondary,
                              fontFamily: 'Pretendard',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildActionButton(
                  icon: message.isLiked
                      ? Icons.favorite
                      : Icons.favorite_border_rounded,
                  label: _formatCount(message.likeCount),
                  isActive: message.isLiked,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      message.isLiked = !message.isLiked;
                      message.likeCount += message.isLiked ? 1 : -1;
                    });
                  },
                ),
                const SizedBox(width: 16),
                _buildActionButton(
                  icon: Icons.visibility_outlined,
                  label: _formatCount(message.viewCount),
                  onTap: () {
                    // View count is just informational
                  },
                ),
                const Spacer(),
                _buildActionButton(
                  icon: Icons.share_outlined,
                  label: '공유',
                  onTap: () {
                    DemoFeedback.showShareDemo(context, '버블 메시지');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageTypeIcon(BubbleMessageType type) {
    IconData icon;
    Color color;

    switch (type) {
      case BubbleMessageType.text:
        icon = Icons.chat_bubble_outline_rounded;
        color = AppColors.primary;
        break;
      case BubbleMessageType.image:
        icon = Icons.image_outlined;
        color = AppColors.success;
        break;
      case BubbleMessageType.voice:
        icon = Icons.mic_outlined;
        color = AppColors.warning;
        break;
      case BubbleMessageType.video:
        icon = Icons.videocam_outlined;
        color = AppColors.info;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isActive ? AppColors.primary : AppColors.textTertiary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: Responsive.sp(13),
              color: isActive ? AppColors.primary : AppColors.textSecondary,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              fontFamily: 'Pretendard',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionList() {
    final subscribedIdols = MockData.idolModels
        .where((idol) => idol.hasBubble)
        .toList();

    return ListView.builder(
      padding: EdgeInsets.all(Responsive.wp(4)),
      itemCount: subscribedIdols.length,
      itemBuilder: (context, index) {
        final idol = subscribedIdols[index];
        return _buildSubscriptionCard(idol);
      },
    );
  }

  Widget _buildSubscriptionCard(dynamic idol) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.softShadow(),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: CachedNetworkImageProvider(idol.profileImage),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      idol.stageName,
                      style: TextStyle(
                        fontSize: Responsive.sp(16),
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                    if (idol.isVerified) ...[
                      const SizedBox(width: 4),
                      Icon(Icons.verified, size: 16, color: AppColors.primary),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '월 ${_formatPrice(idol.bubblePrice ?? 0)}원',
                  style: TextStyle(
                    fontSize: Responsive.sp(13),
                    color: AppColors.textSecondary,
                    fontFamily: 'Pretendard',
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '구독중',
              style: TextStyle(
                fontSize: Responsive.sp(13),
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontFamily: 'Pretendard',
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}분 전';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}시간 전';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}일 전';
    } else {
      return '${dateTime.month}/${dateTime.day}';
    }
  }

  String _formatCount(int count) {
    if (count >= 10000) {
      return '${(count / 10000).toStringAsFixed(1)}만';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}천';
    }
    return count.toString();
  }

  String _formatPrice(int price) {
    if (price >= 10000) {
      return '${(price / 10000).toStringAsFixed(0)}만';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(1)}천';
    }
    return price.toString();
  }
}

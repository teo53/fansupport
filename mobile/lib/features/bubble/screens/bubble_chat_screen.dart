import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/models/bubble_message_model.dart';

/// 💬 버블 채팅 화면 (실제 버블 서비스 스타일)
class BubbleChatScreen extends ConsumerStatefulWidget {
  final String idolId;
  final String idolName;
  final String idolProfileImage;

  const BubbleChatScreen({
    super.key,
    required this.idolId,
    required this.idolName,
    required this.idolProfileImage,
  });

  @override
  ConsumerState<BubbleChatScreen> createState() => _BubbleChatScreenState();
}

class _BubbleChatScreenState extends ConsumerState<BubbleChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();

  // 데모 메시지 (실제 버블 스타일)
  final List<BubbleMessage> _messages = [
    BubbleMessage(
      id: '1',
      text: '아 어제 밤에 카카오톡 오픈채팅방 잠깐 들어갔었다??',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      isFromIdol: true,
    ),
    BubbleMessage(
      id: '2',
      text: '한 2분만인가',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      isFromIdol: true,
    ),
    BubbleMessage(
      id: '3',
      text: '계속 애기나오는데 그냥 이쑤안만들고\n싶어서 별말 안하려고 했는데\n어제부터 계속 애기하니까 그냥\n애기해줄게\n다른데서 진짜들으면 좀 서운할거바\n적어보는디',
      timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
      isFromIdol: true,
    ),
    BubbleMessage(
      id: '4',
      text: '나는 그냥 이벤트성으로 팬들한테 사랑주고\n싶어서 들어갔는데 몇몇분들이 버블에서\n애기안하고 카톡에서 연락하게 좀 마음이\n안좋았나바',
      timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
      isFromIdol: true,
    ),
    BubbleMessage(
      id: '5',
      text: '충분히 서운하다고 생각할 수 있고\n버블구독한사람은 뭐가 되나고 자꾸\n애기하시는데',
      timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
      isFromIdol: true,
    ),
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Scaffold(
      backgroundColor: Colors.black, // 버블 스타일: 검은색 배경
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => context.pop(),
      ),
      title: Row(
        children: [
          // 프로필 이미지 (핑크색 테두리)
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary, // 핑크색 테두리
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 18,
              backgroundImage: CachedNetworkImageProvider(widget.idolProfileImage),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.idolName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  '버블',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onPressed: () {
            // 메뉴
          },
        ),
      ],
    );
  }

  Widget _buildMessageBubble(BubbleMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 프로필 이미지 (핑크색 테두리)
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary, // 핑크색 테두리
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 20,
              backgroundImage: CachedNetworkImageProvider(widget.idolProfileImage),
            ),
          ),
          const SizedBox(width: 12),

          // 메시지 내용
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ARTIST 배지 + 이름
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'ARTIST',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.idolName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // 말풍선
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    message.text,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 4),

                // 시간 (오후 1:22 형식)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    _formatTime(message.timestamp),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white54,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // 플러스 버튼
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: Colors.white70, size: 22),
              onPressed: () {
                // 미디어 추가
              },
            ),
          ),
          const SizedBox(width: 12),

          // 입력 필드
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _messageController,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                ),
                decoration: const InputDecoration(
                  hintText: '메시지 입력...',
                  hintStyle: TextStyle(
                    fontSize: 15,
                    color: Colors.white38,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
                maxLines: null,
                textInputAction: TextInputAction.newline,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // 전송 버튼
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: () {
                if (_messageController.text.trim().isNotEmpty) {
                  // 메시지 전송
                  HapticFeedback.lightImpact();
                  _messageController.clear();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour < 12 ? '오전' : '오후';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    return '$period $displayHour:${minute.toString().padLeft(2, '0')}';
  }
}

/// 버블 메시지 모델
class BubbleMessage {
  final String id;
  final String text;
  final DateTime timestamp;
  final bool isFromIdol;
  final String? mediaUrl;

  const BubbleMessage({
    required this.id,
    required this.text,
    required this.timestamp,
    this.isFromIdol = true,
    this.mediaUrl,
  });
}

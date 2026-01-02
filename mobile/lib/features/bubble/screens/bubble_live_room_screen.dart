import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/mock/mock_analytics_data.dart';
import '../../../core/mock/mock_data.dart';
import '../../../shared/models/live_chat_model.dart';
import '../../../shared/models/idol_model.dart';

/// 버블 스타일 라이브 채팅방
/// 레퍼런스: 디어유 버블 앱
///
/// 핵심 특징:
/// 1. 팬은 아이돌 메시지 + 자신의 메시지만 보임 (1:1 대화 느낌)
/// 2. 아이돌이 특정 팬 메시지를 태그하면 모든 팬에게 보임
/// 3. 아이돌은 모든 팬 메시지를 볼 수 있음
class BubbleLiveRoomScreen extends ConsumerStatefulWidget {
  final IdolModel? idol;
  final String? roomId;

  const BubbleLiveRoomScreen({super.key, this.idol, this.roomId});

  @override
  ConsumerState<BubbleLiveRoomScreen> createState() => _BubbleLiveRoomScreenState();
}

class _BubbleLiveRoomScreenState extends ConsumerState<BubbleLiveRoomScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Mock 데이터
  late BubbleLiveRoom _liveRoom;
  late List<LiveChatMessage> _allMessages;
  List<LiveChatMessage> _visibleMessages = [];

  // 현재 유저 정보 (Mock)
  final String _myUserId = 'user_demo_001';
  final String _myUserName = '별빛팬';
  final bool _isIdolMode = false; // 아이돌 모드 토글 (테스트용)

  // 구독 정보
  final int _subscriptionDays = 62;

  // 실시간 업데이트 타이머
  Timer? _updateTimer;
  int _viewerCount = 1234;

  IdolModel get _idol => widget.idol ?? MockData.idolModels.first;

  @override
  void initState() {
    super.initState();
    _liveRoom = MockAnalyticsData.getLiveRoom(_idol.id);
    _allMessages = MockAnalyticsData.getLiveChatMessages(_liveRoom.id, _myUserId);
    _filterVisibleMessages();
    _startRealtimeUpdates();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _updateTimer?.cancel();
    super.dispose();
  }

  // 실시간 업데이트 시뮬레이션
  void _startRealtimeUpdates() {
    _updateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          _viewerCount += (DateTime.now().second % 3) - 1; // 랜덤 변동
          if (_viewerCount < 100) _viewerCount = 100;
        });
      }
    });
  }

  /// 버블 스타일 핵심 로직: 팬이 볼 수 있는 메시지만 필터링
  void _filterVisibleMessages() {
    if (_isIdolMode) {
      // 아이돌은 모든 메시지 보임
      _visibleMessages = List.from(_allMessages);
    } else {
      // 팬은 아이돌 메시지 + 내 메시지 + 태그된 메시지만 보임
      _visibleMessages = _allMessages.where((msg) {
        return msg.isVisibleToFan(_myUserId);
      }).toList();
    }
  }

  int _getCharLimit() {
    if (_subscriptionDays < 50) return 30;
    if (_subscriptionDays < 100) return 50;
    return 1500;
  }

  void _sendMessage() {
    if (_textController.text.trim().isEmpty) return;

    HapticFeedback.lightImpact();

    final newMessage = LiveChatMessage(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      roomId: _liveRoom.id,
      senderId: _myUserId,
      senderName: _myUserName,
      senderType: SenderType.fan,
      messageType: LiveChatMessageType.text,
      content: _textController.text,
      createdAt: DateTime.now(),
    );

    setState(() {
      _allMessages.add(newMessage);
      _filterVisibleMessages();
      _textController.clear();
    });

    // 자동 스크롤
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Stack(
        children: [
          // 배경 그라데이션
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF2D2D44),
                  const Color(0xFF1A1A2E),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _build1to1Notice(),
                Expanded(child: _buildChatList()),
                _buildInputArea(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // 뒤로가기
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 12),

          // 아이돌 프로필
          Stack(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundImage: CachedNetworkImageProvider(_idol.profileImage),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF1A1A2E), width: 2),
                  ),
                  child: const Center(
                    child: Icon(Icons.play_arrow, color: Colors.white, size: 8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),

          // 아이돌 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _idol.stageName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  '시청 $_viewerCount명 • ${_liveRoom.liveDuration}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // 버블 구독 뱃지
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.pink.shade400, Colors.purple.shade400],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Text('💕', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 4),
                Text(
                  '+$_subscriptionDays',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 1:1 대화 느낌 안내
  Widget _build1to1Notice() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_outline, color: AppColors.primary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${_idol.stageName}님과 1:1 대화처럼 느껴져요\n다른 팬의 메시지는 보이지 않아요 💕',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _visibleMessages.length,
      itemBuilder: (context, index) {
        final message = _visibleMessages[index];
        return _buildMessageItem(message);
      },
    );
  }

  Widget _buildMessageItem(LiveChatMessage message) {
    switch (message.senderType) {
      case SenderType.idol:
        return _buildIdolMessage(message);
      case SenderType.fan:
        return _buildFanMessage(message);
      case SenderType.system:
        return _buildSystemMessage(message);
    }
  }

  // 아이돌 메시지 (왼쪽)
  Widget _buildIdolMessage(LiveChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: CachedNetworkImageProvider(message.senderProfileImage ?? _idol.profileImage),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 이름 + ARTIST 뱃지
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3D99FF),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'ARTIST',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      message.senderName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // 태그된 메시지 (있을 경우)
                if (message.isTaggedByIdol && message.taggedContent != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.reply, color: AppColors.primary, size: 14),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message.taggedFanName ?? '',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                message.taggedContent!,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                // 메시지 버블
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      constraints: BoxConstraints(maxWidth: Responsive.wp(65)),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18).copyWith(
                          topLeft: Radius.zero,
                        ),
                      ),
                      child: message.messageType == LiveChatMessageType.voice
                          ? _buildVoiceContent(message)
                          : Text(
                              message.content,
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.4,
                                color: Colors.black87,
                              ),
                            ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatTime(message.createdAt),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 보이스 메시지 컨텐츠
  Widget _buildVoiceContent(LiveChatMessage message) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.play_arrow, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 100,
              height: 3,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '0:${message.duration?.toString().padLeft(2, '0') ?? '00'}',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 내 메시지 (오른쪽)
  Widget _buildFanMessage(LiveChatMessage message) {
    final isMyMessage = message.senderId == _myUserId;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 읽음 표시 (아이돌이 읽으면 ✓✓)
              Text(
                message.isRead ? '✓✓' : '1',
                style: TextStyle(
                  color: message.isRead
                      ? Colors.lightBlueAccent
                      : Colors.yellow.shade300,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _formatTime(message.createdAt),
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ],
          ),
          const SizedBox(width: 6),
          Container(
            constraints: BoxConstraints(maxWidth: Responsive.wp(70)),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withBlue(200),
                ],
              ),
              borderRadius: BorderRadius.circular(18).copyWith(
                topRight: Radius.zero,
              ),
            ),
            child: Text(
              message.content,
              style: const TextStyle(
                fontSize: 15,
                height: 1.4,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 시스템 메시지 (중앙)
  Widget _buildSystemMessage(LiveChatMessage message) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.amber.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.amber.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (message.giftType != null) ...[
              const Text('🎁', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                message.content,
                style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    final charLimit = _getCharLimit();

    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D44),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          // 이모지/스티커 버튼
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.emoji_emotions_outlined, color: Colors.white70, size: 22),
            ),
          ),
          const SizedBox(width: 10),

          // 텍스트 입력
          Expanded(
            child: TextField(
              controller: _textController,
              maxLength: charLimit,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              onChanged: (val) => setState(() {}),
              decoration: InputDecoration(
                hintText: '${_idol.stageName}에게 메시지 보내기...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14),
                counterText: '${_textController.text.length}/$charLimit',
                counterStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // 전송 버튼
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: _textController.text.isNotEmpty
                    ? LinearGradient(colors: [AppColors.primary, AppColors.primary.withBlue(200)])
                    : null,
                color: _textController.text.isEmpty ? Colors.white.withOpacity(0.1) : null,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.send_rounded,
                color: _textController.text.isNotEmpty ? Colors.white : Colors.white38,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

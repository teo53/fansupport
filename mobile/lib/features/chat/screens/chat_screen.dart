import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/models/idol_model.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final IdolModel idol;

  const ChatScreen({super.key, required this.idol});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Mock Subscription Data
  final int _subscriptionDays = 62;

  // Mock User ID (Current User)
  final String _myId = 'user_1';

  // Mock Messages (In a real app, this comes from a backend/stream)
  // 'type': 'idol' | 'fan'
  final List<Map<String, dynamic>> _allMessages = [
    {
      'id': '1',
      'senderId': 'idol_1',
      'type': 'idol',
      'text': '다이브 꾸이꾸이 해줘',
      'timestamp': DateTime.now()
          .subtract(const Duration(days: 8)), // Setup for Refund Test
    },
    {
      'id': '2',
      'senderId': 'user_1',
      'type': 'fan',
      'text': '꾸이꾸이', // My message
      'timestamp': DateTime.now().subtract(const Duration(minutes: 4)),
    },
    {
      'id': '3',
      'senderId': 'user_2',
      'type': 'fan',
      'text': '와 너무 귀엽다 ㅠㅠ', // Other fan's message (Should be hidden for me)
      'timestamp': DateTime.now().subtract(const Duration(minutes: 3)),
    },
    {
      'id': '4',
      'senderId': 'idol_1',
      'type': 'idol',
      'text': '웃겨 ㅋㅋㅋ',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 1)),
    },
  ];

  late List<Map<String, dynamic>> _visibleMessages;
  // ignore: prefer_const_declarations
  final bool _isIdolMode = false; // Toggle for testing

  @override
  void initState() {
    super.initState();
    _filterMessages();
  }

  void _filterMessages() {
    // 1:1 Illusion Logic
    // If I am IDOL: See ALL messages.
    // If I am FAN: See ONLY Idol messages AND My messages.

    // For this mock, let's assume the current app user is a FAN by default unless specific role is toggled.
    // In a real scenario, use: final userRole = ref.read(authProvider).role;

    if (_isIdolMode) {
      _visibleMessages = List.from(_allMessages);
    } else {
      _visibleMessages = _allMessages.where((msg) {
        return msg['type'] == 'idol' || msg['senderId'] == _myId;
      }).toList();
    }
  }

  int _getCharLimit() {
    if (_subscriptionDays < 50) return 30;
    if (_subscriptionDays < 100) return 50;
    return 1500; // Unlimited/High cap
  }

  void _sendMessage() {
    if (_textController.text.trim().isEmpty) return;

    setState(() {
      _allMessages.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'senderId': _myId,
        'type': 'fan',
        'text': _textController.text,
        'timestamp': DateTime.now(),
      });
      _filterMessages(); // Re-filter to show new message
      _textController.clear();
    });

    // Auto-scroll
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

  bool _shouldShowInactiveBanner() {
    // Mock logic: check last idol message
    final lastIdolMsg =
        _allMessages.where((m) => m['type'] == 'idol').lastOrNull;
    if (lastIdolMsg == null) return false;

    final lastDate = lastIdolMsg['timestamp'] as DateTime;
    // Check if 7 days have passed
    return DateTime.now().difference(lastDate).inDays >= 7;
  }

  void _showRefundDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('구독 환불'),
        content: const Text(
            '아티스트의 활동이 7일 이상 없어\n이번 달 구독료를 전액 환불해 드립니다.\n\n정말 환불하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('환불 신청이 완료되었습니다.')),
              );
            },
            child: const Text('환불 신청', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final charLimit = _getCharLimit();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.95),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Column(
          children: [
            Text(
              widget.idol.stageName,
              style: TextStyle(
                color: Colors.black,
                fontSize: Responsive.sp(16),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'bubble 🩷 + $_subscriptionDays',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: Responsive.sp(12),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onSelected: (value) {
              if (value == 'refund') {
                _showRefundDialog();
              }
            },
            itemBuilder: (BuildContext context) {
              final canRefund =
                  _shouldShowInactiveBanner(); // Reuse logic or independent check
              return [
                const PopupMenuItem(
                  value: 'settings',
                  child: Text('채팅방 설정'),
                ),
                PopupMenuItem(
                  value: 'refund',
                  enabled: canRefund,
                  child: Row(
                    children: [
                      Text(
                        '구독 환불 요청',
                        style: TextStyle(
                            color: canRefund ? Colors.red : Colors.grey),
                      ),
                      if (canRefund) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.error_outline,
                            color: Colors.red, size: 16),
                      ],
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: CachedNetworkImageProvider(
                'https://i.pinimg.com/736x/8e/1e/8e/8e1e8e9e9e9e9e9e9e9e9e9e9e9e9e9e.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black12, BlendMode.darken),
          ),
          color: Color(0xFFF2F2F2),
        ),
        child: Column(
          children: [
            SizedBox(
                height: kToolbarHeight + MediaQuery.of(context).padding.top),

            // Refund Alert Banner
            if (_shouldShowInactiveBanner())
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                color: const Color(0xB3000000), // Semi-transparent black
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '최근 ${widget.idol.stageName}님의 메시지가 없습니다.\n7일 이상 미수신 시 환불이 가능합니다.',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),

            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                itemCount: _visibleMessages.length,
                itemBuilder: (context, index) {
                  final msg = _visibleMessages[index];
                  final isIdol = msg['type'] == 'idol';

                  final time =
                      "${msg['timestamp'].hour}:${msg['timestamp'].minute.toString().padLeft(2, '0')}";

                  if (isIdol) {
                    return _buildIdolMessage(msg['text'], time);
                  } else {
                    return _buildMyMessage(msg['text'], time);
                  }
                },
              ),
            ),
            _buildInputArea(charLimit),
          ],
        ),
      ),
    );
  }

  Widget _buildIdolMessage(String text, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundImage: NetworkImage(widget.idol.profileImage),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3D99FF), // Bubble Blue Badge
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'ARTIST',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.idol.stageName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.black87),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    constraints: BoxConstraints(maxWidth: Responsive.wp(65)),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18)
                          .copyWith(topLeft: Radius.zero),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 4,
                            offset: Offset(0, 2))
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          text,
                          style: const TextStyle(
                              fontSize: 15, height: 1.4, color: Colors.black87),
                        ),
                        // Translation & Copy Icons (Mock)
                        const SizedBox(height: 8),
                        Divider(height: 1, color: Colors.grey[200]),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.translate,
                                size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text('번역보기',
                                style: TextStyle(
                                    color: Colors.grey[500], fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    time,
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMyMessage(String text, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Read receipt '1' (disappears when read - mock always read for now or just '1')
              const Text('1',
                  style: TextStyle(
                      color: Colors.yellow,
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
              Text(
                time,
                style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600]), // Darker text for visibility
              ),
            ],
          ),
          const SizedBox(width: 4),
          Container(
            constraints: BoxConstraints(maxWidth: Responsive.wp(70)),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(
                  0xFFFFE030), // Warning/Yellow (Kakao style) or Custom Blue?
              // The reference image has standard yellow for user messages in some versions, or white/blue.
              // Let's use a nice soft Yellow or Blue. User asked for "Bubble".
              // JYP Bubble uses Yellow for user? No, usually Blue for Artist, Yellow for user is Kakao.
              // Bubble app user bubbles are often customizable. Let's stick to a clean Yellow to contrast with White.
              borderRadius:
                  BorderRadius.circular(18).copyWith(topRight: Radius.zero),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: Offset(0, 2))
              ],
            ),
            child: Text(
              text,
              style: const TextStyle(
                  fontSize: 15, height: 1.4, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(int charLimit) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              maxLength: charLimit,
              onChanged: (val) => setState(() {}),
              decoration: InputDecoration(
                hintText: '메세지를 입력하세요...',
                counterText: '${_textController.text.length} / $charLimit',
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(
              color: Colors.grey, // Active color if text > 0
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Transform.translate(
                offset: const Offset(2, 0),
                child: const Icon(Icons.send, color: Colors.white, size: 20),
              ),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}

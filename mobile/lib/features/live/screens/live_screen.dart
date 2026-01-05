import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/utils/responsive.dart';
import '../../../shared/models/idol_model.dart';
import 'dart:async';
import 'dart:math' as math;

class LiveScreen extends StatefulWidget {
  final IdolModel idol;

  const LiveScreen({super.key, required this.idol});

  @override
  State<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen> with TickerProviderStateMixin {
  final TextEditingController _commentController = TextEditingController();
  final List<String> _comments = [
    '안녕하세요!!',
    '기다렸어요 ㅠㅠ',
    '오늘 의상 대박...',
    '사랑해!!!',
  ];
  final List<FloatingHeart> _hearts = [];
  Timer? _heartTimer;
  Timer? _commentTimer;
  final ScrollController _scrollController = ScrollController();

  // Fake viewer count logic
  int _viewerCount = 1240;

  @override
  void initState() {
    super.initState();
    // Start auto-generating hearts
    _heartTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (mounted) {
        _addHeart();
      }
    });

    // Start auto-scrolling comments (simulated)
    _commentTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        setState(() {
          _comments.add(_generateRandomComment());
          // Auto scroll to bottom
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent + 50,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _heartTimer?.cancel();
    _commentTimer?.cancel();
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addHeart() {
    setState(() {
      _hearts.add(FloatingHeart(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        animationController: AnimationController(
          vsync: this,
          duration: const Duration(seconds: 2),
        )..forward().whenComplete(() {
            // Cleanup logic would go here in a real app,
            // but strictly removing from list can be tricky during iteration.
            // For this mock, we just let them fade out visually.
          }),
        color: [
          Colors.pink,
          Colors.red,
          Colors.purple,
          Colors.orange
        ][math.Random().nextInt(4)],
      ));
    });
  }

  String _generateRandomComment() {
    final comments = [
      '언니 너무 예뻐요',
      '목소리 꿀이다',
      'Live 화이팅!',
      'ㅋㅋㅋ',
      '대박',
      '팬이에요!!',
      '오늘 뭐해요?'
    ];
    return comments[math.Random().nextInt(comments.length)];
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    // Simulate Video Feed with Image
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Background (Video Feed Placeholder)
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: widget.idol.profileImage,
              fit: BoxFit.cover,
              color: Colors.black.withValues(alpha: 0.0), // No darken, clean look
              colorBlendMode: BlendMode.darken,
            ),
          ),

          // 2. Gradient Overlay for Text Readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.6),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.2, 0.6, 1.0],
                ),
              ),
            ),
          ),

          // 3. Top Header (Streamer Info)
          Positioned(
            top: Responsive.hp(6),
            left: Responsive.wp(4),
            right: Responsive.wp(4),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage(widget.idol.profileImage),
                ),
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.idol.stageName,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '초대하는 중...', // or "Live now"
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('LIVE',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
                SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.remove_red_eye, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text('$_viewerCount',
                          style: TextStyle(color: Colors.white, fontSize: 12)),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
              ],
            ),
          ),

          // 4. Live Comments Area
          Positioned(
            left: Responsive.wp(4),
            bottom: Responsive.hp(12),
            width: Responsive.wp(70),
            height: Responsive.hp(30),
            child: ShaderMask(
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.center,
                  colors: [Colors.transparent, Colors.white],
                  stops: [0.0, 0.3],
                ).createShader(bounds);
              },
              blendMode: BlendMode.dstIn,
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.zero,
                itemCount: _comments.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.grey[800],
                          child:
                              Icon(Icons.person, size: 14, color: Colors.white),
                        ),
                        SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'User ${index * 324}',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              _comments[index],
                              style:
                                  TextStyle(color: Colors.white, fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          // 5. Floating Hearts Animation Layer
          Positioned(
            right: 0,
            bottom: Responsive.hp(15),
            width: 100,
            height: 400,
            child: IgnorePointer(
              child: Stack(
                children: _hearts.map((heart) {
                  return AnimatedBuilder(
                    animation: heart.animationController,
                    builder: (context, child) {
                      final value = heart.animationController.value;
                      final opacity = value < 0.8 ? 1.0 : (1.0 - value) * 5;
                      // Simple straight up movement with fade
                      return Positioned(
                        bottom: value * 300,
                        right: 20 + (math.sin(value * 10) * 20), // Wiggle
                        child: Opacity(
                          opacity: opacity.clamp(0.0, 1.0),
                          child: Icon(Icons.favorite,
                              color: heart.color, size: 30),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
          ),

          // 6. Bottom Input Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                  Responsive.wp(4), 10, Responsive.wp(4), Responsive.hp(4)),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 45,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: TextField(
                        controller: _commentController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '코멘트 달기...',
                          hintStyle: TextStyle(color: Colors.white70),
                        ),
                        onSubmitted: (value) {
                          if (value.isNotEmpty) {
                            setState(() {
                              _comments.add(value);
                              _commentController.clear();
                              _scrollController.animateTo(
                                _scrollController.position.maxScrollExtent + 50,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                              );
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  IconButton(
                    icon: Icon(Icons.card_giftcard,
                        color: Colors.white, size: 28),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(Icons.share, color: Colors.white, size: 28),
                    onPressed: () {},
                  ),
                  GestureDetector(
                    onTap: _addHeart,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.8),
                        shape: BoxShape.circle,
                      ),
                      child:
                          Icon(Icons.favorite, color: Colors.white, size: 24),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FloatingHeart {
  final String id;
  final AnimationController animationController;
  final Color color;

  FloatingHeart(
      {required this.id,
      required this.animationController,
      required this.color});
}

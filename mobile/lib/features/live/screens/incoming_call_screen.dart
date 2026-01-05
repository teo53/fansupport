import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/models/idol_model.dart';
import 'live_screen.dart';

class IncomingCallScreen extends StatelessWidget {
  final IdolModel idol;

  const IncomingCallScreen({super.key, required this.idol});

  void _acceptCall(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LiveScreen(idol: idol)),
    );
  }

  void _declineCall(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background (Blurred or Darkened)
          CachedNetworkImage(
            imageUrl: idol.profileImage,
            fit: BoxFit.cover,
            color: Colors.black.withValues(alpha: 0.8),
            colorBlendMode: BlendMode.darken,
          ),

          // Content
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Idol Info
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage:
                        CachedNetworkImageProvider(idol.profileImage),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  idol.stageName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'bubble LIVE',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '팬들과 일상을 공유하고 있어요!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),

                const Spacer(flex: 3),

                // Buttons
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCallButton(
                        context,
                        icon: Icons.call_end,
                        color: Colors.red,
                        label: '거절',
                        onTap: () => _declineCall(context),
                      ),
                      const SizedBox(width: 40),
                      _buildCallButton(
                        context,
                        icon: Icons.videocam,
                        color: Colors.green,
                        label: '입장',
                        onTap: () => _acceptCall(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallButton(BuildContext context,
      {required IconData icon,
      required Color color,
      required String label,
      required VoidCallback onTap}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 15,
                    spreadRadius: 2),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ],
    );
  }
}

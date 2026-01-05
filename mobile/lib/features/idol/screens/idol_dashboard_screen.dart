import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/models/idol_model.dart';
import '../../live/screens/live_screen.dart';

class IdolDashboardScreen extends StatelessWidget {
  final IdolModel idol;

  const IdolDashboardScreen({super.key, required this.idol});

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
                backgroundImage: NetworkImage(idol.profileImage), radius: 16),
            const SizedBox(width: 8),
            Text(idol.stageName,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black)),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
              icon: const Icon(Icons.menu, color: Colors.black),
              onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            _buildStatusCard(),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context,
                    label: 'Go Live',
                    icon: Icons.videocam_rounded,
                    color: Colors.redAccent,
                    onTap: () {
                      // Navigate to Live Screen (Broadcaster Mode Mock)
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => LiveScreen(idol: idol)),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionButton(
                    context,
                    label: 'Broadcast',
                    icon: Icons.send_rounded,
                    color: AppColors.primary,
                    onTap: () {
                      context.push('/message/create', extra: idol);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildExchangeButton(context),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Recent Activity / Fan Feed
            const Text(
              'Recent Fan Activity',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildFanActivityItem('user_99', 'Sent a Short Cake 🍰', '2m ago'),
            _buildFanActivityItem(
                'fan_club_prez', 'Sent a Cake Tower 🏰', '5m ago'),
            _buildFanActivityItem(
                'lovelive', 'Replied to your story', '12m ago'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        children: [
          const Text('Total Subscribers',
              style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          const Text('12,405',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatusItem('Live Views', '1.2M'),
              Container(width: 1, height: 24, color: Colors.white24),
              _buildStatusItem('Gifts', '8,450 🎁'),
              Container(width: 1, height: 24, color: Colors.white24),
              _buildStatusItem('Revenue', '₩24M'),
            ],
          ),
        ],
      ),
    );
  }

  // Helper method for Exchange Button
  Widget _buildExchangeButton(BuildContext context) {
    return _buildActionButton(
      context,
      label: '환전 신청',
      icon: Icons.currency_exchange,
      color: Colors.green,
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('환전 신청'),
            content: const Text('현재 환전 가능한 금액은 24,000,000원입니다.\n신청하시겠습니까?'),
            actions: [
              TextButton(
                  onPressed: () => context.pop(), child: const Text('취소')),
              TextButton(
                onPressed: () {
                  context.pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('환전 신청이 완료되었습니다.')),
                  );
                },
                child: const Text('신청', style: TextStyle(color: Colors.green)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusItem(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context,
      {required String label,
      required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120, // Square-ish
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 12),
            Text(label,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildFanActivityItem(String user, String action, String time) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12)),
      ),
      child: Row(
        children: [
          CircleAvatar(
              backgroundColor: Colors.grey[200],
              child: Text(user[0].toUpperCase(),
                  style: const TextStyle(color: Colors.black54))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    text: user,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 14),
                    children: [
                      TextSpan(
                          text: ' $action',
                          style:
                              const TextStyle(fontWeight: FontWeight.normal)),
                    ],
                  ),
                ),
                Text(time,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

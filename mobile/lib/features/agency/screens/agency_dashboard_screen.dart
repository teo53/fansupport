import 'package:flutter/material.dart';
// Assuming fl_chart is available, or use simple Containers if not
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/models/idol_model.dart';
import '../../../core/mock/mock_data.dart'; // Ensure MockData is accessible

class AgencyDashboardScreen extends StatelessWidget {
  const AgencyDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final idols = MockData.idolModels;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Agency Dashboard',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
              icon: const Icon(Icons.notifications_none, color: Colors.black),
              onPressed: () => _showNotifications(context)),
          IconButton(
              icon: const Icon(Icons.settings, color: Colors.black),
              onPressed: () => _showSettings(context)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overview',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: _buildStatCard('Total Revenue', '₩ 1.2B',
                        Icons.attach_money, Colors.green)),
                const SizedBox(width: 12),
                Expanded(
                    child: _buildStatCard('Active Idols', '${idols.length}',
                        Icons.star, Colors.purple)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _buildStatCard(
                        'Total Fans', '2.5M', Icons.people, Colors.blue)),
                const SizedBox(width: 12),
                Expanded(
                    child: _buildStatCard(
                        'Growth', '+15%', Icons.trending_up, Colors.orange)),
              ],
            ),
            const SizedBox(height: 32),

            // Managed Idols Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Managed Idols',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () => _showAddIdolDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add New'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...idols.map((idol) => _buildIdolCard(context, idol)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(value,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          const SizedBox(height: 4),
          Text(title,
              style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildIdolCard(BuildContext context, IdolModel idol) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(idol.profileImage),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(idol.stageName,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                Text(
                    '${idol.groupName ?? 'Solo'} • ${idol.supporterCount} Fans',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.grey),
            onPressed: () => _showEditIdolSheet(context, idol),
          ),
          IconButton(
            icon:
                const Icon(Icons.analytics_outlined, color: AppColors.primary),
            onPressed: () => _showIdolAnalytics(context, idol),
          ),
        ],
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('알림', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.attach_money, color: Colors.white, size: 20)),
              title: const Text('새로운 후원금 입금'),
              subtitle: const Text('하늘별님께 ₩50,000 후원이 도착했습니다'),
              trailing: const Text('방금', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ),
            ListTile(
              leading: const CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.person_add, color: Colors.white, size: 20)),
              title: const Text('신규 구독자'),
              subtitle: const Text('루나님의 프리미엄 구독자가 5명 증가했습니다'),
              trailing: const Text('1시간 전', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('설정', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(leading: const Icon(Icons.business), title: const Text('소속사 정보 관리'), onTap: () => Navigator.pop(context)),
            ListTile(leading: const Icon(Icons.payment), title: const Text('정산 계좌 관리'), onTap: () => Navigator.pop(context)),
            ListTile(leading: const Icon(Icons.notifications), title: const Text('알림 설정'), onTap: () => Navigator.pop(context)),
            ListTile(leading: const Icon(Icons.logout, color: Colors.red), title: const Text('로그아웃', style: TextStyle(color: Colors.red)), onTap: () => Navigator.pop(context)),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showAddIdolDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('새 아이돌 등록'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(decoration: const InputDecoration(labelText: '활동명', hintText: '예: 하늘별')),
            const SizedBox(height: 12),
            TextField(decoration: const InputDecoration(labelText: '본명 (선택)')),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: '카테고리'),
              items: const [
                DropdownMenuItem(value: 'idol', child: Text('지하 아이돌')),
                DropdownMenuItem(value: 'maid', child: Text('메이드 카페')),
                DropdownMenuItem(value: 'cosplay', child: Text('코스플레이어')),
              ],
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('아이돌이 등록되었습니다!')));
            },
            child: const Text('등록'),
          ),
        ],
      ),
    );
  }

  void _showEditIdolSheet(BuildContext context, IdolModel idol) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${idol.stageName} 관리', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(leading: const Icon(Icons.person), title: const Text('프로필 수정'), onTap: () => Navigator.pop(context)),
            ListTile(leading: const Icon(Icons.photo_library), title: const Text('갤러리 관리'), onTap: () => Navigator.pop(context)),
            ListTile(leading: const Icon(Icons.schedule), title: const Text('스케줄 관리'), onTap: () => Navigator.pop(context)),
            ListTile(leading: const Icon(Icons.monetization_on), title: const Text('서비스 가격 설정'), onTap: () => Navigator.pop(context)),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showIdolAnalytics(BuildContext context, IdolModel idol) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            children: [
              Row(
                children: [
                  CircleAvatar(radius: 24, backgroundImage: NetworkImage(idol.profileImage)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(idol.stageName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('이번 달 분석 리포트', style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 24),
              _buildAnalyticsItem('총 수익', '₩${(idol.totalSupport / 10000).toStringAsFixed(0)}만원', Colors.green, Icons.attach_money),
              _buildAnalyticsItem('구독자', '${idol.subscriberCount}명', Colors.blue, Icons.people),
              _buildAnalyticsItem('후원자', '${idol.supporterCount}명', Colors.purple, Icons.favorite),
              _buildAnalyticsItem('랭킹', '#${idol.ranking}', Colors.orange, Icons.leaderboard),
              const SizedBox(height: 24),
              const Text('최근 30일 추이', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(child: Text('📈 차트 영역', style: TextStyle(color: Colors.grey))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticsItem(String label, String value, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 15))),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

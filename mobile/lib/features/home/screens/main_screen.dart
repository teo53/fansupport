import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/design_system.dart';

/// 메인 화면 - 전략적 하단 네비게이션 구조
///
/// 네비게이션 전략:
/// 1. 홈 - 내 기여도 + 개인화된 대시보드
/// 2. 스케줄 - 초기 유저 유입 훅 (일상적 유틸리티)
/// 3. 펀딩 - 핵심 수익 모델 (가운데 강조)
/// 4. 아이돌 - 콘텐츠 탐색
/// 5. 마이 - 기여도 과시 + 설정
///
/// 커뮤니티는 유저 수 N명 이상일 때 조건부 활성화 (설정에서 접근)
class MainScreen extends StatefulWidget {
  final Widget child;

  const MainScreen({super.key, required this.child});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    // 스케줄 탭 (초기 유저 훅 - 2번째)
    if (location.startsWith('/schedule')) {
      return 1;
    }
    // 펀딩 탭 (가운데 강조 - 3번째)
    if (location.startsWith('/campaigns')) {
      return 2;
    }
    // 아이돌 탭 (4번째)
    if (location.startsWith('/idols') || location.startsWith('/ranking')) {
      return 3;
    }
    // 마이 탭 (5번째)
    if (location.startsWith('/profile') || location.startsWith('/wallet')) {
      return 4;
    }
    // 홈 (1번째)
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    HapticFeedback.selectionClick();
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/schedule');
        break;
      case 2:
        context.go('/campaigns');
        break;
      case 3:
        context.go('/idols');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: widget.child,
      extendBody: true,
      bottomNavigationBar: _buildBottomNavBar(context, selectedIndex),
    );
  }

  Widget _buildBottomNavBar(BuildContext context, int selectedIndex) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: AppColors.bottomNavShadow(),
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              // 1. 홈 - 내 기여도 대시보드
              _buildNavItem(
                context: context,
                index: 0,
                selectedIndex: selectedIndex,
                icon: Icons.home_outlined,
                selectedIcon: Icons.home_rounded,
                label: '홈',
              ),
              // 2. 스케줄 - 초기 유저 훅 (매일 사용하는 유틸리티)
              _buildNavItem(
                context: context,
                index: 1,
                selectedIndex: selectedIndex,
                icon: Icons.calendar_today_outlined,
                selectedIcon: Icons.calendar_today_rounded,
                label: '스케줄',
              ),
              // 3. 펀딩 - 가운데 강조 (핵심 수익)
              _buildCenterNavItem(context, selectedIndex),
              // 4. 아이돌 - 콘텐츠 탐색
              _buildNavItem(
                context: context,
                index: 3,
                selectedIndex: selectedIndex,
                icon: Icons.favorite_outline_rounded,
                selectedIcon: Icons.favorite_rounded,
                label: '아이돌',
              ),
              // 5. 마이 - 기여도 과시 + 설정
              _buildNavItem(
                context: context,
                index: 4,
                selectedIndex: selectedIndex,
                icon: Icons.person_outline_rounded,
                selectedIcon: Icons.person_rounded,
                label: '마이',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required int selectedIndex,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
  }) {
    final isSelected = index == selectedIndex;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(context, index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(
                  horizontal: isSelected ? 12 : 0,
                  vertical: isSelected ? 4 : 0,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  isSelected ? selectedIcon : icon,
                  size: 22,
                  color: isSelected ? AppColors.primary : AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.primary : AppColors.textTertiary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterNavItem(BuildContext context, int selectedIndex) {
    final isSelected = selectedIndex == 2;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(context, 2),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? AppColors.primaryGradient
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary.withValues(alpha: 0.85),
                          AppColors.neonPurple.withValues(alpha: 0.85),
                        ],
                      ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: isSelected ? 0.35 : 0.2),
                    blurRadius: isSelected ? 12 : 8,
                    offset: const Offset(0, 3),
                    spreadRadius: isSelected ? 0 : -1,
                  ),
                ],
              ),
              child: Icon(
                Icons.rocket_launch_rounded,
                size: 22,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '펀딩',
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

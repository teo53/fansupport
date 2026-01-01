import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class MainScreen extends StatefulWidget {
  final Widget child;

  const MainScreen({super.key, required this.child});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/idols') || location.startsWith('/ranking')) {
      return 1;
    }
    if (location.startsWith('/campaigns')) {
      return 2;
    }
    if (location.startsWith('/community')) {
      return 3;
    }
    if (location.startsWith('/profile') || location.startsWith('/wallet')) {
      return 4;
    }
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    HapticFeedback.selectionClick();
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/idols');
        break;
      case 2:
        context.go('/campaigns');
        break;
      case 3:
        context.go('/community');
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
              _buildNavItem(
                context: context,
                index: 0,
                selectedIndex: selectedIndex,
                icon: Icons.home_outlined,
                selectedIcon: Icons.home_rounded,
                label: '홈',
              ),
              _buildNavItem(
                context: context,
                index: 1,
                selectedIndex: selectedIndex,
                icon: Icons.favorite_outline_rounded,
                selectedIcon: Icons.favorite_rounded,
                label: '아이돌',
              ),
              _buildCenterNavItem(context, selectedIndex),
              _buildNavItem(
                context: context,
                index: 3,
                selectedIndex: selectedIndex,
                icon: Icons.chat_bubble_outline_rounded,
                selectedIcon: Icons.chat_bubble_rounded,
                label: '커뮤니티',
              ),
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

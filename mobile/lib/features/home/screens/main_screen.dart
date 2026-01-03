import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/utils/responsive.dart';

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
    if (location.startsWith('/bubble') || location.startsWith('/posts')) {
      return 2;
    }
    if (location.startsWith('/community')) {
      return 3;
    }
    if (location.startsWith('/profile') ||
        location.startsWith('/wallet') ||
        location.startsWith('/agency') ||
        location.startsWith('/idol/crm')) {
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
        // Bubble/Messages - the core feature for fan communication
        context.go('/bubble');
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
    Responsive.init(context);
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
        border: Border(
          top: BorderSide(
            color: AppColors.border.withOpacity(0.3),
            width: 1,
          ),
        ),
        boxShadow: Shadows.bottomNav,
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 88,
          padding: EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
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
          duration: AnimDurations.normal,
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(vertical: Spacing.xs + 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: AnimDurations.normal,
                padding: EdgeInsets.symmetric(
                  horizontal: isSelected ? Spacing.base : 0,
                  vertical: isSelected ? Spacing.xs + 2 : 0,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(Radii.xl),
                ),
                child: Icon(
                  isSelected ? selectedIcon : icon,
                  size: IconSizes.md,
                  color:
                      isSelected ? AppColors.primary : AppColors.textTertiary,
                ),
              ),
              SizedBox(height: Spacing.xs),
              AnimatedDefaultTextStyle(
                duration: AnimDurations.normal,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color:
                      isSelected ? AppColors.primary : AppColors.textTertiary,
                  fontFamily: TypographyTokens.fontFamily,
                ),
                child: Text(label),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? AppColors.primaryGradient
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary400,
                          AppColors.primary700,
                        ],
                      ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary
                        .withOpacity(isSelected ? 0.4 : 0.25),
                    blurRadius: isSelected ? 16 : 12,
                    offset: const Offset(0, 4),
                    spreadRadius: isSelected ? 0 : -2,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Shimmer effect
                  if (isSelected)
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.25),
                            Colors.transparent,
                            Colors.white.withOpacity(0.1),
                          ],
                        ),
                      ),
                    ),
                  // Bubble icon - core communication feature
                  Icon(
                    Icons.chat_bubble_rounded,
                    size: IconSizes.lg,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            SizedBox(height: Spacing.xs - 2),
            Text(
              '버블',
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontFamily: TypographyTokens.fontFamily,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

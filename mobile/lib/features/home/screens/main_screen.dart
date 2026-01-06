import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/design_system.dart';

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
        color: PipoColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: PipoSpacing.sm),
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
                label: '크리에이터',
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
          duration: PipoAnimations.fast,
          curve: PipoAnimations.standard,
          padding: const EdgeInsets.symmetric(vertical: PipoSpacing.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: PipoAnimations.fast,
                padding: EdgeInsets.symmetric(
                  horizontal: isSelected ? 14 : 0,
                  vertical: isSelected ? 6 : 0,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? PipoColors.primarySoft
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(PipoRadius.lg),
                ),
                child: Icon(
                  isSelected ? selectedIcon : icon,
                  size: 24,
                  color: isSelected
                      ? PipoColors.primary
                      : PipoColors.textTertiary,
                ),
              ),
              const SizedBox(height: PipoSpacing.xs),
              AnimatedDefaultTextStyle(
                duration: PipoAnimations.fast,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? PipoColors.primary
                      : PipoColors.textTertiary,
                  fontFamily: PipoTypography.fontFamily,
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
            AnimatedContainer(
              duration: PipoAnimations.fast,
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: PipoColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: isSelected
                    ? PipoShadows.primaryGlow
                    : [
                        BoxShadow(
                          color: PipoColors.primary.withOpacity(0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Shimmer effect when selected
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
                  const Icon(
                    Icons.rocket_launch_rounded,
                    size: 24,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            const SizedBox(height: PipoSpacing.xs),
            Text(
              '펀딩',
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected
                    ? PipoColors.primary
                    : PipoColors.textSecondary,
                fontFamily: PipoTypography.fontFamily,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

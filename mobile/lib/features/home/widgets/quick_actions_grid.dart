import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/mock/mock_data.dart';
import '../../chat/screens/chat_screen.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickAction(
        icon: Icons.star_rounded,
        label: '멤버십',
        color: PipoColors.purple,
        onTap: () => context.go('/membership'),
      ),
      _QuickAction(
        icon: Icons.chat_bubble_rounded,
        label: 'Bubble',
        color: PipoColors.primary,
        onTap: () {
          final firstIdol = MockData.idolModels.first;
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ChatScreen(idol: firstIdol),
            ),
          );
        },
      ),
      _QuickAction(
        icon: Icons.feed_rounded,
        label: '피드',
        color: PipoColors.teal,
        onTap: () => context.go('/community'),
      ),
      _QuickAction(
        icon: Icons.calendar_today_rounded,
        label: '스케줄',
        color: PipoColors.orange,
        onTap: () => context.go('/schedule'),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        PipoSpacing.xl,
        PipoSpacing.xxl,
        PipoSpacing.xl,
        0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: actions.map((action) {
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              action.onTap();
            },
            child: SizedBox(
              width: 70,
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: action.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(PipoRadius.lg),
                    ),
                    child: Icon(
                      action.icon,
                      color: action.color,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: PipoSpacing.sm),
                  Text(
                    action.label,
                    style: PipoTypography.labelSmall.copyWith(
                      color: PipoColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

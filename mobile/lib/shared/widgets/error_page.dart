import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/custom_button.dart';

/// 🚫 404 Error Page - Bubble Style
class ErrorPage extends StatelessWidget {
  final String? errorMessage;

  const ErrorPage({
    super.key,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Error Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline_rounded,
                    size: 60,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 32),

                // Error Code
                Text(
                  '404',
                  style: TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                    letterSpacing: -2,
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  '페이지를 찾을 수 없습니다',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Description
                Text(
                  errorMessage ?? '요청하신 페이지가 존재하지 않거나\n이동되었을 수 있습니다.',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Back to Home Button
                CustomButton(
                  onPressed: () => context.go('/'),
                  text: '홈으로 돌아가기',
                  prefixIcon: Icons.home_rounded,
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

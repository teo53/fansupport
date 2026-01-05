import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';

/// 🔗 소셜 링크 섹션
class SocialLinksSection extends StatelessWidget {
  final String? twitterUrl;
  final String? instagramUrl;
  final String? youtubeUrl;
  final String? tiktokUrl;
  final String? fanCafeUrl;

  const SocialLinksSection({
    super.key,
    this.twitterUrl,
    this.instagramUrl,
    this.youtubeUrl,
    this.tiktokUrl,
    this.fanCafeUrl,
  });

  bool get hasAnyLinks =>
      twitterUrl != null ||
      instagramUrl != null ||
      youtubeUrl != null ||
      tiktokUrl != null ||
      fanCafeUrl != null;

  @override
  Widget build(BuildContext context) {
    if (!hasAnyLinks) return const SizedBox.shrink();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              const Text(
                '🔗',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              const Text(
                '소셜 미디어',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 링크 버튼들
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              if (twitterUrl != null)
                _buildSocialButton(
                  icon: '𝕏',
                  label: 'Twitter',
                  url: twitterUrl!,
                  color: const Color(0xFF000000),
                  backgroundColor: const Color(0xFFF5F5F5),
                ),
              if (instagramUrl != null)
                _buildSocialButton(
                  icon: '📷',
                  label: 'Instagram',
                  url: instagramUrl!,
                  color: const Color(0xFFE1306C),
                  backgroundColor: const Color(0xFFFCE4EC),
                ),
              if (youtubeUrl != null)
                _buildSocialButton(
                  icon: '▶️',
                  label: 'YouTube',
                  url: youtubeUrl!,
                  color: const Color(0xFFFF0000),
                  backgroundColor: const Color(0xFFFFEBEE),
                ),
              if (tiktokUrl != null)
                _buildSocialButton(
                  icon: '🎵',
                  label: 'TikTok',
                  url: tiktokUrl!,
                  color: const Color(0xFF000000),
                  backgroundColor: const Color(0xFFF5F5F5),
                ),
              if (fanCafeUrl != null)
                _buildSocialButton(
                  icon: '☕',
                  label: '팬카페',
                  url: fanCafeUrl!,
                  color: const Color(0xFF03C75A),
                  backgroundColor: const Color(0xFFE8F5E9),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required String icon,
    required String label,
    required String url,
    required Color color,
    required Color backgroundColor,
  }) {
    return InkWell(
      onTap: () => _launchUrl(url),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.open_in_new,
              size: 14,
              color: color.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

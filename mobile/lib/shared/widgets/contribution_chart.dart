import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/design_system.dart';

/// 후원자 데이터 모델
class ContributorData {
  final String id;
  final String name;
  final String profileImage;
  final double percentage;
  final int rank;
  final bool isCurrentUser;

  const ContributorData({
    required this.id,
    required this.name,
    required this.profileImage,
    required this.percentage,
    required this.rank,
    this.isCurrentUser = false,
  });
}

/// 후원 비율 원형 차트
/// 핵심 UX: 현재 사용자의 기여도를 과시할 수 있도록 강조 표시
class ContributionChart extends StatefulWidget {
  final List<ContributorData> contributors;
  final double size;
  final double strokeWidth;
  final bool showLegend;
  final bool animated;
  final VoidCallback? onTap;

  const ContributionChart({
    super.key,
    required this.contributors,
    this.size = 200,
    this.strokeWidth = 24,
    this.showLegend = true,
    this.animated = true,
    this.onTap,
  });

  @override
  State<ContributionChart> createState() => _ContributionChartState();
}

class _ContributionChartState extends State<ContributionChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int? _selectedIndex;

  // 차트 색상 팔레트 (상위 순위일수록 더 눈에 띄는 색상)
  static const List<Color> _chartColors = [
    Color(0xFF5046E5), // Primary - 1위
    Color(0xFFFF6B9D), // Secondary - 2위
    Color(0xFF8B5CF6), // Purple - 3위
    Color(0xFF06B6D4), // Cyan - 4위
    Color(0xFFF59E0B), // Amber - 5위
    Color(0xFF10B981), // Emerald - 6위
    Color(0xFFEC4899), // Pink - 7위
    Color(0xFF6366F1), // Indigo - 8위
    Color(0xFF94A3B8), // Gray - 나머지
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    if (widget.animated) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getColorForIndex(int index) {
    if (index < _chartColors.length - 1) {
      return _chartColors[index];
    }
    return _chartColors.last;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: widget.onTap,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return CustomPaint(
                  painter: _ContributionChartPainter(
                    contributors: widget.contributors,
                    progress: _animation.value,
                    strokeWidth: widget.strokeWidth,
                    selectedIndex: _selectedIndex,
                    colors: List.generate(
                      widget.contributors.length,
                      (i) => _getColorForIndex(i),
                    ),
                  ),
                  child: Center(
                    child: _buildCenterContent(),
                  ),
                );
              },
            ),
          ),
        ),
        if (widget.showLegend) ...[
          const SizedBox(height: DS.space5),
          _buildLegend(),
        ],
      ],
    );
  }

  Widget _buildCenterContent() {
    final currentUser = widget.contributors.where((c) => c.isCurrentUser).firstOrNull;

    if (currentUser == null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '총 ${widget.contributors.length}명',
            style: DS.textSm(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 2),
          Text(
            '서포터',
            style: DS.textBase(weight: DS.weightSemibold),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '내 순위',
            style: DS.textXs(
              color: AppColors.primary,
              weight: DS.weightMedium,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${currentUser.rank}위',
          style: DS.text3xl(
            color: AppColors.primary,
            weight: DS.weightExtrabold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${currentUser.percentage.toStringAsFixed(1)}%',
          style: DS.textLg(
            color: AppColors.textSecondary,
            weight: DS.weightSemibold,
          ),
        ),
      ],
    );
  }

  Widget _buildLegend() {
    // 상위 5명만 표시
    final topContributors = widget.contributors.take(5).toList();

    return Wrap(
      spacing: DS.space3,
      runSpacing: DS.space2,
      alignment: WrapAlignment.center,
      children: topContributors.asMap().entries.map((entry) {
        final index = entry.key;
        final contributor = entry.value;
        final color = _getColorForIndex(index);
        final isSelected = _selectedIndex == index;

        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() {
              _selectedIndex = isSelected ? null : index;
            });
          },
          child: AnimatedContainer(
            duration: DS.durationFast,
            padding: EdgeInsets.symmetric(
              horizontal: isSelected ? DS.space3 : DS.space2,
              vertical: DS.space1,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withValues(alpha: 0.15)
                  : (contributor.isCurrentUser
                      ? AppColors.primarySoft
                      : Colors.transparent),
              borderRadius: DS.borderRadiusSm,
              border: contributor.isCurrentUser
                  ? Border.all(color: AppColors.primary, width: 1.5)
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  contributor.isCurrentUser ? '나' : contributor.name,
                  style: DS.textSm(
                    weight: contributor.isCurrentUser
                        ? DS.weightBold
                        : DS.weightMedium,
                    color: contributor.isCurrentUser
                        ? AppColors.primary
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${contributor.percentage.toStringAsFixed(1)}%',
                  style: DS.textXs(
                    color: AppColors.textSecondary,
                    weight: DS.weightMedium,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ContributionChartPainter extends CustomPainter {
  final List<ContributorData> contributors;
  final double progress;
  final double strokeWidth;
  final int? selectedIndex;
  final List<Color> colors;

  _ContributionChartPainter({
    required this.contributors,
    required this.progress,
    required this.strokeWidth,
    required this.selectedIndex,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // 배경 원
    final bgPaint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // 시작 각도 (-90도 = 12시 방향)
    double startAngle = -math.pi / 2;

    for (int i = 0; i < contributors.length; i++) {
      final contributor = contributors[i];
      final sweepAngle = (contributor.percentage / 100) * 2 * math.pi * progress;

      final isSelected = selectedIndex == i;
      final isCurrentUser = contributor.isCurrentUser;

      // 현재 사용자 또는 선택된 항목 강조
      final adjustedStrokeWidth = isSelected
          ? strokeWidth + 6
          : (isCurrentUser ? strokeWidth + 3 : strokeWidth);

      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = adjustedStrokeWidth
        ..strokeCap = StrokeCap.butt;

      // 선택된 항목에 그림자 효과
      if (isSelected || isCurrentUser) {
        final shadowPaint = Paint()
          ..color = colors[i].withValues(alpha: 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = adjustedStrokeWidth + 8
          ..strokeCap = StrokeCap.butt
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweepAngle,
          false,
          shadowPaint,
        );
      }

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _ContributionChartPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.contributors != contributors;
  }
}

/// 후원자 랭킹 리스트 카드
class ContributorRankingCard extends StatelessWidget {
  final ContributorData contributor;
  final Color color;
  final VoidCallback? onTap;

  const ContributorRankingCard({
    super.key,
    required this.contributor,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrentUser = contributor.isCurrentUser;
    final isTopThree = contributor.rank <= 3;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.all(DS.space4),
        decoration: BoxDecoration(
          color: isCurrentUser ? AppColors.primarySoft : Colors.white,
          borderRadius: DS.borderRadiusMd,
          border: Border.all(
            color: isCurrentUser ? AppColors.primary : AppColors.border,
            width: isCurrentUser ? 2 : 1,
          ),
          boxShadow: isCurrentUser ? [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ] : null,
        ),
        child: Row(
          children: [
            // 순위 배지
            _buildRankBadge(isTopThree),
            const SizedBox(width: DS.space3),

            // 프로필 이미지
            Container(
              width: DS.avatarMd,
              height: DS.avatarMd,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: color,
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: Image.network(
                  contributor.profileImage,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: color.withValues(alpha: 0.2),
                    child: Icon(
                      Icons.person,
                      color: color,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: DS.space3),

            // 이름
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        isCurrentUser ? '나 (${contributor.name})' : contributor.name,
                        style: DS.textBase(
                          weight: isCurrentUser ? DS.weightBold : DS.weightSemibold,
                          color: isCurrentUser ? AppColors.primary : AppColors.textPrimary,
                        ),
                      ),
                      if (isCurrentUser) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'ME',
                            style: DS.textXs(
                              color: Colors.white,
                              weight: DS.weightBold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (isTopThree)
                    Text(
                      _getRankTitle(contributor.rank),
                      style: DS.textXs(
                        color: color,
                        weight: DS.weightMedium,
                      ),
                    ),
                ],
              ),
            ),

            // 기여도 퍼센트
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DS.space3,
                vertical: DS.space2,
              ),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: DS.borderRadiusSm,
              ),
              child: Text(
                '${contributor.percentage.toStringAsFixed(1)}%',
                style: DS.textBase(
                  color: color,
                  weight: DS.weightBold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankBadge(bool isTopThree) {
    if (isTopThree) {
      final icons = [
        Icons.emoji_events, // 1위 - 트로피
        Icons.workspace_premium, // 2위 - 프리미엄
        Icons.military_tech, // 3위 - 메달
      ];
      final colors = [
        const Color(0xFFFFD700), // Gold
        const Color(0xFFC0C0C0), // Silver
        const Color(0xFFCD7F32), // Bronze
      ];

      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors[contributor.rank - 1],
              colors[contributor.rank - 1].withValues(alpha: 0.7),
            ],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: colors[contributor.rank - 1].withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icons[contributor.rank - 1],
          size: 18,
          color: Colors.white,
        ),
      );
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.backgroundAlt,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Text(
          '${contributor.rank}',
          style: DS.textSm(
            weight: DS.weightBold,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  String _getRankTitle(int rank) {
    switch (rank) {
      case 1:
        return '🏆 최고 서포터';
      case 2:
        return '⭐ 프리미엄 서포터';
      case 3:
        return '💫 골드 서포터';
      default:
        return '';
    }
  }
}

/// 전체 후원자 통계 섹션
class ContributionStatsSection extends StatelessWidget {
  final List<ContributorData> contributors;
  final String? idolName;

  const ContributionStatsSection({
    super.key,
    required this.contributors,
    this.idolName,
  });

  @override
  Widget build(BuildContext context) {
    final currentUser = contributors.where((c) => c.isCurrentUser).firstOrNull;

    return Container(
      padding: const EdgeInsets.all(DS.space5),
      decoration: DS.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: DS.borderRadiusSm,
                ),
                child: const Icon(
                  Icons.pie_chart_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: DS.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '서포터 기여도',
                      style: DS.heading4,
                    ),
                    if (idolName != null)
                      Text(
                        '$idolName의 서포터들',
                        style: DS.textSm(color: AppColors.textSecondary),
                      ),
                  ],
                ),
              ),
              if (currentUser != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DS.space3,
                    vertical: DS.space1,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: DS.borderRadiusSm,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.trending_up_rounded,
                        size: 14,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${currentUser.rank}위',
                        style: DS.textSm(
                          color: AppColors.success,
                          weight: DS.weightBold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: DS.space6),

          // 차트
          Center(
            child: ContributionChart(
              contributors: contributors,
              size: 180,
              strokeWidth: 22,
            ),
          ),

          const SizedBox(height: DS.space6),

          // 상위 랭커 리스트
          ...contributors.take(5).map((contributor) {
            final index = contributors.indexOf(contributor);
            return Padding(
              padding: const EdgeInsets.only(bottom: DS.space3),
              child: ContributorRankingCard(
                contributor: contributor,
                color: _getColorForIndex(index),
              ),
            );
          }),

          // 더보기 버튼
          if (contributors.length > 5)
            Center(
              child: TextButton(
                onPressed: () {
                  // TODO: 전체 랭킹 페이지로 이동
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '전체 ${contributors.length}명 보기',
                      style: DS.textSm(
                        color: AppColors.primary,
                        weight: DS.weightMedium,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getColorForIndex(int index) {
    const colors = [
      Color(0xFF5046E5),
      Color(0xFFFF6B9D),
      Color(0xFF8B5CF6),
      Color(0xFF06B6D4),
      Color(0xFFF59E0B),
    ];
    return index < colors.length ? colors[index] : const Color(0xFF94A3B8);
  }
}

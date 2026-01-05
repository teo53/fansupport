import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/models/photocard_model.dart';
import '../../../shared/widgets/glass_card.dart';

/// Mock data for photocards - would come from API in production
final List<PhotocardModel> mockPhotocards = [
  PhotocardModel(
    id: 'pc-001',
    idolId: 'idol-001',
    idolName: '하늘별',
    idolGroup: 'Solo',
    imageUrl: 'https://i.pravatar.cc/400?img=5',
    backImageUrl: 'https://picsum.photos/seed/back1/400/600',
    issuedAt: DateTime(2024, 12, 25),
    type: PhotocardType.support,
    rarity: PhotocardRarity.rare,
    serialNumber: 42,
    totalIssued: 1000,
    message: '항상 응원해주셔서 감사해요! 💕',
    isHolographic: true,
  ),
  PhotocardModel(
    id: 'pc-002',
    idolId: 'idol-003',
    idolName: '루나',
    idolGroup: 'MoonLight',
    imageUrl: 'https://i.pravatar.cc/400?img=10',
    issuedAt: DateTime(2024, 12, 20),
    type: PhotocardType.subscription,
    rarity: PhotocardRarity.superRare,
    serialNumber: 15,
    totalIssued: 500,
    message: '달빛과 함께하는 특별한 순간 🌙',
    isHolographic: true,
  ),
  PhotocardModel(
    id: 'pc-003',
    idolId: 'idol-002',
    idolName: '미유',
    idolGroup: 'StarLight Cafe',
    imageUrl: 'https://i.pravatar.cc/400?img=9',
    issuedAt: DateTime(2024, 12, 15),
    type: PhotocardType.event,
    rarity: PhotocardRarity.legendary,
    serialNumber: 7,
    totalIssued: 100,
    eventName: '크리스마스 스페셜',
    isHolographic: true,
  ),
  PhotocardModel(
    id: 'pc-004',
    idolId: 'idol-001',
    idolName: '하늘별',
    idolGroup: 'Solo',
    imageUrl: 'https://i.pravatar.cc/400?img=32',
    issuedAt: DateTime(2024, 11, 10),
    type: PhotocardType.firstMeet,
    rarity: PhotocardRarity.common,
    serialNumber: 234,
    totalIssued: 2000,
  ),
  PhotocardModel(
    id: 'pc-005',
    idolId: 'idol-004',
    idolName: '사쿠라',
    idolGroup: '',
    imageUrl: 'https://i.pravatar.cc/400?img=20',
    issuedAt: DateTime(2024, 10, 5),
    type: PhotocardType.support,
    rarity: PhotocardRarity.rare,
    serialNumber: 89,
    totalIssued: 800,
    isHolographic: true,
  ),
];

class PhotocardScreen extends ConsumerStatefulWidget {
  const PhotocardScreen({super.key});

  @override
  ConsumerState<PhotocardScreen> createState() => _PhotocardScreenState();
}

class _PhotocardScreenState extends ConsumerState<PhotocardScreen> {
  PhotocardRarity? _selectedRarity;

  List<PhotocardModel> get _filteredCards {
    if (_selectedRarity == null) return mockPhotocards;
    return mockPhotocards.where((c) => c.rarity == _selectedRarity).toList();
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(),
            _buildStats(),
            _buildRarityFilter(),
            _buildPhotocardGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(Responsive.wp(4)),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.glassWhite,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            SizedBox(width: Responsive.wp(3)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) =>
                        AppColors.holographicGradient.createShader(bounds),
                    child: Text(
                      'My Collection',
                      style: TextStyle(
                        fontSize: Responsive.sp(24),
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  Text(
                    '${mockPhotocards.length}장의 포토카드',
                    style: TextStyle(
                      fontSize: Responsive.sp(13),
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats() {
    final legendaryCount = mockPhotocards
        .where((c) => c.rarity == PhotocardRarity.legendary)
        .length;
    final holoCount = mockPhotocards.where((c) => c.isHolographic).length;

    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: Responsive.wp(4)),
        child: GlassCard(
          showNeonBorder: true,
          neonColor: AppColors.neonPurple,
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                  '전체', '${mockPhotocards.length}', AppColors.neonCyan),
              _buildStatItem('레전더리', '$legendaryCount', AppColors.holoGold),
              _buildStatItem('홀로그램', '$holoCount', AppColors.neonPink),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: Responsive.sp(24),
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: Responsive.sp(12),
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildRarityFilter() {
    return SliverToBoxAdapter(
      child: Container(
        height: 50,
        margin: EdgeInsets.symmetric(vertical: Responsive.hp(2)),
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: Responsive.wp(4)),
          children: [
            _buildFilterChip(null, '전체', AppColors.neonCyan),
            ...PhotocardRarity.values.map(
              (rarity) =>
                  _buildFilterChip(rarity, rarity.displayName, rarity.color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(PhotocardRarity? rarity, String label, Color color) {
    final isSelected = _selectedRarity == rarity;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedRarity = rarity);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(colors: [color, color.withValues(alpha: 0.7)])
              : null,
          color: isSelected ? null : AppColors.glassWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : AppColors.glassBorder,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? AppColors.glowShadow(color) : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: Responsive.sp(13),
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildPhotocardGrid() {
    final cards = _filteredCards;

    return SliverPadding(
      padding: EdgeInsets.all(Responsive.wp(4)),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: Responsive.wp(3),
          mainAxisSpacing: Responsive.wp(3),
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildPhotocardItem(cards[index]),
          childCount: cards.length,
        ),
      ),
    );
  }

  Widget _buildPhotocardItem(PhotocardModel card) {
    return GestureDetector(
      onTap: () => _showPhotocardDetail(card),
      child: Hero(
        tag: 'photocard-${card.id}',
        child: card.isHolographic
            ? HolographicOverlay(
                intensity: 0.25,
                child: _buildCardContent(card),
              )
            : _buildCardContent(card),
      ),
    );
  }

  Widget _buildCardContent(PhotocardModel card) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.glowShadow(card.rarity.color, opacity: 0.3),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Card Image
            CachedNetworkImage(
              imageUrl: card.imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                color: AppColors.darkSurface,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.neonPurple,
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
            // Rarity Badge
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: card.rarity.color,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: AppColors.glowShadow(card.rarity.color),
                ),
                child: Text(
                  card.rarity.stars,
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
            // Holographic Badge
            if (card.isHolographic)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: AppColors.holographicGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            // Info
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    card.idolName,
                    style: TextStyle(
                      fontSize: Responsive.sp(14),
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          card.type.displayName,
                          style: TextStyle(
                            fontSize: Responsive.sp(10),
                            color: Colors.white70,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        card.serialDisplay,
                        style: TextStyle(
                          fontSize: Responsive.sp(9),
                          color: Colors.white54,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPhotocardDetail(PhotocardModel card) {
    HapticFeedback.mediumImpact();
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close',
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return _PhotocardDetailDialog(card: card);
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1).animate(
              CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
            ),
            child: child,
          ),
        );
      },
    );
  }
}

class _PhotocardDetailDialog extends StatelessWidget {
  final PhotocardModel card;

  const _PhotocardDetailDialog({required this.card});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Hero(
          tag: 'photocard-${card.id}',
          child: FlipCard3D(
            front: _buildFront(context),
            back: _buildBack(context),
          ),
        ),
      ),
    );
  }

  Widget _buildFront(BuildContext context) {
    return card.isHolographic
        ? HolographicOverlay(
            intensity: 0.35,
            child: _buildFrontContent(context),
          )
        : _buildFrontContent(context);
  }

  Widget _buildFrontContent(BuildContext context) {
    return Container(
      width: 280,
      height: 420,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.glowShadow(card.rarity.color, opacity: 0.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: card.imageUrl,
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                  stops: const [0.6, 1.0],
                ),
              ),
            ),
            // Rarity
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: card.rarity.color,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: AppColors.glowShadow(card.rarity.color),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      card.rarity.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(card.rarity.stars,
                        style: const TextStyle(fontSize: 10)),
                  ],
                ),
              ),
            ),
            // Info
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.idolName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  if (card.idolGroup.isNotEmpty)
                    Text(
                      card.idolGroup,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          card.type.displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        card.serialDisplay,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.6),
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Tap hint
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  '탭해서 뒤집기',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBack(BuildContext context) {
    return Container(
      width: 280,
      height: 420,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: AppColors.premiumGradient,
        boxShadow: AppColors.elevatedShadow(opacity: 0.3),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Pattern background
            Positioned.fill(
              child: Opacity(
                opacity: 0.1,
                child: Image.network(
                  'https://picsum.photos/seed/pattern/300/450',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo
                  ShaderMask(
                    shaderCallback: (bounds) =>
                        AppColors.holographicGradient.createShader(bounds),
                    child: const Text(
                      'IDOL SUPPORT',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Digital Photocard',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.5),
                      letterSpacing: 1,
                    ),
                  ),
                  const Spacer(),
                  // Message
                  if (card.message != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        card.message!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.9),
                          height: 1.5,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  const Spacer(),
                  // Details
                  _buildBackRow('발급일', card.issuedDateDisplay),
                  const SizedBox(height: 8),
                  _buildBackRow('시리얼', card.serialDisplay),
                  const SizedBox(height: 8),
                  _buildBackRow('타입', card.type.displayName),
                  const SizedBox(height: 8),
                  _buildBackRow('등급', card.rarity.displayName),
                  const SizedBox(height: 24),
                  // Close button
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.neonBorderGradient,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Text(
                        '닫기',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

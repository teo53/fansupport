import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/mock/mock_data.dart';
import '../../../shared/models/idol_model.dart';
import '../../live/screens/incoming_call_screen.dart';
import 'story_item.dart';

class LiveStoriesSection extends StatelessWidget {
  const LiveStoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final idols = MockData.idolModels;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            PipoSpacing.xl,
            PipoSpacing.xxl,
            PipoSpacing.xl,
            PipoSpacing.md,
          ),
          child: Text(
            '스토리',
            style: PipoTypography.titleMedium.copyWith(
              color: PipoColors.textPrimary,
            ),
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: PipoSpacing.xl),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: idols.length,
            itemBuilder: (context, index) {
              final idol = idols[index];
              final isLive = index == 0;
              return StoryItem(
                idol: idol,
                isLive: isLive,
                onTap: () {
                  if (isLive) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => IncomingCallScreen(idol: idol),
                        fullscreenDialog: true,
                      ),
                    );
                  } else {
                    _showStoryView(context, idol);
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showStoryView(BuildContext context, IdolModel idol) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close',
      barrierColor: Colors.black,
      pageBuilder: (context, anim1, anim2) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                color: Colors.black,
                child: Center(
                  child: CachedNetworkImage(
                    imageUrl: idol.profileImage,
                    fit: BoxFit.cover,
                    height: double.infinity,
                    width: double.infinity,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.transparent,
                      Colors.black.withOpacity(0.6),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.3, 0.8],
                  ),
                ),
              ),
              SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(PipoSpacing.lg),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundImage:
                                CachedNetworkImageProvider(idol.profileImage),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            idol.stageName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close,
                                color: Colors.white, size: 28),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(PipoSpacing.xl),
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            context.go('/idols/${idol.id}');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: PipoRadius.button,
                            ),
                          ),
                          child: const Text(
                            '프로필 방문하기',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(opacity: anim1, child: child);
      },
    );
  }
}

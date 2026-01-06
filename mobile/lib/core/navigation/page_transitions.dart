import 'package:flutter/material.dart';

/// ============================================================
/// PIPO Page Transition Effects
/// 페이지 전환 시 Premium 느낌을 주는 애니메이션
/// ============================================================

/// 1. 슬라이드 + 페이드 전환 (기본)
class SlideUpFadeTransition extends PageRouteBuilder {
  final Widget page;

  SlideUpFadeTransition({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 400),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 0.08);
            const end = Offset.zero;
            const curve = Curves.easeOutCubic;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            var fadeTween = Tween(begin: 0.0, end: 1.0).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: FadeTransition(
                opacity: animation.drive(fadeTween),
                child: child,
              ),
            );
          },
        );
}

/// 2. 스케일 + 페이드 전환 (디테일 화면)
class ScaleFadeTransition extends PageRouteBuilder {
  final Widget page;
  final Alignment alignment;

  ScaleFadeTransition({
    required this.page,
    this.alignment = Alignment.center,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 350),
          reverseTransitionDuration: const Duration(milliseconds: 250),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const curve = Curves.easeOutCubic;

            var scaleTween = Tween(begin: 0.92, end: 1.0).chain(
              CurveTween(curve: curve),
            );

            var fadeTween = Tween(begin: 0.0, end: 1.0).chain(
              CurveTween(curve: curve),
            );

            return ScaleTransition(
              scale: animation.drive(scaleTween),
              alignment: alignment,
              child: FadeTransition(
                opacity: animation.drive(fadeTween),
                child: child,
              ),
            );
          },
        );
}

/// 3. 히어로 스타일 전환 (공유 요소 애니메이션 느낌)
class SharedAxisTransition extends PageRouteBuilder {
  final Widget page;
  final SharedAxisType type;

  SharedAxisTransition({
    required this.page,
    this.type = SharedAxisType.horizontal,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 400),
          reverseTransitionDuration: const Duration(milliseconds: 350),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );

            Offset beginOffset;
            switch (type) {
              case SharedAxisType.horizontal:
                beginOffset = const Offset(0.15, 0);
                break;
              case SharedAxisType.vertical:
                beginOffset = const Offset(0, 0.15);
                break;
              case SharedAxisType.scaled:
                return FadeTransition(
                  opacity: curvedAnimation,
                  child: ScaleTransition(
                    scale: Tween(begin: 0.8, end: 1.0).animate(curvedAnimation),
                    child: child,
                  ),
                );
            }

            return FadeTransition(
              opacity: curvedAnimation,
              child: SlideTransition(
                position: Tween(begin: beginOffset, end: Offset.zero)
                    .animate(curvedAnimation),
                child: child,
              ),
            );
          },
        );
}

enum SharedAxisType { horizontal, vertical, scaled }

/// 4. 모달 바텀 시트 스타일 전환
class BottomSheetPageTransition extends PageRouteBuilder {
  final Widget page;

  BottomSheetPageTransition({required this.page})
      : super(
          opaque: false,
          barrierColor: Colors.black54,
          barrierDismissible: true,
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 350),
          reverseTransitionDuration: const Duration(milliseconds: 250),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;

            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );

            return SlideTransition(
              position: Tween(begin: begin, end: end).animate(curvedAnimation),
              child: child,
            );
          },
        );
}

/// 5. iOS 스타일 푸시 전환
class CupertinoStyleTransition extends PageRouteBuilder {
  final Widget page;

  CupertinoStyleTransition({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 400),
          reverseTransitionDuration: const Duration(milliseconds: 350),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            );

            final secondaryCurvedAnimation = CurvedAnimation(
              parent: secondaryAnimation,
              curve: Curves.easeOutCubic,
            );

            return SlideTransition(
              position: Tween(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: SlideTransition(
                position: Tween(
                  begin: Offset.zero,
                  end: const Offset(-0.3, 0.0),
                ).animate(secondaryCurvedAnimation),
                child: child,
              ),
            );
          },
        );
}

/// 6. 카드 확장 전환 (클릭한 카드가 전체 화면으로)
class CardExpansionTransition extends PageRouteBuilder {
  final Widget page;
  final Rect? sourceRect;

  CardExpansionTransition({
    required this.page,
    this.sourceRect,
  }) : super(
          opaque: false,
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 500),
          reverseTransitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            );

            return FadeTransition(
              opacity: curvedAnimation,
              child: ScaleTransition(
                scale: Tween(begin: 0.85, end: 1.0).animate(curvedAnimation),
                child: child,
              ),
            );
          },
        );
}

/// 7. 회전 + 페이드 전환 (특별 화면)
class RotateFadeTransition extends PageRouteBuilder {
  final Widget page;
  final double rotationAngle;

  RotateFadeTransition({
    required this.page,
    this.rotationAngle = 0.03,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 450),
          reverseTransitionDuration: const Duration(milliseconds: 350),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutBack,
            );

            return FadeTransition(
              opacity: curvedAnimation,
              child: RotationTransition(
                turns: Tween(begin: rotationAngle, end: 0.0).animate(curvedAnimation),
                child: ScaleTransition(
                  scale: Tween(begin: 0.9, end: 1.0).animate(curvedAnimation),
                  child: child,
                ),
              ),
            );
          },
        );
}

/// 8. 블러 페이드 전환 (프리미엄 느낌)
class BlurFadeTransition extends PageRouteBuilder {
  final Widget page;

  BlurFadeTransition({required this.page})
      : super(
          opaque: false,
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 400),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            );

            return FadeTransition(
              opacity: curvedAnimation,
              child: child,
            );
          },
        );
}

/// Page Transition Helper
class PipoPageTransitions {
  /// 기본 슬라이드 업 페이드
  static Route slideUpFade(Widget page) => SlideUpFadeTransition(page: page);

  /// 스케일 페이드 (디테일 화면용)
  static Route scaleFade(Widget page, {Alignment? alignment}) =>
      ScaleFadeTransition(page: page, alignment: alignment ?? Alignment.center);

  /// 공유 축 전환
  static Route sharedAxis(Widget page, {SharedAxisType? type}) =>
      SharedAxisTransition(page: page, type: type ?? SharedAxisType.horizontal);

  /// 바텀 시트 스타일
  static Route bottomSheet(Widget page) => BottomSheetPageTransition(page: page);

  /// iOS 스타일 푸시
  static Route cupertino(Widget page) => CupertinoStyleTransition(page: page);

  /// 카드 확장
  static Route cardExpansion(Widget page, {Rect? sourceRect}) =>
      CardExpansionTransition(page: page, sourceRect: sourceRect);

  /// 회전 페이드
  static Route rotateFade(Widget page) => RotateFadeTransition(page: page);

  /// 블러 페이드
  static Route blurFade(Widget page) => BlurFadeTransition(page: page);
}

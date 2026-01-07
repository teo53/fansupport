import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/design_system.dart';

/// Custom page transitions for better UX
///
/// Provides various page transition animations
class PageTransitions {
  /// Slide transition from right
  static Page<void> slideFromRight<T>({
    required Widget child,
    required GoRouterState state,
    String? name,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      name: name,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        final tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: PipoAnimations.medium,
    );
  }

  /// Slide transition from bottom
  static Page<void> slideFromBottom<T>({
    required Widget child,
    required GoRouterState state,
    String? name,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      name: name,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        final tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: PipoAnimations.medium,
    );
  }

  /// Fade transition
  static Page<void> fade<T>({
    required Widget child,
    required GoRouterState state,
    String? name,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      name: name,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: PipoAnimations.normal,
    );
  }

  /// Scale transition
  static Page<void> scale<T>({
    required Widget child,
    required GoRouterState state,
    String? name,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      name: name,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = 0.9;
        const end = 1.0;
        const curve = Curves.easeOutCubic;

        final tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return ScaleTransition(
          scale: animation.drive(tween),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      transitionDuration: PipoAnimations.medium,
    );
  }

  /// Slide and fade combined
  static Page<void> slideAndFade<T>({
    required Widget child,
    required GoRouterState state,
    String? name,
    Offset begin = const Offset(1.0, 0.0),
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      name: name,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        final slideTween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(slideTween),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      transitionDuration: PipoAnimations.medium,
    );
  }

  /// No transition (instant)
  static Page<void> none<T>({
    required Widget child,
    required GoRouterState state,
    String? name,
  }) {
    return NoTransitionPage<T>(
      key: state.pageKey,
      child: child,
      name: name,
    );
  }

  /// Shared axis transition (Material Design)
  static Page<void> sharedAxis<T>({
    required Widget child,
    required GoRouterState state,
    String? name,
    SharedAxisTransitionType transitionType = SharedAxisTransitionType.scaled,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      name: name,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        switch (transitionType) {
          case SharedAxisTransitionType.horizontal:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.3, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          case SharedAxisTransitionType.vertical:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.3),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          case SharedAxisTransitionType.scaled:
          default:
            return ScaleTransition(
              scale: Tween<double>(
                begin: 0.8,
                end: 1.0,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
        }
      },
      transitionDuration: PipoAnimations.medium,
    );
  }
}

/// Shared axis transition types
enum SharedAxisTransitionType {
  horizontal,
  vertical,
  scaled,
}

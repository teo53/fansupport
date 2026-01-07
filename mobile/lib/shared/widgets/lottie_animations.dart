import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../core/theme/design_system.dart';

/// Lottie animation widgets for common UI states
///
/// Provides reusable animated illustrations using Lottie
class LottieAnimations {
  // Animation asset paths (to be added to assets folder)
  static const String _loadingPath = 'assets/lottie/loading.json';
  static const String _emptyPath = 'assets/lottie/empty.json';
  static const String _errorPath = 'assets/lottie/error.json';
  static const String _successPath = 'assets/lottie/success.json';
  static const String _searchPath = 'assets/lottie/search.json';
  static const String _noConnectionPath = 'assets/lottie/no_connection.json';

  /// Loading animation
  static Widget loading({
    double size = 200,
    String? message,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: _buildAnimation(_loadingPath),
        ),
        if (message != null) ...[
          const SizedBox(height: PipoSpacing.md),
          Text(
            message,
            style: PipoTypography.bodyMedium.copyWith(
              color: PipoColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  /// Empty state animation
  static Widget empty({
    double size = 200,
    required String message,
    String? description,
    Widget? action,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: _buildAnimation(_emptyPath),
        ),
        const SizedBox(height: PipoSpacing.lg),
        Text(
          message,
          style: PipoTypography.titleLarge.copyWith(
            color: PipoColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        if (description != null) ...[
          const SizedBox(height: PipoSpacing.sm),
          Text(
            description,
            style: PipoTypography.bodyMedium.copyWith(
              color: PipoColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        if (action != null) ...[
          const SizedBox(height: PipoSpacing.xl),
          action,
        ],
      ],
    );
  }

  /// Error state animation
  static Widget error({
    double size = 200,
    required String message,
    String? description,
    VoidCallback? onRetry,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: _buildAnimation(_errorPath, repeat: false),
        ),
        const SizedBox(height: PipoSpacing.lg),
        Text(
          message,
          style: PipoTypography.titleLarge.copyWith(
            color: PipoColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        if (description != null) ...[
          const SizedBox(height: PipoSpacing.sm),
          Text(
            description,
            style: PipoTypography.bodyMedium.copyWith(
              color: PipoColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        if (onRetry != null) ...[
          const SizedBox(height: PipoSpacing.xl),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: PipoColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: PipoSpacing.xxl,
                vertical: PipoSpacing.md,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: PipoRadius.button,
              ),
            ),
            child: const Text('다시 시도'),
          ),
        ],
      ],
    );
  }

  /// Success animation
  static Widget success({
    double size = 150,
    String? message,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: _buildAnimation(_successPath, repeat: false),
        ),
        if (message != null) ...[
          const SizedBox(height: PipoSpacing.md),
          Text(
            message,
            style: PipoTypography.titleMedium.copyWith(
              color: PipoColors.success,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  /// Search animation
  static Widget search({
    double size = 200,
    String message = '검색 중...',
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: _buildAnimation(_searchPath),
        ),
        const SizedBox(height: PipoSpacing.md),
        Text(
          message,
          style: PipoTypography.bodyMedium.copyWith(
            color: PipoColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// No connection animation
  static Widget noConnection({
    double size = 200,
    VoidCallback? onRetry,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: _buildAnimation(_noConnectionPath),
        ),
        const SizedBox(height: PipoSpacing.lg),
        Text(
          '인터넷 연결 없음',
          style: PipoTypography.titleLarge.copyWith(
            color: PipoColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: PipoSpacing.sm),
        Text(
          '인터넷 연결을 확인하고 다시 시도해주세요.',
          style: PipoTypography.bodyMedium.copyWith(
            color: PipoColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        if (onRetry != null) ...[
          const SizedBox(height: PipoSpacing.xl),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('다시 시도'),
            style: ElevatedButton.styleFrom(
              backgroundColor: PipoColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: PipoSpacing.xxl,
                vertical: PipoSpacing.md,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: PipoRadius.button,
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Build animation widget
  static Widget _buildAnimation(
    String path, {
    bool repeat = true,
  }) {
    // For now, return a placeholder since we don't have actual Lottie files
    // In production, uncomment the Lottie.asset code below
    return _PlaceholderAnimation(path: path, repeat: repeat);

    /* Uncomment when Lottie files are added:
    return Lottie.asset(
      path,
      repeat: repeat,
      frameRate: FrameRate.max,
      errorBuilder: (context, error, stackTrace) {
        return _PlaceholderAnimation(path: path, repeat: repeat);
      },
    );
    */
  }
}

/// Placeholder animation until Lottie files are added
class _PlaceholderAnimation extends StatefulWidget {
  final String path;
  final bool repeat;

  const _PlaceholderAnimation({
    required this.path,
    required this.repeat,
  });

  @override
  State<_PlaceholderAnimation> createState() => _PlaceholderAnimationState();
}

class _PlaceholderAnimationState extends State<_PlaceholderAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    if (widget.repeat) {
      _controller.repeat();
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    if (widget.path.contains('loading')) {
      icon = Icons.refresh;
      color = PipoColors.primary;
    } else if (widget.path.contains('empty')) {
      icon = Icons.inbox_outlined;
      color = PipoColors.textSecondary;
    } else if (widget.path.contains('error')) {
      icon = Icons.error_outline;
      color = PipoColors.error;
    } else if (widget.path.contains('success')) {
      icon = Icons.check_circle_outline;
      color = PipoColors.success;
    } else if (widget.path.contains('search')) {
      icon = Icons.search;
      color = PipoColors.primary;
    } else if (widget.path.contains('no_connection')) {
      icon = Icons.wifi_off;
      color = PipoColors.error;
    } else {
      icon = Icons.animation;
      color = PipoColors.primary;
    }

    return RotationTransition(
      turns: widget.repeat ? _controller : const AlwaysStoppedAnimation(0),
      child: Icon(
        icon,
        size: 80,
        color: color,
      ),
    );
  }
}

/// Full screen loading overlay with Lottie animation
class LottieLoadingOverlay extends StatelessWidget {
  final String? message;
  final bool dismissible;

  const LottieLoadingOverlay({
    super.key,
    this.message,
    this.dismissible = false,
  });

  static void show(
    BuildContext context, {
    String? message,
    bool dismissible = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: dismissible,
      builder: (context) => LottieLoadingOverlay(
        message: message,
        dismissible: dismissible,
      ),
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: dismissible,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(PipoSpacing.xxl),
          decoration: BoxDecoration(
            color: PipoColors.surface,
            borderRadius: BorderRadius.circular(PipoRadius.xl),
          ),
          child: LottieAnimations.loading(
            size: 150,
            message: message,
          ),
        ),
      ),
    );
  }
}

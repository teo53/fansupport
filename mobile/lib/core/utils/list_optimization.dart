import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Optimized list item builder with automatic key generation
class OptimizedListItem extends StatelessWidget {
  final String id;
  final Widget child;

  const OptimizedListItem({
    required this.id,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: ValueKey(id),
      child: child,
    );
  }
}

/// Sliver list with automatic viewport optimization
class OptimizedSliverList extends StatelessWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;

  const OptimizedSliverList({
    required this.itemCount,
    required this.itemBuilder,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        itemBuilder,
        childCount: itemCount,
        addAutomaticKeepAlives: addAutomaticKeepAlives,
        addRepaintBoundaries: addRepaintBoundaries,
      ),
    );
  }
}

/// Grid with optimized rendering
class OptimizedGrid extends StatelessWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;

  const OptimizedGrid({
    required this.itemCount,
    required this.itemBuilder,
    required this.crossAxisCount,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
    this.childAspectRatio = 1,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return RepaintBoundary(
          child: itemBuilder(context, index),
        );
      },
    );
  }
}

/// Lazy loading controller for infinite scroll
class LazyLoadController {
  final VoidCallback onLoadMore;
  final ScrollController scrollController;
  final double threshold;
  bool _isLoading = false;

  LazyLoadController({
    required this.onLoadMore,
    required this.scrollController,
    this.threshold = 0.8, // Load when 80% scrolled
  }) {
    scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_isLoading) return;

    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.position.pixels;
    final delta = maxScroll - currentScroll;

    // Load more when reaching threshold
    if (delta <= maxScroll * (1 - threshold)) {
      _isLoading = true;
      onLoadMore();
    }
  }

  /// Call this after loading is complete
  void completeLoading() {
    _isLoading = false;
  }

  void dispose() {
    scrollController.removeListener(_scrollListener);
  }
}

/// Item visibility tracker for analytics
class ItemVisibilityTracker extends StatefulWidget {
  final String itemId;
  final Widget child;
  final void Function(String itemId)? onVisible;
  final void Function(String itemId)? onHidden;
  final double visibilityThreshold;

  const ItemVisibilityTracker({
    required this.itemId,
    required this.child,
    this.onVisible,
    this.onHidden,
    this.visibilityThreshold = 0.5,
    super.key,
  });

  @override
  State<ItemVisibilityTracker> createState() => _ItemVisibilityTrackerState();
}

class _ItemVisibilityTrackerState extends State<ItemVisibilityTracker> {
  bool _wasVisible = false;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.itemId),
      onVisibilityChanged: (info) {
        final isVisible = info.visibleFraction >= widget.visibilityThreshold;

        if (isVisible && !_wasVisible) {
          _wasVisible = true;
          widget.onVisible?.call(widget.itemId);
        } else if (!isVisible && _wasVisible) {
          _wasVisible = false;
          widget.onHidden?.call(widget.itemId);
        }
      },
      child: widget.child,
    );
  }
}

/// Simple visibility detector (built-in alternative)
class VisibilityDetector extends StatefulWidget {
  final Key key;
  final Widget child;
  final Function(VisibilityInfo) onVisibilityChanged;

  const VisibilityDetector({
    required this.key,
    required this.child,
    required this.onVisibilityChanged,
  }) : super(key: key);

  @override
  State<VisibilityDetector> createState() => _VisibilityDetectorState();
}

class _VisibilityDetectorState extends State<VisibilityDetector> {
  @override
  Widget build(BuildContext context) {
    // Note: For production, use the visibility_detector package
    // This is a simplified implementation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVisibility();
    });

    return widget.child;
  }

  void _checkVisibility() {
    final renderObject = context.findRenderObject();
    if (renderObject is RenderBox && renderObject.hasSize) {
      final viewport = RenderAbstractViewport.of(renderObject);
      final visible = viewport != null &&
          renderObject.paintBounds.overlaps(viewport.paintBounds);

      widget.onVisibilityChanged(VisibilityInfo(
        key: widget.key!,
        size: renderObject.size,
        visibleFraction: visible ? 1.0 : 0.0,
      ));
    }
  }
}

/// Visibility information
class VisibilityInfo {
  final Key key;
  final Size size;
  final double visibleFraction;

  const VisibilityInfo({
    required this.key,
    required this.size,
    required this.visibleFraction,
  });
}

/// Cached network image with memory optimization
class OptimizedCachedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget Function(BuildContext, String)? placeholder;
  final Widget Function(BuildContext, String, dynamic)? errorWidget;

  const OptimizedCachedImage({
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      // Optimize memory by not caching large images
      cacheWidth: width?.toInt(),
      cacheHeight: height?.toInt(),
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;

        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: child,
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;

        if (placeholder != null) {
          return placeholder!(context, imageUrl);
        }

        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        if (errorWidget != null) {
          return errorWidget!(context, imageUrl, error);
        }

        return const Center(
          child: Icon(Icons.error_outline, color: Colors.red),
        );
      },
    );
  }
}

/// List pagination helper
class PaginationHelper<T> {
  final List<T> _allItems = [];
  final int pageSize;
  int _currentPage = 0;

  PaginationHelper({this.pageSize = 20});

  /// Add items to the list
  void addItems(List<T> items) {
    _allItems.addAll(items);
  }

  /// Get current page items
  List<T> getCurrentPage() {
    final start = _currentPage * pageSize;
    final end = start + pageSize;

    if (start >= _allItems.length) return [];

    return _allItems.sublist(
      start,
      end > _allItems.length ? _allItems.length : end,
    );
  }

  /// Get all loaded items up to current page
  List<T> getAllLoadedItems() {
    final end = (_currentPage + 1) * pageSize;
    return _allItems.sublist(
      0,
      end > _allItems.length ? _allItems.length : end,
    );
  }

  /// Load next page
  bool loadNextPage() {
    final maxPage = (_allItems.length / pageSize).ceil() - 1;

    if (_currentPage < maxPage) {
      _currentPage++;
      return true;
    }

    return false;
  }

  /// Reset pagination
  void reset() {
    _currentPage = 0;
    _allItems.clear();
  }

  /// Check if has more pages
  bool get hasMorePages {
    return (_currentPage + 1) * pageSize < _allItems.length;
  }

  /// Get total item count
  int get totalCount => _allItems.length;

  /// Get current page number (0-indexed)
  int get currentPage => _currentPage;
}

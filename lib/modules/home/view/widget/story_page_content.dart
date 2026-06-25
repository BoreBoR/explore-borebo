import 'dart:async';

import 'package:benjii/modules/home/view/widget/story_page_data.dart';
import 'package:benjii/util/app_color.dart';
import 'package:flutter/material.dart';

class StoryPageContent extends StatelessWidget {
  const StoryPageContent({super.key, required this.page});

  final StoryPageData page;

  @override
  Widget build(BuildContext context) {
    switch (page.kind) {
      case StoryPageKind.list:
        return _ListContent(items: page.items);
      case StoryPageKind.memoryCards:
        return _MemoryCards(items: page.items);
      case StoryPageKind.gallery:
        return _PhotoGallery(
          captions: page.items,
          imageAssets: page.imageAssets,
        );
      case StoryPageKind.letter:
        return const _LetterNote();
      case StoryPageKind.wish:
        return const _WishCard();
      case StoryPageKind.standard:
      case StoryPageKind.timeTogether:
        return const SizedBox.shrink();
    }
  }
}

class _ListContent extends StatelessWidget {
  const _ListContent({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        children: items.map((item) => _SoftTile(text: item)).toList(),
      ),
    );
  }
}

class _MemoryCards extends StatelessWidget {
  const _MemoryCards({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        children: [
          for (var index = 0; index < items.length; index++)
            _SoftTile(
              text: items[index],
              leading: '${index + 1}',
              icon: Icons.bookmark_border_rounded,
            ),
        ],
      ),
    );
  }
}

class _PhotoGallery extends StatefulWidget {
  const _PhotoGallery({required this.captions, required this.imageAssets});

  static const thumbnailCacheWidth = 420;

  final List<String> captions;
  final List<String> imageAssets;

  @override
  State<_PhotoGallery> createState() => _PhotoGalleryState();
}

class _PhotoGalleryState extends State<_PhotoGallery> {
  static const _initialVisibleCount = 4;
  static const _batchSize = 4;
  static const _batchDelay = Duration(milliseconds: 70);

  Timer? _revealTimer;
  late int _visibleCount = _limitedCount(_initialVisibleCount);

  @override
  void initState() {
    super.initState();
    _scheduleMoreImages();
  }

  @override
  void didUpdateWidget(covariant _PhotoGallery oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageAssets.length != widget.imageAssets.length) {
      _revealTimer?.cancel();
      _visibleCount = _limitedCount(_initialVisibleCount);
      _scheduleMoreImages();
    }
  }

  void _scheduleMoreImages() {
    if (_visibleCount >= widget.imageAssets.length) {
      return;
    }
    _revealTimer = Timer.periodic(_batchDelay, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _visibleCount = _limitedCount(_visibleCount + _batchSize);
      });
      if (_visibleCount >= widget.imageAssets.length) {
        timer.cancel();
      }
    });
  }

  int _limitedCount(int value) {
    final total = widget.imageAssets.length;
    return value > total ? total : value;
  }

  @override
  void dispose() {
    _revealTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: GridView.builder(
        key: const ValueKey('photo-gallery'),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _visibleCount,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.92,
        ),
        itemBuilder: (context, index) {
          final assetPath = widget.imageAssets[index];
          final caption = index < widget.captions.length
              ? widget.captions[index]
              : '';

          return Material(
            color: AppColor.surface.withValues(alpha: 0.96),
            elevation: 4,
            shadowColor: AppColor.primaryBlueDark.withValues(alpha: 0.1),
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: AppColor.surface.withValues(alpha: 0.92)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: InkWell(
              key: ValueKey('gallery-image-$index'),
              onTap: () => _openImageViewer(
                context,
                assetPath: assetPath,
                caption: caption,
                index: index,
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'gallery-image-hero-$index',
                    child: Image.asset(
                      assetPath,
                      fit: BoxFit.cover,
                      cacheWidth: _PhotoGallery.thumbnailCacheWidth,
                      semanticLabel: caption,
                      errorBuilder: (context, error, stackTrace) {
                        return DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColor.primaryBlueLight.withValues(
                              alpha: 0.16,
                            ),
                          ),
                          child: Icon(
                            Icons.image_outlined,
                            color: AppColor.textSecondary.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xB3000000)],
                        stops: [0.52, 1],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 11,
                    child: Text(
                      caption,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _openImageViewer(
    BuildContext context, {
    required String assetPath,
    required String caption,
    required int index,
  }) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: _FullScreenImageViewer(
              assetPath: assetPath,
              caption: caption,
              heroTag: 'gallery-image-hero-$index',
            ),
          );
        },
      ),
    );
  }
}

class _FullScreenImageViewer extends StatelessWidget {
  const _FullScreenImageViewer({
    required this.assetPath,
    required this.caption,
    required this.heroTag,
  });

  final String assetPath;
  final String caption;
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey('full-screen-image-viewer'),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child: Center(
                  child: Hero(
                    tag: heroTag,
                    child: Image.asset(
                      assetPath,
                      fit: BoxFit.contain,
                      semanticLabel: caption,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton.filled(
                key: const ValueKey('close-image-viewer'),
                tooltip: 'Close photo',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ),
            if (caption.isNotEmpty)
              Positioned(
                left: 24,
                right: 24,
                bottom: 20,
                child: Text(
                  caption,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    shadows: const [Shadow(color: Colors.black, blurRadius: 8)],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LetterNote extends StatelessWidget {
  const _LetterNote();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class _WishCard extends StatelessWidget {
  const _WishCard();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColor.blush.withValues(alpha: 0.92),
              AppColor.lilac.withValues(alpha: 0.72),
            ],
          ),
          border: Border.all(color: AppColor.surface.withValues(alpha: 0.86)),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColor.blushDeep.withValues(alpha: 0.09),
              blurRadius: 26,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              const Icon(
                Icons.cake_outlined,
                color: AppColor.blushDeep,
                size: 34,
              ),
              const SizedBox(height: 10),
              Text(
                'เก็บคำอธิษฐานเล็กๆไว้ให้เธอเสมอนะ',
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(height: 1.35),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SoftTile extends StatelessWidget {
  const _SoftTile({
    required this.text,
    this.leading,
    this.icon = Icons.favorite_border_rounded,
  });

  final String text;
  final String? leading;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColor.surface.withValues(alpha: 0.88),
          border: Border.all(color: AppColor.outline.withValues(alpha: 0.72)),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColor.primaryBlueDark.withValues(alpha: 0.045),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (leading == null)
                Icon(icon, color: AppColor.primaryBlue, size: 20)
              else
                CircleAvatar(
                  radius: 13,
                  backgroundColor: AppColor.primaryBlueLight.withValues(
                    alpha: 0.2,
                  ),
                  child: Text(
                    leading!,
                    style: textTheme.labelMedium?.copyWith(
                      color: AppColor.primaryBlue,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: textTheme.bodyLarge?.copyWith(height: 1.35),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

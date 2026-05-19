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
        return _GalleryPlaceholders(items: page.items);
      case StoryPageKind.letter:
        return const _LetterNote();
      case StoryPageKind.wish:
        return const _WishCard();
      case StoryPageKind.standard:
      case StoryPageKind.restart:
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

class _GalleryPlaceholders extends StatelessWidget {
  const _GalleryPlaceholders({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: GridView.builder(
        key: const ValueKey('gallery-placeholders'),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.05,
        ),
        itemBuilder: (context, index) {
          return DecoratedBox(
            decoration: BoxDecoration(
              color: AppColor.surface,
              border: Border.all(color: AppColor.outline),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.add_photo_alternate_outlined,
                    color: AppColor.primaryBlue,
                    size: 28,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    items[index],
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(height: 1.25),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LetterNote extends StatelessWidget {
  const _LetterNote();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColor.surface,
          border: Border.all(color: AppColor.outline),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Text(
            'You can replace this with the real letter later. The layout already allows the page to scroll when the message becomes longer.',
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              color: AppColor.textSecondary,
              height: 1.45,
            ),
          ),
        ),
      ),
    );
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
          color: AppColor.primaryBlueLight.withValues(alpha: 0.16),
          border: Border.all(color: AppColor.primaryBlueLight),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              const Icon(
                Icons.cake_outlined,
                color: AppColor.primaryBlue,
                size: 34,
              ),
              const SizedBox(height: 10),
              Text(
                'A tiny birthday candle, saved just for your wish.',
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
          color: AppColor.surface,
          border: Border.all(color: AppColor.outline),
          borderRadius: BorderRadius.circular(16),
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

import 'package:benjii/modules/home/view/widget/story_page_content.dart';
import 'package:benjii/modules/home/view/widget/story_page_data.dart';
import 'package:benjii/modules/home/view/widget/story_progress_dots.dart';
import 'package:benjii/util/app_color.dart';
import 'package:flutter/material.dart';

class StoryPage extends StatelessWidget {
  const StoryPage({
    super.key,
    required this.page,
    required this.pageNumber,
    required this.totalPages,
    required this.onPrimaryAction,
  });

  final StoryPageData page;
  final int pageNumber;
  final int totalPages;
  final VoidCallback onPrimaryAction;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      StoryProgressDots(
                        currentPage: pageNumber,
                        totalPages: totalPages,
                      ),
                      const SizedBox(height: 30),
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: 82,
                          height: 82,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                colorScheme.secondaryContainer,
                                colorScheme.primaryContainer.withValues(
                                  alpha: 0.62,
                                ),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(26),
                            boxShadow: [
                              BoxShadow(
                                color: AppColor.blushDeep.withValues(
                                  alpha: 0.1,
                                ),
                                blurRadius: 30,
                                offset: const Offset(0, 16),
                              ),
                            ],
                          ),
                          child: Icon(
                            page.icon,
                            color: colorScheme.primary,
                            size: 36,
                          ),
                        ),
                      ),
                      const SizedBox(height: 26),
                      Text(
                        page.title,
                        textAlign: TextAlign.center,
                        style: textTheme.displaySmall?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        page.body,
                        textAlign: TextAlign.center,
                        style: textTheme.titleMedium?.copyWith(
                          color: AppColor.textSecondary,
                          height: 1.45,
                        ),
                      ),
                      if (page.footer != null) ...[
                        const SizedBox(height: 14),
                        Text(
                          page.footer!,
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.secondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                      StoryPageContent(page: page),
                      const SizedBox(height: 32),
                      FilledButton.icon(
                        key: const ValueKey('surprise-next-button'),
                        onPressed: onPrimaryAction,
                        icon: Icon(_buttonIcon(page)),
                        label: Text(page.buttonLabel),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _buttonIcon(StoryPageData page) {
    if (page.kind == StoryPageKind.timeTogether) {
      return Icons.hourglass_top_rounded;
    }

    if (page.kind == StoryPageKind.wish) {
      return Icons.favorite_border_rounded;
    }

    return Icons.arrow_forward_rounded;
  }
}

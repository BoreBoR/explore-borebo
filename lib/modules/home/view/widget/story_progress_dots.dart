import 'package:benjii/util/app_color.dart';
import 'package:flutter/material.dart';

class StoryProgressDots extends StatelessWidget {
  const StoryProgressDots({
    super.key,
    required this.currentPage,
    required this.totalPages,
  });

  final int currentPage;
  final int totalPages;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Text(
          '$currentPage / $totalPages',
          style: textTheme.labelLarge?.copyWith(
            color: AppColor.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(totalPages, (index) {
            final isActive = index + 1 <= currentPage;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: isActive ? 18 : 7,
              height: 7,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: isActive ? AppColor.primaryBlue : AppColor.outline,
                borderRadius: BorderRadius.circular(8),
              ),
            );
          }),
        ),
      ],
    );
  }
}

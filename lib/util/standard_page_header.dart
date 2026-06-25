import 'package:benjii/util/app_color.dart';
import 'package:flutter/material.dart';

class StandardPageHeader extends StatelessWidget {
  const StandardPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.backButtonKey,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final Key? backButtonKey;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hasBack = onBack != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 58,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 58,
                child: hasBack
                    ? Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton.filled(
                          key: backButtonKey,
                          tooltip: 'Back',
                          onPressed: onBack,
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.displaySmall?.copyWith(
                    color: AppColor.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              SizedBox(
                width: 58,
                child: trailing == null
                    ? const SizedBox.shrink()
                    : Align(alignment: Alignment.centerRight, child: trailing),
              ),
            ],
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: EdgeInsets.only(left: hasBack ? 58 : 0),
            child: Text(
              subtitle!,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColor.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

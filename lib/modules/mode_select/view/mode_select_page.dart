import 'package:benjii/modular/number_random.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class ModeSelectPage extends StatelessWidget {
  const ModeSelectPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.apps_rounded,
                    size: 48,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Choose mode',
                    textAlign: TextAlign.center,
                    style: textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pick which app you want to open.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _ModeButton(
                    key: const ValueKey('number-random-mode-button'),
                    icon: Icons.casino_rounded,
                    title: 'Number Random',
                    subtitle: 'Generate a random number',
                    onTap: () {
                      Modular.to.navigate(
                        NumberRandomPageType.numberRandom.path,
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  _ModeButton(
                    key: const ValueKey('benji-message-mode-button'),
                    title: 'Coming soon',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    super.key,
    required this.title,
    this.icon,
    this.subtitle,
    this.onTap,
  });

  final IconData? icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isEnabled = onTap != null;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              if (icon != null) ...[
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SizedBox.square(
                    dimension: 48,
                    child: Icon(
                      icon,
                      color: isEnabled
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleMedium?.copyWith(
                        color: isEnabled
                            ? colorScheme.onSurface
                            : colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (isEnabled)
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

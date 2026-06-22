import 'package:benjii/modular/kang_game.dart';
import 'package:benjii/modular/number_random.dart';
import 'package:benjii/modules/auth/view/google_sign_in_button.dart';
import 'package:benjii/util/app_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class ModeSelectPage extends StatelessWidget {
  const ModeSelectPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 620),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 620),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 18 * (1 - value)),
                                child: child,
                              ),
                            );
                          },
                          child: Container(
                            width: 74,
                            height: 74,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  colorScheme.secondaryContainer,
                                  colorScheme.primaryContainer.withValues(
                                    alpha: 0.58,
                                  ),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.secondary.withValues(
                                    alpha: 0.12,
                                  ),
                                  blurRadius: 28,
                                  offset: const Offset(0, 14),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.apps_rounded,
                              size: 38,
                              color: colorScheme.primary,
                            ),
                          ),
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
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isNarrow = constraints.maxWidth < 440;
                            return GridView(
                              key: const ValueKey('mode-select-grid'),
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: isNarrow ? 1 : 2,
                                    mainAxisSpacing: 14,
                                    crossAxisSpacing: 14,
                                    mainAxisExtent: isNarrow ? 172 : 190,
                                  ),
                              children: [
                                _ModeButton(
                                  key: const ValueKey(
                                    'number-random-mode-button',
                                  ),
                                  icon: Icons.casino_rounded,
                                  title: 'Number Random',
                                  subtitle: 'Generate a random number',
                                  onTap: () {
                                    Modular.to.navigate(
                                      NumberRandomPageType.numberRandom.path,
                                    );
                                  },
                                ),
                                _ModeButton(
                                  key: ValueKey('benji-message-mode-button'),
                                  icon: Icons.hourglass_empty_rounded,
                                  title: 'Coming soon',
                                  onTap: () {
                                    // Modular.to.navigate(
                                    //
                                    // );
                                  },
                                ),
                                _ModeButton(
                                  key: const ValueKey('kang-game-mode-button'),
                                  icon: Icons.style_rounded,
                                  title: 'Kang Game',
                                  subtitle: 'Test local Thai Kang rules',
                                  onTap: () {
                                    Modular.to.navigate(
                                      KangGamePageType.kangGame.path,
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Positioned(top: 16, right: 16, child: GoogleSignInButton()),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeButton extends StatefulWidget {
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
  State<_ModeButton> createState() => _ModeButtonState();
}

class _ModeButtonState extends State<_ModeButton> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (_isPressed == value) {
      return;
    }
    setState(() => _isPressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isEnabled = widget.onTap != null;

    return AnimatedPhysicalModel(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      color: colorScheme.surface.withValues(alpha: 0.94),
      elevation: _isPressed ? 1 : 5,
      shadowColor: colorScheme.primary.withValues(alpha: 0.12),
      shape: BoxShape.rectangle,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          onTapDown: isEnabled ? (_) => _setPressed(true) : null,
          onTapCancel: isEnabled ? () => _setPressed(false) : null,
          onTapUp: isEnabled ? (_) => _setPressed(false) : null,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(
                color: isEnabled
                    ? colorScheme.primary.withValues(alpha: 0.13)
                    : colorScheme.outlineVariant,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.icon != null) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              colorScheme.primaryContainer.withValues(
                                alpha: isEnabled ? 0.62 : 0.24,
                              ),
                              colorScheme.secondaryContainer.withValues(
                                alpha: isEnabled ? 0.72 : 0.24,
                              ),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SizedBox.square(
                          dimension: 48,
                          child: Icon(
                            widget.icon,
                            color: isEnabled
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  Text(
                    widget.title,
                    style: textTheme.titleMedium?.copyWith(
                      color: isEnabled
                          ? colorScheme.onSurface
                          : colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (widget.subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle!,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

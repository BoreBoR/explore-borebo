import 'package:benjii/modular/kang_game.dart';
import 'package:benjii/modular/number_random.dart';
import 'package:benjii/modules/auth/view/google_sign_in_button.dart';
import 'package:benjii/modules/home/view/widget/story_pages.dart';
import 'package:benjii/util/app_background.dart';
import 'package:benjii/util/app_asset_preloader.dart';
import 'package:benjii/util/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class ModeSelectPage extends StatelessWidget {
  const ModeSelectPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppAssetPreloader(
      imageAssets: StoryPages.all[4].imageAssets,
      cacheWidth: 420,
      child: Scaffold(
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
                                      mainAxisExtent: isNarrow ? 204 : 214,
                                    ),
                                children: [
                                  _ModeButton(
                                    key: const ValueKey(
                                      'number-random-mode-button',
                                    ),
                                    icon: Icons.casino_rounded,
                                    actionIcon: Icons.casino_outlined,
                                    accentColor: AppColor.primaryBlue,
                                    softColor: AppColor.primaryBlueLight,
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
                                    icon: Icons.favorite_rounded,
                                    actionIcon: Icons.favorite_border_rounded,
                                    accentColor: AppColor.blushDeep,
                                    softColor: AppColor.blush,
                                    title: 'Coming soon',
                                    subtitle: 'Something sweet is waiting',
                                    onTap: () {
                                      // Modular.to.navigate(
                                      //
                                      // );
                                    },
                                  ),
                                  _ModeButton(
                                    key: const ValueKey(
                                      'kang-game-mode-button',
                                    ),
                                    icon: Icons.style_rounded,
                                    actionIcon: Icons.auto_awesome_rounded,
                                    accentColor: AppColor.warmGold,
                                    softColor: const Color(0xFFFFE2A8),
                                    title: 'Kang Game',
                                    subtitle: 'Play local Thai Kang rules',
                                    onTap: () {
                                      Modular.to.navigate(
                                        KangGamePageType.kangGame.path,
                                      );
                                    },
                                  ),
                                  _ModeButton(
                                    key: const ValueKey(
                                      'kang-multiplayer-mode-button',
                                    ),
                                    icon: Icons.groups_rounded,
                                    actionIcon: Icons.wifi_tethering_rounded,
                                    accentColor: const Color(0xFF6F4BD8),
                                    softColor: AppColor.lilac,
                                    title: 'Kang Online',
                                    subtitle: 'Create or join a live match',
                                    onTap: () {
                                      Modular.to.navigate(
                                        KangGamePageType.multiplayerLobby.path,
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
                const Positioned(
                  top: 16,
                  right: 16,
                  child: GoogleSignInButton(),
                ),
              ],
            ),
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
    this.actionIcon,
    required this.accentColor,
    required this.softColor,
    this.subtitle,
    this.onTap,
  });

  final IconData? icon;
  final IconData? actionIcon;
  final Color accentColor;
  final Color softColor;
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
    final foregroundColor = isEnabled
        ? colorScheme.onSurface
        : colorScheme.onSurfaceVariant;
    final accentColor = isEnabled
        ? widget.accentColor
        : colorScheme.onSurfaceVariant;
    final softColor = isEnabled
        ? widget.softColor
        : colorScheme.surfaceContainerHighest;

    return AnimatedPhysicalModel(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      color: colorScheme.surface.withValues(alpha: 0.98),
      elevation: _isPressed ? 2 : 7,
      shadowColor: accentColor.withValues(alpha: 0.17),
      shape: BoxShape.rectangle,
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          onTapDown: isEnabled ? (_) => _setPressed(true) : null,
          onTapCancel: isEnabled ? () => _setPressed(false) : null,
          onTapUp: isEnabled ? (_) => _setPressed(false) : null,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.12),
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FractionallySizedBox(
                    widthFactor: 0.48,
                    heightFactor: 1,
                    alignment: Alignment.centerRight,
                    child: ClipPath(
                      clipper: const _ModeButtonBandClipper(),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              softColor.withValues(alpha: 0.4),
                              accentColor.withValues(alpha: 0.92),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 16,
                bottom: 16,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withValues(alpha: 0.82),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.18),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: SizedBox.square(
                    dimension: 58,
                    child: Icon(
                      widget.actionIcon ?? widget.icon ?? Icons.apps_rounded,
                      color: accentColor,
                      size: 30,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 126, 14),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.icon != null) ...[
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              softColor.withValues(alpha: 0.78),
                              colorScheme.surface.withValues(alpha: 0.86),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SizedBox.square(
                          dimension: 46,
                          child: Icon(widget.icon, color: accentColor),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    Text(
                      widget.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleLarge?.copyWith(
                        color: foregroundColor,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (widget.subtitle != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        widget.subtitle!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeButtonBandClipper extends CustomClipper<Path> {
  const _ModeButtonBandClipper();

  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(size.width * 0.8, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant _ModeButtonBandClipper oldClipper) => false;
}

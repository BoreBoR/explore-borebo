import 'package:benjii/modular/home.dart';
import 'package:benjii/modular/landing.dart';
import 'package:benjii/modular/mode_select.dart';
import 'package:benjii/modular/timer_together.dart';
import 'package:benjii/modules/developer/config/developer_config.dart';
import 'package:benjii/modules/developer/controller/developer_navigation_controller.dart';
import 'package:benjii/modules/home/view/widget/story_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class DeveloperFloatingButton extends StatefulWidget {
  const DeveloperFloatingButton({super.key});

  @override
  State<DeveloperFloatingButton> createState() =>
      _DeveloperFloatingButtonState();
}

class _DeveloperFloatingButtonState extends State<DeveloperFloatingButton> {
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    if (!DeveloperConfig.enabled) {
      return const SizedBox.shrink();
    }

    return Positioned(
      right: 16,
      bottom: 16,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (_isOpen) ...[
              _DeveloperMenu(
                onNavigate: _handleNavigate,
                onNavigateModeSelect: _handleNavigateModeSelect,
                onNavigateTimerTogether: _handleNavigateTimerTogether,
              ),
              const SizedBox(height: 12),
            ],
            Material(
              key: const ValueKey('developer-floating-button'),
              color: Theme.of(context).colorScheme.primary,
              shape: const CircleBorder(),
              elevation: 6,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => setState(() => _isOpen = !_isOpen),
                child: SizedBox.square(
                  dimension: 44,
                  child: Icon(
                    _isOpen ? Icons.close_rounded : Icons.code_rounded,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleNavigate(int? storyPageIndex) {
    setState(() => _isOpen = false);

    if (storyPageIndex == null) {
      Modular.to.navigate(LandingPageType.landingScreen.path);
      return;
    }

    DeveloperNavigationController.instance.requestStoryPage(storyPageIndex);
    Modular.to.navigate(HomePageType.homepage.path);
  }

  void _handleNavigateModeSelect() {
    setState(() => _isOpen = false);
    Modular.to.navigate(ModeSelectPageType.modeSelect.path);
  }

  void _handleNavigateTimerTogether() {
    setState(() => _isOpen = false);
    Modular.to.navigate(TimerTogetherPageType.timerTogether.path);
  }
}

class _DeveloperMenu extends StatelessWidget {
  const _DeveloperMenu({
    required this.onNavigate,
    required this.onNavigateModeSelect,
    required this.onNavigateTimerTogether,
  });

  final ValueChanged<int?> onNavigate;
  final VoidCallback onNavigateModeSelect;
  final VoidCallback onNavigateTimerTogether;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      key: const ValueKey('developer-navigation-menu'),
      elevation: 10,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 310, maxHeight: 480),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
              child: Text(
                'Developer navigation',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            ListTile(
              dense: true,
              leading: const Icon(Icons.apps_rounded),
              title: const Text('Mode select'),
              subtitle: const Text('Go back to the first screen'),
              onTap: onNavigateModeSelect,
            ),
            ListTile(
              dense: true,
              leading: const Icon(Icons.lock_outline_rounded),
              title: const Text('PIN page'),
              subtitle: const Text('Open Benji Message PIN'),
              onTap: () => onNavigate(null),
            ),
            ListTile(
              key: const ValueKey('developer-timer-together-button'),
              dense: true,
              leading: const Icon(Icons.hourglass_top_rounded),
              title: const Text('Timer together'),
              subtitle: const Text('Open module 3'),
              onTap: onNavigateTimerTogether,
            ),
            const Divider(height: 1),
            for (var index = 0; index < StoryPages.all.length; index++)
              ListTile(
                dense: true,
                leading: CircleAvatar(radius: 13, child: Text('${index + 1}')),
                title: Text(StoryPages.all[index].title),
                subtitle: Text('Story page ${index + 1}'),
                onTap: () => onNavigate(index),
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:benjii/modular/timer_together.dart';
import 'package:benjii/modules/home/bloc/home_bloc.dart';
import 'package:benjii/modules/developer/controller/developer_navigation_controller.dart';
import 'package:benjii/modules/home/view/widget/story_page.dart';
import 'package:benjii/modules/home/view/widget/story_page_data.dart';
import 'package:benjii/modules/home/view/widget/story_pages.dart';
import 'package:benjii/util/app_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key, this.onStoryComplete});

  final VoidCallback? onStoryComplete;

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final _developerNavigationController = DeveloperNavigationController.instance;

  int _currentPage = 0;
  int _pageDirection = 1;

  @override
  void initState() {
    super.initState();
    _applyRequestedStoryPage();
    _developerNavigationController.addListener(_applyRequestedStoryPage);
  }

  @override
  void dispose() {
    _developerNavigationController.removeListener(_applyRequestedStoryPage);
    super.dispose();
  }

  void _applyRequestedStoryPage() {
    final requestedIndex = _developerNavigationController
        .takeRequestedStoryPageIndex();
    if (requestedIndex == null) {
      return;
    }

    final nextIndex = requestedIndex.clamp(0, StoryPages.all.length - 1);
    if (mounted) {
      setState(() {
        _pageDirection = nextIndex >= _currentPage ? 1 : -1;
        _currentPage = nextIndex;
      });
    } else {
      _currentPage = nextIndex;
    }
  }

  void _handlePrimaryAction() {
    final current = StoryPages.all[_currentPage];

    if (current.kind == StoryPageKind.timeTogether) {
      final onStoryComplete = widget.onStoryComplete;
      if (onStoryComplete != null) {
        onStoryComplete();
      } else {
        Modular.to.navigate(TimerTogetherPageType.timerTogether.path);
      }
      return;
    }

    if (_currentPage < StoryPages.all.length - 1) {
      setState(() {
        _pageDirection = 1;
        _currentPage += 1;
      });
    }
  }

  void _goBack() {
    if (_currentPage > 0) {
      setState(() {
        _pageDirection = -1;
        _currentPage -= 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final current = StoryPages.all[_currentPage];

        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: _currentPage == 0
              ? null
              : FloatingActionButton.small(
                  key: const ValueKey('story-back-button'),
                  heroTag: 'story-back-button',
                  tooltip: 'Back',
                  onPressed: _goBack,
                  child: const Icon(Icons.arrow_back_ios_new_rounded),
                ),
          floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
          body: AppBackground(
            child: SafeArea(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 520),
                reverseDuration: const Duration(milliseconds: 340),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  final curvedAnimation = CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                    reverseCurve: Curves.easeInCubic,
                  );
                  final offset = Tween<Offset>(
                    begin: Offset(0.08 * _pageDirection, 0),
                    end: Offset.zero,
                  ).animate(curvedAnimation);
                  final scale = Tween<double>(
                    begin: 0.985,
                    end: 1,
                  ).animate(curvedAnimation);

                  return FadeTransition(
                    opacity: curvedAnimation,
                    child: SlideTransition(
                      position: offset,
                      child: ScaleTransition(scale: scale, child: child),
                    ),
                  );
                },
                child: StoryPage(
                  key: ValueKey(current.title),
                  page: current,
                  pageNumber: _currentPage + 1,
                  totalPages: StoryPages.all.length,
                  onPrimaryAction: _handlePrimaryAction,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

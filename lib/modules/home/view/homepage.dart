import 'package:benjii/modules/home/bloc/home_bloc.dart';
import 'package:benjii/modules/developer/controller/developer_navigation_controller.dart';
import 'package:benjii/modules/home/view/widget/story_page.dart';
import 'package:benjii/modules/home/view/widget/story_page_data.dart';
import 'package:benjii/modules/home/view/widget/story_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final _developerNavigationController = DeveloperNavigationController.instance;

  int _currentPage = 0;

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
      setState(() => _currentPage = nextIndex);
    } else {
      _currentPage = nextIndex;
    }
  }

  void _handlePrimaryAction() {
    final current = StoryPages.all[_currentPage];

    if (current.kind == StoryPageKind.restart) {
      setState(() => _currentPage = 0);
      return;
    }

    if (_currentPage < StoryPages.all.length - 1) {
      setState(() => _currentPage += 1);
    }
  }

  void _goBack() {
    if (_currentPage > 0) {
      setState(() => _currentPage -= 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final current = StoryPages.all[_currentPage];

        return Scaffold(
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
          body: SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 1500),
              reverseDuration: const Duration(milliseconds: 500),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeOut,
              transitionBuilder: (child, animation) {
                final pageAnimation = CurvedAnimation(
                  parent: animation,
                  curve: const Interval(0.38, 1, curve: Curves.easeOut),
                  reverseCurve: Curves.easeOut,
                );
                final offsetAnimation = Tween<Offset>(
                  begin: const Offset(0, 0),
                  end: Offset.zero,
                ).animate(pageAnimation);

                return FadeTransition(
                  opacity: pageAnimation,
                  child: SlideTransition(
                    position: offsetAnimation,
                    child: child,
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
        );
      },
    );
  }
}

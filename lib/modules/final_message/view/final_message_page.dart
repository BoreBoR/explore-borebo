import 'dart:async';

import 'package:benjii/modular/mode_select.dart';
import 'package:benjii/util/app_background.dart';
import 'package:benjii/util/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class FinalMessagePage extends StatefulWidget {
  const FinalMessagePage({super.key});

  static const messages = [
    'Final message placeholder 1',
    'Final message placeholder 2',
    'Final message placeholder 3',
    'Final message placeholder 4',
  ];

  @override
  State<FinalMessagePage> createState() => _FinalMessagePageState();
}

class _FinalMessagePageState extends State<FinalMessagePage> {
  static const _fadeDuration = Duration(milliseconds: 700);
  static const _messageHoldDuration = Duration(milliseconds: 1400);
  static const _countDelay = Duration(seconds: 1);

  final List<Timer> _timers = [];
  int _messageIndex = 0;
  int _count = 0;
  bool _messageVisible = false;

  bool get _isLastMessage =>
      _messageIndex == FinalMessagePage.messages.length - 1;

  bool get _showQuitButton => _count >= 3;

  @override
  void initState() {
    super.initState();
    _schedule(const Duration(milliseconds: 120), () {
      setState(() => _messageVisible = true);
      _scheduleMessageStep();
    });
  }

  @override
  void dispose() {
    for (final timer in _timers) {
      timer.cancel();
    }
    super.dispose();
  }

  void _schedule(Duration duration, VoidCallback callback) {
    final timer = Timer(duration, () {
      if (!mounted) {
        return;
      }
      callback();
    });
    _timers.add(timer);
  }

  void _scheduleMessageStep() {
    if (_isLastMessage) {
      _schedule(_messageHoldDuration, _startCount);
      return;
    }

    _schedule(_messageHoldDuration, () {
      setState(() => _messageVisible = false);
      _schedule(_fadeDuration, () {
        setState(() {
          _messageIndex += 1;
          _messageVisible = true;
        });
        _scheduleMessageStep();
      });
    });
  }

  void _startCount() {
    _schedule(_countDelay, () {
      setState(() => _count += 1);
      if (_count < 3) {
        _startCount();
      }
    });
  }

  void _quitProgram() {
    Modular.to.navigate(ModeSelectPageType.modeSelect.path);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                              AppColor.blush,
                              AppColor.lilac.withValues(alpha: 0.78),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(26),
                          boxShadow: [
                            BoxShadow(
                              color: AppColor.blushDeep.withValues(alpha: 0.1),
                              blurRadius: 30,
                              offset: const Offset(0, 16),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.favorite_rounded,
                          color: AppColor.blushDeep,
                          size: 42,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    AnimatedOpacity(
                      key: const ValueKey('final-message-page'),
                      opacity: _messageVisible ? 1 : 0,
                      duration: _fadeDuration,
                      curve: Curves.easeOut,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColor.surface.withValues(alpha: 0.84),
                          border: Border.all(
                            color: AppColor.outline.withValues(alpha: 0.7),
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColor.primaryBlueDark.withValues(
                                alpha: 0.06,
                              ),
                              blurRadius: 26,
                              offset: const Offset(0, 14),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 24,
                          ),
                          child: Text(
                            FinalMessagePage.messages[_messageIndex],
                            key: ValueKey('final-message-text-$_messageIndex'),
                            textAlign: TextAlign.center,
                            style: textTheme.headlineSmall?.copyWith(
                              color: AppColor.textPrimary,
                              fontWeight: FontWeight.w800,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      height: 48,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _count == 0
                            ? const SizedBox.shrink()
                            : Text(
                                '$_count',
                                key: ValueKey('final-message-count-$_count'),
                                textAlign: TextAlign.center,
                                style: textTheme.displaySmall?.copyWith(
                                  color: AppColor.blushDeep,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 48,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 700),
                        switchInCurve: Curves.easeOut,
                        child: _showQuitButton
                            ? FilledButton.icon(
                                key: const ValueKey('quit-program-button'),
                                onPressed: _quitProgram,
                                icon: const Icon(Icons.logout_rounded),
                                label: const Text('Quit program'),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

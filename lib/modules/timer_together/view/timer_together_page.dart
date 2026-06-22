import 'dart:async';
import 'dart:math' as math;

import 'package:benjii/modular/final_message.dart';
import 'package:benjii/util/app_background.dart';
import 'package:benjii/util/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class TimerTogetherPage extends StatefulWidget {
  const TimerTogetherPage({super.key});

  @override
  State<TimerTogetherPage> createState() => _TimerTogetherPageState();
}

class _TimerTogetherPageState extends State<TimerTogetherPage> {
  Timer? _continueButtonTimer;
  bool _showContinueButton = false;

  @override
  void initState() {
    super.initState();
    _continueButtonTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _showContinueButton = true);
      }
    });
  }

  @override
  void dispose() {
    _continueButtonTimer?.cancel();
    super.dispose();
  }

  void _openFinalMessage() {
    Modular.to.navigate(FinalMessagePageType.finalMessage.path);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
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
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColor.blush,
                              AppColor.primaryBlueLight.withValues(alpha: 0.28),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(26),
                          boxShadow: [
                            BoxShadow(
                              color: AppColor.primaryBlueDark.withValues(
                                alpha: 0.1,
                              ),
                              blurRadius: 30,
                              offset: const Offset(0, 16),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.hourglass_top_rounded,
                          color: AppColor.primaryBlue,
                          size: 36,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Since we became us',
                      textAlign: TextAlign.center,
                      style: textTheme.displaySmall?.copyWith(
                        color: AppColor.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Counting every moment since 14 February 2026, 8:00 PM.',
                      textAlign: TextAlign.center,
                      style: textTheme.titleMedium?.copyWith(
                        color: AppColor.textSecondary,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 32),
                    const _RelationshipTimer(),
                    const SizedBox(height: 28),
                    SizedBox(
                      height: 48,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 700),
                        switchInCurve: Curves.easeOut,
                        child: _showContinueButton
                            ? FilledButton.icon(
                                key: const ValueKey(
                                  'timer-final-message-button',
                                ),
                                onPressed: _openFinalMessage,
                                icon: const Icon(Icons.arrow_forward_rounded),
                                label: const Text('Continue'),
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

class _RelationshipTimer extends StatefulWidget {
  const _RelationshipTimer();

  @override
  State<_RelationshipTimer> createState() => _RelationshipTimerState();
}

class _RelationshipTimerState extends State<_RelationshipTimer> {
  static final DateTime _startedAt = DateTime.utc(2026, 2, 14, 13);

  late Duration _elapsed = _calculateElapsed();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsed = _calculateElapsed());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Duration _calculateElapsed() {
    final elapsed = DateTime.now().toUtc().difference(_startedAt);
    if (elapsed.isNegative) {
      return Duration.zero;
    }

    return elapsed;
  }

  @override
  Widget build(BuildContext context) {
    final days = _elapsed.inDays;
    final hours = _elapsed.inHours.remainder(24);
    final minutes = _elapsed.inMinutes.remainder(60);
    final seconds = _elapsed.inSeconds.remainder(60);

    return Column(
      children: [
        _DayCircle(days: days),
        const SizedBox(height: 24),
        _TimeGroup(hours: hours, minutes: minutes, seconds: seconds),
      ],
    );
  }
}

class _DayCircle extends StatelessWidget {
  const _DayCircle({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Container(
        width: 216,
        height: 216,
        decoration: BoxDecoration(
          color: AppColor.surface,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColor.blushDeep.withValues(alpha: 0.18),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColor.blushDeep.withValues(alpha: 0.09),
              blurRadius: 34,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(26),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: _FlipClockValue(
                  value: days.toString(),
                  textStyle: textTheme.displayMedium?.copyWith(
                    color: AppColor.primaryBlue,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Days',
                textAlign: TextAlign.center,
                style: textTheme.titleMedium?.copyWith(
                  color: AppColor.textSecondary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeGroup extends StatelessWidget {
  const _TimeGroup({
    required this.hours,
    required this.minutes,
    required this.seconds,
  });

  final int hours;
  final int minutes;
  final int seconds;

  @override
  Widget build(BuildContext context) {
    final numberStyle = Theme.of(context).textTheme.headlineMedium?.copyWith(
      color: AppColor.primaryBlue,
      fontWeight: FontWeight.w900,
      height: 1,
    );
    final labelStyle = Theme.of(context).textTheme.labelMedium?.copyWith(
      color: AppColor.textSecondary,
      fontWeight: FontWeight.w700,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColor.surface.withValues(alpha: 0.9),
        border: Border.all(color: AppColor.outline.withValues(alpha: 0.72)),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColor.primaryBlueDark.withValues(alpha: 0.07),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
        child: Row(
          children: [
            Expanded(
              child: _TimerUnit(
                value: hours.toString().padLeft(2, '0'),
                label: 'Hours',
                numberStyle: numberStyle,
                labelStyle: labelStyle,
              ),
            ),
            const _TimeDivider(),
            Expanded(
              child: _TimerUnit(
                value: minutes.toString().padLeft(2, '0'),
                label: 'Minutes',
                numberStyle: numberStyle,
                labelStyle: labelStyle,
              ),
            ),
            const _TimeDivider(),
            Expanded(
              child: _TimerUnit(
                value: seconds.toString().padLeft(2, '0'),
                label: 'Seconds',
                numberStyle: numberStyle,
                labelStyle: labelStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimerUnit extends StatelessWidget {
  const _TimerUnit({
    required this.value,
    required this.label,
    required this.numberStyle,
    required this.labelStyle,
  });

  final String value;
  final String label;
  final TextStyle? numberStyle;
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: _FlipClockValue(value: value, textStyle: numberStyle),
        ),
        const SizedBox(height: 8),
        Text(label, textAlign: TextAlign.center, style: labelStyle),
      ],
    );
  }
}

class _FlipClockValue extends StatefulWidget {
  const _FlipClockValue({required this.value, required this.textStyle});

  final String value;
  final TextStyle? textStyle;

  @override
  State<_FlipClockValue> createState() => _FlipClockValueState();
}

class _FlipClockValueState extends State<_FlipClockValue>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late String _previousValue = widget.value;
  late String _currentValue = widget.value;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 620),
    );
  }

  @override
  void didUpdateWidget(covariant _FlipClockValue oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value == widget.value) {
      return;
    }

    _previousValue = oldWidget.value;
    _currentValue = widget.value;
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final progress = _controller.value;
        final isAnimating = progress > 0 && progress < 1;
        final valueWidth = _valueWidth;
        final valueHeight = _valueHeight;
        final foldOut = Curves.easeInCubic.transform(
          (progress * 2).clamp(0, 1),
        );
        final foldIn = Curves.easeOutCubic.transform(
          ((progress - 0.5) * 2).clamp(0, 1),
        );

        return SizedBox(
          width: valueWidth,
          height: valueHeight,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              _FlipHalf(
                value: _currentValue,
                textStyle: widget.textStyle,
                half: _FlipHalfPosition.top,
                width: valueWidth,
                height: valueHeight,
              ),
              _FlipHalf(
                value: isAnimating ? _previousValue : _currentValue,
                textStyle: widget.textStyle,
                half: _FlipHalfPosition.bottom,
                width: valueWidth,
                height: valueHeight,
              ),
              if (isAnimating && progress < 0.5)
                _FlipHalf(
                  value: _previousValue,
                  textStyle: widget.textStyle,
                  half: _FlipHalfPosition.top,
                  width: valueWidth,
                  height: valueHeight,
                  rotationX: -math.pi / 2 * foldOut,
                  shadowOpacity: foldOut * 0.22,
                ),
              if (isAnimating && progress >= 0.5)
                _FlipHalf(
                  value: _currentValue,
                  textStyle: widget.textStyle,
                  half: _FlipHalfPosition.bottom,
                  width: valueWidth,
                  height: valueHeight,
                  rotationX: math.pi / 2 * (1 - foldIn),
                  shadowOpacity: (1 - foldIn) * 0.22,
                ),
            ],
          ),
        );
      },
    );
  }

  double get _valueWidth {
    final fontSize = widget.textStyle?.fontSize ?? 34;
    final longestValue = math.max(_previousValue.length, _currentValue.length);
    return math.max(58, fontSize * (longestValue * 0.72) + 20);
  }

  double get _valueHeight {
    final fontSize = widget.textStyle?.fontSize ?? 34;
    return math.max(50, fontSize * 1.35);
  }
}

enum _FlipHalfPosition { top, bottom }

class _FlipHalf extends StatelessWidget {
  const _FlipHalf({
    required this.value,
    required this.textStyle,
    required this.half,
    required this.width,
    required this.height,
    this.rotationX = 0,
    this.shadowOpacity = 0,
  });

  final String value;
  final TextStyle? textStyle;
  final _FlipHalfPosition half;
  final double width;
  final double height;
  final double rotationX;
  final double shadowOpacity;

  @override
  Widget build(BuildContext context) {
    final isTop = half == _FlipHalfPosition.top;
    final halfHeight = height / 2;

    return Positioned(
      top: isTop ? 0 : null,
      bottom: isTop ? null : 0,
      width: width,
      height: halfHeight,
      child: Transform(
        alignment: isTop ? Alignment.bottomCenter : Alignment.topCenter,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.0018)
          ..rotateX(rotationX),
        child: ClipRect(
          child: Stack(
            fit: StackFit.expand,
            children: [
              OverflowBox(
                alignment: isTop ? Alignment.topCenter : Alignment.bottomCenter,
                minWidth: width,
                maxWidth: width,
                minHeight: height,
                maxHeight: height,
                child: Center(
                  child: Text(value, maxLines: 1, style: textStyle),
                ),
              ),
              if (shadowOpacity > 0)
                Positioned.fill(
                  child: ColoredBox(
                    color: AppColor.textPrimary.withValues(
                      alpha: shadowOpacity,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeDivider extends StatelessWidget {
  const _TimeDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 52,
      color: AppColor.outline.withValues(alpha: 0.72),
    );
  }
}

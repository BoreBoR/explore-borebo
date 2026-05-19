import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class NumberRandomPage extends StatefulWidget {
  const NumberRandomPage({super.key});

  @override
  State<NumberRandomPage> createState() => _NumberRandomPageState();
}

class _NumberRandomPageState extends State<NumberRandomPage> {
  final _random = Random();
  int _digitCount = 6;
  String? _result;
  final List<String> _history = [];

  void _changeDigitCount(double value) {
    setState(() {
      _digitCount = value.round();
    });
  }

  void _generate() {
    final nextResult = List.generate(
      _digitCount,
      (_) => _random.nextInt(10).toString(),
    ).join();

    setState(() {
      _result = nextResult;
      _history.insert(0, nextResult);
      if (_history.length > 10) {
        _history.removeRange(10, _history.length);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Modular.to.navigate('/'),
        ),
        title: const Text('Number Random'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _NumberBoxes(result: _result, digitCount: _digitCount),
                  const SizedBox(height: 24),
                  _DigitSlider(
                    value: _digitCount,
                    onChanged: _changeDigitCount,
                  ),
                  const SizedBox(height: 28),
                  FilledButton.icon(
                    key: const ValueKey('generate-number-button'),
                    onPressed: _generate,
                    icon: const Icon(Icons.casino_rounded),
                    label: const Text('Generate'),
                  ),
                  const SizedBox(height: 28),
                  _HistoryList(history: _history),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NumberBoxes extends StatelessWidget {
  const _NumberBoxes({required this.result, required this.digitCount});

  final String? result;
  final int digitCount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final digits = result?.padLeft(6, ' ') ?? ''.padLeft(6, ' ');
    final firstActiveIndex = 6 - digitCount;

    return Row(
      key: const ValueKey('random-result-boxes'),
      children: [
        for (var index = 0; index < 6; index++) ...[
          Expanded(
            child: AspectRatio(
              aspectRatio: 0.82,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: index >= firstActiveIndex
                      ? colorScheme.surface
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: index >= firstActiveIndex
                        ? colorScheme.primary.withValues(alpha: 0.35)
                        : colorScheme.outlineVariant,
                  ),
                ),
                child: Center(
                  child: Text(
                    digits[index].trim().isEmpty ? '-' : digits[index],
                    key: ValueKey('random-result-digit-$index'),
                    style: textTheme.headlineMedium?.copyWith(
                      color: index >= firstActiveIndex
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (index < 5) const SizedBox(width: 8),
        ],
      ],
    );
  }
}

class _DigitSlider extends StatelessWidget {
  const _DigitSlider({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Digits',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              '$value',
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        Slider(
          value: value.toDouble(),
          min: 1,
          max: 6,
          divisions: 5,
          label: '$value',
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _HistoryList extends StatelessWidget {
  const _HistoryList({required this.history});

  final List<String> history;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      key: const ValueKey('random-history'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'History',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        if (history.isEmpty)
          Text(
            'No guesses yet',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          )
        else
          for (var index = 0; index < history.length; index++) ...[
            _HistoryRow(index: index + 1, value: history[index]),
            if (index < history.length - 1)
              Divider(height: 1, color: colorScheme.outlineVariant),
          ],
      ],
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.index, required this.value});

  final int index;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 34,
            child: Text(
              '#$index',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              key: ValueKey('random-history-item-$index'),
              textAlign: TextAlign.right,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

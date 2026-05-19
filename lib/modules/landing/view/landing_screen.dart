import 'package:benjii/modules/landing/view/widget/pin_input_button.dart';
import 'package:benjii/modular/home.dart';
import 'package:benjii/modules/landing/controller/pin_gate_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:pinput/pinput.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: const SafeArea(child: PinWidget()));
  }
}

class PinWidget extends StatefulWidget {
  const PinWidget({super.key});

  @override
  State<PinWidget> createState() => _PinWidgetState();
}

class _PinWidgetState extends State<PinWidget> {
  final _formKey = GlobalKey<FormState>();
  final _pinController = TextEditingController();
  String? _errorText;

  @override
  void initState() {
    super.initState();
    PinGateController.lock();
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  String? _validatePin(String? value) {
    final pin = value ?? '';
    if (pin.length != 6) {
      return 'PIN must be 6 digits';
    }

    switch (pin) {
      case '140226':
        return null;
      case '123456':
        return 'Hmm, not that one. Try the day that matters to us.';
      default:
        return 'Hmm, not that one. Try the day that matters to us.';
    }
  }

  void _validateCompletedPin() {
    final errorText = _validatePin(_pinController.text);
    setState(() {
      _errorText = errorText;
    });

    if (errorText == null) {
      PinGateController.unlock();
      Modular.to.navigate(HomePageType.homepage.path);
    }
  }

  void _addDigit(String digit) {
    if (_errorText != null) {
      _pinController.clear();
    }

    setState(() => _errorText = null);
    _pinController.append(digit, 6);

    if (_pinController.text.length == 6) {
      _validateCompletedPin();
    }
  }

  void _deleteDigit() {
    setState(() => _errorText = null);
    _pinController.delete();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final size = MediaQuery.sizeOf(context);
    final contentWidth = size.width < 520 ? double.infinity : 480.0;
    final errorTextStyle = textTheme.bodyMedium?.copyWith(
      color: colorScheme.error,
      fontWeight: FontWeight.w600,
    );
    final defaultPinTheme = PinTheme(
      width: 64,
      height: 58,
      textStyle: textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(16),
      ),
    );
    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: colorScheme.primary, width: 1.5),
      borderRadius: BorderRadius.circular(16),
    );
    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: colorScheme.primaryContainer.withValues(alpha: 0.35),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.45)),
      ),
    );
    final errorPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: colorScheme.error, width: 1.5),
      borderRadius: BorderRadius.circular(16),
    );

    return Form(
      key: _formKey,
      child: SizedBox.expand(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'For someone special',
                      textAlign: TextAlign.center,
                      style: textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter the secret date to open your surprise',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Pinput(
                      key: const ValueKey('pin-display'),
                      controller: _pinController,
                      length: 6,
                      useNativeKeyboard: false,
                      showCursor: false,
                      enableInteractiveSelection: false,
                      toolbarEnabled: false,
                      defaultPinTheme: defaultPinTheme,
                      focusedPinTheme: focusedPinTheme,
                      submittedPinTheme: submittedPinTheme,
                      errorPinTheme: errorPinTheme,
                      forceErrorState: _errorText != null,
                      errorText: _errorText,
                      errorBuilder: (errorText, _) {
                        if (errorText == null) {
                          return const SizedBox.shrink();
                        }

                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Text(errorText, style: errorTextStyle),
                        );
                      },
                      pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                      validator: _validatePin,
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 3),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentWidth),
                child: _PinKeyboard(
                  onDigitPressed: _addDigit,
                  onDeletePressed: _deleteDigit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PinKeyboard extends StatelessWidget {
  const _PinKeyboard({
    required this.onDigitPressed,
    required this.onDeletePressed,
  });

  final ValueChanged<String> onDigitPressed;
  final VoidCallback onDeletePressed;

  @override
  Widget build(BuildContext context) {
    final keys = [
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '',
      '0',
      'delete',
    ];

    return GridView.builder(
      key: const ValueKey('pin-keyboard'),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 1.8,
      ),
      itemCount: keys.length,
      itemBuilder: (context, index) {
        final key = keys[index];
        if (key.isEmpty) {
          return const SizedBox.shrink();
        }

        if (key == 'delete') {
          return FilledButton.tonal(
            key: const ValueKey('pin-key-delete'),
            style: FilledButton.styleFrom(shape: const CircleBorder()),
            onPressed: onDeletePressed,
            child: const Icon(Icons.backspace_outlined),
          );
        }

        return KeyedSubtree(
          key: ValueKey('pin-key-$key'),
          child: Center(
            child: pinInputButton(
              digit: key,
              onPressed: () => onDigitPressed(key),
            ),
          ),
        );
      },
    );
  }
}

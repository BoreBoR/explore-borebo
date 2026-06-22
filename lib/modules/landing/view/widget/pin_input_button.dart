import 'package:benjii/util/app_color.dart';
import 'package:flutter/material.dart';

Widget pinInputButton({
  required String digit,
  required VoidCallback onPressed,
}) {
  return _PinInputButton(digit: digit, onPressed: onPressed);
}

class _PinInputButton extends StatefulWidget {
  const _PinInputButton({required this.digit, required this.onPressed});

  final String digit;
  final VoidCallback onPressed;

  @override
  State<_PinInputButton> createState() => _PinInputButtonState();
}

class _PinInputButtonState extends State<_PinInputButton> {
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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 130),
      curve: Curves.easeOut,
      height: 62,
      decoration: BoxDecoration(
        color: _isPressed
            ? AppColor.primaryBlue.withValues(alpha: 0.12)
            : AppColor.surface.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isPressed
              ? AppColor.primaryBlue.withValues(alpha: 0.34)
              : AppColor.primaryBlue.withValues(alpha: 0.16),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.primaryBlueDark.withValues(alpha: 0.09),
            blurRadius: _isPressed ? 8 : 18,
            offset: Offset(0, _isPressed ? 4 : 9),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onPressed,
          onTapDown: (_) => _setPressed(true),
          onTapCancel: () => _setPressed(false),
          onTapUp: (_) => _setPressed(false),
          child: Center(
            child: Text(
              widget.digit,
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taka/theme/taka_colors.dart';

// On desktop Flutter's focus highlight mode can't tell a click from a Tab, so
// whether the last input was a key is tracked here instead.
final _lastInputWasKey = ValueNotifier(false);

ValueListenable<bool> get lastInputWasKey => _lastInputWasKey;

void watchInputKind() {
  HardwareKeyboard.instance.addHandler((event) {
    if (event is KeyDownEvent) _lastInputWasKey.value = true;
    return false;
  });
  GestureBinding.instance.pointerRouter.addGlobalRoute((event) {
    if (event is PointerDownEvent) _lastInputWasKey.value = false;
  });
}

/// An accent outline over [child] while it [isFocused] from the keyboard.
class const FocusRing({
  super.key,
  required final bool isFocused,
  final BorderRadius? borderRadius,
  required final Widget child,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _lastInputWasKey,
      child: child,
      builder: (context, lastInputWasKey, child) => DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: isFocused && lastInputWasKey
            ? BoxDecoration(
                border: Border.all(color: TakaColors.of(context).accent),
                borderRadius: borderRadius,
              )
            : const BoxDecoration(),
        child: child,
      ),
    );
  }
}

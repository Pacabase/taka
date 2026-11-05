import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

final _modifiers = {
  LogicalKeyboardKey.shiftLeft,
  LogicalKeyboardKey.shiftRight,
  LogicalKeyboardKey.controlLeft,
  LogicalKeyboardKey.controlRight,
  LogicalKeyboardKey.altLeft,
  LogicalKeyboardKey.altRight,
  LogicalKeyboardKey.metaLeft,
  LogicalKeyboardKey.metaRight,
  LogicalKeyboardKey.capsLock,
  LogicalKeyboardKey.fn,
};

// On desktop Flutter keeps showing focus highlights after a click, so they
// follow the last input instead: shown after a key, hidden after a click.
void watchInputKind() {
  final focus = FocusManager.instance
    ..highlightStrategy = FocusHighlightStrategy.alwaysTouch;
  HardwareKeyboard.instance.addHandler((event) {
    if (event is KeyDownEvent && !_modifiers.contains(event.logicalKey)) {
      focus.highlightStrategy = FocusHighlightStrategy.alwaysTraditional;
    }
    return false;
  });
  GestureBinding.instance.pointerRouter.addGlobalRoute((event) {
    if (event is PointerDownEvent) {
      focus.highlightStrategy = FocusHighlightStrategy.alwaysTouch;
    }
  });
}

bool get showsFocus =>
    FocusManager.instance.highlightMode == FocusHighlightMode.traditional;

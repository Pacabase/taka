import 'dart:ffi';

import 'package:agent/src/appkit_bindings.g.dart';
import 'package:core/core.dart';
import 'package:objective_c/objective_c.dart';

/// Brings Taka in front while tunnels connect, then hands focus back to the
/// app that had it once the last one is done.
class Foreground({
  required final Future<void> Function() activate,
  required final int? Function() frontmostApp,
  required final void Function(int pid) activateApp,
  required final int self,
}) {
  int _holds = 0;
  // Kept between holds: just after a hand back, Taka may still be in front.
  int? _previous;
  Future<void>? _activating;

  Future<HandBack> comeForward() async {
    final front = frontmostApp();
    final isHeld = _holds > 0 && front == self;
    if (_holds == 0 && front != self) _previous = front;
    _holds++;
    var isHandedBack = false;
    Future<void> handBack() async {
      if (isHandedBack) return;
      isHandedBack = true;
      if (--_holds > 0) return;

      final previous = _previous;
      // The user, or 1Password's prompt, may have moved on by now.
      if (previous != null && frontmostApp() == self) activateApp(previous);
    }

    try {
      if (!isHeld) {
        await (_activating ??= _activate().whenComplete(
          () => _activating = null,
        ));
      }
    } on Object {
      await handBack();
      rethrow;
    }
    return handBack;
  }

  // open returns before the switch it asks for, which a hand back must see.
  Future<void> _activate() async {
    await activate();
    for (var tries = 0; tries < 20 && frontmostApp() != self; tries++) {
      await Future<void>.delayed(const Duration(milliseconds: 25));
    }
  }
}

// nativeapi loads AppKit too, but these shouldn't count on it; opening it
// again is only a count.
T _inAppKit<T>(T Function() body) {
  DynamicLibrary.open('/System/Library/Frameworks/AppKit.framework/AppKit');
  return autoReleasePool(body);
}

/// The pid of the app in front on macOS, or null if none is.
int? macFrontmostApp() => _inAppKit(
  () =>
      NSWorkspace.getSharedWorkspace().frontmostApplication?.processIdentifier,
);

/// Brings the macOS app with [pid] in front, if it still runs.
void macActivateApp(int pid) => _inAppKit(
  // Ignoring other apps does nothing since macOS 14, where activating is a
  // request; Taka is in front when it asks, so it's granted.
  () => NSRunningApplication.runningApplicationWithProcessIdentifier(pid)
      ?.activateWithOptions(
        NSApplicationActivationOptions.NSApplicationActivateIgnoringOtherApps,
      ),
);

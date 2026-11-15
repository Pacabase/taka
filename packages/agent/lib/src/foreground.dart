import 'dart:ffi';

import 'package:core/core.dart';
import 'package:ffi/ffi.dart';

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

@Native<Pointer<Void> Function(Pointer<Utf8>)>(symbol: 'objc_getClass')
external Pointer<Void> _class(Pointer<Utf8> name);

@Native<Pointer<Void> Function(Pointer<Utf8>)>(symbol: 'sel_registerName')
external Pointer<Void> _selector(Pointer<Utf8> name);

@Native<Pointer<Void> Function(Pointer<Void>, Pointer<Void>)>(
  symbol: 'objc_msgSend',
)
external Pointer<Void> _sendForObject(
  Pointer<Void> receiver,
  Pointer<Void> selector,
);

@Native<Int32 Function(Pointer<Void>, Pointer<Void>)>(symbol: 'objc_msgSend')
external int _sendForInt(Pointer<Void> receiver, Pointer<Void> selector);

@Native<Pointer<Void> Function(Pointer<Void>, Pointer<Void>, Int32)>(
  symbol: 'objc_msgSend',
)
external Pointer<Void> _sendWithInt(
  Pointer<Void> receiver,
  Pointer<Void> selector,
  int argument,
);

@Native<Bool Function(Pointer<Void>, Pointer<Void>, UnsignedLong)>(
  symbol: 'objc_msgSend',
)
external bool _sendWithOptions(
  Pointer<Void> receiver,
  Pointer<Void> selector,
  int options,
);

@Native<Pointer<Void> Function()>(symbol: 'objc_autoreleasePoolPush')
external Pointer<Void> _pushPool();

@Native<Void Function(Pointer<Void>)>(symbol: 'objc_autoreleasePoolPop')
external void _popPool(Pointer<Void> pool);

T _inPool<T>(T Function(Arena arena) body) {
  final pool = _pushPool();
  try {
    return using(body);
  } finally {
    _popPool(pool);
  }
}

/// The pid of the app in front on macOS, or null if none is.
int? macFrontmostApp() => _inPool((arena) {
  Pointer<Utf8> name(String text) => text.toNativeUtf8(allocator: arena);

  final workspace = _sendForObject(
    _class(name('NSWorkspace')),
    _selector(name('sharedWorkspace')),
  );
  final front = _sendForObject(
    workspace,
    _selector(name('frontmostApplication')),
  );
  if (front == nullptr) return null;
  return _sendForInt(front, _selector(name('processIdentifier')));
});

/// Brings the macOS app with [pid] in front, if it still runs.
void macActivateApp(int pid) => _inPool((arena) {
  Pointer<Utf8> name(String text) => text.toNativeUtf8(allocator: arena);
  const ignoringOtherApps = 1 << 1;

  final app = _sendWithInt(
    _class(name('NSRunningApplication')),
    _selector(name('runningApplicationWithProcessIdentifier:')),
    pid,
  );
  if (app != nullptr) {
    _sendWithOptions(
      app,
      _selector(name('activateWithOptions:')),
      ignoringOtherApps,
    );
  }
});

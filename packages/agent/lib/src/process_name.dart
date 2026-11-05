import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:fimber/fimber.dart';

@Native<Pointer<Void> Function(Pointer<Void>, Pointer<Utf8>, Uint32)>(
  symbol: 'CFStringCreateWithCString',
)
external Pointer<Void> _createString(
  Pointer<Void> allocator,
  Pointer<Utf8> text,
  int encoding,
);

@Native<Pointer<Void> Function()>(symbol: '_LSGetCurrentApplicationASN')
external Pointer<Void> _currentApplication();

@Native<
  Int32 Function(
    Int32,
    Pointer<Void>,
    Pointer<Void>,
    Pointer<Void>,
    Pointer<Void>,
  )
>(symbol: '_LSSetApplicationInformationItem')
external int _setInformation(
  int session,
  Pointer<Void> application,
  Pointer<Void> key,
  Pointer<Void> value,
  Pointer<Void> changes,
);

@Native<Pointer<Void>>(symbol: '_kLSDisplayNameKey')
external final Pointer<Void> _displayNameKey;

/// Gives this process [name] in LaunchServices, which 1Password's prompt
/// shows; the Dart runtime renames it `dart:<executable>` at startup.
void restoreProcessName(String name) {
  const defaultSession = -2;
  const utf8Encoding = 0x08000100;

  try {
    final value = using(
      (arena) => _createString(
        nullptr,
        name.toNativeUtf8(allocator: arena),
        utf8Encoding,
      ),
    );
    final status = _setInformation(
      defaultSession,
      _currentApplication(),
      _displayNameKey,
      value,
      nullptr,
    );
    if (status != 0) throw StateError('LaunchServices said $status');
  } on Object catch (exception) {
    Fimber.w('Could not set the process name', ex: exception);
  }
}

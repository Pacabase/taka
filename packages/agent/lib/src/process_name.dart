import 'dart:ffi';
import 'dart:io';

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

/// Replaces Dart's `dart:<executable>` name, shown by 1Password's prompt and ps.
void restoreProcessName(String name) {
  if (Platform.isLinux) {
    try {
      File('/proc/self/comm').writeAsStringSync(name);
    } on FileSystemException catch (exception) {
      Fimber.w('Could not set the process name', ex: exception);
    }
  } else if (Platform.isMacOS) {
    _restoreLaunchServicesName(name);
  }
}

void _restoreLaunchServicesName(String name) {
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

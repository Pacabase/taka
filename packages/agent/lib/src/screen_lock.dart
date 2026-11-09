import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

/// Whether the user's screen is locked; false where Taka can't tell.
Future<bool> isScreenLocked() async {
  if (Platform.isMacOS) return _isMacLocked();
  if (Platform.isLinux) return _isLinuxLocked();
  return false;
}

final _coreGraphics = DynamicLibrary.open(
  '/System/Library/Frameworks/CoreGraphics.framework/CoreGraphics',
);
final _coreFoundation = DynamicLibrary.open(
  '/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation',
);

final _copySession = _coreGraphics
    .lookupFunction<Pointer<Void> Function(), Pointer<Void> Function()>(
      'CGSessionCopyCurrentDictionary',
    );
final _createString = _coreFoundation
    .lookupFunction<
      Pointer<Void> Function(Pointer<Void>, Pointer<Utf8>, Uint32),
      Pointer<Void> Function(Pointer<Void>, Pointer<Utf8>, int)
    >('CFStringCreateWithCString');
final _valueOf = _coreFoundation
    .lookupFunction<
      Pointer<Void> Function(Pointer<Void>, Pointer<Void>),
      Pointer<Void> Function(Pointer<Void>, Pointer<Void>)
    >('CFDictionaryGetValue');
final _boolOf = _coreFoundation
    .lookupFunction<Uint8 Function(Pointer<Void>), int Function(Pointer<Void>)>(
      'CFBooleanGetValue',
    );
final _release = _coreFoundation
    .lookupFunction<Void Function(Pointer<Void>), void Function(Pointer<Void>)>(
      'CFRelease',
    );

bool _isMacLocked() {
  const utf8Encoding = 0x08000100;

  final session = _copySession();
  if (session == nullptr) return false;

  final key = using(
    (arena) => _createString(
      nullptr,
      'CGSSessionScreenIsLocked'.toNativeUtf8(allocator: arena),
      utf8Encoding,
    ),
  );
  try {
    final locked = _valueOf(session, key);
    return locked != nullptr && _boolOf(locked) != 0;
  } finally {
    _release(key);
    _release(session);
  }
}

Future<bool> _isLinuxLocked() async {
  final session = Platform.environment['XDG_SESSION_ID'] ?? 'auto';
  try {
    final result = await Process.run('loginctl', [
      'show-session',
      session,
      '--property=LockedHint',
      '--value',
    ]);
    return result.exitCode == 0 && '${result.stdout}'.trim() == 'yes';
  } on ProcessException {
    return false;
  }
}

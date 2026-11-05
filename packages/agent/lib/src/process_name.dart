import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:fimber/fimber.dart';

typedef _Pointer = Pointer<Void>;

/// Gives this process [name] in LaunchServices, which 1Password's approval
/// prompt and Activity Monitor show.
///
/// Dart names every process `dart:<executable>` this way at startup
/// (Platform::SetProcessName in runtime/bin/platform_macos.cc), over the
/// bundle's own name; this puts it back. macOS only.
void restoreProcessName(String name) {
  try {
    _setDisplayName(name);
  } on Object catch (exception) {
    Fimber.w('Could not set the process name', ex: exception);
  }
}

void _setDisplayName(String name) {
  final foundation = DynamicLibrary.open(
    '/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation',
  );
  DynamicLibrary.open(
    '/System/Library/Frameworks/ApplicationServices.framework/ApplicationServices',
  );
  final string = foundation
      .lookupFunction<
        _Pointer Function(_Pointer, Pointer<Utf8>, Uint32),
        _Pointer Function(_Pointer, Pointer<Utf8>, int)
      >('CFStringCreateWithCString');
  final bundleWithIdentifier = foundation
      .lookupFunction<_Pointer Function(_Pointer), _Pointer Function(_Pointer)>(
        'CFBundleGetBundleWithIdentifier',
      );
  final functionNamed = foundation
      .lookupFunction<
        _Pointer Function(_Pointer, _Pointer),
        _Pointer Function(_Pointer, _Pointer)
      >('CFBundleGetFunctionPointerForName');
  final dataNamed = foundation
      .lookupFunction<
        _Pointer Function(_Pointer, _Pointer),
        _Pointer Function(_Pointer, _Pointer)
      >('CFBundleGetDataPointerForName');

  const utf8Encoding = 0x08000100;
  _Pointer text(String value) => using(
    (arena) =>
        string(nullptr, value.toNativeUtf8(allocator: arena), utf8Encoding),
  );
  _Pointer found(_Pointer pointer, String symbol) => pointer == nullptr
      ? throw StateError('LaunchServices has no $symbol')
      : pointer;

  final launchServices = found(
    bundleWithIdentifier(text('com.apple.LaunchServices')),
    'bundle',
  );
  final currentApplication =
      found(
            functionNamed(launchServices, text('_LSGetCurrentApplicationASN')),
            '_LSGetCurrentApplicationASN',
          )
          .cast<NativeFunction<_Pointer Function()>>()
          .asFunction<_Pointer Function()>();
  final setInformation =
      found(
            functionNamed(
              launchServices,
              text('_LSSetApplicationInformationItem'),
            ),
            '_LSSetApplicationInformationItem',
          )
          .cast<
            NativeFunction<
              Int32 Function(Int32, _Pointer, _Pointer, _Pointer, _Pointer)
            >
          >()
          .asFunction<
            int Function(int, _Pointer, _Pointer, _Pointer, _Pointer)
          >();
  final displayNameKey = found(
    dataNamed(launchServices, text('_kLSDisplayNameKey')),
    '_kLSDisplayNameKey',
  ).cast<_Pointer>().value;

  final application = found(currentApplication(), 'current application');
  final status = setInformation(
    -2,
    application,
    displayNameKey,
    text(name),
    nullptr,
  );
  if (status != 0) throw StateError('LaunchServices said $status');
}

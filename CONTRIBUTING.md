# Contributing

## Building

Install [FVM](https://fvm.app), which fetches the SDK version pinned in `.fvmrc`, then:

```bash
fvm flutter run -d macos              # the app from source
fvm flutter build macos --release     # build/macos/Build/Products/Release/Taka.app
```

Either builds the background helper for your Mac's chip and puts it inside the app.

## Tests

The unit tests run per package:

```bash
fvm flutter test --tags unit
(cd packages/core && fvm dart test --tags unit)
(cd packages/agent && fvm dart test --tags unit)
```

## Licences

After changing the background helper's dependencies, run `fvm dart run tool/agent_licences.dart` so About lists their licences; CI checks they match.

## Linux

Linux build machines need `sudo apt-get install libgtk-3-dev libx11-dev libxi-dev` for the tray icon.

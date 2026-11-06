# Contributing

## Building

Install [FVM](https://fvm.app), which fetches the SDK version pinned in `.fvmrc`, then:

```bash
fvm flutter run -d macos              # the app from source
fvm flutter build macos --release     # build/macos/Build/Products/Release/Taka.app
```

Either builds the agent (`packages/agent`, the background helper that owns the tray and the tunnels) for your Mac's chip and puts it inside the app.

## Tests

The unit tests run per package:

```bash
fvm flutter test --tags unit
(cd packages/core && fvm dart test --tags unit)
(cd packages/agent && fvm dart test --tags unit)
```

## Licences

After changing the dependencies of `packages/agent` or `packages/core`, run `fvm dart run tool/agent_licences.dart` so About lists the agent's licences; CI checks they match.

## Linux

Linux build machines need `sudo apt-get install libgtk-3-dev libx11-dev libxi-dev` for the tray icon.

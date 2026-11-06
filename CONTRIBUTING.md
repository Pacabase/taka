# Contributing

## Building

Install [FVM](https://fvm.app), which fetches the SDK version pinned in `.fvmrc`, then:

```bash
fvm flutter run -d macos              # the app from source
fvm flutter build macos --release     # build/macos/Build/Products/Release/Taka.app
```

### Linux

On Debian or Ubuntu, install the build tools and libraries first:

```bash
sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev libx11-dev libxi-dev
```

```bash
fvm flutter run -d linux              # the app from source
fvm flutter build linux --release     # build/linux/x64/release/bundle/taka
```

Either build puts the agent beside the window, in `agent/`.

## Tests

The unit tests run per package:

```bash
fvm flutter test --tags unit
(cd packages/core && fvm dart test --tags unit)
(cd packages/agent && fvm dart test --tags unit)
```

## Licences

After changing the dependencies of `packages/agent` or `packages/core`, run `fvm dart run tool/agent_licences.dart` so About lists the agent's licences; CI checks they match.

# Contributing

## Building

Install [FVM](https://fvm.app), which fetches the SDK version pinned in `.fvmrc`, then:

```bash
fvm flutter run -d macos              # the app from source
fvm flutter build macos --release     # build/macos/Build/Products/Release/Taka.app
```

### Linux

On Debian or Ubuntu, building or testing needs:

```bash
sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev libstdc++-12-dev libx11-dev libxi-dev
```

```bash
fvm flutter run -d linux              # the app from source
fvm flutter build linux --release     # build/linux/<x64 or arm64>/release/bundle/taka
```

### Debug and release side by side

A debug build has a red icon, so the Dock tells the two apart. After changing `assets/icon/icon.png`, run `fvm dart run flutter_launcher_icons` and then `fvm dart run tool/dev_icon.dart`; a test fails until the red icon matches.


Debug and profile builds run as Taka Dev (`com.pacabase.taka.dev`), with their own tunnels, background helper, socket, logs and login item. So `flutter run` never reads, rewrites or replaces an installed release's. A first debug run starts with no tunnels. To try it with your own, export them from the release and import them into Taka Dev. On Linux, a dev build has no `.desktop` file, so the dock shows it with a generic icon.

## Tests

The unit tests run per package:

```bash
fvm flutter test --tags unit
(cd packages/core && fvm dart test --tags unit)
(cd packages/agent && fvm dart test --tags unit)
```

## Licences

After changing the dependencies of `packages/agent` or `packages/core`, run `fvm dart run tool/agent_licences.dart` so About lists the agent's licences; CI checks they match.

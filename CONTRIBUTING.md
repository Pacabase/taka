# Contributing

## Building

Install [FVM](https://fvm.app), which fetches the SDK version pinned in `.fvmrc`, then:

```bash
fvm flutter run -d macos              # the app from source
fvm flutter build macos --release     # build/macos/Build/Products/Release/Taka.app
macos/packaging/make_dmg.sh 0.1.0 macos-apple-silicon   # dist/Taka-0.1.0-macos-apple-silicon.dmg
```

Each packaging script takes the version and the target, packages the release build as `build.yml` does, and writes into `dist/`.

### Linux

On Debian or Ubuntu, building or testing needs:

```bash
sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev libstdc++-12-dev libx11-dev libxi-dev
```

```bash
fvm flutter run -d linux              # the app from source
fvm flutter build linux --release     # build/linux/<x64 or arm64>/release/bundle/taka
linux/packaging/package.sh 0.1.0 linux-x64   # or linux-arm64: the .tar.gz, .deb and .rpm
```

The script uses [nfpm](https://nfpm.goreleaser.com) from `PATH`, or downloads the version `build.yml` uses.

### Windows

Building needs Visual Studio 2022 with the "Desktop development with C++" workload, which also builds the agent's native library.

```bash
fvm flutter run -d windows            # the app from source
fvm flutter build windows --release   # build/windows/x64/runner/Release/taka.exe
```

The zip and the installer, made with 7-Zip and [Inno Setup](https://jrsoftware.org/isinfo.php) 6, come from PowerShell:

```powershell
windows\packaging\package.ps1 0.1.0 windows-x64
```

The script uses an installed Inno Setup 6, or downloads the version `build.yml` uses.

## Tests

The unit tests run per package:

```bash
fvm flutter test --tags unit
(cd packages/core && fvm dart test --tags unit)
(cd packages/agent && fvm dart test --tags unit)
```

## Licences

After changing the dependencies of `packages/agent` or `packages/core`, run `fvm dart run tool/agent_licences.dart` so About lists the agent's licences; CI checks they match.

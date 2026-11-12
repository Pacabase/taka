# AGENTS.md

Guidance for coding agents (and people) working on Taka. Building and testing by hand are in [CONTRIBUTING.md](CONTRIBUTING.md); what's planned is under "Roadmap" in [README.md](README.md).

## What Taka promises

Taka is a menu bar app for SSH tunnels (`ssh -L`) and SOCKS proxies (`ssh -D`), in Flutter, macOS first, then Linux and Windows. Every change must keep these promises:

- **It runs the system's own `ssh`.** Never add an SSH implementation. `~/.ssh/config`, `ProxyJump`, certificates and agents (1Password and others) must work exactly as in a terminal. That is also why Taka isn't sandboxed and isn't on the Mac App Store (#10).
- **It stores no secrets.** The tunnels file holds names, hosts and ports only, so an export is safe to commit. Keys, passwords and passphrases stay with ssh and the user's agent.
- **Idle Taka stays small.** The background agent idles near 17 MB, and the Flutter window (50–60 MB) runs only while it's open. Tray and tunnel work belongs in the agent, never in the window.
- **Saved tunnels survive upgrades.** The tunnels file is versioned (`tunnels_file.dart`). A new optional field that older builds ignore keeps the version. Any other change in shape needs a new version that still reads every old one.

## How it fits together

Two processes, one app bundle:

- **`packages/core`**: pure Dart, shared by both processes. It holds the `Tunnel` model and its store, `TunnelManager` (opens and stops tunnels, and emits a `TunnelsSnapshot` on every change) with one `TunnelSession` per tunnel, and the protocol. `AgentServer` and `SocketAgentClient` exchange one JSON object per line over `agentSocketPath()`: `AgentMessage`s from the agent, `AgentCommand`s from the window. Paths are worked out in plain Dart, because the agent has no Flutter plugins.
- **`packages/agent`**: the background agent (plain Dart, nativeapi's `runNativeApp`). It owns the tray, the saved tunnels and every `ssh`, and keeps running. A second copy exits when it can't bind the socket. Menu decisions live in the pure, tested `trayEntries(snapshot)`. The native side keeps menus and listeners alive by itself, so only the tray icon must stay referenced from Dart. An uncaught error ends the process, so catch at the edges.
- **The window** (this package, `lib/`): started on demand, it starts the agent if needed (`lib/agent/agent_launcher.dart`), mirrors its snapshots in `TunnelsBloc` and sends it what the user does. It quits when its window closes or the agent goes away.
- **Builds:** every macOS build, `flutter run` included, runs `macos/embed_agent.sh` from an Xcode build phase. The script builds the agent with `dart build cli` and puts it inside the app as `Contents/Library/LoginItems/Taka.app`, signed like the app. Every Linux build does the same from CMake with `linux/embed_agent.sh`, which puts the agent beside the window as `agent/`. In development, `TAKA_AGENT` and `TAKA_APP` point to another build. `build.yml` packages what's built with [fastforge](https://github.com/fastforgedev/fastforge): the macOS app as a disk image, and the Linux bundle as a `.deb` and `.rpm` installed in `/opt/taka`. Its settings are `.fastforge/config.yaml` and the `make_config.yaml` files under `macos/packaging` and `linux/packaging`. Its `linux-packages` jobs run `linux/packaging/check_install.sh` in clean Ubuntu, Debian and Fedora containers to check that the declared dependencies bring every library.

A tunnel bug or a missing ssh option belongs in [`system_ssh`](https://github.com/Pacabase/system_ssh), with its own tests, not in a workaround here. Taka depends on a released version. system_ssh is never a path dependency in a commit.

## Code

Keep it simple. Build only what the current change needs, and prefer the straightforward over the clever. No abstractions in advance.

- **State:** BLoC (`flutter_bloc`) with Freezed. Short state names, inline handlers in the constructor, and every state and event `@freezed`. Every `Bloc` overrides `toString()` to its class name.
- **Constructors:** declare fields in a primary constructor, like `class const TunnelTile({super.key, required final Tunnel tunnel}) extends StatelessWidget`. Write freezed factories without the class name (`const factory connected() = Connected;`).
- **Naming:** no abbreviations (`index`, not `idx`; `tunnel`, not `t`). Write `catch (exception)`.
- **Collections:** prefer `.where()`, `.map()`, collection-`for`/`if` and `package:collection` over loops that build up a result.
- **Comments:** none by default. Write one only when the code, names and tests can't give the reason (a hidden constraint, an outside quirk, a workaround) and one short line is enough. "Could add X later" goes in the README's Roadmap, not in a comment.
- **Dependencies:** pin exact versions (`1.2.3`, never `^1.2.3`). SDK constraints under `environment:` stay ranges. After changing `packages/agent` or `packages/core` dependencies, run `fvm dart run tool/agent_licences.dart`.

## Words

- **UI text** says what happened in plain words, with no exception text or jargon ("It started but didn't answer within 5 seconds."). Users see the agent as "Taka's background helper".
- **PR titles** say what changes for the user, as a short imperative sentence ("Reconnect a dropped tunnel").
- **The README Roadmap** is a public list ordered by priority, with each line about one pull request. When a change finishes an item, remove it, and add any must-have the change surfaced.

## Tests

Business logic (BLoCs, stores, models, the manager and the protocol) gets unit tests in the same change. Cover the happy path, every failure path and the edge cases: aborting while connecting, a drop, closing twice. Every test file declares `@Tags(['unit'])`.

## Before you finish

Use FVM, because `.fvmrc` pins the Flutter version. After changing a `@freezed` file, run `fvm dart run build_runner build`. Then run what CI runs:

```bash
fvm dart format lib test tool packages
fvm flutter analyze && fvm flutter test --tags unit
(cd packages/core && fvm dart analyze --fatal-infos && fvm dart test --tags unit)
(cd packages/agent && fvm dart analyze --fatal-infos && fvm dart test --tags unit && fvm dart build cli)
fvm dart run tool/agent_licences.dart && git diff --exit-code assets/agent_licences.json
```

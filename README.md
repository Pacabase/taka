# Taka

A menu bar app for SSH tunnels and SOCKS proxies, built on [`system_ssh`](https://github.com/Pacabase/system_ssh). It runs your own `ssh`, so `~/.ssh/config`, `ProxyJump` and agents such as 1Password's work as in a terminal, and Taka stores no secrets.

## Mac App Store

Taka isn't on the Mac App Store. The store only allows sandboxed apps, and a sandboxed app can't use your own `ssh` setup, which is what Taka is built on. If you'd use a store version with its own SSH built in, give [issue #10](https://github.com/Pacabase/taka/issues/10) a 👍.

## Building

Install [FVM](https://fvm.app), which fetches the SDK version pinned in `.fvmrc`, then:

```bash
make run      # the app from source, with a freshly built agent
make macos    # build/macos/Build/Products/Release/Taka.app, agent inside
make test
```

Linux build machines need `sudo apt-get install libgtk-3-dev libx11-dev libxi-dev` for the tray icon.

## Roadmap

Ordered roughly by priority; each line is about one pull request.

### First preview (0.1, macOS)

- [ ] **Launch at login.**
- [ ] **Empty and error states** — a first run that explains what a tunnel is, and a proper screen when the agent can't start.
- [ ] **Releases** — a universal `.dmg` from CI on a version tag, a Homebrew tap, and signed auto-updates. The agent's packages (`nativeapi` and its C++ library, `platform`, `process`) must be in the app's licences first: a Dart command-line build collects none.

### Daily driver (0.2, Linux)

- [ ] **Notifications** when a tunnel connects, drops or gives up.
- [ ] **Activity log** per tunnel.
- [ ] **Groups and tags**, as tray submenus too.
- [ ] **Import** hosts from `~/.ssh/config`, or a tunnel from a pasted `ssh -L` command; copy a tunnel back as an `ssh` command.
- [ ] **Linux packages** — AppImage, `.deb`, `.rpm` and the AUR.

### Windows (0.3)

- [ ] **Windows support** — the agent's transport, paths, an installer and `winget`.

### Logins (0.4)

- [ ] **Passwords, passphrases and 2FA** through `SSH_ASKPASS`, with 1Password `op://` references.
- [ ] **Host-key prompt** showing the fingerprint on first connect.

### Power users (0.5)

- [ ] **Every action is a command**, with shortcuts and a command palette.
- [ ] **A `taka` command line** — `up`, `down`, `status --json`, and `run <tunnel> -- <command>`.
- [ ] **Export, import and a shareable tunnels file** — safe to commit, since Taka stores no secrets.

### Beyond (0.6 and 1.0)

- [ ] **Health checks** that show a tunnel as connected only once the service behind it answers.
- [ ] **Network rules** — connect on a given Wi-Fi or VPN, pause while offline.
- [ ] **On-demand tunnels** that start ssh on the first connection and stop when idle.
- [ ] **Remote forwards (`-R`)**, Unix-socket forwards, and binding to the LAN.

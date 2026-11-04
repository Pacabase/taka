# Taka

A menu bar app for SSH tunnels and SOCKS proxies, built on [`system_ssh`](https://github.com/Pacabase/system_ssh). It runs your own `ssh`, so `~/.ssh/config`, `ProxyJump` and agents such as 1Password's work as in a terminal, and Taka stores no secrets.

## How it runs

Taka is one app with two processes:

- **The agent** (`packages/taka_agent`) is a small background program, about 17 MB. It owns the tray icon, the saved tunnels and every `ssh`, and keeps running while the window is closed.
- **The settings window** (this package), about 50 MB while open, starts the agent if it isn't running, talks to it over a Unix socket, and quits when it closes.

`packages/taka_core` holds what both share: the tunnel model, the store, `TunnelManager` and the socket protocol. The agent ships inside the app, in `Taka.app/Contents/Helpers/agent`.

## Roadmap

Ordered roughly by priority; each line is about one pull request.

### First preview (0.1, macOS)

- [ ] **Agree on a version with the agent** — the agent outlives the app, so a newer app hands an older agent over and starts its own.
- [ ] **Log to a file** in both processes, so a failed connect can be reported.
- [ ] **Say why a tunnel dropped** — today it says "Disconnected"; needs `system_ssh` to report ssh's last lines.
- [ ] **Reconnect a dropped tunnel** with backoff and keepalive, and stop on a failure that won't heal (host key changed, port in use).
- [ ] **Launch at login**, and reconnect the tunnels that were on.
- [ ] **Look and feel** — themes, fonts, app and tray icons, a compact window with empty and error states.
- [ ] **Releases** — a universal `.dmg` from CI on a version tag, a Homebrew tap, and signed auto-updates.

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

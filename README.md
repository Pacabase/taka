# Taka

A menu bar app for SSH tunnels and SOCKS proxies, built on [`system_ssh`](https://github.com/Pacabase/system_ssh). It runs your own `ssh`, so `~/.ssh/config`, `ProxyJump` and agents such as 1Password's work as in a terminal, and Taka stores no secrets.

## Download

Get the latest build from [Releases](https://github.com/Pacabase/taka/releases):

- **macOS:** `Taka-<version>-macos-apple-silicon.dmg` or `Taka-<version>-macos-intel.dmg`. Open it and drag Taka to Applications. The builds aren't notarized yet, so the first time macOS says it can't check Taka: click **Done**, then **Open Anyway** in System Settings → Privacy & Security.
- **Debian, Ubuntu:** `sudo apt install ./Taka-<version>-linux-x64.deb` (or `-linux-arm64.deb`), which brings the libraries Taka needs. Then open Taka from your applications, or run `taka`.
- **Fedora:** `sudo dnf install ./Taka-<version>-linux-x64.rpm` (or `-linux-arm64.rpm`).
- **Other Linux:** `Taka-<version>-linux-x64.tar.gz` or `Taka-<version>-linux-arm64.tar.gz`. Extract it and run `taka/taka`.

Each release lists the files' checksums in `SHA256SUMS`.

### If Taka doesn't start on Linux

The `.deb` and `.rpm` install the libraries Taka needs. With the tarball, most desktops already have them; if yours doesn't, Taka fails to open with no message, or its window says *Taka's background helper didn't start*. To see why, run it from a terminal:

```sh
taka/taka                  # the window
taka/agent/bin/taka_agent  # the background helper behind the tray icon
```

An error such as `libgtk-3.so.0: cannot open shared object file` means GTK 3 is missing:

- **Debian, Ubuntu:** `sudo apt install libgtk-3-0`
- **Fedora:** `sudo dnf install gtk3`
- **Arch:** `sudo pacman -S gtk3`
- **NixOS:** downloaded programs don't run on NixOS out of the box. Turn on [nix-ld](https://github.com/nix-community/nix-ld) with the libraries Taka uses, then rebuild:

  ```nix
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    gtk3 glib pango cairo atk gdk-pixbuf harfbuzz fontconfig libepoxy
    xorg.libX11 xorg.libXi stdenv.cc.cc.lib
  ];
  ```

## Requirements

- **macOS** 14 (Sonoma) or later, on Apple Silicon or Intel.
- **Linux** on x64 or arm64 with glibc 2.35 or later (Ubuntu 22.04, Debian 12, Fedora 36 or newer) and GTK 3. The tray icon needs StatusNotifierItem support, which KDE, Xfce, Cinnamon and Ubuntu have; on other GNOME desktops, install the [AppIndicator extension](https://extensions.gnome.org/extension/615/appindicator-support/).

Windows is on the [roadmap](#roadmap).

## Mac App Store

Taka isn't on the Mac App Store. The store only allows sandboxed apps, and a sandboxed app can't use your own `ssh` setup, which is what Taka is built on. If you'd use a store version with its own SSH built in, give [issue #10](https://github.com/Pacabase/taka/issues/10) a 👍.

## Building from source

See [CONTRIBUTING.md](CONTRIBUTING.md).

## Roadmap

Ordered roughly by priority; each line is about one pull request.

### First preview (0.1, macOS)

- [ ] **Signed and notarized builds**, so macOS opens Taka without a warning.
- [ ] **Homebrew tap** — `brew install --cask taka`, from the release `.dmg`.
- [ ] **Signed auto-updates**.

### Daily driver (0.2, Linux)

- [ ] **Activity log** per tunnel.
- [ ] **A colour per tunnel**, picked from the app theme's palette and shown on its row, so tunnels tell apart at a glance. In the tray, a coloured square beside the name: the nearest emoji square (🟥 🟧 🟨 🟩 🟦 🟪) on macOS and Linux, and a real icon on Windows, where menus can't draw emoji in colour.
- [ ] **Tags**, several per tunnel, to filter the list by.
- [ ] **Import** hosts from `~/.ssh/config`.
- [ ] **More Linux packages** — AppImage and the AUR.

### Windows (0.3)

- [ ] **Windows support** — the agent's transport, paths, an installer and `winget`.

### Logins (0.4)

- [ ] **Passwords, passphrases and 2FA** through `SSH_ASKPASS`, with 1Password `op://` references.

### Power users (0.5)

- [ ] **Every action is a command**, with shortcuts and a command palette.
- [ ] **A `taka` command line** — `up`, `down`, `status --json`, and `run <tunnel> -- <command>`.
- [ ] **A shareable tunnels file** that Taka keeps in sync, safe to commit since Taka stores no secrets.

### Beyond (0.6 and 1.0)

- [ ] **Notifications** when a tunnel drops or gives up, saying why, and opening it in the window when clicked. nativeapi has no notifications on macOS or Linux yet, so it means Apple's UserNotifications through `objective_c` and D-Bus's `org.freedesktop.Notifications`, or adding them to nativeapi.
- [ ] **Health checks** that show a tunnel as connected only once the service behind it answers.
- [ ] **Network rules** — connect on a given Wi-Fi or VPN, pause while offline.
- [ ] **On-demand tunnels** that start ssh on the first connection and stop when idle.
- [ ] **Binding to the LAN**, so other devices can use a tunnel.

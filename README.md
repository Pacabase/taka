# Taka

A menu bar app for SSH tunnels and SOCKS proxies, built on [`system_ssh`](https://github.com/Pacabase/system_ssh). It runs your own `ssh`, so `~/.ssh/config`, `ProxyJump` and agents such as 1Password's work as in a terminal, and Taka stores no secrets.

## Download

Get the latest build from [Releases](https://github.com/Pacabase/taka/releases):

- **macOS:** `Taka-<version>-macos-apple-silicon.dmg` or `Taka-<version>-macos-intel.dmg`. Open it and drag Taka to Applications. The builds aren't notarized yet, so the first time macOS says it can't check Taka: click **Done**, then **Open Anyway** in System Settings → Privacy & Security.
- **Debian, Ubuntu:** `sudo apt install ./Taka-<version>-linux-x64.deb` (or `-linux-arm64.deb`), which brings the libraries Taka needs. Then open Taka from your applications, or run `taka`.
- **Fedora:** `sudo dnf install ./Taka-<version>-linux-x64.rpm` (or `-linux-arm64.rpm`).
- **Arch:** from the AUR, with `yay -S taka-bin` or `paru -S taka-bin`, on x86_64 or aarch64.
- **Other Linux:** `Taka-<version>-linux-x64.tar.gz` or `Taka-<version>-linux-arm64.tar.gz`. Extract it and run `taka/taka`.
- **Windows:** `Taka-<version>-windows-x64-setup.exe` installs Taka for your user, with no administrator rights needed. Or extract `Taka-<version>-windows-x64.zip` and run `Taka\taka.exe`. The builds aren't signed yet, so SmartScreen may say it protected your PC: click **More info**, then **Run anyway**. With Smart App Control on, Windows blocks unsigned apps outright, so Taka won't open there until the builds are signed.

Each release lists the files' checksums in `SHA256SUMS`.

### If Taka doesn't start on Linux

The `.deb`, `.rpm` and AUR package install the libraries Taka needs. With the tarball, most desktops already have them; if yours doesn't, Taka fails to open with no message, or its window says *Taka's background helper didn't start*. To see why, run it from a terminal:

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
- **Windows** 10 or 11 on x64, with the OpenSSH Client that Windows includes (Settings → System → Optional features). Taka runs the `ssh` a terminal would. Click the tray icon to open Taka and right-click it for the menu.

## Memory

Taka is two programs. A small background helper owns the tray icon and runs your tunnels all day. The window starts when you open it and quits when you close it, so it uses no memory the rest of the time.

|             | Background helper | Window, while open |
| ----------- | ----------------- | ------------------ |
| **macOS**   | about 20–30 MB    | about 50 MB        |
| **Windows** | about 20 MB       | about 80 MB        |
| **Linux**   | about 25 MB       | depends on the graphics driver; about 150 MB without a GPU |

Each tunnel's `ssh` adds 1–3 MB. On macOS and Linux, tunnels to the same server share one `ssh`. The figures are each system's own measure of memory the program holds for itself (macOS: memory in Activity Monitor; Windows: committed memory; Linux: private memory), with four tunnels open.

## Mac App Store

Taka isn't on the Mac App Store. The store only allows sandboxed apps, and a sandboxed app can't use your own `ssh` setup, which is what Taka is built on. If you'd use a store version with its own SSH built in, give [issue #10](https://github.com/Pacabase/taka/issues/10) a 👍.

## Building from source

See [CONTRIBUTING.md](CONTRIBUTING.md).

## Roadmap

Ordered roughly by priority; each line is about one pull request.

### Signed macOS releases

- [ ] **Signed and notarized builds**, so macOS opens Taka without a warning.
- [ ] **Homebrew tap** — `brew install --cask taka`, from the release `.dmg`.
- [ ] **Signed auto-updates**.

### Daily driver

- [ ] **Activity log** per tunnel.
- [ ] **Tags**, several per tunnel, to filter the list by.
- [ ] **Import** hosts from `~/.ssh/config`.
- [ ] **More Linux packages** — AppImage.

### Signed Windows releases

- [ ] **Signed Windows builds**, so Smart App Control lets Taka run and SmartScreen opens it without a warning.
- [ ] **`winget`** — `winget install Taka`, from the release installer.

### Logins

- [ ] **Passwords, passphrases and 2FA** through `SSH_ASKPASS`, with 1Password `op://` references.

### Power users

- [ ] **Every action is a command**, with shortcuts and a command palette.
- [ ] **A `taka` command line** — `up`, `down`, `status --json`, and `run <tunnel> -- <command>`.
- [ ] **A shareable tunnels file** that Taka keeps in sync, safe to commit since Taka stores no secrets.

### Beyond

- [ ] **Notifications** when a tunnel drops or gives up, saying why, and opening it in the window when clicked. nativeapi has no notifications on macOS or Linux yet, so it means Apple's UserNotifications through `objective_c` and D-Bus's `org.freedesktop.Notifications`, or adding them to nativeapi.
- [ ] **Health checks** that show a tunnel as connected only once the service behind it answers.
- [ ] **Network rules** — connect on a given Wi-Fi or VPN, pause while offline.
- [ ] **On-demand tunnels** that start ssh on the first connection and stop when idle.

#!/bin/sh
# Usage: check_appimage.sh <folder with the .AppImage>
# Starts Taka's AppImage on this system, after check_install.sh has brought the
# libraries, and checks that it copied out a helper that has every library and
# opens the window through the AppImage.
set -eu
appimage=$(readlink -f "$1"/*.AppImage)
# Artifacts lose the executable bit, as downloads do.
chmod +x "$appimage"
XDG_DATA_HOME=$(mktemp -d)
export XDG_DATA_HOME

# Containers have no FUSE, and no display, so the window stops at once.
timeout 60 "$appimage" --appimage-extract-and-run || true

copy=$(echo "$XDG_DATA_HOME"/com.pacabase.taka/appimage/*)
test -x "$copy/agent/bin/taka_agent"
test "$(readlink -f "$copy/taka")" = "$appimage"

missing=$(ldd "$copy/agent/bin/taka_agent" "$copy"/agent/lib/*.so | grep "not found" || true)
if [ -n "$missing" ]; then
  echo "Missing libraries:" >&2
  echo "$missing" | sort -u >&2
  exit 1
fi

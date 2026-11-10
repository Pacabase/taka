#!/bin/sh
# Usage: check_install.sh <folder with the .deb and .rpm>
# Installs Taka's package on this clean system, as root, and checks that it
# brought every library the app and its helper load.
set -eu
# apt reads a relative dist/x.deb as package dist from release x.deb.
packages=$(cd "$1" && pwd)

if command -v apt-get >/dev/null; then
  apt-get update -qq
  DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "$packages"/*.deb >/dev/null
else
  dnf install -y -q "$packages"/*.rpm
fi

# The plugins find Flutter's own library only once the app has loaded it.
missing=$(ldd /opt/taka/taka /opt/taka/lib/*.so /opt/taka/agent/bin/taka_agent /opt/taka/agent/lib/*.so |
  grep "not found" | grep -v libflutter_linux_gtk.so || true)
if [ -n "$missing" ]; then
  echo "Missing libraries:" >&2
  echo "$missing" | sort -u >&2
  exit 1
fi

test -x /usr/bin/taka
command -v ssh

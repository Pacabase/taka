#!/bin/sh
# Usage: render.sh <version> <SHA256SUMS> <output folder>
# Writes the AUR PKGBUILD for a release from PKGBUILD.in. The tarballs' sums
# come from the release's SHA256SUMS, the other sources' from this checkout,
# which must be at the release's tag.
set -eu
version=$1
sums=$2
out=$3
here=$(cd "$(dirname "$0")" && pwd)
root=$(cd "$here/../../.." && pwd)

release_sum() {
  sum=$(awk -v file="$1" '$2 == file { print $1 }' "$sums")
  if [ -z "$sum" ]; then
    echo "$1 isn't in $sums" >&2
    exit 1
  fi
  echo "$sum"
}

file_sum() {
  sha256sum "$root/$1" | cut -d' ' -f1
}

x64=$(release_sum "Taka-$version-linux-x64.tar.gz")
arm64=$(release_sum "Taka-$version-linux-arm64.tar.gz")
desktop=$(file_sum linux/packaging/com.pacabase.taka.desktop)
icon=$(file_sum assets/icon/icon.png)
licence=$(file_sum LICENSE)

mkdir -p "$out"
sed -e "s/@VERSION@/$version/" \
  -e "s/@SHA256_X64@/$x64/" \
  -e "s/@SHA256_ARM64@/$arm64/" \
  -e "s/@SHA256_DESKTOP@/$desktop/" \
  -e "s/@SHA256_ICON@/$icon/" \
  -e "s/@SHA256_LICENSE@/$licence/" \
  "$here/PKGBUILD.in" >"$out/PKGBUILD"

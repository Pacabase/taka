#!/bin/sh
# Usage: package.sh <version> <target: linux-x64 or linux-arm64>
# Packages the release bundle as dist/Taka-<version>-<target>.tar.gz, .deb and
# .rpm. Uses nfpm from PATH, or downloads the pinned version.
set -eu

version="$1"
target="$2"
cd "$(dirname "$0")/../.."
release="build/linux/${target#linux-}/release"
nfpm_version=2.48.0

case "$target" in
  linux-x64) arch=amd64 nfpm_arch=x86_64 sum=6d7f9a28b2f397934403950fcbba83f598b08d02edbe79a0815b3b4897341750 ;;
  linux-arm64) arch=arm64 nfpm_arch=arm64 sum=a9a75213763783b7669719e505474c748c5ad7dc66591a195619deb50f85c2f4 ;;
  *) echo "No package architecture for $target" >&2; exit 1 ;;
esac

test -x "$release/bundle/taka" && test -x "$release/bundle/agent/bin/taka_agent"
mkdir -p dist
tar -czf "dist/Taka-$version-$target.tar.gz" -C "$release" --transform 's,^bundle,taka,' bundle

if command -v nfpm >/dev/null; then
  nfpm=nfpm
else
  tools=$(mktemp -d)
  trap 'rm -rf "$tools"' EXIT
  curl -fsSLo "$tools/nfpm.tar.gz" "https://github.com/goreleaser/nfpm/releases/download/v$nfpm_version/nfpm_${nfpm_version}_Linux_$nfpm_arch.tar.gz"
  echo "$sum  $tools/nfpm.tar.gz" | sha256sum -c -
  tar -xzf "$tools/nfpm.tar.gz" -C "$tools" nfpm
  nfpm="$tools/nfpm"
fi

rm -rf build/package/taka
mkdir -p build/package
cp -R "$release/bundle" build/package/taka
export VERSION="$version" ARCH="$arch"
for packager in deb rpm; do
  "$nfpm" package --config linux/packaging/nfpm.yaml --packager "$packager" \
    --target "dist/Taka-$version-$target.$packager"
done

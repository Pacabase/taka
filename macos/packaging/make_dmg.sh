#!/bin/sh
# Usage: make_dmg.sh <version> <target, such as macos-apple-silicon>
# Packages the release build as dist/Taka-<version>-<target>.dmg.
set -eu

version="$1"
target="$2"
cd "$(dirname "$0")/../.."
app=build/macos/Build/Products/Release/Taka.app
dmg="dist/Taka-$version-$target.dmg"

test -x "$app/Contents/Library/LoginItems/Taka.app/Contents/MacOS/Taka"
codesign --verify --deep --strict "$app"

rm -rf build/dmg
mkdir -p build/dmg dist
cp -R "$app" build/dmg/
ln -s /Applications build/dmg/Applications
# hdiutil on GitHub's runners sometimes fails with "Resource busy".
for attempt in 1 2 3 4 5; do
  hdiutil create -volname Taka -srcfolder build/dmg -format ULMO -ov "$dmg" && break
  [ "$attempt" = 5 ] && exit 1
  sleep $((attempt * 5))
done

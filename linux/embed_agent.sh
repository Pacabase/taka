#!/bin/sh
# Usage: embed_agent.sh <flutter root> <target platform> <destination>
set -eu

dart="$1/bin/dart"
platform=$(echo "$2" | tr - _)
destination="$3"
agent="$(dirname "$0")/../packages/agent"
bundle="$agent/build/cli/$platform/bundle"

# Without the old builds, one for another chip can't pass the check below.
rm -rf "$agent/build/cli"
(cd "$agent" && "$dart" pub get && "$dart" build cli)
test -x "$bundle/bin/taka_agent" || {
  echo "error: the app is built for $2, but Dart builds the agent only for this machine" >&2
  exit 1
}

rm -rf "$destination"
mkdir -p "$destination"
cp -R "$bundle/bin" "$bundle/lib" "$destination/"
cp "$agent"/assets/*.png "$destination/"

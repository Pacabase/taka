#!/bin/sh
set -eu

dart="$FLUTTER_ROOT/bin/dart"
agent="$FLUTTER_APPLICATION_PATH/packages/agent"
platform=$("$dart" --version 2>&1 | sed -n 's/.*on "\(macos_[a-z0-9]*\)".*/\1/p')
bundle="$agent/build/cli/$platform/bundle"
app="$BUILT_PRODUCTS_DIR/$WRAPPER_NAME"
helper="$app/Contents/Library/LoginItems/Taka.app"
identity="${EXPANDED_CODE_SIGN_IDENTITY:--}"

(cd "$agent" && "$dart" pub get && "$dart" build cli)
for arch in $ARCHS; do
  if ! lipo "$bundle/bin/taka_agent" -verify_arch "$arch" 2>/dev/null; then
    echo "error: the app is built for $ARCHS, but Dart built the agent in $bundle" >&2
    exit 1
  fi
done

rm -rf "$helper"
mkdir -p "$helper/Contents/MacOS" "$helper/Contents/Resources"
cp "$agent/macos/Info.plist" "$helper/Contents/"
cp "$bundle/bin/taka_agent" "$helper/Contents/MacOS/Taka"
cp -R "$bundle/lib" "$helper/Contents/lib"
cp "$agent"/assets/*.png "$app/Contents/Resources/AppIcon.icns" "$helper/Contents/Resources/"

codesign --force --sign "$identity" "$helper"/Contents/lib/*.dylib
codesign --force --sign "$identity" "$helper"

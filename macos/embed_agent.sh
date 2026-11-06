#!/bin/sh
set -eu

dart="$FLUTTER_ROOT/bin/dart"
agent="$FLUTTER_APPLICATION_PATH/packages/agent"
platform=$("$dart" --version 2>&1 | sed -n 's/.*on "\(macos_[a-z0-9]*\)".*/\1/p')
bundle="$agent/build/cli/$platform/bundle"
app="$BUILT_PRODUCTS_DIR/$WRAPPER_NAME"
helper="$app/Contents/Library/LoginItems/Taka.app"

(cd "$agent" && "$dart" pub get && "$dart" build cli)
lipo "$bundle/bin/taka_agent" -verify_arch $ARCHS || {
  echo "error: the app is built for $ARCHS, but Dart built the agent in $bundle" >&2
  exit 1
}

rm -rf "$helper"
mkdir -p "$helper/Contents/MacOS" "$helper/Contents/Resources"
cp "$agent/macos/Info.plist" "$helper/Contents/"
cp "$bundle/bin/taka_agent" "$helper/Contents/MacOS/Taka"
cp -R "$bundle/lib" "$helper/Contents/lib"
cp "$agent"/assets/*.png "$app/Contents/Resources/AppIcon.icns" "$helper/Contents/Resources/"

codesign --force --sign "${EXPANDED_CODE_SIGN_IDENTITY:--}" "$helper"/Contents/lib/*.dylib "$helper"

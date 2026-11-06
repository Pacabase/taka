#!/bin/sh
# Builds the background helper for this Mac's chip and puts it inside the app
# as its login item, signed like the app.
set -eu

agent="$FLUTTER_APPLICATION_PATH/packages/agent"
case "$(uname -m)" in
  arm64) arch=arm64 ;;
  *) arch=x64 ;;
esac
bundle="$agent/build/cli/macos_$arch/bundle"
app="$BUILT_PRODUCTS_DIR/$WRAPPER_NAME"
helper="$app/Contents/Library/LoginItems/Taka.app"
identity="${EXPANDED_CODE_SIGN_IDENTITY:--}"

(cd "$agent" && "$FLUTTER_ROOT/bin/dart" build cli)

rm -rf "$helper"
mkdir -p "$helper/Contents/MacOS" "$helper/Contents/Resources"
cp "$agent/macos/Info.plist" "$helper/Contents/"
cp "$bundle/bin/taka_agent" "$helper/Contents/MacOS/Taka"
cp -R "$bundle/lib" "$helper/Contents/lib"
cp "$agent"/assets/*.png "$app/Contents/Resources/AppIcon.icns" "$helper/Contents/Resources/"

codesign --force --sign "$identity" "$helper"/Contents/lib/*.dylib
codesign --force --sign "$identity" "$helper"

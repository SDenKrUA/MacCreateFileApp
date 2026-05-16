#!/bin/sh
set -eu

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$ROOT_DIR/build"
DIST_DIR="$ROOT_DIR/dist"
APP_NAME="Mac Create File"
APP_BUNDLE="$DIST_DIR/$APP_NAME.app"
APP_CONTENTS="$APP_BUNDLE/Contents"
APP_MACOS="$APP_CONTENTS/MacOS"
APP_RESOURCES="$APP_CONTENTS/Resources"
PLUGINS_DIR="$APP_CONTENTS/PlugIns"
EXT_NAME="MacCreateFileFinderExtension.appex"
EXT_BUNDLE="$PLUGINS_DIR/$EXT_NAME"
EXT_CONTENTS="$EXT_BUNDLE/Contents"
EXT_MACOS="$EXT_CONTENTS/MacOS"
EXT_RESOURCES="$EXT_CONTENTS/Resources"
ICONSET_DIR="$BUILD_DIR/MacCreateFileApp.iconset"
APP_ICON="$APP_RESOURCES/MacCreateFileAppIcon.icns"
SDKROOT="$(xcrun --sdk macosx --show-sdk-path)"
ARCH="$(uname -m)"
TARGET="$ARCH-apple-macos13.0"
SIGN_IDENTITY="${SIGN_IDENTITY:--}"

rm -rf "$BUILD_DIR" "$DIST_DIR"
mkdir -p "$BUILD_DIR" "$APP_MACOS" "$APP_RESOURCES" "$PLUGINS_DIR" "$EXT_MACOS" "$EXT_RESOURCES"

swiftc \
  -sdk "$SDKROOT" \
  -target "$TARGET" \
  -module-name MacCreateFileApp \
  -parse-as-library \
  -framework AppKit \
  -framework SwiftUI \
  "$ROOT_DIR/Sources/MacCreateFileApp/MacCreateFileApp.swift" \
  -o "$APP_MACOS/MacCreateFileApp"

swiftc \
  -sdk "$SDKROOT" \
  -target "$TARGET" \
  -module-name MacCreateFileFinderExtension \
  -parse-as-library \
  -emit-executable \
  -framework AppKit \
  -framework FinderSync \
  -Xlinker -e \
  -Xlinker _NSExtensionMain \
  "$ROOT_DIR/Sources/MacCreateFileFinderExtension/FinderSync.swift" \
  "$ROOT_DIR/Sources/MacCreateFileFinderExtension/MinimalFiles.swift" \
  -o "$EXT_MACOS/MacCreateFileFinderExtension"

cp "$ROOT_DIR/Info-App.plist" "$APP_CONTENTS/Info.plist"
cp "$ROOT_DIR/Info-Extension.plist" "$EXT_CONTENTS/Info.plist"
cp -R "$ROOT_DIR/Resources/." "$APP_RESOURCES/"
cp -R "$ROOT_DIR/ExtensionResources/." "$EXT_RESOURCES/"

/usr/bin/swift "$ROOT_DIR/scripts/generate_app_icon.swift" "$BUILD_DIR"
/usr/bin/iconutil -c icns "$ICONSET_DIR" -o "$APP_ICON"

codesign --force --sign "$SIGN_IDENTITY" --entitlements "$ROOT_DIR/Entitlements-Extension.plist" "$EXT_BUNDLE"
codesign --force --sign "$SIGN_IDENTITY" "$APP_BUNDLE"

echo "Built: $APP_BUNDLE"

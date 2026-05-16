#!/bin/sh
set -eu

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="${VERSION:-1.0.0}"
ARCH="$(uname -m)"
APP_NAME="Mac Create File"
APP_BUNDLE="$ROOT_DIR/dist/$APP_NAME.app"
RELEASE_BASENAME="MacCreateFile-$VERSION-mac-$ARCH"
ZIP_PATH="$ROOT_DIR/dist/$RELEASE_BASENAME.zip"
DMG_PATH="$ROOT_DIR/dist/$RELEASE_BASENAME.dmg"
DMG_ROOT="$ROOT_DIR/build/dmg"

"$ROOT_DIR/scripts/build_app.sh"

rm -rf "$DMG_ROOT" "$ZIP_PATH" "$DMG_PATH"
mkdir -p "$DMG_ROOT"
ditto "$APP_BUNDLE" "$DMG_ROOT/$APP_NAME.app"
ln -s /Applications "$DMG_ROOT/Applications"

(
  cd "$ROOT_DIR/dist"
  ditto -c -k --keepParent "$APP_NAME.app" "$ZIP_PATH"
)

hdiutil create \
  -volname "$APP_NAME" \
  -srcfolder "$DMG_ROOT" \
  -ov \
  -format UDZO \
  "$DMG_PATH"

echo "Release files:"
echo "$ZIP_PATH"
echo "$DMG_PATH"

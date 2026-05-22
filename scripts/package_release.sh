#!/bin/sh
set -eu

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="${VERSION:-1.0.0}"
ARCH="$(uname -m)"
APP_NAME="Mac Create File"
APP_BUNDLE="$ROOT_DIR/dist/$APP_NAME.app"
RELEASE_BASENAME="MacCreateFile-$VERSION-mac-$ARCH"
DMG_PATH="$ROOT_DIR/dist/$RELEASE_BASENAME.dmg"
PACKAGE_DIR="$ROOT_DIR/build/release-package"

"$ROOT_DIR/scripts/build_app.sh"

rm -f "$DMG_PATH"
rm -rf "$PACKAGE_DIR"
mkdir -p "$PACKAGE_DIR"
ditto "$APP_BUNDLE" "$PACKAGE_DIR/$APP_NAME.app"
ln -s /Applications "$PACKAGE_DIR/Applications"
cp "$ROOT_DIR/scripts/uninstall.command" "$PACKAGE_DIR/uninstall.command"
chmod +x "$PACKAGE_DIR/uninstall.command"

/usr/bin/hdiutil create \
  -volname "$APP_NAME $VERSION" \
  -srcfolder "$PACKAGE_DIR" \
  -ov \
  -format UDZO \
  "$DMG_PATH"

echo "Release files:"
echo "$DMG_PATH"
